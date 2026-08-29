/*
 * arm_all_four.c - USB鼠标 + PS/2鼠标 + RS422 + CAN 四路单进程数据采集程序
 *
 * 功能：单进程并行采集四路数据，分别写入 DDR 共享内存不同槽位：
 *   - USB 鼠标  ：poll()/dev/input/event1，每 input_event 一条记录，
 *                 data={type(2B),code(2B),value(4B)}，写槽位 0x20000000 (device_id=0)
 *   - PS/2 鼠标 ：poll()/dev/input/event4（PS/2转USB模块），按 SYN_REPORT 聚合，
 *                 封装成标准 PS/2 鼠标 3 字节数据包，写槽位 0x20000040 (device_id=2)
 *   - RS422     ：寄存器级轮询 PS UART1(EMIO) FIFO，解析协议帧，写槽位 0x20000060 (device_id=3)
 *   - CAN       ：CH343 USB-CANFD 包模式(MODE2)，解析 17 字节包，写槽位 0x20000020 (device_id=1)
 *
 * 并发模型：单线程 —— poll 同时监听两个鼠标 fd + CAN 串口 fd（5ms 短超时）；
 *   超时即轮询 UART1 RX FIFO。四路槽位地址独立、seq 各自递增，无需加锁。
 *
 * 硬件连接：
 *   USB  ：原生USB鼠标插开发板 USB Host 口，/dev/input/event1
 *   PS/2 ：PS/2鼠标经转USB模块插另一个 USB Host 口，/dev/input/event4
 *   RS422：pin26(E5)=UART1_TX, pin28(B1)=UART1_RX, pin29=3.3V, pin30=GND
 *   CAN  ：泥人科技 USB-CANFD-V1（CH343）插 PS 侧 USB Host 口，/dev/ttyCH343USB0
 *          驱动 ch343.ko（节点 /dev/ttyCH343USB0），CAN 侧由模块收发器输出，与 Zynq 隔离
 *
 * 标准PS/2鼠标数据包（3字节，data_len=3）：
 *   Byte0: [Y溢出][X溢出][Y符号][X符号][1][中键][右键][左键]
 *   Byte1: X位移（9位补码低8位，右为正）
 *   Byte2: Y位移（9位补码低8位，PS/2约定上为正，与evdev相反故取反）
 *
 * 包模式 CAN 帧格式（17 字节，含包尾）：
 *   [0]0xAA [1]扩展帧标识 [2]远程帧标识 [3]DLC [4..7]帧ID(4B大端)
 *   [8..15]帧数据(8B) [16]0x7A
 *
 * 编译：gcc -O2 -o arm_all_four arm_all_four.c
 * 运行：sudo systemctl stop serial-getty@ttyPS0.service   # RS422 占用 UART1，需先停 console
 *       sudo ./arm_all_four [stream|remote] [-b 波特率] [--query-version] [周期us] [usb节点] [ps2节点]
 *       默认 usb=/dev/input/event1  ps2=/dev/input/event4  can=/dev/ttyCH343USB0
 *       任一设备未插入/打开失败不报错退出，对应路自动禁用，其余路照常工作
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <linux/input.h>
#include <poll.h>
#include <stdint.h>
#include <time.h>
#include <sys/syscall.h>
#include <termios.h>
#include <sys/select.h>

/* ===== DDR共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    0x4000   /* 16KB：单槽区 + 四个环形缓冲区 */

/* 四路接口槽位地址（每路32字节，对齐cache line，互不竞争） */
#define SLOT_USB     0x00   /* 0x20000000 USB */
#define SLOT_CAN     0x20   /* 0x20000020 CAN */
#define SLOT_PS2     0x40   /* 0x20000040 PS2 */
#define SLOT_RS422   0x60   /* 0x20000060 RS422 */

/* 环形缓冲区（每路64槽×32B=2KB）：记录历史帧，解决单槽覆盖丢帧
 * PC端一次DMA读整块2KB，按槽内seq升序回放 */
#define RING_SLOTS   64
#define RING_USB     0x0100   /* 0x20000100 USB环形区 */
#define RING_PS2     0x0900   /* 0x20000900 PS2环形区 */
#define RING_RS422   0x1100   /* 0x20001100 RS422环形区 */
#define RING_CAN     0x1900   /* 0x20001900 CAN环形区 */

/* 接口类型标识 */
#define DEV_USB    0
#define DEV_CAN    1
#define DEV_PS2    2
#define DEV_RS422  3

/* ===== CAN 设备与包模式常量 ===== */
#define CAN_DEV     "/dev/ttyCH343USB0"
#define PKT_HDR     0xAA
#define PKT_TAIL    0x7A
#define PKT_LEN     17

/* 协议帧 ID（29 位扩展帧，A825/ARINC825）*/
#define CAN_ID_TRACKBALL  0x01180118
#define CAN_ID_VER_QUERY  0x01180119
#define CAN_ID_VER_REPLY  0x01180117
#define CAN_ID_PBIT       0x01180116
#define CAN_ID_MODEL      0x01180115

