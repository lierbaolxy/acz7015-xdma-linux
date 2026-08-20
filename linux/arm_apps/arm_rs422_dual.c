/*
 * arm_rs422_dual.c - 开发板侧 RS422 双模式收发程序（寄存器级，Stream/Remote）
 *
 * 功能：在 arm_rs422_sender.c（纯接收）基础上，增加 UART1 TX 发送能力，
 *       支持轨迹球的两种工作模式：
 *         - Stream 模式：轨迹球移动/按键时主动实时发位移，本程序被动接收
 *         - Remote 模式：本程序以 3~5ms 周期下发 0xEB 0xEB 查询位移，轨迹球应答后接收
 *
 * 协议依据（原始文档：轨迹球组件测试验证系统-通信协议（20260625）.docx）：
 *   - 115200 8N1，数据帧 = 帧头(0x55) | 标识(0xD1~0xD5) | 有效数据 | 校验和
 *   - 命令（测试系统→轨迹球）为**裸字节**，无 0x55 帧头、无校验和：
 *       状态查询 E9 E9 E9 | 温度查询 E4 E4 E4 | 电压查询 E3 E3 E3 | 版本查询 E2 E2 E2
 *       切 Stream EA EA EA | 切 Remote F0 F0 F0 | 采样率配置 F3 F3 F3(+值) | 分辨率配置 E8 E8 E8(+值)
 *       Remote 位移查询 EB EB（仅 Remote 模式，3~5ms 周期）
 *
 * 硬件连接：
 *   轨迹球 ──RS422──> TTL转RS422模块 ──TTL──> ACZ7015 40pin排针
 *     pin26(E5)=UART1_TX(下行命令), pin28(B1)=UART1_RX(上行数据), pin29=3.3V, pin30=GND
 *
 * 关键点（同 V3）：
 *   1) 启动写 SLCR 把 MIO49/48 切 GPIO，释放 UART1 EMIO RX 被 MIO49 恒高污染
 *   2) mmap UART1 寄存器，禁用中断，NORMAL 模式，轮询 FIFO
 *
 * 编译：gcc -O2 -o arm_rs422_dual arm_rs422_dual.c
 * 运行：sudo systemctl stop serial-getty@ttyPS0.service
 *       sudo ./arm_rs422_dual [stream|remote] [查询周期us]
 *         默认 stream；remote 模式默认 4000us(4ms)，范围 2000~5000us
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <stdint.h>
#include <time.h>

/* ===== DDR共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    4096
#define SLOT_RS422  0x60   /* 0x20000060 RS422槽位 */

/* ===== SLCR / UART1 寄存器级访问（与 arm_rs422_sender.c 一致） ===== */
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

/* 接口类型标识 */
#define DEV_RS422  3

/* RS422协议常量（数据帧） */
#define RS422_FRAME_HEAD       0x55
#define RS422_CMD_DISPLACEMENT 0xD1  /* 位移信息，3字节数据 */
#define RS422_CMD_STATUS       0xD2  /* 状态信息，3字节数据 */
#define RS422_CMD_TEMP         0xD3  /* 温度，1字节数据 */
#define RS422_CMD_VOLTAGE      0xD4  /* 电压，2字节数据 */
#define RS422_CMD_VERSION      0xD5  /* 版本，3字节数据 */

/* 命令（测试系统→轨迹球，裸字节，无帧头/校验和） */
#define CMD_Q_STATUS      0xE9  /* 状态查询:  E9 E9 E9 */
#define CMD_Q_TEMP        0xE4  /* 温度查询:  E4 E4 E4 */
#define CMD_Q_VOLTAGE     0xE3  /* 电压查询:  E3 E3 E3 */
#define CMD_Q_VERSION     0xE2  /* 版本查询:  E2 E2 E2 */
#define CMD_MODE_STREAM   0xEA  /* 切Stream:  EA EA EA */
#define CMD_MODE_REMOTE   0xF0  /* 切Remote:  F0 F0 F0 */
#define CMD_CFG_SAMPLERATE 0xF3 /* 采样率配置: F3 F3 F3 + 5~10ms后配置值 */
#define CMD_CFG_CPI       0xE8  /* 分辨率配置: E8 E8 E8 + 5~10ms后配置值 */
#define CMD_RM_QUERY      0xEB  /* Remote位移查询: EB EB（3~5ms周期）*/

/* 统一DDR转发槽位格式（32字节，对齐cache line） */
typedef struct {
    volatile uint32_t seq;        /* 0x00: 序号 */
    volatile uint32_t device_id;  /* 0x04: 3=RS422 */
    volatile uint32_t data_len;   /* 0x08: 有效数据长度 */
    volatile uint32_t reserved;   /* 0x0C: 保留 */
    volatile uint8_t  data[8];    /* 0x10: data[0]=标识, data[1..]=有效数据 */
    volatile uint32_t tv_sec;     /* 0x18: 时间戳-秒 */
    volatile uint32_t tv_nsec;    /* 0x1C: 时间戳-纳秒 */
} share_slot_t;

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

