/*
 * arm_rs422_sender.c - 开发板侧RS422数据采集程序（协议标准格式V3，寄存器级）
 *
 * 功能：从PS UART1(EMIO)寄存器级接收轨迹球RS422数据，解析协议帧，写入DDR共享内存
 *
 * 硬件连接：
 *   轨迹球 ──RS422──> TTL转RS422模块 ──TTL──> ACZ7015 40pin排针
 *     pin26(E5)=UART1_TX, pin28(B1)=UART1_RX, pin29=3.3V, pin30=GND
 *
 * 协议依据：docs/RS422接口对接文档.md
 *   - 115200 8N1，自定义帧
 *   - 帧格式: 帧头(0x55) | 报文标识 | 有效数据 | 校验和
 *   - 校验和 = 帧头..有效数据末字节 累加取低8位
 *   - 5种报文: 位移(0xD1,3B) 状态(0xD2,3B) 温度(0xD3,1B) 电压(0xD4,2B) 版本(0xD5,3B)
 *
 * V3 关键修复（相对V2）：
 *   1) 启动时写 SLCR 把 MIO49/48 切为 GPIO，释放 UART1 EMIO RX 被 MIO49
 *      恒高电平污染的根因（UART1 RX = MIO49 | EMIO_RX 相或）
 *   2) 接收改为直接 mmap UART1 寄存器轮询 FIFO，不用 tty 驱动——
 *      EMIO 模式下 tty 驱动的 RX 中断路径不触发，read() 永远收不到数据
 *
 * 编译：gcc -O2 -o arm_rs422_sender arm_rs422_sender.c
 * 运行：sudo systemctl stop serial-getty@ttyPS0.service
 *       sudo ./arm_rs422_sender
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

/* ===== SLCR / UART1 寄存器级访问（与 rs422_verify.c 一致） ===== */
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

/* RS422协议常量 */
#define RS422_FRAME_HEAD       0x55
#define RS422_CMD_DISPLACEMENT 0xD1  /* 位移信息，3字节数据 */
#define RS422_CMD_STATUS       0xD2  /* 状态信息，3字节数据 */
#define RS422_CMD_TEMP         0xD3  /* 温度，1字节数据 */
#define RS422_CMD_VOLTAGE      0xD4  /* 电压，2字节数据 */
#define RS422_CMD_VERSION      0xD5  /* 版本，3字节数据 */

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

/* 位移信息解析显示（bf 指向有效数据，bf[0] 对应文档 data[1]） */
static void print_displacement(const uint8_t *bf)
{
    uint8_t b1 = bf[0];            /* bit0=左键 bit1=右键 bit4=X符号 bit5=Y符号 */
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
    uint8_t cmd;        /* 当前报文标识 */
    int data_len;       /* 期望数据长度 */
    int data_idx;       /* 已读数据索引 */
    uint8_t buf[8];     /* 有效数据缓冲 */
    uint8_t checksum;   /* 累加校验和 */
} rs422_parser_t;

static void parser_reset(rs422_parser_t *p)
{
    memset(p, 0, sizeof(*p));
}

/* 状态机处理1字节，返回1=完整帧校验通过, 0=继续 */
static int parser_feed(rs422_parser_t *p, uint8_t b)
{
    switch (p->state) {
    case 0: /* 等帧头 */
        if (b == RS422_FRAME_HEAD) {
            p->state = 1;
            p->checksum = b;   /* 校验和从帧头开始累加 */
        }
        return 0;

    case 1: /* 读报文标识 */
        p->cmd = b;
        p->data_len = get_data_len(b);
        if (p->data_len < 0) {   /* 未知标识，回等帧头 */
            p->state = 0;
            return 0;
        }
        p->checksum += b;
        p->data_idx = 0;
        p->state = 2;
        return 0;

    case 2: /* 读有效数据 */
        p->buf[p->data_idx++] = b;
        p->checksum += b;
        if (p->data_idx >= p->data_len)
            p->state = 3;
        return 0;

    case 3: /* 读校验和 */
        p->state = 0;
        return ((p->checksum & 0xFF) == b) ? 1 : 0;

    default:
        p->state = 0;
        return 0;
    }
}

