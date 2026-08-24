/*
 * arm_usb_ps2_rs422_sender.c - USB鼠标 + PS/2鼠标 + RS422 三路并发数据采集程序
 *
 * 功能：单进程并行采集三路数据，分别写入 DDR 共享内存不同槽位：
 *   - USB 鼠标  ：poll()/dev/input/event1，每 input_event 一条记录，
 *                 data={type(2B),code(2B),value(4B)}，写槽位 0x20000000 (device_id=0)
 *   - PS/2 鼠标 ：poll()/dev/input/event4（PS/2转USB模块），按 SYN_REPORT 聚合，
 *                 封装成标准 PS/2 鼠标 3 字节数据包，写槽位 0x20000040 (device_id=2)
 *   - RS422     ：寄存器级轮询 PS UART1(EMIO) FIFO，解析协议帧，写槽位 0x20000060 (device_id=3)
 *
 * 标准PS/2鼠标数据包（3字节，data_len=3）：
 *   Byte0: [Y溢出][X溢出][Y符号][X符号][1][中键][右键][左键]
 *   Byte1: X位移（9位补码低8位，右为正）
 *   Byte2: Y位移（9位补码低8位，PS/2约定上为正，与evdev相反故取反）
 *
 * 并发模型：单线程 —— poll 同时监听两个鼠标 fd（5ms 短超时）；超时即轮询 UART1 RX FIFO。
 *   三路槽位地址独立、seq 各自递增，无需加锁。
 *
 * 硬件连接：
 *   USB  ：原生USB鼠标插开发板 USB Host 口，/dev/input/event1
 *   PS/2 ：PS/2鼠标经转USB模块插另一个 USB Host 口，/dev/input/event4
 *   RS422：pin26(E5)=UART1_TX, pin28(B1)=UART1_RX, pin29=3.3V, pin30=GND
 *
 * 协议依据：docs/protocol_spec.md + docs/USB接口对接文档.md + docs/RS422接口对接文档.md
 *   DDR 槽位 : 统一32字节 {seq,device_id,data_len,reserved,data[8],tv_sec,tv_nsec}
 *   环形缓冲 : 每路64槽环形区(2KB)记录历史帧，单槽区同步写最新值（兼容旧PC程序）
 *              USB@0x20000100 PS2@0x20000900 RS422@0x20001100，写ring[seq%64]
 *   PS/2     : 标准扫描码（3字节鼠标数据包）
 *   RS422 RX : 帧头0x55 | 标识0xD1~0xD7 | 有效数据 | 校验和(累加取低8位)
 *   RS422 TX : 裸字节下行命令（无帧头/校验和）：
 *              Stream EA EA EA | Remote F0 F0 F0 | 查询E9/E4/E3/E2 | Remote位移EB EB | 配置E8/F3
 *
 * 编译：gcc -O2 -o arm_usb_ps2_rs422_sender arm_usb_ps2_rs422_sender.c
 * 运行：sudo systemctl stop serial-getty@ttyPS0.service   # RS422 占用 UART1，需先停 console
 *       sudo ./arm_usb_ps2_rs422_sender [stream|remote] [周期us] [--query xxx] [--cpi n] [--rate n] [usb节点] [ps2节点]
 *       默认 usb=/dev/input/event1  ps2=/dev/input/event4；默认 stream 模式被动接收
 *       任一鼠标未插入不报错退出，对应路自动禁用，其余路照常工作
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

/* ===== DDR共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    0x4000   /* 16KB：单槽区 + 3个环形缓冲区 */

/* 四路接口槽位地址（每路32字节，对齐cache line，互不竞争） */
#define SLOT_USB     0x00   /* 0x20000000 USB */
#define SLOT_CAN     0x20   /* 0x20000020 CAN（预留） */
#define SLOT_PS2     0x40   /* 0x20000040 PS2 */
#define SLOT_RS422   0x60   /* 0x20000060 RS422 */

