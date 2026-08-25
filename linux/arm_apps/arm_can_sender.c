/*
 * arm_can_sender.c - CAN 数据采集程序（CH343 USB-CANFD，包模式 MODE2）
 *
 * 功能：打开 CH343 USB 串口 /dev/ttyCH343USB0，通过 AT 指令把设备配置为
 *       500kbps + 包模式(MODE2) + 正常收发(CAN_MODE=0)，持续接收 CAN 总线
 *       上的 29 位扩展帧，解析 17 字节包，按项目协议封装写入 DDR 共享内存
 *       CAN 槽位（0x20000020，device_id=1），供 PC 端经 XDMA 读取。
 *
 * 硬件：泥人科技 USB-CANFD-V1（CH343 USB 转串口 + 内置 CAN 控制器），
 *       插 PS 侧 USB Host 口，驱动 = ch343.ko（节点 /dev/ttyCH343USB0）。
 *       CAN 侧由模块内部收发器输出 CANH/CANL，与 Zynq IO 完全隔离。
 *
 * 包模式 CAN 帧格式（17 字节，含包尾）：
 *   [0]   0xAA       包头(固定)
 *   [1]   0x00/0x01  扩展帧标识(0标准 1扩展)
 *   [2]   0x00/0x01  远程帧标识(0数据 1远程)
 *   [3]   DLC        有效数据长度 0~8
 *   [4..7] 帧ID(4B大端, 扩展帧低29bit有效)
 *   [8..15] 帧数据(8B, 不足补0x00)
 *   [16]  0x7A       包尾(可配置)
 *
 * 参考：泥人科技《CAN转换器系列使用手册V2.7》6.3 包模式 +《AT指令表》
 *
 * 编译(板端): gcc -O2 -o arm_can_sender arm_can_sender.c
 * 运行(板端): echo root | sudo -S /tmp/arm_can_sender [-b 波特率] [--probe|--loopback|--query-version]
 *   默认: normal 模式持续收帧写 DDR；串口波特率默认 9600
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <termios.h>
#include <sys/mman.h>
#include <sys/select.h>
#include <time.h>
#include <sys/syscall.h>

#define DEV "/dev/ttyCH343USB0"

/* ===== DDR 共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    0x4000          /* 16KB：单槽区 + 环形缓冲区（与三路程序统一）*/
#define SLOT_CAN    0x20            /* CAN 槽位偏移 0x20000020 */
#define DEV_CAN     1

/* CAN 环形缓冲区（64 槽×32B=2KB）：记录历史帧，解决单槽覆盖丢帧
 * 位置紧随 RS422 环形区 0x1100+0x800=0x1900，PC 端一次 DMA 读整块回放 */
#define RING_SLOTS  64
#define RING_CAN    0x1900          /* 0x20001900 */

/* ===== 包模式帧常量 ===== */
#define PKT_HDR     0xAA
#define PKT_TAIL    0x7A
#define PKT_LEN     17

/* ===== 协议帧 ID（29 位扩展帧，A825/ARINC825）===== */
#define CAN_ID_TRACKBALL  0x01180118   /* 轨迹球数据（轨迹球→测试系统，4字节）*/
#define CAN_ID_VER_QUERY  0x01180119   /* 软件版本查询（测试系统→轨迹球，4字节）*/
#define CAN_ID_VER_REPLY  0x01180117   /* 软件版本回复（轨迹球→测试系统，3字节）*/
#define CAN_ID_PBIT       0x01180116   /* 上电PBIT（轨迹球→测试系统，6字节，连续5帧）*/
#define CAN_ID_MODEL      0x01180115   /* 设备型号（轨迹球→测试系统，6字节，连续3帧）*/

/* ===== 统一 DDR 转发槽位格式（32 字节，对齐 cache line）===== */
typedef struct {
    volatile uint32_t seq;
    volatile uint32_t device_id;
    volatile uint32_t data_len;
    volatile uint32_t reserved;
    volatile uint8_t  data[8];
    volatile uint32_t tv_sec;
    volatile uint32_t tv_nsec;
} share_slot_t;