/* ===== SLCR / UART1 寄存器级访问 ===== */
#define SLCR_BASE   0xF8000000UL
#define UART1_BASE  0xE0001000UL
#define MAP_SIZE    0x1000UL

/* UART1 (cdns_uart) 寄存器偏移 */
#define CR   0x00
#define MR   0x04
#define IER  0x08
#define IDR  0x0C
#define IMR  0x10
#define ISR  0x14
#define SR   0x2C
#define FIFO 0x30

#define SR_RXEMPTY  0x02
#define SR_TXEMPTY  0x08

/* ===== RS422协议常量 ===== */
#define RS422_FRAME_HEAD       0x55
#define RS422_CMD_DISPLACEMENT 0xD1
#define RS422_CMD_STATUS       0xD2
#define RS422_CMD_TEMP         0xD3
#define RS422_CMD_VOLTAGE      0xD4
#define RS422_CMD_VERSION      0xD5
#define RS422_CMD_PBIT         0xD6
#define RS422_CMD_DEVNAME      0xD7

/* RS422 下行命令（采集卡 -> 轨迹球，裸字节）*/
#define CMD_Q_STATUS          0xE9
#define CMD_Q_TEMP            0xE4
#define CMD_Q_VOLTAGE         0xE3
#define CMD_Q_VERSION         0xE2
#define CMD_MODE_STREAM       0xEA
#define CMD_MODE_REMOTE       0xF0
#define CMD_CFG_CPI           0xE8
#define CMD_CFG_SAMPLERATE    0xF3
#define CMD_RM_QUERY          0xEB

/* 统一DDR转发槽位格式（32字节，对齐cache line） */
typedef struct {
    volatile uint32_t seq;
    volatile uint32_t device_id;
    volatile uint32_t data_len;
    volatile uint32_t reserved;
    volatile uint8_t  data[8];
    volatile uint32_t tv_sec;
    volatile uint32_t tv_nsec;
} share_slot_t;  /* 共32字节 */

/* ARM cacheflush 系统调用号 */
#ifndef __ARM_NR_cacheflush
#define __ARM_NR_cacheflush (0x0f0000 + 2)
#endif

static inline void dma_wb_slot(const volatile void *p)
{
    syscall(__ARM_NR_cacheflush, (long)p,
            (long)((const char *)p + sizeof(share_slot_t)), 0);
}

/* USB data字段封装（8字节）：type(2B)+code(2B)+value(4B) */
typedef struct {
    uint16_t type;
    uint16_t code;
    int32_t  value;
} __attribute__((packed)) usb_event_t;

/* PS/2帧聚合器 */
typedef struct {
    int      dx, dy, dz;
    uint8_t  btn;
    int      dirty;
} ps2_agg_t;

/* ===== CAN 全局状态 ===== */
static int can_fd = -1;
static uint32_t can_seq = 0;
static unsigned char g_rx[4096];
static int g_rxlen = 0;

/* ===== 寄存器访问辅助 ===== */
static volatile uint32_t *map_phys(uint32_t base)
{
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open /dev/mem"); return NULL; }
    void *p = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
                   fd, base & ~(MAP_SIZE - 1));
    if (p == MAP_FAILED) { perror("mmap"); close(fd); return NULL; }
    close(fd);
    return (volatile uint32_t *)((char *)p + (base & (MAP_SIZE - 1)));
}

static inline uint32_t rd(volatile uint32_t *r, uint32_t off)
{
    return r[off / 4];
}

static inline void wr(volatile uint32_t *r, uint32_t off, uint32_t v)
{
    r[off / 4] = v;
}

/* ===== UART1 TX（下行命令下发：采集卡 -> 轨迹球）===== */
static void uart_send_bytes(volatile uint32_t *uart, const uint8_t *buf, int len)
{
    int i, wait;
    for (i = 0; i < len; i++)
        wr(uart, FIFO, buf[i]);
    wait = 0;
    while (!(rd(uart, SR) & SR_TXEMPTY)) {
        if (++wait > 1000000) { printf("[警告] TX 等待超时\n"); break; }
    }
}

static void uart_send_cmd3(volatile uint32_t *uart, uint8_t c)
{
    uint8_t b[3] = { c, c, c };
    uart_send_bytes(uart, b, 3);
}

static void uart_send_cmd2(volatile uint32_t *uart, uint8_t c1, uint8_t c2)
{
    uint8_t b[2] = { c1, c2 };
    uart_send_bytes(uart, b, 2);
}

/* ===== PS/2 标准数据包构造 ===== */
static void ps2_build_packet(const ps2_agg_t *a, uint8_t pkt[4])
{
    int x = a->dx;
    int y = -a->dy;
    int z = a->dz;
    uint8_t b0 = 0x08;

    b0 |= (uint8_t)(a->btn & 0x07);

    if (x > 255)  { x = 255;  b0 |= 0x40; }
    if (x < -256) { x = -256; b0 |= 0x40; }
    if (x < 0)      b0 |= 0x10;
    if (y > 255)  { y = 255;  b0 |= 0x80; }
    if (y < -256) { y = -256; b0 |= 0x80; }
    if (y < 0)      b0 |= 0x20;

    /* 滚轮限制在 -8~+7 */
    if (z > 7)  z = 7;
    if (z < -8) z = -8;

    pkt[0] = b0;
    pkt[1] = (uint8_t)(x & 0xFF);
    pkt[2] = (uint8_t)(y & 0xFF);
    pkt[3] = (uint8_t)(z & 0xFF);
}

