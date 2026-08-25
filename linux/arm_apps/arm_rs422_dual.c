/*
 * arm_rs422_dual.c - 开发板侧 RS422 完整收发程序（寄存器级，Stream/Remote）
 *
 * 功能：完整实现 protocol_spec.md 中 RS422 接口的双向通信：
 *
 *   RX（轨迹球 -> 采集卡，0x55 帧头 + 校验和）：
 *     7 种报文：位移 D1 / 状态 D2 / 温度 D3 / 电压 D4 / 版本 D5 /
 *               上电PBIT D6(6B) / 设备型号 D7(16B, 分片存储)
 *     解析后写 DDR 单槽 0x20000060 + 环形缓冲 0x20001100(64槽)
 *
 *   TX（采集卡 -> 轨迹球，裸字节，无帧头/校验和）：
 *     状态查询 E9 E9 E9 | 温度查询 E4 E4 E4 | 电压查询 E3 E3 E3 | 版本查询 E2 E2 E2
 *     切 Stream EA EA EA | 切 Remote F0 F0 F0 | Remote位移 EB EB(周期)
 *     采样率配置 F3 F3 F3 + 值 | 分辨率配置 E8 E8 E8 + 值
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
 *       sudo ./arm_rs422_dual [stream|remote] [查询周期us] [--query xxx] [--cpi n] [--rate n]
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
#include <sys/syscall.h>

/* ===== DDR共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    0x4000   /* 16KB：单槽区 + 环形缓冲区 */
#define SLOT_RS422  0x60     /* 0x20000060 RS422单槽 */
#define RING_SLOTS  64
#define RING_RS422  0x1100   /* 0x20001100 RS422环形区(64槽x32B=2KB) */

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

/* 接口类型标识 */
#define DEV_RS422  3

/* 数据帧标识（轨迹球上报） */
#define RS422_FRAME_HEAD       0x55
#define RS422_CMD_DISPLACEMENT 0xD1  /* 位移信息，3字节数据 */
#define RS422_CMD_STATUS       0xD2  /* 状态信息，3字节数据 */
#define RS422_CMD_TEMP         0xD3  /* 温度，1字节数据 */
#define RS422_CMD_VOLTAGE      0xD4  /* 电压，2字节数据 */
#define RS422_CMD_VERSION      0xD5  /* 版本，3字节数据 */
#define RS422_CMD_PBIT         0xD6  /* 上电PBIT，6字节数据 */
#define RS422_CMD_DEVNAME      0xD7  /* 设备型号，16字节数据 */

/* 命令（采集卡 -> 轨迹球，裸字节，无帧头/校验和） */
#define CMD_Q_STATUS      0xE9
#define CMD_Q_TEMP        0xE4
#define CMD_Q_VOLTAGE     0xE3
#define CMD_Q_VERSION     0xE2
#define CMD_MODE_STREAM   0xEA
#define CMD_MODE_REMOTE   0xF0
#define CMD_CFG_SAMPLERATE 0xF3
#define CMD_CFG_CPI       0xE8
#define CMD_RM_QUERY      0xEB

/* 统一DDR转发槽位格式（32字节，对齐cache line） */
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

/* ===== UART1 TX ===== */
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

static void uart_send_cfg3(volatile uint32_t *uart, uint8_t cmd, uint8_t val)
{
    uart_send_cmd3(uart, cmd);
    usleep(7000);
    wr(uart, FIFO, val);
    int wait = 0;
    while (!(rd(uart, SR) & SR_TXEMPTY)) {
        if (++wait > 1000000) { printf("[警告] TX 等待超时\n"); break; }
    }
}

/* ===== 报文解析辅助 ===== */
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

static const char *cmd_name(uint8_t cmd)
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

static void print_displacement(const uint8_t *bf)
{
    uint8_t b1 = bf[0];
    int8_t x = (int8_t)bf[1];
    int8_t y = (int8_t)bf[2];
    printf("  位移: X=%d Y=%d 左键=%d 右键=%d",
           x, y, b1 & 0x01, (b1 >> 1) & 0x01);
}

static void print_status(const uint8_t *bf)
{
    printf("  状态: 模式=%s 分辨率=%d 采样率=%d",
           (bf[0] >> 6) & 0x01 ? "Remote" : "Stream", bf[1], bf[2]);
}

static void print_temp(const uint8_t *bf)
{
    printf("  温度: %d℃", (int8_t)bf[0]);
}