/* 环形缓冲区（每路64槽×32B=2KB）：记录历史帧，解决单槽覆盖丢帧
 * PC端一次DMA读整块2KB，按槽内seq升序回放 */
#define RING_SLOTS   64
#define RING_USB     0x0100   /* 0x20000100 USB环形区 */
#define RING_PS2     0x0900   /* 0x20000900 PS2环形区 */
#define RING_RS422   0x1100   /* 0x20001100 RS422环形区 */

/* 接口类型标识 */
#define DEV_USB    0
#define DEV_CAN    1
#define DEV_PS2    2
#define DEV_RS422  3

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
#define RS422_CMD_DISPLACEMENT 0xD1   /* 位移信息，3字节数据 */
#define RS422_CMD_STATUS       0xD2   /* 状态信息，3字节数据 */
#define RS422_CMD_TEMP         0xD3   /* 温度，1字节数据 */
#define RS422_CMD_VOLTAGE      0xD4   /* 电压，2字节数据 */
#define RS422_CMD_VERSION      0xD5   /* 版本，3字节数据 */
#define RS422_CMD_PBIT         0xD6   /* 上电PBIT，6字节数据（上电连续5帧） */
#define RS422_CMD_DEVNAME      0xD7   /* 设备型号，16字节CHAR（上电连续3帧） */

/* RS422 下行命令（采集卡 -> 轨迹球，裸字节，无帧头/校验和） */
#define CMD_Q_STATUS          0xE9   /* 状态查询 E9 E9 E9 */
#define CMD_Q_TEMP            0xE4   /* 温度查询 E4 E4 E4 */
#define CMD_Q_VOLTAGE         0xE3   /* 电压查询 E3 E3 E3 */
#define CMD_Q_VERSION         0xE2   /* 版本查询 E2 E2 E2 */
#define CMD_MODE_STREAM       0xEA   /* 切 Stream EA EA EA（默认） */
#define CMD_MODE_REMOTE       0xF0   /* 切 Remote F0 F0 F0 */
#define CMD_CFG_CPI           0xE8   /* 分辨率配置 E8 E8 E8 + 值 */
#define CMD_CFG_SAMPLERATE    0xF3   /* 采样率配置 F3 F3 F3 + 值 */
#define CMD_RM_QUERY          0xEB   /* Remote位移查询 EB EB（周期） */

/* 统一DDR转发槽位格式（32字节，对齐cache line） */
typedef struct {
    volatile uint32_t seq;        /* 0x00: 序号，每次事件+1（PC端检测变化） */
    volatile uint32_t device_id;  /* 0x04: 0=USB 1=CAN 2=PS2 3=RS422 */
    volatile uint32_t data_len;   /* 0x08: 有效数据长度 */
    volatile uint32_t reserved;   /* 0x0C: 保留对齐 */
    volatile uint8_t  data[8];    /* 0x10: 原始数据（见各接口封装） */
    volatile uint32_t tv_sec;     /* 0x18: 时间戳-秒 */
    volatile uint32_t tv_nsec;    /* 0x1C: 时间戳-纳秒 */
} share_slot_t;  /* 共32字节 */

/* ARM cacheflush 系统调用号 */
#ifndef __ARM_NR_cacheflush
#define __ARM_NR_cacheflush (0x0f0000 + 2)
#endif

/* 将共享槽位写回 DDR（D-cache clean，flags=0），确保 XDMA via AXI 能读到最新数据 */
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

/* PS/2帧聚合器：一个SYN_REPORT周期内的位移/按键累计成一个PS/2数据包 */
typedef struct {
    int      dx, dy;      /* 帧内X/Y位移累计（evdev语义：X右正，Y下正） */
    uint8_t  btn;         /* 按键状态 bit0=左 bit1=右 bit2=中（跨帧保持） */
    int      dirty;       /* 本帧有变化 */
} ps2_agg_t;

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
    int i;
    int wait;
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