/* ===== USB 事件名称辅助 ===== */
static const char *ev_type_name(uint16_t type)
{
    switch (type) {
        case EV_KEY:  return "KEY";
        case EV_REL:  return "REL";
        default:      return "???";
    }
}

static const char *ev_code_name(uint16_t type, uint16_t code)
{
    if (type == EV_KEY) {
        switch (code) {
            case BTN_LEFT:   return "左键";
            case BTN_RIGHT:  return "右键";
            case BTN_MIDDLE: return "中键";
            default:         return "其他键";
        }
    }
    if (type == EV_REL) {
        switch (code) {
            case REL_X:      return "X轴";
            case REL_Y:      return "Y轴";
            case REL_WHEEL:  return "滚轮";
            default:         return "其他";
        }
    }
    return "-";
}

/* ===== RS422 帧解析 ===== */
static int get_data_len(uint8_t cmd)
{
    switch (cmd) {
        case RS422_CMD_DISPLACEMENT: return 3;
        case RS422_CMD_STATUS:       return 3;
        case RS422_CMD_TEMP:         return 1;
        case RS422_CMD_VOLTAGE:      return 2;
        case RS422_CMD_VERSION:      return 3;
        case RS422_CMD_PBIT:         return 6;
        case RS422_CMD_DEVNAME:      return 16;
        default:                     return -1;
    }
}

static const char *rs422_cmd_name(uint8_t cmd)
{
    switch (cmd) {
        case RS422_CMD_DISPLACEMENT: return "位移";
        case RS422_CMD_STATUS:       return "状态";
        case RS422_CMD_TEMP:         return "温度";
        case RS422_CMD_VOLTAGE:      return "电压";
        case RS422_CMD_VERSION:      return "版本";
        case RS422_CMD_PBIT:         return "上电PBIT";
        case RS422_CMD_DEVNAME:      return "设备型号";
        default:                     return "未知";
    }
}

static void print_rs422_displacement(const uint8_t *bf)
{
    int8_t x = (int8_t)bf[1];
    int8_t y = (int8_t)bf[2];
    printf("  位移: X=%d Y=%d 左键=%d 右键=%d",
           x, y, bf[0] & 0x01, (bf[0] >> 1) & 0x01);
}

static void print_rs422_status(const uint8_t *bf)
{
    printf("  状态: 模式=%s 分辨率=%d 采样率=%d",
           (bf[0] >> 6) & 0x01 ? "Remote" : "Stream", bf[1], bf[2]);
}

static void print_rs422_temp(const uint8_t *bf)
{
    printf("  温度: %d℃", (int8_t)bf[0]);
}

static void print_rs422_voltage(const uint8_t *bf)
{
    uint16_t vol = bf[0] | (bf[1] << 8);
    printf("  电压: %d.%dV", vol / 100, (vol % 100) / 10);
}

static void print_rs422_version(const uint8_t *bf)
{
    printf("  版本: %d.%02d.%02d", bf[0], bf[1], bf[2]);
}

static void print_rs422_pbit(const uint8_t *bf)
{
    int i;
    printf("  PBIT:");
    for (i = 0; i < 6; i++)
        printf(" %02X", bf[i]);
}

static void print_rs422_devname(const uint8_t *bf)
{
    char name[17];
    memcpy(name, bf, 16);
    name[16] = '\0';
    printf("  型号: %s", name);
}

typedef struct {
    int state;
    uint8_t cmd;
    int data_len;
    int data_idx;
    uint8_t buf[16];
    uint8_t checksum;
} rs422_parser_t;

static void parser_reset(rs422_parser_t *p)
{
    memset(p, 0, sizeof(*p));
}

static int parser_feed(rs422_parser_t *p, uint8_t b)
{
    switch (p->state) {
    case 0:
        if (b == RS422_FRAME_HEAD) {
            p->state = 1;
            p->checksum = b;
        }
        return 0;
    case 1:
        p->cmd = b;
        p->data_len = get_data_len(b);
        if (p->data_len < 0) { p->state = 0; return 0; }
        p->checksum += b;
        p->data_idx = 0;
        p->state = 2;
        return 0;
    case 2:
        p->buf[p->data_idx++] = b;
        p->checksum += b;
        if (p->data_idx >= p->data_len)
            p->state = 3;
        return 0;
    case 3:
        p->state = 0;
        return ((p->checksum & 0xFF) == b) ? 1 : 0;
    default:
        p->state = 0;
        return 0;
    }
}