/* ===== UART1 TX（新增：裸字节发送命令） ===== */
static void uart_send_bytes(volatile uint32_t *uart, const uint8_t *buf, int len)
{
    int i;
    for (i = 0; i < len; i++)
        wr(uart, FIFO, buf[i]);
    int wait = 0;
    while (!(rd(uart, SR) & SR_TXEMPTY)) {
        if (++wait > 1000000) { printf("[警告] TX 等待超时\n"); break; }
    }
}

/* 发送 3 字节重复命令（E9/E4/E3/E2/EA/F0 等） */
static void uart_send_cmd3(volatile uint32_t *uart, uint8_t c)
{
    uint8_t b[3] = { c, c, c };
    uart_send_bytes(uart, b, 3);
}

/* 发送 2 字节命令（Remote 位移查询 EB EB） */
static void uart_send_cmd2(volatile uint32_t *uart, uint8_t c1, uint8_t c2)
{
    uint8_t b[2] = { c1, c2 };
    uart_send_bytes(uart, b, 2);
}

/* 各报文的有效数据长度；未知返回 -1 */
static int get_data_len(uint8_t cmd)
{
    switch (cmd) {
        case RS422_CMD_DISPLACEMENT: return 3;
        case RS422_CMD_STATUS:       return 3;
        case RS422_CMD_TEMP:         return 1;
        case RS422_CMD_VOLTAGE:      return 2;
        case RS422_CMD_VERSION:      return 3;
        default:                     return -1;
    }
}

/* 报文名称 */
static const char *cmd_name(uint8_t cmd)
{
    switch (cmd) {
        case RS422_CMD_DISPLACEMENT: return "位移";
        case RS422_CMD_STATUS:       return "状态";
        case RS422_CMD_TEMP:         return "温度";
        case RS422_CMD_VOLTAGE:      return "电压";
        case RS422_CMD_VERSION:      return "版本";
        default:                     return "未知";
    }
}

/* 位移信息解析显示 */
static void print_displacement(const uint8_t *bf)
{
    uint8_t b1 = bf[0];
    int8_t x = (int8_t)bf[1];
    int8_t y = (int8_t)bf[2];
    printf("  位移: X=%d Y=%d 左键=%d 右键=%d",
           x, y, b1 & 0x01, (b1 >> 1) & 0x01);
}

/* 状态信息解析显示 */
static void print_status(const uint8_t *bf)
{
    printf("  状态: 模式=%s 分辨率=%d 采样率=%d",
           (bf[0] >> 6) & 0x01 ? "Remote" : "Stream", bf[1], bf[2]);
}

/* 温度解析显示 */
static void print_temp(const uint8_t *bf)
{
    printf("  温度: %d℃", (int8_t)bf[0]);
}

/* 电压解析显示（低8位在前，单位10mV） */
static void print_voltage(const uint8_t *bf)
{
    uint16_t vol = bf[0] | (bf[1] << 8);
    printf("  电压: %d.%dV", vol / 100, (vol % 100) / 10);
}

/* 版本解析显示 */
static void print_version(const uint8_t *bf)
{
    printf("  版本: %d.%02d.%02d", bf[0], bf[1], bf[2]);
}

/* ===== RS422帧解析状态机 ===== */
typedef struct {
    int state;          /* 0=等帧头, 1=等标识, 2=读数据, 3=等校验和 */
    uint8_t cmd;
    int data_len;
    int data_idx;
    uint8_t buf[8];
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
    case 0: /* 等帧头 */
        if (b == RS422_FRAME_HEAD) { p->state = 1; p->checksum = b; }
        return 0;
    case 1: /* 读报文标识 */
        p->cmd = b;
        p->data_len = get_data_len(b);
        if (p->data_len < 0) { p->state = 0; return 0; }
        p->checksum += b;
        p->data_idx = 0;
        p->state = 2;
        return 0;
    case 2: /* 读有效数据 */
        p->buf[p->data_idx++] = b;
        p->checksum += b;
        if (p->data_idx >= p->data_len) p->state = 3;
        return 0;
    case 3: /* 读校验和 */
        p->state = 0;
        return ((p->checksum & 0xFF) == b) ? 1 : 0;
    default:
        p->state = 0;
        return 0;
    }
}