/* ARM cacheflush 系统调用号 */
#ifndef __ARM_NR_cacheflush
#define __ARM_NR_cacheflush (0x0f0000 + 2)
#endif

static inline void dma_wb_slot(const volatile void *p)
{
    syscall(__ARM_NR_cacheflush, (long)p,
            (long)((const char *)p + sizeof(share_slot_t)), 0);
}

/* ===== 全局状态 ===== */
static int fd = -1;
static volatile uint8_t *g_ddr_base = NULL;
static uint32_t can_seq = 0;

/* 包模式接收缓冲（串口是字节流，需要自己切分 17 字节帧）*/
static unsigned char g_rx[4096];
static int g_rxlen = 0;

/* ===== 串口波特率映射 ===== */
static speed_t baud_to_speed(int baud)
{
    switch (baud) {
    case 2400:   return B2400;
    case 4800:   return B4800;
    case 9600:   return B9600;
    case 19200:  return B19200;
    case 38400:  return B38400;
    case 57600:  return B57600;
    case 115200: return B115200;
    case 230400: return B230400;
    case 460800: return B460800;
    case 921600: return B921600;
    default:     return B9600;
    }
}

static int open_uart(const char *dev, int baud)
{
    struct termios t;
    speed_t sp = baud_to_speed(baud);

    fd = open(dev, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fd < 0) {
        perror("open");
        return -1;
    }
    if (tcgetattr(fd, &t) < 0) {
        perror("tcgetattr");
        return -1;
    }
    cfmakeraw(&t);
    t.c_cflag |= (CLOCAL | CREAD);
    t.c_cflag &= ~CSIZE;
    t.c_cflag |= CS8;
    t.c_cflag &= ~PARENB;
    t.c_cflag &= ~CSTOPB;
    cfsetispeed(&t, sp);
    cfsetospeed(&t, sp);
    if (tcsetattr(fd, TCSANOW, &t) < 0) {
        perror("tcsetattr");
        return -1;
    }
    tcflush(fd, TCIOFLUSH);
    return 0;
}

/* 累积读取（用于 AT 回复，第一个字节长超时、后续字节短超时）*/
static int read_bytes(unsigned char *buf, int max, int timeout_ms)
{
    int total = 0;
    struct timeval tv;
    fd_set rfds;
    int ret;

    while (total < max) {
        tv.tv_sec = timeout_ms / 1000;
        tv.tv_usec = (timeout_ms % 1000) * 1000;
        FD_ZERO(&rfds);
        FD_SET(fd, &rfds);
        ret = select(fd + 1, &rfds, NULL, NULL, &tv);
        if (ret < 0) return -1;
        if (ret == 0) break;
        ret = read(fd, buf + total, max - total);
        if (ret <= 0) break;
        total += ret;
        timeout_ms = 30; /* 后续字节短超时 */
    }
    return total;
}

/* 单次非阻塞读（主循环轮询用）*/
static int uart_read_some(unsigned char *buf, int max, int timeout_ms)
{
    struct timeval tv;
    fd_set rfds;
    int ret;

    tv.tv_sec = timeout_ms / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;
    FD_ZERO(&rfds);
    FD_SET(fd, &rfds);
    ret = select(fd + 1, &rfds, NULL, NULL, &tv);
    if (ret <= 0) return 0;
    return read(fd, buf, max);
}

static void dump_hex(const unsigned char *b, int n)
{
    int i;
    for (i = 0; i < n; i++)
        printf("%02X ", b[i]);
    printf("\n");
}

/* 发送 AT 指令并读回复。返回 1=收到 OK，0=其它/无回复 */
static int at_cmd(const char *s, int is_plus)
{
    unsigned char buf[128];
    int n;
    ssize_t wr;
    usleep(20000);
    if (is_plus) {
        wr = write(fd, s, strlen(s));
    } else {
        wr = write(fd, s, strlen(s));
        wr = write(fd, "\r\n", 2);
    }
    (void)wr;
    tcdrain(fd);
    usleep(300000);
    n = read_bytes(buf, sizeof(buf), 300);
    printf("  AT >> %-24s -> ", s);
    if (n > 0) {
        int i;
        buf[n] = 0;
        for (i = 0; i < n; i++)
            printf("%c", (buf[i] >= 0x20 && buf[i] < 0x7f) ? buf[i] : '.');
        printf("\n");
        return (strstr((char *)buf, "OK") != NULL) ? 1 : 0;
    }
    printf("(无回复)\n");
    return 0;
}