/* ===== 填充单个槽位（seq 最后写 + 内存屏障）===== */
static void slot_fill(volatile share_slot_t *slot, uint32_t dev_id,
                      const uint8_t *payload, uint32_t len,
                      uint32_t sec, uint32_t nsec, uint32_t seq)
{
    int i;

    slot->device_id = dev_id;
    slot->data_len  = len;
    slot->reserved  = 0;
    for (i = 0; i < (int)len && i < 8; i++)
        slot->data[i] = payload[i];
    for (; i < 8; i++)
        slot->data[i] = 0;
    slot->tv_sec  = sec;
    slot->tv_nsec = nsec;
    __sync_synchronize();
    slot->seq = seq;
}

/* 写槽位公共路径：写环形槽 + 单槽（最新值），seq 最后 + 刷 cache */
static void slot_publish(volatile uint8_t *ddr, uint32_t legacy_off,
                         uint32_t ring_off, uint32_t dev_id,
                         const uint8_t *payload, uint32_t len,
                         uint32_t sec, uint32_t nsec, uint32_t *pseq)
{
    uint32_t seq = *pseq + 1;
    volatile share_slot_t *ring =
        (volatile share_slot_t *)(ddr + ring_off +
                                  (seq % RING_SLOTS) * sizeof(share_slot_t));
    volatile share_slot_t *legacy =
        (volatile share_slot_t *)(ddr + legacy_off);

    slot_fill(ring, dev_id, payload, len, sec, nsec, seq);
    dma_wb_slot(ring);

    slot_fill(legacy, dev_id, payload, len, sec, nsec, seq);
    dma_wb_slot(legacy);

    *pseq = seq;
}

/* 设备型号(16字节)分2片发布，reserved 编码片序+总长 */
static void slot_publish_devname(volatile uint8_t *ddr, uint32_t legacy_off,
                                 uint32_t ring_off, const uint8_t *name16,
                                 uint32_t sec, uint32_t nsec, uint32_t *pseq)
{
    uint32_t seq0 = *pseq + 1;
    uint32_t seq1 = seq0 + 1;
    volatile share_slot_t *r0 =
        (volatile share_slot_t *)(ddr + ring_off +
                                  (seq0 % RING_SLOTS) * sizeof(share_slot_t));
    volatile share_slot_t *r1 =
        (volatile share_slot_t *)(ddr + ring_off +
                                  (seq1 % RING_SLOTS) * sizeof(share_slot_t));
    volatile share_slot_t *legacy =
        (volatile share_slot_t *)(ddr + legacy_off);

    slot_fill(r0, DEV_RS422, name16, 8, sec, nsec, seq0);
    r0->reserved = (0u << 16) | 16u;
    dma_wb_slot(r0);

    slot_fill(r1, DEV_RS422, name16 + 8, 8, sec, nsec, seq1);
    r1->reserved = (1u << 16) | 16u;
    dma_wb_slot(r1);

    slot_fill(legacy, DEV_RS422, name16, 8, sec, nsec, seq0);
    legacy->reserved = (0u << 16) | 16u;
    dma_wb_slot(legacy);

    *pseq = seq1;
}

/* ===== CAN 串口：波特率映射 / 打开 / AT指令 ===== */
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

    can_fd = open(dev, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (can_fd < 0) {
        perror("open CAN");
        return -1;
    }
    if (tcgetattr(can_fd, &t) < 0) { perror("tcgetattr"); return -1; }
    cfmakeraw(&t);
    t.c_cflag |= (CLOCAL | CREAD);
    t.c_cflag &= ~CSIZE;
    t.c_cflag |= CS8;
    t.c_cflag &= ~PARENB;
    t.c_cflag &= ~CSTOPB;
    cfsetispeed(&t, sp);
    cfsetospeed(&t, sp);
    if (tcsetattr(can_fd, TCSANOW, &t) < 0) { perror("tcsetattr"); return -1; }
    tcflush(can_fd, TCIOFLUSH);
    return 0;
}

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
        FD_SET(can_fd, &rfds);
        ret = select(can_fd + 1, &rfds, NULL, NULL, &tv);
        if (ret < 0) return -1;
        if (ret == 0) break;
        ret = read(can_fd, buf + total, max - total);
        if (ret <= 0) break;
        total += ret;
        timeout_ms = 30;
    }
    return total;
}

static int at_cmd(const char *s, int is_plus)
{
    unsigned char buf[128];
    int n;
    ssize_t wr;
    usleep(20000);
    if (is_plus) {
        wr = write(can_fd, s, strlen(s));
    } else {
        wr = write(can_fd, s, strlen(s));
        wr = write(can_fd, "\r\n", 2);
    }
    (void)wr;
    tcdrain(can_fd);
    usleep(300000);
    n = read_bytes(buf, sizeof(buf), 300);
    printf("  AT >> %-24s -> ", s);
    if (n > 0) {
        int i;
        for (i = 0; i < n; i++)
            printf("%c", (buf[i] >= 0x20 && buf[i] < 0x7f) ? buf[i] : '.');
        printf("\n");
        return (strstr((char *)buf, "OK") != NULL) ? 1 : 0;
    }
    printf("(无回复)\n");
    return 0;
}

