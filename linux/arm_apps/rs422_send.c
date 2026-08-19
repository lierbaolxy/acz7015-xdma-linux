/*
 * rs422_send.c - RS422 协议帧发送程序（模拟轨迹球/外部设备，寄存器级）
 *
 * 功能：按 docs/RS422接口对接文档.md 协议，从 PS UART1(EMIO) 生成并发送
 *        标准 RS422 帧（115200 8N1），用于对接收端/采集程序做链路与协议验证。
 *
 * 协议帧格式:
 *   帧头(0x55) | 报文标识(0xD1~0xD5) | 有效数据 | 校验和
 *   校验和 = (帧头 + 标识 + 有效数据各字节) 累加取低 8 位
 *
 * 5 种报文:
 *   位移 0xD1 数据3字节 | 状态 0xD2 数据3字节 | 温度 0xD3 数据1字节
 *   电压 0xD4 数据2字节 | 版本 0xD5 数据3字节
 *
 * 硬件: pin26(E5)=UART1_TX 输出，接接收端/采集模块的 RX（TTL 交叉连接）
 *
 * 编译：gcc -O2 -o rs422_send rs422_send.c
 * 运行：sudo ./rs422_send [轮数] [帧间隔ms]
 *       默认 10 轮，每轮依次发送 D1~D5 五种报文，帧间隔 200ms
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdint.h>

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

#define SR_TXEMPTY  0x08

/* 协议常量 */
#define FRAME_HEAD  0x55
#define CMD_DISPLACEMENT 0xD1   /* 位移信息，3字节数据 */
#define CMD_STATUS       0xD2   /* 状态信息，3字节数据 */
#define CMD_TEMP         0xD3   /* 温度，1字节数据 */
#define CMD_VOLTAGE      0xD4   /* 电压，2字节数据 */
#define CMD_VERSION      0xD5   /* 版本，3字节数据 */

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

/* 组装一帧：帧头 + 标识 + 有效数据 + 校验和，返回帧总长 */
static int build_frame(uint8_t cmd, const uint8_t *d, int dlen, uint8_t *f)
{
    uint32_t s = FRAME_HEAD + cmd;   /* 校验和从帧头+标识开始累加 */
    int i;
    f[0] = FRAME_HEAD;
    f[1] = cmd;
    for (i = 0; i < dlen; i++) {
        f[2 + i] = d[i];
        s += d[i];
    }
    int total = 2 + dlen + 1;
    f[total - 1] = (uint8_t)(s & 0xFF);   /* 累加取低8位 */
    return total;
}

/* 发送一帧：逐字节写 FIFO，再等 TX 空闲 */
static void send_frame(volatile uint32_t *uart, const uint8_t *f, int len)
{
    int i;
    for (i = 0; i < len; i++)
        wr(uart, FIFO, f[i]);
    int wait = 0;
    while (!(rd(uart, SR) & SR_TXEMPTY)) {
        if (++wait > 1000000) { printf("[警告] TX 等待超时\n"); break; }
    }
}

static void dump_hex(const uint8_t *f, int len)
{
    int i;
    for (i = 0; i < len; i++) printf("%02X ", f[i]);
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IOLBF, 0);
    int rounds = (argc > 1) ? atoi(argv[1]) : 10;
    int interval_ms = (argc > 2) ? atoi(argv[2]) : 200;
    if (rounds < 1) rounds = 1;
    if (interval_ms < 0) interval_ms = 200;

    printf("=== RS422 协议帧发送程序（寄存器级）===\n");
    printf("波特率: 115200 8N1  轮数: %d  帧间隔: %dms\n\n", rounds, interval_ms);

    /* 1. 切 MIO49/48 -> GPIO（与接收端一致，避免 MIO 与 EMIO 冲突） */
    volatile uint32_t *slcr = map_phys(SLCR_BASE);
    if (!slcr) return 1;
    wr(slcr, 0x008, 0xDF0D);   /* UNLOCK */
    __sync_synchronize();
    wr(slcr, 0x7C0, 0x1200);   /* MIO48 -> GPIO */
    wr(slcr, 0x7C4, 0x1200);   /* MIO49 -> GPIO */
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);   /* LOCK */
    __sync_synchronize();

    /* 2. mmap UART1，禁中断，NORMAL 模式 */
    volatile uint32_t *uart = map_phys(UART1_BASE);
    if (!uart) return 1;
    wr(uart, IDR, 0xFFFFFFFF);   /* 禁中断，防止 tty 驱动抢占 */
    wr(uart, MR, 0x20);          /* NORMAL（无回环） */

    printf("UART1 就绪，开始发送...\n\n");

    /* 3. 循环发送：每轮依次发 D1~D5 五种报文 */
    int r;
    for (r = 0; r < rounds; r++) {
        uint8_t f[8];
        uint8_t d[3];
        int len;

        /* 位移 D1（3字节）：左键交替，X/Y 位移随轮次变化 */
        d[0] = (uint8_t)((r & 1) ? 0x01 : 0x00);
        d[1] = (uint8_t)((int8_t)((r % 30) - 15));
        d[2] = (uint8_t)((int8_t)(((r * 3) % 20) - 10));
        len = build_frame(CMD_DISPLACEMENT, d, 3, f);
        send_frame(uart, f, len);
        printf("[#%d] 位移  ", r + 1); dump_hex(f, len); printf("\n");
        usleep(interval_ms * 1000);

        /* 状态 D2（3字节）：bit6=1 Remote，分辨率2，采样率1 */
        d[0] = 0x40; d[1] = 0x02; d[2] = 0x01;
        len = build_frame(CMD_STATUS, d, 3, f);
        send_frame(uart, f, len);
        printf("[#%d] 状态  ", r + 1); dump_hex(f, len); printf("\n");
        usleep(interval_ms * 1000);

        /* 温度 D3（1字节）：37℃（0x25） */
        d[0] = 0x25;
        len = build_frame(CMD_TEMP, d, 1, f);
        send_frame(uart, f, len);
        printf("[#%d] 温度  ", r + 1); dump_hex(f, len); printf("\n");
        usleep(interval_ms * 1000);

        /* 电压 D4（2字节）：0x0140=320 => 3.2V */
        d[0] = 0x40; d[1] = 0x01;
        len = build_frame(CMD_VOLTAGE, d, 2, f);
        send_frame(uart, f, len);
        printf("[#%d] 电压  ", r + 1); dump_hex(f, len); printf("\n");
        usleep(interval_ms * 1000);

        /* 版本 D5（3字节）：2.01 */
        d[0] = 0x02; d[1] = 0x00; d[2] = 0x01;
        len = build_frame(CMD_VERSION, d, 3, f);
        send_frame(uart, f, len);
        printf("[#%d] 版本  ", r + 1); dump_hex(f, len); printf("\n");
        usleep(interval_ms * 1000);
    }

    printf("\n=== 发送完成：共 %d 帧（%d 轮 x 5 种报文）===\n", rounds * 5, rounds);
    return 0;
}