/* 把一帧写入 DDR 槽位（先写数据，最后写 seq + 内存屏障，防 PC 端撕裂） */
static void publish_slot(share_slot_t *slot, uint8_t cmd,
                         const uint8_t *data, int data_len, uint32_t *seq)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);

    slot->device_id = DEV_RS422;
    slot->data_len  = (uint32_t)data_len;
    slot->reserved  = 0;
    slot->data[0]   = cmd;
    {
        int k;
        for (k = 0; k < data_len; k++)
            slot->data[1 + k] = data[k];
        for (; k < 7; k++)
            slot->data[1 + k] = 0;
    }
    slot->tv_sec  = (uint32_t)ts.tv_sec;
    slot->tv_nsec = (uint32_t)ts.tv_nsec;
    __sync_synchronize();
    slot->seq = ++(*seq);
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IOLBF, 0);

    /* 解析模式：stream(默认) / remote；周期默认 4000us */
    int remote = 0;
    if (argc > 1 && strcmp(argv[1], "remote") == 0)
        remote = 1;
    int period_us = (argc > 2) ? atoi(argv[2]) : 4000;
    if (period_us < 2000) period_us = 2000;   /* 协议要求 3~5ms，留 2ms 下限保护 */
    if (period_us > 5000) period_us = 5000;

    printf("=== RS422 双模式收发程序（寄存器级）===\n");
    printf("波特率: 115200 8N1  模式: %s  查询周期: %dus\n",
           remote ? "Remote" : "Stream", remote ? period_us : 0);
    printf("RS422槽位: 0x%08X (device_id=%d)\n", DDR_BASE + SLOT_RS422, DEV_RS422);

    /* 1. 切 MIO49/48 -> GPIO，释放 EMIO RX 污染 */
    volatile uint32_t *slcr = map_phys(SLCR_BASE);
    if (!slcr) return 1;
    wr(slcr, 0x008, 0xDF0D);   /* UNLOCK */
    __sync_synchronize();
    wr(slcr, 0x7C4, 0x1200);   /* MIO49 -> GPIO */
    wr(slcr, 0x7C0, 0x1200);   /* MIO48 -> GPIO */
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);   /* LOCK */
    __sync_synchronize();
    printf("[SLCR] MIO48/49 已切 GPIO (0x1200)\n");

    /* 2. mmap UART1，禁中断，NORMAL 模式 */
    volatile uint32_t *uart = map_phys(UART1_BASE);
    if (!uart) return 1;
    wr(uart, IDR, 0xFFFFFFFF);   /* 禁中断 */
    wr(uart, MR, 0x20);          /* NORMAL（无回环） */

    /* 3. mmap DDR 共享内存 */
    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) { perror("open /dev/mem (DDR)"); return 1; }
    void *ddr = mmap(NULL, DDR_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, DDR_BASE);
    if (ddr == MAP_FAILED) { perror("mmap DDR"); close(mem_fd); return 1; }
    share_slot_t *slot = (share_slot_t *)((uint8_t *)ddr + SLOT_RS422);

    /* 4. 下发模式切换命令（裸字节，无帧头/校验和） */
    if (remote) {
        uart_send_cmd3(uart, CMD_MODE_REMOTE);
        printf("[命令] 下发 F0 F0 F0 切轨迹球到 Remote 模式\n");
    } else {
        uart_send_cmd3(uart, CMD_MODE_STREAM);
        printf("[命令] 下发 EA EA EA 切轨迹球到 Stream 模式\n");
    }
    usleep(10000);   /* 等轨迹球处理模式切换 */

    printf("UART1 与 DDR 就绪，开始%s... (Ctrl+C 退出)\n\n",
           remote ? "周期查询(0xEB 0xEB)" : "被动接收");

    /* 5. 主循环：轮询 RX + Remote 周期下发查询 */
    rs422_parser_t parser;
    parser_reset(&parser);
    uint32_t seq = 0;

    while (1) {
        int cnt = 0;
        /* 5.1 连续读空 FIFO（每轮上限 256 字节防饿死）——两种模式都收 */
        while (!(rd(uart, SR) & SR_RXEMPTY) && cnt < 256) {
            uint8_t b = (uint8_t)(rd(uart, FIFO) & 0xFF);
            cnt++;
            if (parser_feed(&parser, b)) {
                publish_slot(slot, parser.cmd, parser.buf, parser.data_len, &seq);
                printf("[接收 #%u] RS422 %s", seq, cmd_name(parser.cmd));
                switch (parser.cmd) {
                    case RS422_CMD_DISPLACEMENT: print_displacement(parser.buf); break;
                    case RS422_CMD_STATUS:       print_status(parser.buf); break;
                    case RS422_CMD_TEMP:         print_temp(parser.buf); break;
                    case RS422_CMD_VOLTAGE:      print_voltage(parser.buf); break;
                    case RS422_CMD_VERSION:      print_version(parser.buf); break;
                }
                printf(" (data_len=%d)\n", parser.data_len);
            }
        }

        /* 5.2 Remote 模式：周期下发 0xEB 0xEB 查询位移 */
        if (remote)
            uart_send_cmd2(uart, CMD_RM_QUERY, CMD_RM_QUERY);

        /* 5.3 Remote 用 3~5ms 周期；Stream 用短超时让出 CPU */
        usleep(remote ? period_us : 500);
    }

    /* 不可达，保留清理逻辑 */
    munmap(ddr, DDR_SIZE);
    close(mem_fd);
    return 0;
}