static void print_voltage(const uint8_t *bf)
{
    uint16_t vol = bf[0] | (bf[1] << 8);
    printf("  电压: %d.%dV", vol / 100, (vol % 100) / 10);
}

static void print_version(const uint8_t *bf)
{
    printf("  版本: %d.%02d.%02d", bf[0], bf[1], bf[2]);
}

static void print_pbit(const uint8_t *bf)
{
    int i;
    printf("  PBIT:");
    for (i = 0; i < 6; i++)
        printf(" %02X", bf[i]);
}

static void print_devname(const uint8_t *bf)
{
    char name[17];
    memcpy(name, bf, 16);
    name[16] = '\0';
    printf("  型号: %s", name);
}

/* ===== RS422帧解析状态机 ===== */
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
        if (b == RS422_FRAME_HEAD) { p->state = 1; p->checksum = b; }
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
        if (p->data_idx >= p->data_len) p->state = 3;
        return 0;
    case 3:
        p->state = 0;
        return ((p->checksum & 0xFF) == b) ? 1 : 0;
    default:
        p->state = 0;
        return 0;
    }
}

/* ===== DDR 槽位发布 ===== */
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

static void slot_publish(volatile uint8_t *ddr, uint32_t dev_id,
                         const uint8_t *payload, uint32_t len,
                         uint32_t sec, uint32_t nsec, uint32_t *pseq)
{
    uint32_t seq = *pseq + 1;
    volatile share_slot_t *ring =
        (volatile share_slot_t *)(ddr + RING_RS422 +
                                  (seq % RING_SLOTS) * sizeof(share_slot_t));
    volatile share_slot_t *legacy =
        (volatile share_slot_t *)(ddr + SLOT_RS422);

    slot_fill(ring, dev_id, payload, len, sec, nsec, seq);
    dma_wb_slot(ring);
    slot_fill(legacy, dev_id, payload, len, sec, nsec, seq);
    dma_wb_slot(legacy);
    *pseq = seq;
}

/* 设备型号16字节分2片：reserved=(片序<<16)|16 */
static void slot_publish_devname(volatile uint8_t *ddr, const uint8_t *name16,
                                 uint32_t sec, uint32_t nsec, uint32_t *pseq)
{
    uint32_t seq0 = *pseq + 1;
    uint32_t seq1 = seq0 + 1;
    volatile share_slot_t *r0 =
        (volatile share_slot_t *)(ddr + RING_RS422 +
                                  (seq0 % RING_SLOTS) * sizeof(share_slot_t));
    volatile share_slot_t *r1 =
        (volatile share_slot_t *)(ddr + RING_RS422 +
                                  (seq1 % RING_SLOTS) * sizeof(share_slot_t));
    volatile share_slot_t *legacy =
        (volatile share_slot_t *)(ddr + SLOT_RS422);

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

/* 发布一帧到 DDR（普通报文 data[0]=标识，型号走分片） */
static void publish_frame(volatile uint8_t *ddr, const rs422_parser_t *parser,
                          uint32_t *pseq)
{
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);

    if (parser->cmd == RS422_CMD_DEVNAME) {
        slot_publish_devname(ddr, parser->buf,
                             (uint32_t)ts.tv_sec, (uint32_t)ts.tv_nsec, pseq);
    } else {
        uint8_t payload[8];
        int k;
        payload[0] = parser->cmd;
        for (k = 0; k < parser->data_len && k < 7; k++)
            payload[1 + k] = parser->buf[k];
        slot_publish(ddr, DEV_RS422, payload,
                     (uint32_t)(1 + parser->data_len),
                     (uint32_t)ts.tv_sec, (uint32_t)ts.tv_nsec, pseq);
    }
}