/* 配置设备：500kbps + 包模式 + 正常收发 */
static void configure_normal(void)
{
    printf("[配置] 进入配置模式，设置 CAN 500kbps + 包模式 + 正常收发\n");
    at_cmd("+++", 1);
    at_cmd("AT+CAN_BAUD=500000", 0);     /* CAN 仲裁域 500kbps */
    at_cmd("AT+CANFD_EN=0", 0);          /* 关 CANFD，走 CAN2.0 */
    at_cmd("AT+CAN_MODE=0", 0);          /* 正常收发模式 */
    at_cmd("AT+MODE=2", 0);              /* 包模式 */
    at_cmd("AT+MODE2=1,122", 0);         /* 使能包尾 0x7A */
    at_cmd("AT+CAN_FILTER0=1,0,4,0,0", 0); /* 过滤器0：允许所有帧(含扩展帧) */
    at_cmd("ATO", 0);                    /* 进入数据模式 */
}

/* 配置设备：回环模式（自检用，不驱动 CAN 总线）*/
static void configure_loopback(void)
{
    printf("[配置] 进入配置模式，设置 500kbps + 包模式 + 回环\n");
    at_cmd("+++", 1);
    at_cmd("AT+CAN_BAUD=500000", 0);
    at_cmd("AT+CANFD_EN=0", 0);
    at_cmd("AT+CAN_MODE=1", 0);          /* 回环模式 */
    at_cmd("AT+MODE=2", 0);
    at_cmd("AT+MODE2=1,122", 0);
    at_cmd("AT+CAN_FILTER0=1,0,4,0,0", 0);
    at_cmd("ATO", 0);
}

/* 构造并发送一帧 17 字节包（扩展帧）*/
static int pkt_send(uint32_t can_id, uint8_t dlc, const uint8_t *data, int is_ext)
{
    unsigned char tx[PKT_LEN];

    if (dlc > 8) dlc = 8;
    memset(tx, 0, sizeof(tx));
    tx[0] = PKT_HDR;
    tx[1] = is_ext ? 0x01 : 0x00;
    tx[2] = 0x00;                        /* 数据帧 */
    tx[3] = dlc;
    tx[4] = (can_id >> 24) & 0xFF;
    tx[5] = (can_id >> 16) & 0xFF;
    tx[6] = (can_id >> 8) & 0xFF;
    tx[7] = can_id & 0xFF;
    memcpy(tx + 8, data, dlc);
    tx[16] = PKT_TAIL;

    if (write(fd, tx, PKT_LEN) != PKT_LEN) {
        perror("write");
        return -1;
    }
    tcdrain(fd);
    return 0;
}

/* 从接收缓冲提取一帧 17 字节包。返回 1=提取到，0=暂无完整帧 */
static int extract_packet(uint32_t *can_id, uint8_t *dlc, uint8_t *data, int *is_ext)
{
    int i;

    while (g_rxlen >= PKT_LEN) {
        for (i = 0; i <= g_rxlen - PKT_LEN; i++) {
            if (g_rx[i] == PKT_HDR && g_rx[i + 16] == PKT_TAIL) {
                *is_ext = g_rx[i + 1] & 0x01;
                *dlc = g_rx[i + 3];
                if (*dlc > 8) *dlc = 8;
                *can_id = ((uint32_t)g_rx[i + 4] << 24) |
                          ((uint32_t)g_rx[i + 5] << 16) |
                          ((uint32_t)g_rx[i + 6] << 8) |
                          ((uint32_t)g_rx[i + 7] << 0);
                memcpy(data, g_rx + i + 8, *dlc);
                memmove(g_rx, g_rx + i + PKT_LEN, g_rxlen - i - PKT_LEN);
                g_rxlen -= i + PKT_LEN;
                return 1;
            }
        }
        /* 未找到完整帧：保留末尾 PKT_LEN-1 字节当作可能的不完整帧头 */
        memmove(g_rx, g_rx + (g_rxlen - (PKT_LEN - 1)), PKT_LEN - 1);
        g_rxlen = PKT_LEN - 1;
        break;
    }
    return 0;
}

