/*
 * rs422_emio_test.c - UART1 EMIO切换 + 回环测试（一体工具）
 *
 * 用法: sudo ./rs422_emio_test [loop|keep]
 *   loop = 测试完成后切回MIO模式（默认，安全）
 *   keep = 测试后保持EMIO模式（供后续收发测试）
 *
 * 前置条件: bitstream含E5(TX)/B1(RX) EMIO布线（194dd82e版）
 * 硬件: 排针pin26(E5)↔pin28(B1)短接（或TTL模块RS422侧Y-A/Z-B短接）
 *
 * 关键原理（此前所有回环失败的根因）:
 *   UART1 CTRL(0xE0001000) bits[1:0]: 00=MIO 10=EMIO
 *   FSBL设MIO做console，Linux驱动不切换 → 必须运行时写寄存器切EMIO
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <errno.h>
#include <sys/mman.h>

#define UART1_CTRL   0xE0001000
#define UART1_MODE   0xE0001004
#define UART1_STATUS 0xE000102C
#define PAGE_SIZE    4096UL

static int mem_fd;
static volatile unsigned int *uart1_ctrl;

/* mmap物理地址 */
static int map_uart1(void)
{
    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) { perror("open /dev/mem"); return -1; }
    void *base = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
                      mem_fd, UART1_CTRL & ~(PAGE_SIZE - 1));
    if (base == MAP_FAILED) { perror("mmap"); close(mem_fd); return -1; }
    uart1_ctrl = (volatile unsigned int *)((char *)base + (UART1_CTRL & (PAGE_SIZE - 1)));
    return 0;
}

static void unmap_uart1(void)
{
    if (uart1_ctrl) {
        void *base = (void *)((unsigned long)uart1_ctrl & ~(PAGE_SIZE - 1));
        munmap(base, PAGE_SIZE);
    }
    if (mem_fd >= 0) close(mem_fd);
}

/* 读UART1寄存器（CTRL在基址，STATUS在基址+0x2C） */
static inline unsigned int rd_reg(unsigned off)
{
    return *(volatile unsigned int *)((char *)uart1_ctrl - (UART1_CTRL & (PAGE_SIZE-1))
                                      + (UART1_CTRL & ~(PAGE_SIZE-1)) + off - UART1_CTRL);
}

int main(int argc, char **argv)
{
    int keep_emio = (argc > 1 && strcmp(argv[1], "keep") == 0);
    unsigned int ctrl_orig, ctrl_val;
    int fd, i, pass = 0, total = 10;

    printf("=== UART1 EMIO切换 + 回环测试 ===\n");

    /* 1. mmap UART1 */
    if (map_uart1() < 0) return 1;
    ctrl_orig = *uart1_ctrl;
    printf("UART1 CTRL = 0x%08X (mode=%s)\n", ctrl_orig,
           (ctrl_orig & 3) == 2 ? "EMIO" : ((ctrl_orig & 3) == 0 ? "MIO" : "?"));

    /* 2. 切EMIO: bits[1:0] = 10 */
    ctrl_val = (ctrl_orig & ~3U) | 2U;
    *uart1_ctrl = ctrl_val;
    printf("已切换 CTRL = 0x%08X (mode=%s)\n", *uart1_ctrl,
           (*uart1_ctrl & 3) == 2 ? "EMIO" : "FAIL!");

    /* 3. 打开串口 */
    fd = open("/dev/ttyPS0", O_RDWR | O_NOCTTY);
    if (fd < 0) { perror("open ttyPS0"); goto out; }

    struct termios tio;
    tcgetattr(fd, &tio);
    cfmakeraw(&tio);
    tio.c_cflag |= (CLOCAL | CREAD);
    tio.c_cc[VMIN] = 0; tio.c_cc[VTIME] = 1;   /* 100ms超时 */
    cfsetispeed(&tio, B115200);
    cfsetospeed(&tio, B115200);
    tcsetattr(fd, TCSANOW, &tio);
    tcflush(fd, TCIOFLUSH);

    /* 4. 回环10次 */
    printf("\n开始回环测试 %d 次（确认pin26↔pin28已短接）...\n", total);
    for (i = 1; i <= total; i++) {
        unsigned char tx[6], rx[6];
        unsigned char sum = 0;
        tx[0] = 0x55; tx[1] = 0xD0 + (i % 5);
        tx[2] = i; tx[3] = 0x20 + i; tx[4] = 0x30 + i;
        for (int k = 0; k < 5; k++) sum += tx[k];
        tx[5] = sum;

        int n = write(fd, tx, 6);
        usleep(20000);                          /* 等200ms内回显 */

        memset(rx, 0, sizeof(rx));
        int got = 0;
        while (got < 6) {
            int r = read(fd, rx + got, 6 - got);
            if (r <= 0) break;
            got += r;
        }

        int ok = (got == 6 && memcmp(tx, rx, 6) == 0);
        if (ok) pass++;
        printf("[#%2d] TX:%02X%02X%02X%02X%02X%02X RX:%s %s\n", i,
               tx[0],tx[1],tx[2],tx[3],tx[4],tx[5],
               got ? "" : "(无)",
               ok ? "PASS" : "FAIL");
        if (!ok && got > 0)
            printf("      RX实际: %02X %02X %02X %02X %02X %02X\n",
                   rx[0],rx[1],rx[2],rx[3],rx[4],rx[5]);
    }

    printf("\n结果: %d/%d %s\n", pass, total, pass == total ? "全部通过" : "未通过");

    close(fd);

    /* 5. 恢复模式 */
    if (keep_emio) {
        printf("保持EMIO模式（CTRL=0x%08X）\n", *uart1_ctrl);
    } else {
        *uart1_ctrl = ctrl_orig;
        printf("已恢复MIO模式（CTRL=0x%08X），console可继续使用\n", *uart1_ctrl);
    }

out:
    unmap_uart1();
    return pass == total ? 0 : 2;
}