int main(void)
{
    setvbuf(stdout, NULL, _IOLBF, 0);   /* 行缓冲，日志实时输出 */
    printf("=== RS422数据采集程序 V3（协议标准格式，寄存器级）===\n");
    printf("波特率: 115200 8N1\n");
    printf("RS422槽位: 0x%08X (device_id=%d)\n", DDR_BASE + SLOT_RS422, DEV_RS422);

    /* 1. 切 MIO49/48 -> GPIO，释放 EMIO RX 污染（核心） */
    volatile uint32_t *slcr = map_phys(SLCR_BASE);
    if (!slcr) return 1;

    printf("[SLCR] 切前 MIO48=0x%X MIO49=0x%X\n", rd(slcr, 0x7C0), rd(slcr, 0x7C4));
    wr(slcr, 0x008, 0xDF0D);   /* UNLOCK */
    __sync_synchronize();
    wr(slcr, 0x7C4, 0x1200);   /* MIO49 -> GPIO */
    wr(slcr, 0x7C0, 0x1200);   /* MIO48 -> GPIO */
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);   /* LOCK */
    __sync_synchronize();
    printf("[SLCR] 切后 MIO48=0x%X MIO49=0x%X\n", rd(slcr, 0x7C0), rd(slcr, 0x7C4));

    /* 2. mmap UART1，禁中断，NORMAL 模式 */
    volatile uint32_t *uart = map_phys(UART1_BASE);
    if (!uart) return 1;
    wr(uart, IDR, 0xFFFFFFFF);   /* 禁中断，防止 tty 驱动抢 FIFO */
    wr(uart, MR, 0x20);          /* NORMAL（无回环） */

    /* 3. mmap DDR 共享内存 */
    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) { perror("open /dev/mem (DDR)"); return 1; }
    void *ddr = mmap(NULL, DDR_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, DDR_BASE);
    if (ddr == MAP_FAILED) { perror("mmap DDR"); close(mem_fd); return 1; }
    share_slot_t *slot = (share_slot_t *)((uint8_t *)ddr + SLOT_RS422);

    printf("UART1 与 DDR 就绪，等待 RS422 数据... (Ctrl+C 退出)\n\n");

    /* 4. 主循环：轮询 FIFO 接收，逐字节喂状态机 */
    rs422_parser_t parser;
    parser_reset(&parser);
    uint32_t seq = 0;

    while (1) {
        int cnt = 0;
        /* 连续读空 FIFO（每轮上限 256 字节防饿死） */
        while (!(rd(uart, SR) & SR_RXEMPTY) && cnt < 256) {
            uint8_t b = (uint8_t)(rd(uart, FIFO) & 0xFF);
            cnt++;

            if (parser_feed(&parser, b)) {
                /* 收到完整帧：写 DDR 槽位 */
                struct timespec ts;
                clock_gettime(CLOCK_MONOTONIC, &ts);

                slot->device_id = DEV_RS422;
                slot->data_len  = (uint32_t)parser.data_len;
                slot->reserved  = 0;
                slot->data[0]   = parser.cmd;
                {
                    int k;
                    for (k = 0; k < parser.data_len; k++)
                        slot->data[1 + k] = parser.buf[k];
                    for (; k < 7; k++)
                        slot->data[1 + k] = 0;   /* 剩余字节清零 */
                }
                slot->tv_sec  = (uint32_t)ts.tv_sec;
                slot->tv_nsec = (uint32_t)ts.tv_nsec;
                /* 内存屏障：先写完所有字段，最后提交 seq，避免 PC 端 DMA 读到撕裂 */
                __sync_synchronize();
                slot->seq = ++seq;

                /* 打印日志 */
                printf("[发送 #%u] RS422 %s", seq, cmd_name(parser.cmd));
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
        usleep(500);   /* FIFO 空时让出 CPU */
    }

    /* 不可达，保留清理逻辑 */
    munmap(ddr, DDR_SIZE);
    close(mem_fd);
    return 0;
}