/* ===== 填充单个 CAN 槽位（data[0..3]=can_id小端, data[4..7]=数据前4字节）=====
 * data_len=dlc，reserved 低16位存数据第5/6字节（dlc>4 时） */
static void can_slot_fill(volatile share_slot_t *slot, uint32_t can_id,
                          uint8_t dlc, const uint8_t *data,
                          uint32_t sec, uint32_t nsec, uint32_t seq)
{
    int n = dlc > 4 ? 4 : dlc;
    int i;

    slot->device_id = DEV_CAN;
    slot->data_len  = dlc;
    slot->reserved  = (dlc > 4) ? ((uint32_t)data[4] | ((uint32_t)data[5] << 8)) : 0;

    slot->data[0] = (uint8_t)(can_id & 0xFF);
    slot->data[1] = (uint8_t)((can_id >> 8) & 0xFF);
    slot->data[2] = (uint8_t)((can_id >> 16) & 0xFF);
    slot->data[3] = (uint8_t)((can_id >> 24) & 0xFF);
    for (i = 0; i < 4; i++)
        slot->data[4 + i] = (i < n) ? data[i] : 0;

    slot->tv_sec  = sec;
    slot->tv_nsec = nsec;
    __sync_synchronize();
    slot->seq = seq;
}

/* 写 CAN 帧到 DDR（环形槽 + 单槽双写，seq 最后 + 刷 cache）*/
static void write_can_to_ddr(uint32_t can_id, uint8_t dlc, const uint8_t *data)
{
    uint32_t seq = can_seq + 1;
    struct timespec ts;
    volatile share_slot_t *ring;
    volatile share_slot_t *legacy;

    if (!g_ddr_base) return;

    clock_gettime(CLOCK_REALTIME, &ts);

    ring = (volatile share_slot_t *)(g_ddr_base + RING_CAN +
                                     (size_t)(seq % RING_SLOTS) * sizeof(share_slot_t));
    legacy = (volatile share_slot_t *)(g_ddr_base + SLOT_CAN);

    can_slot_fill(ring, can_id, dlc, data,
                  (uint32_t)ts.tv_sec, (uint32_t)ts.tv_nsec, seq);
    dma_wb_slot(ring);

    can_slot_fill(legacy, can_id, dlc, data,
                  (uint32_t)ts.tv_sec, (uint32_t)ts.tv_nsec, seq);
    dma_wb_slot(legacy);

    can_seq = seq;
}

/* ===== 帧 ID 名称辅助 ===== */
static const char *can_id_name(uint32_t id)
{
    switch (id) {
        case CAN_ID_TRACKBALL: return "轨迹球数据";
        case CAN_ID_VER_QUERY: return "版本查询";
        case CAN_ID_VER_REPLY: return "版本回复";
        case CAN_ID_PBIT:      return "上电PBIT";
        case CAN_ID_MODEL:     return "设备型号";
        default:               return "未知";
    }
}

/* ===== 主动下发版本查询（测试系统→轨迹球）=====
 * 帧 ID 0x01180119（扩展帧），数据 AA 01 21 AB（4 字节） */
static int can_send_version_query(void)
{
    uint8_t data[4] = {0xAA, 0x01, 0x21, 0xAB};
    return pkt_send(CAN_ID_VER_QUERY, 4, data, 1);
}

/* ===== 包模式回环自检：发送一帧扩展帧 → 回环自收 → 解析校验 =====
 * 不驱动 CAN 总线，零硬件风险 */
