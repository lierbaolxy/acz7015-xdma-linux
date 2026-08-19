/*
 * rs422_verify.c - RS422 回环自测（PS端 C 版，直接寄存器操作）
 *
 * 与 rs422_verify.py 完全等价：
 *   1) 写 SLCR 把 MIO49/48 切为 GPIO，释放 UART1 EMIO RX 被 MIO49
 *      恒高电平污染的根因（UART1 RX = MIO49 | EMIO_RX 相或）
 *   2) 直接 mmap UART1 寄存器，禁中断后轮询 FIFO 收发（不用 tty 驱动，
 *      因为 tty 的 RX 中断路径在 EMIO 下不触发）
 *
 * 编译：gcc -O2 -o rs422_verify rs422_verify.c
 * 运行：sudo ./rs422_verify [轮数]   （默认 20 轮）
 * 前置：先停 console：sudo systemctl stop serial-getty@ttyPS0.service
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <stdint.h>

#define SLCR_BASE  0xF8000000UL
#define UART1_BASE 0xE0001000UL
#define MAP_SIZE   0x1000UL

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

static volatile uint32_t *slcr = NULL;
static volatile uint32_t *uart = NULL;

/* mmap 一段物理地址，返回按目标基址对齐的指针 */
static volatile uint32_t *map_phys(uint32_t base, int *fd_out)
{
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open /dev/mem"); return NULL; }
    void *p = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
                   fd, base & ~(MAP_SIZE - 1));
    if (p == MAP_FAILED) { perror("mmap"); close(fd); return NULL; }
    *fd_out = fd;
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

/* 清空 RX FIFO */
static int drain_rx(void)
{
    int n = 0;
    while (!(rd(uart, SR) & SR_RXEMPTY)) {
        rd(uart, FIFO);
        if (++n > 64) break;
    }
    return n;
}

static int switch_mio_to_gpio(void)
{
    int fd = -1;
    slcr = map_phys(SLCR_BASE, &fd);
    if (!slcr) return -1;

    printf("[SLCR] 切换前 MIO48=0x%X  MIO49=0x%X\n",
           rd(slcr, 0x7C0), rd(slcr, 0x7C4));

    wr(slcr, 0x008, 0xDF0D);   /* UNLOCK */
    __sync_synchronize();
    wr(slcr, 0x7C4, 0x1200);   /* MIO49 -> GPIO */
    wr(slcr, 0x7C0, 0x1200);   /* MIO48 -> GPIO */
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);   /* LOCK */
    __sync_synchronize();

    printf("[SLCR] 切换后 MIO48=0x%X  MIO49=0x%X\n",
           rd(slcr, 0x7C0), rd(slcr, 0x7C4));
    return 0;
}

/* 单轮回环测试：发 6 字节并读回比对 */
static int one_round(int i)
{
    uint8_t tx[6] = {0x55, 0xD1, (uint8_t)(i & 0xFF), 0x20, 0x30, 0x86};
    uint8_t rx[6] = {0};
    int got = 0, k;

    drain_rx();

    for (k = 0; k < 6; k++)
        wr(uart, FIFO, tx[k]);

    /* 等发送完成 */
    int t = 0;
    while (!(rd(uart, SR) & SR_TXEMPTY)) {
        usleep(500);
        if (++t > 2000) return 0;   /* 1s 超时 */
    }

    /* 等 RX 有数据 */
    t = 0;
    while (rd(uart, SR) & SR_RXEMPTY) {
        usleep(500);
        if (++t > 2000) return 0;   /* 1s 超时 */
    }

    /* 读回 */
    t = 0;
    while (!(rd(uart, SR) & SR_RXEMPTY) && got < 16) {
        rx[got] = rd(uart, FIFO) & 0xFF;
        got++;
        if (++t > 600) break;
    }

    return got >= 6 && memcmp(tx, rx, 6) == 0;
}

int main(int argc, char *argv[])
{
    int rounds = (argc > 1) ? atoi(argv[1]) : 20;
    if (rounds <= 0) rounds = 20;

    printf("=== RS422 回环自测 (C版寄存器级, %d 轮) ===\n", rounds);

    if (switch_mio_to_gpio() < 0)
        return 1;

    /* mmap UART1 */
    int fd = -1;
    uart = map_phys(UART1_BASE, &fd);
    if (!uart) return 1;

    /* 禁中断（防止 tty 驱动 RX 中断抢 FIFO） */
    wr(uart, IDR, 0xFFFFFFFF);
    wr(uart, MR, 0x20);   /* NORMAL 模式，无回环 */

    printf("UART1 就绪, 确认 pin26(TX)<->pin28(RX) 已短接\n\n");

    int pass = 0;
    for (int i = 0; i < rounds; i++) {
        int ok = one_round(i);
        if (ok) pass++;
        printf("第%02d轮: %s  TX=55D1%02X203086\n",
               i + 1, ok ? "PASS" : "FAIL", i & 0xFF);
        usleep(30000);
    }

    printf("\n=== 结果: %d/%d %s ===\n", pass, rounds,
           pass == rounds ? "全部通过 (链路正常)" : "未全通过 (检查接线)");

    wr(uart, MR, 0x20);
    return pass == rounds ? 0 : 2;
}