static void configure_normal(void)
{
    printf("[CAN配置] 500kbps + 包模式 + 正常收发\n");
    at_cmd("+++", 1);
    at_cmd("AT+CAN_BAUD=500000", 0);
    at_cmd("AT+CANFD_EN=0", 0);
    at_cmd("AT+CAN_MODE=0", 0);
    at_cmd("AT+MODE=2", 0);
    at_cmd("AT+MODE2=1,122", 0);
    at_cmd("AT+CAN_FILTER0=1,0,4,0,0", 0);
    at_cmd("ATO", 0);
}

/* ===== CAN 包构造 / 提取 ===== */
static int pkt_send(uint32_t can_id, uint8_t dlc, const uint8_t *data, int is_ext)
{
    unsigned char tx[PKT_LEN];

    if (dlc > 8) dlc = 8;
    memset(tx, 0, sizeof(tx));
    tx[0] = PKT_HDR;
    tx[1] = is_ext ? 0x01 : 0x00;
    tx[2] = 0x00;
    tx[3] = dlc;
    tx[4] = (can_id >> 24) & 0xFF;
    tx[5] = (can_id >> 16) & 0xFF;
    tx[6] = (can_id >> 8) & 0xFF;
    tx[7] = can_id & 0xFF;
    memcpy(tx + 8, data, dlc);
    tx[16] = PKT_TAIL;

    if (write(can_fd, tx, PKT_LEN) != PKT_LEN) {
        perror("write CAN");
        return -1;
    }
    tcdrain(can_fd);
    return 0;
}

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
        memmove(g_rx, g_rx + (g_rxlen - (PKT_LEN - 1)), PKT_LEN - 1);
        g_rxlen = PKT_LEN - 1;
        break;
    }
    return 0;
}

/* ===== 填充 CAN 槽位（data[0..3]=can_id小端, data[4..7]=帧数据前4字节）===== */
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

static void write_can_to_ddr(volatile uint8_t *ddr, uint32_t can_id,
                             uint8_t dlc, const uint8_t *data)
{
    uint32_t seq = can_seq + 1;
    struct timespec ts;
    volatile share_slot_t *ring;
    volatile share_slot_t *legacy;

    clock_gettime(CLOCK_REALTIME, &ts);

    ring = (volatile share_slot_t *)(ddr + RING_CAN +
                                     (size_t)(seq % RING_SLOTS) * sizeof(share_slot_t));
    legacy = (volatile share_slot_t *)(ddr + SLOT_CAN);

    can_slot_fill(ring, can_id, dlc, data, (uint32_t)ts.tv_sec, (uint32_t)ts.tv_nsec, seq);
    dma_wb_slot(ring);

    can_slot_fill(legacy, can_id, dlc, data, (uint32_t)ts.tv_sec, (uint32_t)ts.tv_nsec, seq);
    dma_wb_slot(legacy);

    can_seq = seq;
}

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

static int can_send_version_query(void)
{
    uint8_t data[4] = {0xAA, 0x01, 0x21, 0xAB};
    return pkt_send(CAN_ID_VER_QUERY, 4, data, 1);
}