static int self_test_loopback(void)
{
    static const uint32_t test_id = 0x01180118;
    static const uint8_t  test_dlc = 4;
    static const uint8_t  test_data[4] = {0x11, 0x22, 0x33, 0x44};
    unsigned char tmp[128];
    uint32_t rx_id = 0;
    uint8_t  rx_dlc = 0;
    uint8_t  rx_data[8] = {0};
    int is_ext = 0, n, retry;

    printf("\n===== CH343 包模式回环自检 =====\n");
    configure_loopback();
    usleep(300000);
    tcflush(fd, TCIOFLUSH);
    g_rxlen = 0;   /* 清空接收缓冲 */

    printf("[发送] 回环帧 ID=0x%08X DLC=%d\n", test_id, test_dlc);
    if (pkt_send(test_id, test_dlc, test_data, 1) < 0) {
        printf("[FAIL] 发送失败\n");
        return -1;
    }

    for (retry = 0; retry < 100; retry++) {
        n = uart_read_some(tmp, sizeof(tmp), 20);
        if (n > 0) {
            if (g_rxlen + n <= (int)sizeof(g_rx)) {
                memcpy(g_rx + g_rxlen, tmp, n);
                g_rxlen += n;
            }
            if (extract_packet(&rx_id, &rx_dlc, rx_data, &is_ext) == 1)
                break;
        }
    }

    if (retry >= 100) {
        printf("[FAIL] 回环 2s 内未收到完整帧\n");
        return -1;
    }

    printf("[解析] 扩展=%d ID=0x%08X DLC=%d 数据=", is_ext, rx_id, rx_dlc);
    dump_hex(rx_data, rx_dlc);

    if (rx_id != test_id) { printf("[FAIL] ID 不匹配\n"); return -1; }
    if (rx_dlc != test_dlc) { printf("[FAIL] DLC 不匹配\n"); return -1; }
    if (memcmp(rx_data, test_data, test_dlc) != 0) {
        printf("[FAIL] 数据不匹配\n");
        return -1;
    }

    printf("[PASS] 包模式回环自检通过\n");
    if (g_ddr_base) {
        write_can_to_ddr(rx_id, rx_dlc, rx_data);
        printf("[OK] 已写入 DDR CAN 槽位 seq=%u\n", can_seq);
    }
    return 0;
}

/* ===== mmap DDR（clear_ring=1 时清零环形区，dump 时传 0 保留内容）===== */
static int map_ddr(int clear_ring)
{
    int mfd = open("/dev/mem", O_RDWR | O_SYNC);
    void *p;
    if (mfd < 0) { perror("open /dev/mem"); return -1; }
    p = mmap(NULL, DDR_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mfd, DDR_BASE);
    close(mfd);
    if (p == MAP_FAILED) { fprintf(stderr, "[FAIL] mmap DDR\n"); return -1; }
    g_ddr_base = (volatile uint8_t *)p;
    printf("[OK] 映射 DDR @ 0x%08X (size 0x%X)\n", DDR_BASE, DDR_SIZE);

    /* 清零 CAN 环形缓冲区，memset 只写 D-cache，须 clean 到 DDR */
    if (clear_ring) {
        memset((void *)(g_ddr_base + RING_CAN), 0, RING_SLOTS * sizeof(share_slot_t));
        syscall(__ARM_NR_cacheflush, (long)(g_ddr_base + RING_CAN),
                (long)(g_ddr_base + RING_CAN + RING_SLOTS * sizeof(share_slot_t)), 0);
    }
    return 0;
}

/* ===== 读取并打印一个 DDR 槽位内容（自测校验用，通用 hex 显示）===== */
static void dump_slot(const char *name, size_t off)
{
    const volatile share_slot_t *s = (const volatile share_slot_t *)(g_ddr_base + off);
    printf("[%s] seq=%u dev=%u len=%u reserved=0x%04X data=%02X %02X %02X %02X %02X %02X %02X %02X\n",
           name, s->seq, s->device_id, s->data_len, s->reserved,
           s->data[0], s->data[1], s->data[2], s->data[3],
           s->data[4], s->data[5], s->data[6], s->data[7]);
}

