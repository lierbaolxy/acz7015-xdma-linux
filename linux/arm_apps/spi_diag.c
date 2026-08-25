/*
 * spi_diag.c - MCP2518FD SPI 链路诊断（读多个已知复位值寄存器 + 双模式对比）
 * 编译：gcc -O2 -o spi_diag spi_diag.c
 * 运行：sudo ./spi_diag
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define SPI0_BASE       0xE0006000
#define SLCR_BASE       0xF8000000
#define SLCR_OFF_UNLOCK 0x008
#define SLCR_OFF_LOCK   0x004
#define SLCR_APER_CLK_CTRL 0x12C
#define SLCR_SPI_CLK_CTRL  0x158
#define SLCR_SPI_RST_CTRL  0x21C
#define SLCR_UNLOCK_KEY 0xDF0D
#define SLCR_LOCK_KEY   0x767B

#define CR_OFF 0x00
#define SR_OFF 0x04
#define ER_OFF 0x14
#define TXD_OFF 0x1C
#define RXD_OFF 0x20

#define TXFULL  0x08
#define RXNEMPTY 0x10
#define MSTREN  0x00000001U
#define SSFORCE 0x00004000U
#define SSCTRL_NOSS (0xF << 10)
#define SSCTRL_SS0  (0xE << 10)

static volatile uint32_t *spi0 = NULL;
static volatile uint32_t *slcr = NULL;
static uint32_t cr_base = 0;

static void *mapd(uint32_t base, size_t len) {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    void *p;
    if (fd < 0) { perror("open"); return NULL; }
    p = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, base);
    close(fd);
    if (p == MAP_FAILED) return NULL;
    return p;
}

static void spwr(uint32_t off, uint32_t v) { spi0[off/4] = v; }
static uint32_t sprd(uint32_t off) { return spi0[off/4]; }

static void spi_init(int cpol, int cpha, int div) {
    uint32_t v = MSTREN | SSFORCE | ((uint32_t)(div & 7) << 3) | SSCTRL_NOSS;
    if (cpol) v |= 0x02;  /* CPOL bit1 */
    if (cpha) v |= 0x04;  /* CPHA bit2 */
    cr_base = v;
    spwr(CR_OFF, cr_base);
    spwr(ER_OFF, 0x01);
}

static int spi_xfer(const uint8_t *tx, uint8_t *rx, int len) {
    int i;
    spwr(CR_OFF, (cr_base & ~(0xF << 10)) | SSCTRL_SS0);
    for (i = 0; i < len; i++) {
        int t = 2000000;
        while ((sprd(SR_OFF) & TXFULL) && --t);
        if (t <= 0) { spwr(CR_OFF, cr_base); return -1; }
        spwr(TXD_OFF, tx ? tx[i] : 0x00);
    }
    for (i = 0; i < len; i++) {
        int t = 2000000;
        while (!(sprd(SR_OFF) & RXNEMPTY) && --t);
        if (rx) rx[i] = (uint8_t)(sprd(RXD_OFF) & 0xFF);
        else (void)sprd(RXD_OFF);
    }
    spwr(CR_OFF, cr_base);
    return 0;
}

static void reset(void) {
    uint8_t tx[2] = {0,0}, rx[2];
    spi_xfer(tx, rx, 2);
    usleep(10000);
}

static void read_reg(uint16_t addr, uint8_t *buf, int len) {
    uint8_t tx[64] = {0}, rx[64] = {0};
    uint16_t instr = 0x3000 | (addr & 0x0FFF);
    tx[0] = (uint8_t)(instr >> 8);
    tx[1] = (uint8_t)(instr & 0xFF);
    spi_xfer(tx, rx, 2 + len);
    memcpy(buf, rx + 2, len);
}

static void dump_regs(const char *tag) {
    uint8_t b[4];
    struct { uint16_t addr; const char *name; } regs[] = {
        {0xE00, "OSC  "}, {0xE04, "IOCON"}, {0xE08, "CRC  "},
        {0xE0C, "ECCCON"}, {0xE14, "DEVID"},
        {0x000, "C1CON"}, {0x004, "C1NBTCFG"},
    };
    int i;
    printf("--- %s ---\n", tag);
    for (i = 0; i < (int)(sizeof(regs)/sizeof(regs[0])); i++) {
        read_reg(regs[i].addr, b, 4);
        printf("  %s(0x%03X)= %02X %02X %02X %02X\n", regs[i].name, regs[i].addr,
               b[0], b[1], b[2], b[3]);
    }
}

int main(void) {
    setvbuf(stdout, NULL, _IOLBF, 0);

    slcr = (volatile uint32_t *)mapd(SLCR_BASE, 0x1000);
    if (!slcr) { printf("mmap SLCR fail\n"); return 1; }
    slcr[SLCR_OFF_UNLOCK/4] = SLCR_UNLOCK_KEY;
    slcr[SLCR_APER_CLK_CTRL/4] |= (1u << 14);
    slcr[SLCR_SPI_CLK_CTRL/4]  |= (1u << 0);
    slcr[SLCR_OFF_LOCK/4] = SLCR_LOCK_KEY;
    usleep(50000);
    slcr[SLCR_OFF_UNLOCK/4] = SLCR_UNLOCK_KEY;
    slcr[SLCR_SPI_RST_CTRL/4] |= (1u << 0);
    usleep(10000);
    slcr[SLCR_SPI_RST_CTRL/4] &= ~(1u << 0);
    slcr[SLCR_OFF_LOCK/4] = SLCR_LOCK_KEY;
    usleep(50000);

    spi0 = (volatile uint32_t *)mapd(SPI0_BASE, 0x1000);
    if (!spi0) { printf("mmap SPI0 fail\n"); return 1; }

    /* 模式1：mode0(CPOL0/CPHA0) div=7 */
    spi_init(0, 0, 7);
    reset();
    dump_regs("mode0 div7");

    /* 模式2：mode3(CPOL1/CPHA1) div=7 */
    spi_init(1, 1, 7);
    reset();
    dump_regs("mode3 div7");

    /* 模式3：mode0 div=31（最慢） */
    spi_init(0, 0, 31);
    reset();
    dump_regs("mode0 div31");

    /* 模式4：mode0 div=127（最慢） */
    spi_init(0, 0, 127);
    reset();
    dump_regs("mode0 div127");

    printf("DONE\n");
    return 0;
}