/* ===== PS/2 标准数据包构造 =====
 * 将聚合器状态编码为标准PS/2鼠标3字节数据包：
 *   Byte0 = Y溢出(b7)|X溢出(b6)|Y符号(b5)|X符号(b4)|1(b3)|中键(b2)|右键(b1)|左键(b0)
 *   Byte1 = X位移，Byte2 = Y位移（9位补码，X右正/Y上正）
 * 注意：evdev的Y向下为正，PS/2约定Y向上为正，故Y取反还原PS/2语义
 */
static void ps2_build_packet(const ps2_agg_t *a, uint8_t pkt[3])
{
    int x = a->dx;
    int y = -a->dy;                       /* evdev Y下正 → PS/2 Y上正 */
    uint8_t b0 = 0x08;                    /* bit3恒为1 */

    b0 |= (uint8_t)(a->btn & 0x07);       /* 左/右/中键 */

    /* X：9位补码范围 -256~+255，超限钳位并置溢出位 */
    if (x > 255)  { x = 255;  b0 |= 0x40; }
    if (x < -256) { x = -256; b0 |= 0x40; }
    if (x < 0)      b0 |= 0x10;           /* X符号位 */
    /* Y */
    if (y > 255)  { y = 255;  b0 |= 0x80; }
    if (y < -256) { y = -256; b0 |= 0x80; }
    if (y < 0)      b0 |= 0x20;           /* Y符号位 */

    pkt[0] = b0;
    pkt[1] = (uint8_t)(x & 0xFF);         /* 9位补码低8位（负数即补码形式） */
    pkt[2] = (uint8_t)(y & 0xFF);
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

/* 位移信息解析显示（bf 指向有效数据，bf[0] 对应文档 data[1]） */
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
    int state;          /* 0=等帧头, 1=等标识, 2=读数据, 3=等校验和 */
    uint8_t cmd;
    int data_len;
    int data_idx;
    uint8_t buf[16];    /* 最大16字节（设备型号报文） */
    uint8_t checksum;
} rs422_parser_t;

static void parser_reset(rs422_parser_t *p)
{
    memset(p, 0, sizeof(*p));
}

/* 状态机处理1字节，返回1=完整帧校验通过 */
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

/* 填充单个槽位：字段→内存屏障→seq（seq最后写，PC端见新seq则数据已就绪） */
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

/* 写槽位公共路径：写环形槽（历史帧）+ 单槽（最新值，兼容旧PC程序） */
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