/* ===== 主程序 ===== */
int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IONBF, 0);

    int fd_usb = -1, fd_ps2 = -1, fd_mem;
    volatile uint8_t *ddr_base;
    struct input_event ev;
    struct pollfd pfds[3];
    int nfd = 0;
    uint32_t usb_seq = 0, ps2_seq = 0, rs422_seq = 0;
    const char *usb_dev = "/dev/input/event1";
    const char *ps2_dev = "/dev/input/event4";
    int baud = 9600;
    int query_version = 0;
    int probe_mode = 0;
    int remote = 0;
    int period_us = 4000;
    int query = -1;
    int cpi = -1;
    int rate = -1;

    /* 参数解析 */
    {
        int i, dev_idx = 0;
        for (i = 1; i < argc; i++) {
            const char *a = argv[i];
            if (strcmp(a, "remote") == 0) { remote = 1; }
            else if (strcmp(a, "stream") == 0) { remote = 0; }
            else if (strcmp(a, "-b") == 0 && i + 1 < argc) { baud = atoi(argv[++i]); }
            else if (strcmp(a, "--query-version") == 0) { query_version = 1; }
            else if (strcmp(a, "--probe") == 0) { probe_mode = 1; }
            else if (strcmp(a, "--query") == 0 && i + 1 < argc) {
                const char *q = argv[++i];
                if      (strcmp(q, "status")  == 0) query = 0;
                else if (strcmp(q, "temp")    == 0) query = 1;
                else if (strcmp(q, "voltage") == 0) query = 2;
                else if (strcmp(q, "version") == 0) query = 3;
            } else if (strcmp(a, "--cpi") == 0 && i + 1 < argc) {
                cpi = atoi(argv[++i]);
                if (cpi < 0) cpi = 0;
                if (cpi > 10) cpi = 10;
            } else if (strcmp(a, "--rate") == 0 && i + 1 < argc) {
                rate = atoi(argv[++i]);
                if (rate < 0) rate = 0;
                if (rate > 40) rate = 40;
            } else if (a[0] >= '0' && a[0] <= '9') {
                period_us = atoi(a);
            } else if (strncmp(a, "/dev/input/event", 16) == 0) {
                if (dev_idx == 0) { usb_dev = a; dev_idx = 1; }
                else              { ps2_dev = a; }
            }
        }
    }
    if (period_us < 2000) period_us = 2000;
    if (period_us > 5000) period_us = 5000;

    /* --probe：仅打开 CAN 串口做 AT 查询验证链路，不切 MIO、不 map DDR、不长驻 */
    if (probe_mode) {
        if (open_uart(CAN_DEV, baud) < 0) {
            printf("[FAIL] CAN 串口 %s 打开失败\n", CAN_DEV);
            return 1;
        }
        printf("[OK] 串口已打开 %s\n", CAN_DEV);
        at_cmd("+++", 1);
        at_cmd("AT", 0);
        at_cmd("AT+VER=?", 0);
        at_cmd("AT+CAN_BAUD=?", 0);
        at_cmd("AT+CAN_MODE=?", 0);
        at_cmd("AT+MODE=?", 0);
        at_cmd("ATO", 0);
        close(can_fd);
        return 0;
    }

    printf("=== USB + PS/2 + RS422 + CAN 四路单进程采集程序 ===\n");
    printf("RS422模式: %s%s%s | CAN: %s @%d%s\n",
           remote ? "Remote" : "Stream",
           query >= 0 ? " +查询" : "",
           cpi >= 0 || rate >= 0 ? " +配置" : "",
           CAN_DEV, baud, query_version ? " +版本查询" : "");

    /* 1. 切 MIO49/48 -> GPIO，释放 UART1 EMIO RX */
    volatile uint32_t *slcr = map_phys(SLCR_BASE);
    if (!slcr) return 1;
    wr(slcr, 0x008, 0xDF0D);
    __sync_synchronize();
    wr(slcr, 0x7C0, 0x1200);
    wr(slcr, 0x7C4, 0x1200);
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);
    __sync_synchronize();

    /* 2. mmap UART1，禁中断，NORMAL 模式 */
    volatile uint32_t *uart = map_phys(UART1_BASE);
    if (!uart) return 1;
    wr(uart, IDR, 0xFFFFFFFF);
    wr(uart, CR, 0x17);
    wr(uart, MR, 0x20);

    /* 2.5 RS422 下行命令 */
    uart_send_cmd3(uart, remote ? CMD_MODE_REMOTE : CMD_MODE_STREAM);
    usleep(10000);
    if (query >= 0) {
        static const uint8_t qcmd[4] = { CMD_Q_STATUS, CMD_Q_TEMP, CMD_Q_VOLTAGE, CMD_Q_VERSION };
        static const char *qname[4]  = { "状态", "温度", "电压", "版本" };
        uart_send_cmd3(uart, qcmd[query]);
        printf("[命令] 下发%s查询\n", qname[query]);
        usleep(10000);
    }
    if (cpi >= 0) {
        uart_send_cmd3(uart, CMD_CFG_CPI);
        usleep(7000);
        uart_send_bytes(uart, (const uint8_t *)&cpi, 1);
        usleep(10000);
    }
    if (rate >= 0) {
        uart_send_cmd3(uart, CMD_CFG_SAMPLERATE);
        usleep(7000);
        uart_send_bytes(uart, (const uint8_t *)&rate, 1);
        usleep(10000);
    }

    struct timespec last_query;
    clock_gettime(CLOCK_MONOTONIC, &last_query);

    /* 3. mmap DDR 共享内存 */
    fd_mem = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd_mem < 0) { perror("open /dev/mem (DDR)"); return 1; }
    ddr_base = (volatile uint8_t *)mmap(NULL, DDR_SIZE,
             PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DDR_BASE);
    if (ddr_base == MAP_FAILED) { perror("mmap DDR"); close(fd_mem); return 1; }
    /* 清零四个环形缓冲区 + clean 到 DDR */
    memset((void *)(ddr_base + RING_USB),   0, RING_SLOTS * sizeof(share_slot_t));
    memset((void *)(ddr_base + RING_PS2),   0, RING_SLOTS * sizeof(share_slot_t));
    memset((void *)(ddr_base + RING_RS422), 0, RING_SLOTS * sizeof(share_slot_t));
    memset((void *)(ddr_base + RING_CAN),   0, RING_SLOTS * sizeof(share_slot_t));
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + RING_USB),
            (long)(ddr_base + RING_USB + RING_SLOTS * sizeof(share_slot_t)), 0);
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + RING_PS2),
            (long)(ddr_base + RING_PS2 + RING_SLOTS * sizeof(share_slot_t)), 0);
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + RING_RS422),
            (long)(ddr_base + RING_RS422 + RING_SLOTS * sizeof(share_slot_t)), 0);
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + RING_CAN),
            (long)(ddr_base + RING_CAN + RING_SLOTS * sizeof(share_slot_t)), 0);
    /* 清零四个单槽区（避免 seq 上电残留非 0 导致 PC 端误判"有数据"）*/
    memset((void *)(ddr_base + SLOT_USB),   0, sizeof(share_slot_t));
    memset((void *)(ddr_base + SLOT_CAN),   0, sizeof(share_slot_t));
    memset((void *)(ddr_base + SLOT_PS2),   0, sizeof(share_slot_t));
    memset((void *)(ddr_base + SLOT_RS422), 0, sizeof(share_slot_t));
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + SLOT_USB),
            (long)(ddr_base + SLOT_RS422 + sizeof(share_slot_t)), 0);

    /* 4. 打开并配置 CAN（失败仅禁用 CAN 路）*/
    if (open_uart(CAN_DEV, baud) < 0) {
        printf("[警告] CAN 串口 %s 打开失败，CAN 路禁用\n", CAN_DEV);
        can_fd = -1;
    } else {
        configure_normal();
        usleep(300000);
        tcflush(can_fd, TCIOFLUSH);
        g_rxlen = 0;
        pfds[nfd].fd = can_fd;
        pfds[nfd].events = POLLIN;
        nfd++;
    }

    /* 5. 打开两只鼠标（任一失败不退出）*/
    fd_usb = open(usb_dev, O_RDONLY);
    if (fd_usb < 0) {
        printf("[警告] USB鼠标 %s 打开失败，USB路禁用\n", usb_dev);
    } else {
        pfds[nfd].fd = fd_usb;
        pfds[nfd].events = POLLIN;
        nfd++;
    }

    fd_ps2 = open(ps2_dev, O_RDONLY);
    if (fd_ps2 < 0) {
        printf("[警告] PS/2鼠标 %s 打开失败，PS/2路禁用\n", ps2_dev);
    } else {
        pfds[nfd].fd = fd_ps2;
        pfds[nfd].events = POLLIN;
        nfd++;
    }

    if (nfd == 0 && !uart) {
        printf("[错误] 四路设备(CAN/USB/PS2/RS422)均失败，退出\n");
        close(fd_mem);
        return 1;
    }

    printf("USB 槽位: 0x%08X 环形区: 0x%08X (device_id=%d)  设备: %s\n",
           DDR_BASE + SLOT_USB, DDR_BASE + RING_USB, DEV_USB,
           fd_usb >= 0 ? usb_dev : "禁用");
    printf("PS/2槽位: 0x%08X 环形区: 0x%08X (device_id=%d)  设备: %s\n",
           DDR_BASE + SLOT_PS2, DDR_BASE + RING_PS2, DEV_PS2,
           fd_ps2 >= 0 ? ps2_dev : "禁用");
    printf("RS422槽位: 0x%08X 环形区: 0x%08X (device_id=%d)\n",
           DDR_BASE + SLOT_RS422, DDR_BASE + RING_RS422, DEV_RS422);
    printf("CAN 槽位: 0x%08X 环形区: 0x%08X (device_id=%d)  设备: %s\n",
           DDR_BASE + SLOT_CAN, DDR_BASE + RING_CAN, DEV_CAN,
           can_fd >= 0 ? CAN_DEV : "禁用");

    if (query_version && can_fd >= 0) {
        if (can_send_version_query() == 0)
            printf("[命令] 下发版本查询 0x01180119 = AA 01 21 AB\n");
    }

    printf("四路并行收集中... (Ctrl+C 退出)\n\n");

    rs422_parser_t parser;
    parser_reset(&parser);

    ps2_agg_t agg;
    memset(&agg, 0, sizeof(agg));

    /* 6. 主循环：poll 三路 fd(usb/ps2/can, 5ms超时) + 超时轮询 UART1 FIFO */
    while (1) {
        int ret = poll(pfds, nfd, 5);
        int i;

        for (i = 0; i < nfd && ret > 0; i++) {
            if (!(pfds[i].revents & POLLIN))
                continue;

            /* 6.0 CAN：读字节流，累积后切分 17 字节包 */
            if (pfds[i].fd == can_fd) {
                unsigned char tmp[512];
                ssize_t n = read(can_fd, tmp, sizeof(tmp));
                if (n > 0) {
                    if (g_rxlen + n <= (int)sizeof(g_rx)) {
                        memcpy(g_rx + g_rxlen, tmp, n);
                        g_rxlen += n;
                    } else {
                        g_rxlen = 0;   /* 溢出保护，丢弃重同步 */
                    }
                    while (1) {
                        uint32_t can_id = 0;
                        uint8_t  dlc = 0;
                        uint8_t  data[8] = {0};
                        int is_ext = 0;
                        if (extract_packet(&can_id, &dlc, data, &is_ext) != 1)
                            break;
                        write_can_to_ddr(ddr_base, can_id, dlc, data);
                        printf("[CAN #%u] ID=0x%08X %s DLC=%d 数据=",
                               can_seq, can_id, can_id_name(can_id), dlc);
                        {
                            int k;
                            for (k = 0; k < dlc; k++)
                                printf("%02X ", data[k]);
                            printf("\n");
                        }
                    }
                }
                continue;
            }

            /* 6.1/6.2 USB & PS/2：读定长 input_event */
            ssize_t n = read(pfds[i].fd, &ev, sizeof(ev));
            if (n != sizeof(ev))
                continue;

            if (pfds[i].fd == fd_usb) {
                if (ev.type != EV_SYN && ev.type != EV_MSC) {
                    usb_event_t usb_ev;
                    usb_ev.type  = ev.type;
                    usb_ev.code  = ev.code;
                    usb_ev.value = ev.value;

                    slot_publish(ddr_base, SLOT_USB, RING_USB, DEV_USB,
                                 (const uint8_t *)&usb_ev, sizeof(usb_ev),
                                 (uint32_t)ev.time.tv_sec,
                                 (uint32_t)ev.time.tv_usec * 1000,
                                 &usb_seq);

                    printf("[USB  #%u] %s %s = %d\n",
                           usb_seq, ev_type_name(ev.type),
                           ev_code_name(ev.type, ev.code), ev.value);
                }
            } else if (pfds[i].fd == fd_ps2) {
                if (ev.type != EV_SYN && ev.type != EV_MSC) {
                    usb_event_t ps2_ev;
                    ps2_ev.type  = ev.type;
                    ps2_ev.code  = ev.code;
                    ps2_ev.value = ev.value;

                    slot_publish(ddr_base, SLOT_PS2, RING_PS2, DEV_PS2,
                                 (const uint8_t *)&ps2_ev, sizeof(ps2_ev),
                                 (uint32_t)ev.time.tv_sec,
                                 (uint32_t)ev.time.tv_usec * 1000,
                                 &ps2_seq);

                    printf("[PS/2 #%u] %s %s = %d\n",
                           ps2_seq, ev_type_name(ev.type),
                           ev_code_name(ev.type, ev.code), ev.value);
                }
            }
        }

        /* 6.3 RS422：轮询 UART1 RX FIFO，逐字节喂状态机 */
        int cnt = 0;
        while (!(rd(uart, SR) & SR_RXEMPTY) && cnt < 256) {
            uint8_t b = (uint8_t)(rd(uart, FIFO) & 0xFF);
            cnt++;

            if (parser_feed(&parser, b)) {
                struct timespec ts;
                int k;
                clock_gettime(CLOCK_REALTIME, &ts);

                if (parser.cmd == RS422_CMD_DEVNAME) {
                    slot_publish_devname(ddr_base, SLOT_RS422, RING_RS422,
                                         parser.buf,
                                         (uint32_t)ts.tv_sec,
                                         (uint32_t)ts.tv_nsec,
                                         &rs422_seq);
                } else {
                    uint8_t payload[8];
                    payload[0] = parser.cmd;
                    for (k = 0; k < parser.data_len && k < 7; k++)
                        payload[1 + k] = parser.buf[k];

                    slot_publish(ddr_base, SLOT_RS422, RING_RS422, DEV_RS422,
                                 payload, (uint32_t)(1 + parser.data_len),
                                 (uint32_t)ts.tv_sec,
                                 (uint32_t)ts.tv_nsec,
                                 &rs422_seq);
                }

                printf("[RS422 #%u] %s", rs422_seq, rs422_cmd_name(parser.cmd));
                switch (parser.cmd) {
                    case RS422_CMD_DISPLACEMENT: print_rs422_displacement(parser.buf); break;
                    case RS422_CMD_STATUS:       print_rs422_status(parser.buf); break;
                    case RS422_CMD_TEMP:         print_rs422_temp(parser.buf); break;
                    case RS422_CMD_VOLTAGE:      print_rs422_voltage(parser.buf); break;
                    case RS422_CMD_VERSION:      print_rs422_version(parser.buf); break;
                    case RS422_CMD_PBIT:         print_rs422_pbit(parser.buf); break;
                    case RS422_CMD_DEVNAME:      print_rs422_devname(parser.buf); break;
                }
                printf("\n");
            }
        }

        /* 6.4 Remote 模式：按周期下发位移查询 EB EB */
        if (remote) {
            struct timespec now;
            long elapsed_us;
            clock_gettime(CLOCK_MONOTONIC, &now);
            elapsed_us = (now.tv_sec - last_query.tv_sec) * 1000000L +
                         (now.tv_nsec - last_query.tv_nsec) / 1000;
            if (elapsed_us >= period_us) {
                uart_send_cmd2(uart, CMD_RM_QUERY, CMD_RM_QUERY);
                last_query = now;
            }
        }
    }

    munmap((void *)ddr_base, DDR_SIZE);
    close(fd_mem);
    if (fd_usb >= 0) close(fd_usb);
    if (fd_ps2 >= 0) close(fd_ps2);
    if (can_fd >= 0) close(can_fd);
    return 0;
}