int main(int argc, char **argv)
{
    int baud = 9600;
    int mode = 0;           /* 0=normal, 1=probe, 2=loopback, 3=dump */
    int query_version = 0;
    int i;

    setvbuf(stdout, NULL, _IOLBF, 0);

    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--probe") == 0)
            mode = 1;
        else if (strcmp(argv[i], "--loopback") == 0)
            mode = 2;
        else if (strcmp(argv[i], "--dump") == 0)
            mode = 3;
        else if (strcmp(argv[i], "--query-version") == 0)
            query_version = 1;
        else if (strcmp(argv[i], "-b") == 0 && i + 1 < argc)
            baud = atoi(argv[++i]);
    }

    printf("=== CAN 数据采集程序（CH343 USB-CANFD，包模式）===\n");
    printf("节点=%s 波特率=%d 模式=%s\n", DEV, baud,
           mode == 1 ? "probe" : mode == 2 ? "loopback" :
           mode == 3 ? "dump" : "normal");

    /* --dump：读回 DDR 四路槽位（不需串口，自测校验内存布局无冲突）*/
    if (mode == 3) {
        if (map_ddr(0) < 0) return 1;
        printf("=== DDR 四路槽位读回（seq>0 表示该路已收到数据）===\n");
        dump_slot("USB   0x00", 0x00);
        dump_slot("CAN   0x20", 0x20);
        dump_slot("PS2   0x40", 0x40);
        dump_slot("RS422 0x60", 0x60);
        return 0;
    }

    if (open_uart(DEV, baud) < 0)
        return 1;
    printf("[OK] 串口已打开\n");

    /* --probe：查询设备参数，验证串口链路 */
    if (mode == 1) {
        at_cmd("+++", 1);
        at_cmd("AT", 0);
        at_cmd("AT+VER=?", 0);
        at_cmd("AT+CAN_BAUD=?", 0);
        at_cmd("AT+CAN_MODE=?", 0);
        at_cmd("AT+MODE=?", 0);
        at_cmd("ATO", 0);
        close(fd);
        return 0;
    }

    /* --loopback：回环自检（不驱动总线）*/
    if (mode == 2) {
        if (map_ddr(1) < 0) { close(fd); return 1; }
        int r = self_test_loopback();
        printf(r == 0 ? "\n[PASS] 回环自检全部通过\n" : "\n[FAIL] 回环自检失败\n");
        close(fd);
        return r == 0 ? 0 : 1;
    }

    /* normal：配置 + DDR + 收帧 */
    configure_normal();
    usleep(300000);
    tcflush(fd, TCIOFLUSH);
    g_rxlen = 0;

    if (map_ddr(1) < 0) { close(fd); return 1; }

    if (query_version) {
        if (can_send_version_query() == 0)
            printf("[命令] 下发版本查询 0x01180119 = AA 01 21 AB\n");
        else
            printf("[FAIL] 版本查询下发失败\n");
    }

    printf("\n等待 CAN 数据... (Ctrl+C 退出)\n");

    while (1) {
        unsigned char tmp[512];
        int n = uart_read_some(tmp, sizeof(tmp), 50);
        if (n > 0) {
            if (g_rxlen + n <= (int)sizeof(g_rx)) {
                memcpy(g_rx + g_rxlen, tmp, n);
                g_rxlen += n;
            } else {
                g_rxlen = 0;   /* 缓冲溢出保护，丢弃重新同步 */
            }
            while (1) {
                uint32_t can_id = 0;
                uint8_t  dlc = 0;
                uint8_t  data[8] = {0};
                int is_ext = 0;
                if (extract_packet(&can_id, &dlc, data, &is_ext) != 1)
                    break;
                write_can_to_ddr(can_id, dlc, data);
                printf("[CAN #%u] ID=0x%08X %s DLC=%d 数据=",
                       can_seq, can_id, can_id_name(can_id), dlc);
                dump_hex(data, dlc);
            }
        }
    }

    close(fd);
    return 0;
}