/* 设备型号(16字节超data[8]上限)分2片发布：
 *   reserved = (片序号 << 16) | 总长度(16)，PC端据此合并两片
 *   片0: data[8]=型号[0..7],   片1: data[8]=型号[8..15]
 * 均为裸字节存储（不含0x55帧头/标识/校验和，只存16字节CHAR原文） */
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
    r0->reserved = (0u << 16) | 16u;   /* 片0，总长16 */
    dma_wb_slot(r0);

    slot_fill(r1, DEV_RS422, name16 + 8, 8, sec, nsec, seq1);
    r1->reserved = (1u << 16) | 16u;   /* 片1，总长16 */
    dma_wb_slot(r1);

    /* 单槽区只能放8字节，仅存高16位片计数（legacy区不承载完整型号） */
    slot_fill(legacy, DEV_RS422, name16, 8, sec, nsec, seq0);
    legacy->reserved = (0u << 16) | 16u;
    dma_wb_slot(legacy);

    *pseq = seq1;
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IONBF, 0);   /* 无缓冲：确保 nohup 重定向下日志实时落盘 */

    int fd_usb = -1, fd_ps2 = -1, fd_mem;
    volatile uint8_t *ddr_base;
    struct input_event ev;
    struct pollfd pfds[2];
    int nfd = 0;
    uint32_t usb_seq = 0, ps2_seq = 0, rs422_seq = 0;
    const char *usb_dev = "/dev/input/event1";
    const char *ps2_dev = "/dev/input/event4";
    int remote = 0;           /* 0=Stream 1=Remote（RS422 下行模式） */
    int period_us = 4000;     /* Remote 位移查询周期 3~5ms */
    int query = -1;           /* 一次性查询命令：0状态 1温度 2电压 3版本 */
    int cpi = -1;             /* 分辨率配置值 0~10 */
    int rate = -1;            /* 采样率配置值 10/20/30/40 */

    /* 参数解析：支持 remote/stream 模式 + 原 USB/PS2 节点（向后兼容）
     * 用法：./arm_multi [stream|remote] [周期us] [--query xxx] [--cpi n] [--rate n] [usb节点] [ps2节点] */
    {
        int i;
        int dev_idx = 0;
        for (i = 1; i < argc; i++) {
            const char *a = argv[i];
            if (strcmp(a, "remote") == 0) { remote = 1; }
            else if (strcmp(a, "stream") == 0) { remote = 0; }
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

    printf("=== USB + PS/2 + RS422 三路并发数据采集程序（协议标准格式）===\n");
    printf("RS422模式: %s%s%s\n", remote ? "Remote(周期查询EB EB)" : "Stream(被动接收)",
           query >= 0 ? " +查询" : "", cpi >= 0 || rate >= 0 ? " +配置" : "");

    /* 1. 切 MIO49/48 -> GPIO，释放 UART1 EMIO RX 污染（RS422 接收前提） */
    volatile uint32_t *slcr = map_phys(SLCR_BASE);
    if (!slcr) return 1;
    wr(slcr, 0x008, 0xDF0D);   /* UNLOCK */
    __sync_synchronize();
    wr(slcr, 0x7C0, 0x1200);   /* MIO48 -> GPIO */
    wr(slcr, 0x7C4, 0x1200);   /* MIO49 -> GPIO */
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);   /* LOCK */
    __sync_synchronize();
    printf("[SLCR] MIO48/49 已切 GPIO (0x1200)\n");

    /* 2. mmap UART1，禁中断，NORMAL 模式（RS422 寄存器级接收） */
    volatile uint32_t *uart = map_phys(UART1_BASE);
    if (!uart) return 1;
    wr(uart, IDR, 0xFFFFFFFF);
    wr(uart, CR, 0x17);   /* RXRST|TXRST|RX_EN|TX_EN：显式复位并使能UART，不依赖serial-getty遗留状态 */
    wr(uart, MR, 0x20);

    /* 2.5 下发 RS422 下行命令（采集卡 -> 轨迹球，裸字节） */
    uart_send_cmd3(uart, remote ? CMD_MODE_REMOTE : CMD_MODE_STREAM);
    printf("[命令] 下发 %02X %02X %02X 切轨迹球到 %s 模式\n",
           remote ? CMD_MODE_REMOTE : CMD_MODE_STREAM,
           remote ? CMD_MODE_REMOTE : CMD_MODE_STREAM,
           remote ? CMD_MODE_REMOTE : CMD_MODE_STREAM,
           remote ? "Remote" : "Stream");
    usleep(10000);

    if (query >= 0) {
        static const uint8_t qcmd[4] = { CMD_Q_STATUS, CMD_Q_TEMP, CMD_Q_VOLTAGE, CMD_Q_VERSION };
        static const char *qname[4]  = { "状态", "温度", "电压", "版本" };
        uart_send_cmd3(uart, qcmd[query]);
        printf("[命令] 下发%s查询: %02X %02X %02X\n",
               qname[query], qcmd[query], qcmd[query], qcmd[query]);
        usleep(10000);
    }
    if (cpi >= 0) {
        uart_send_cmd3(uart, CMD_CFG_CPI);
        usleep(7000);
        uart_send_bytes(uart, (const uint8_t *)&cpi, 1);
        printf("[命令] 下发分辨率配置: E8 E8 E8 + %d (CPI=%d)\n", cpi, 125 + cpi * 125);
        usleep(10000);
    }
    if (rate >= 0) {
        uart_send_cmd3(uart, CMD_CFG_SAMPLERATE);
        usleep(7000);
        uart_send_bytes(uart, (const uint8_t *)&rate, 1);
        printf("[命令] 下发采样率配置: F3 F3 F3 + %d (%d fps)\n", rate, rate * 10);
        usleep(10000);
    }

    /* 2.6 Remote 位移查询周期计时基准 */
    struct timespec last_query;
    clock_gettime(CLOCK_MONOTONIC, &last_query);

    /* 3. mmap DDR 共享内存 */
    fd_mem = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd_mem < 0) { perror("open /dev/mem (DDR)"); return 1; }
    ddr_base = (volatile uint8_t *)mmap(NULL, DDR_SIZE,
             PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DDR_BASE);
    if (ddr_base == MAP_FAILED) { perror("mmap DDR"); close(fd_mem); return 1; }
    /* 清零三个环形缓冲区（DDR残留旧数据会干扰PC端seq判重）
     * 注意：memset 只写 D-cache，必须 clean 到 DDR，否则 XDMA 经 AXI 读到旧脏 seq */
    memset((void *)(ddr_base + RING_USB),   0, RING_SLOTS * sizeof(share_slot_t));
    memset((void *)(ddr_base + RING_PS2),   0, RING_SLOTS * sizeof(share_slot_t));
    memset((void *)(ddr_base + RING_RS422), 0, RING_SLOTS * sizeof(share_slot_t));
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + RING_USB),
            (long)(ddr_base + RING_USB + RING_SLOTS * sizeof(share_slot_t)), 0);
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + RING_PS2),
            (long)(ddr_base + RING_PS2 + RING_SLOTS * sizeof(share_slot_t)), 0);
    syscall(__ARM_NR_cacheflush, (long)(ddr_base + RING_RS422),
            (long)(ddr_base + RING_RS422 + RING_SLOTS * sizeof(share_slot_t)), 0);

    /* 4. 打开两只鼠标设备（任一失败不退出，对应路禁用） */
    fd_usb = open(usb_dev, O_RDONLY);
    if (fd_usb < 0) {
        printf("[警告] USB鼠标 %s 打开失败(%s)，USB路禁用\n",
               usb_dev, strerror(errno));
    } else {
        pfds[nfd].fd = fd_usb;
        pfds[nfd].events = POLLIN;
        nfd++;
    }

    fd_ps2 = open(ps2_dev, O_RDONLY);
    if (fd_ps2 < 0) {
        printf("[警告] PS/2鼠标 %s 打开失败(%s)，PS/2路禁用\n",
               ps2_dev, strerror(errno));
    } else {
        pfds[nfd].fd = fd_ps2;
        pfds[nfd].events = POLLIN;
        nfd++;
    }

    if (nfd == 0) {
        printf("[错误] 两只鼠标均无法打开，退出\n");
        printf("提示: cat /proc/bus/input/devices 查看鼠标对应 event 节点\n");
        close(fd_mem);
        return 1;
    }

    printf("USB 槽位: 0x%08X 环形区: 0x%08X (device_id=%d)  输入设备: %s\n",
           DDR_BASE + SLOT_USB, DDR_BASE + RING_USB, DEV_USB,
           fd_usb >= 0 ? usb_dev : "禁用");
    printf("PS/2槽位: 0x%08X 环形区: 0x%08X (device_id=%d)  输入设备: %s\n",
           DDR_BASE + SLOT_PS2, DDR_BASE + RING_PS2, DEV_PS2,
           fd_ps2 >= 0 ? ps2_dev : "禁用");
    printf("RS422槽位: 0x%08X 环形区: 0x%08X (device_id=%d)\n",
           DDR_BASE + SLOT_RS422, DDR_BASE + RING_RS422, DEV_RS422);
    printf("三路并行收集中... (Ctrl+C 退出)\n\n");

    rs422_parser_t parser;
    parser_reset(&parser);

    ps2_agg_t agg;
    memset(&agg, 0, sizeof(agg));

    /* 5. 主循环：poll 两路鼠标(5ms超时) + 超时轮询 UART1 FIFO */
    while (1) {
        int ret = poll(pfds, nfd, 5);
        int i;

        for (i = 0; i < nfd && ret > 0; i++) {
            if (!(pfds[i].revents & POLLIN))
                continue;

            ssize_t n = read(pfds[i].fd, &ev, sizeof(ev));
            if (n != sizeof(ev))
                continue;

            if (pfds[i].fd == fd_usb) {
                /* 5.1 USB路：每 input_event 直接一条记录（现有协议格式） */
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
                /* 5.2 PS/2路：帧内聚合，SYN_REPORT时发标准PS/2数据包 */
                if (ev.type == EV_REL) {
                    if (ev.code == REL_X)      { agg.dx += ev.value; agg.dirty = 1; }
                    else if (ev.code == REL_Y) { agg.dy += ev.value; agg.dirty = 1; }
                } else if (ev.type == EV_KEY) {
                    uint8_t mask = 0;
                    switch (ev.code) {
                        case BTN_LEFT:   mask = 0x01; break;
                        case BTN_RIGHT:  mask = 0x02; break;
                        case BTN_MIDDLE: mask = 0x04; break;
                        default: break;
                    }
                    if (mask) {
                        if (ev.value) agg.btn |= mask;
                        else          agg.btn &= (uint8_t)~mask;
                        agg.dirty = 1;
                    }
                } else if (ev.type == EV_SYN && ev.code == SYN_REPORT) {
                    if (agg.dirty) {
                        uint8_t pkt[3];
                        struct timespec ts;

                        /* 用REALTIME与USB路ev.time同基准，PC端统一校准延时 */
                        clock_gettime(CLOCK_REALTIME, &ts);
                        ps2_build_packet(&agg, pkt);

                        slot_publish(ddr_base, SLOT_PS2, RING_PS2, DEV_PS2,
                                     pkt, 3,
                                     (uint32_t)ts.tv_sec,
                                     (uint32_t)ts.tv_nsec,
                                     &ps2_seq);

                        printf("[PS/2 #%u] 帧 %02X %02X %02X (X%+d Y%+d L%d R%d M%d)\n",
                               ps2_seq, pkt[0], pkt[1], pkt[2],
                               agg.dx, -agg.dy,
                               agg.btn & 0x01, (agg.btn >> 1) & 0x01,
                               (agg.btn >> 2) & 0x01);

                        /* 位移清零，按键状态保留（PS/2按键状态跨帧保持） */
                        agg.dx = 0;
                        agg.dy = 0;
                        agg.dirty = 0;
                    }
                }
            }
        }

        /* 5.3 RS422：轮询 UART1 RX FIFO，逐字节喂状态机 */
        int cnt = 0;
        while (!(rd(uart, SR) & SR_RXEMPTY) && cnt < 256) {
            uint8_t b = (uint8_t)(rd(uart, FIFO) & 0xFF);
            cnt++;

            if (parser_feed(&parser, b)) {
                struct timespec ts;
                int k;

                /* 用REALTIME与USB路ev.time同基准，PC端统一校准延时 */
                clock_gettime(CLOCK_REALTIME, &ts);

                if (parser.cmd == RS422_CMD_DEVNAME) {
                    /* 设备型号16字节：分2片裸字节存储，reserved编码片序+总长 */
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

        /* 5.4 Remote 模式：按周期下发位移查询 EB EB（3~5ms） */
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
    return 0;
}