static void print_frame(const rs422_parser_t *parser, uint32_t seq)
{
    printf("[接收 #%u] RS422 %s", seq, cmd_name(parser->cmd));
    switch (parser->cmd) {
        case RS422_CMD_DISPLACEMENT: print_displacement(parser->buf); break;
        case RS422_CMD_STATUS:       print_status(parser->buf); break;
        case RS422_CMD_TEMP:         print_temp(parser->buf); break;
        case RS422_CMD_VOLTAGE:      print_voltage(parser->buf); break;
        case RS422_CMD_VERSION:      print_version(parser->buf); break;
        case RS422_CMD_PBIT:         print_pbit(parser->buf); break;
        case RS422_CMD_DEVNAME:      print_devname(parser->buf); break;
    }
    printf(" (data_len=%d)\n", parser->data_len);
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IOLBF, 0);

    int remote = 0;
    int period_us = 4000;
    int query = -1;
    int cpi = -1;
    int rate = -1;
    int i;
    for (i = 1; i < argc; i++) {
        const char *a = argv[i];
        if (strcmp(a, "remote") == 0) remote = 1;
        else if (strcmp(a, "stream") == 0) remote = 0;
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
        }
    }
    if (period_us < 2000) period_us = 2000;
    if (period_us > 5000) period_us = 5000;

    printf("=== RS422 完整收发程序（寄存器级，7种报文+命令下发）===\n");
    printf("波特率: 115200 8N1  模式: %s  查询周期: %dus\n",
           remote ? "Remote" : "Stream", remote ? period_us : 0);
    printf("RS422单槽: 0x%08X 环形区: 0x%08X (device_id=%d)\n",
           DDR_BASE + SLOT_RS422, DDR_BASE + RING_RS422, DEV_RS422);

    /* 1. 切 MIO49/48 -> GPIO */
    volatile uint32_t *slcr = map_phys(SLCR_BASE);
    if (!slcr) return 1;
    wr(slcr, 0x008, 0xDF0D);
    __sync_synchronize();
    wr(slcr, 0x7C4, 0x1200);
    wr(slcr, 0x7C0, 0x1200);
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);
    __sync_synchronize();
    printf("[SLCR] MIO48/49 已切 GPIO (0x1200)\n");

    /* 2. mmap UART1 */
    volatile uint32_t *uart = map_phys(UART1_BASE);
    if (!uart) return 1;
    wr(uart, IDR, 0xFFFFFFFF);
    wr(uart, MR, 0x20);

    /* 3. mmap DDR */
    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) { perror("open /dev/mem (DDR)"); return 1; }
    volatile uint8_t *ddr = (volatile uint8_t *)mmap(NULL, DDR_SIZE,
             PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, DDR_BASE);
    if (ddr == MAP_FAILED) { perror("mmap DDR"); close(mem_fd); return 1; }
    memset((void *)(ddr + RING_RS422), 0, RING_SLOTS * sizeof(share_slot_t));

    /* 4. 下发模式切换命令 */
    if (remote) {
        uart_send_cmd3(uart, CMD_MODE_REMOTE);
        printf("[命令] 下发 F0 F0 F0 切轨迹球到 Remote 模式\n");
    } else {
        uart_send_cmd3(uart, CMD_MODE_STREAM);
        printf("[命令] 下发 EA EA EA 切轨迹球到 Stream 模式\n");
    }
    usleep(10000);

    if (query >= 0) {
        static const uint8_t qcmd[4] = { CMD_Q_STATUS, CMD_Q_TEMP, CMD_Q_VOLTAGE, CMD_Q_VERSION };
        static const char *qname[4]  = { "状态", "温度", "电压", "版本" };
        uart_send_cmd3(uart, qcmd[query]);
        printf("[命令] 下发%s查询: 0x%02X 0x%02X 0x%02X\n",
               qname[query], qcmd[query], qcmd[query], qcmd[query]);
        usleep(10000);
    }
    if (cpi >= 0) {
        uart_send_cfg3(uart, CMD_CFG_CPI, (uint8_t)cpi);
        printf("[命令] 下发分辨率配置: E8 E8 E8 + %d (CPI=%d)\n", cpi, 125 + cpi * 125);
        usleep(10000);
    }
    if (rate >= 0) {
        uart_send_cfg3(uart, CMD_CFG_SAMPLERATE, (uint8_t)rate);
        printf("[命令] 下发采样率配置: F3 F3 F3 + %d (%d fps)\n", rate, rate * 10);
        usleep(10000);
    }

    printf("UART1 与 DDR 就绪，开始%s... (Ctrl+C 退出)\n\n",
           remote ? "周期查询(0xEB 0xEB)" : "被动接收");

    rs422_parser_t parser;
    parser_reset(&parser);
    uint32_t seq = 0;

    while (1) {
        int cnt = 0;
        while (!(rd(uart, SR) & SR_RXEMPTY) && cnt < 256) {
            uint8_t b = (uint8_t)(rd(uart, FIFO) & 0xFF);
            cnt++;
            if (parser_feed(&parser, b)) {
                publish_frame(ddr, &parser, &seq);
                print_frame(&parser, seq);
            }
        }

        if (remote)
            uart_send_cmd2(uart, CMD_RM_QUERY, CMD_RM_QUERY);

        usleep(remote ? period_us : 500);
    }

    return 0;
}