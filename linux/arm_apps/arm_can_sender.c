/*
 * arm_can_sender.c - CAN 数据采集程序（PS 端 Linux，寄存器级 SPI 访问）
 *
 * 功能：通过 PS SPI0（EMIO，/dev/mem 寄存器级访问，不依赖 spidev）读取
 *       小梅哥 ACM_CANFD_RS485 模块上的 MCP2518FD 芯片，解析 CAN 2.0B
 *       扩展帧，按项目协议封装写入 DDR 共享内存 CAN 槽位（0x20000020，
 *       device_id=1），供 PC 端经 XDMA 读取。
 *
 * 为何寄存器级访问（绕过 spidev）：
 *   板卡内核未开启 CONFIG_SPI_SPIDEV，无法生成 /dev/spidev0.0。
 *   直接 mmap /dev/mem 访问 XSPIPS 寄存器，已在 spi_xfer_test.py 验证链路可用。
 *
 * 关键修正（对照 Linux 内核 mcp251xfd 驱动 + DS20006027A/DS20006134）：
 *   - MCP2518FD 使用 16 位 SPI 指令字（READ=0x3<<12|addr, WRITE=0x2<<12|addr），
 *     不是 MCP2515 的 0x03/0x02 字节命令（旧代码此处有误）。
 *   - 寄存器基址：C1CON=0x000、C1NBTCFG=0x004、C1DBTCFG=0x008、C1TDC=0x00C、
 *     C1TBC=0x010、C1TSCON=0x014、C1VEC=0x018、C1INT=0x01C、C1RXIF=0x020、
 *     C1TEFCON=0x040、C1TXQCON=0x050、C1FIFOCON(x)=0x050+0xC*x、
 *     C1FIFOSTA(x)=0x054+0xC*x、C1FIFOUA(x)=0x058+0xC*x、
 *     C1FLTCON(x)=0x1D0+0x4*x、C1FLTOBJ(x)=0x1F0+0x8*x、C1FLTMASK(x)=0x1F4+0x8*x、
 *     RAM 起始 0x400、OSC=0xE00、IOCON=0xE04、DEVID=0xE14。
 *
 * 硬件连接（小梅哥模块扣 40pin 排针，1 脚对齐）：
 *   SPI0 : SCK=C4 MOSI=D5 MISO=G8 SS=C8
 *   GPIO : B7/B6/G7/G6/F6/G3/C1/B2（AXI GPIO 8 位，中断 + RS485 方向）
 *   RS485: UART1 TX=E5 RX=B1
 *
 * 前置条件：
 *   1. bitstream 已启用 SPI0 EMIO（当前 CAN 版已启用）
 *   2. 运行前：sudo systemctl stop serial-getty@ttyPS0.service
 *
 * 编译：arm-xilinx-linux-gnueabi-gcc -O2 -o arm_can_sender arm_can_sender.c
 * 运行：sudo ./arm_can_sender
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <time.h>
#include <sys/syscall.h>

/* ===== DDR 共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    4096
#define SLOT_CAN    0x20            /* CAN 槽位偏移 0x20000020 */
#define DEV_CAN     1

/* ===== AXI GPIO（控制 CAN 中断输入 + RS485 方向）===== */
#define AXI_GPIO_BASE   0x41200000
#define AXI_GPIO_DATA   0x00
#define AXI_GPIO_TRI    0x04
#define GPIO_TRI_DIR    0x3F          /* bit0-5=输入(INT)，bit6-7=输出(RE) */
#define RS485_RX_MODE   0x00
#define RS485_TX_MODE   0xC0

/* ===== PS SPI0 (XSPIPS) 寄存器（xspips_hw.h 权威偏移）===== */
#define SPI0_BASE       0xE0006000
#define XSPIPS_CR_OFF   0x00
#define XSPIPS_SR_OFF   0x04
#define XSPIPS_ER_OFF   0x14
#define XSPIPS_TXD_OFF  0x1C
#define XSPIPS_RXD_OFF  0x20

#define XSPIPS_CR_MSTREN_MASK   0x00000001U
#define XSPIPS_CR_PRESC_MASK    0x00000038U  /* bits[5:3] */
#define XSPIPS_CR_MODF_GEN_EN   0x00020000U
#define XSPIPS_SR_TXFULL_MASK   0x00000008U  /* bit3 */
#define XSPIPS_SR_RXNEMPTY_MASK 0x00000010U  /* bit4 */
#define XSPIPS_ER_ENABLE_MASK   0x00000001U

/* ===== SLCR 寄存器（SPI0 时钟/复位使能，值经验证）===== */
#define SLCR_BASE       0xF8000000
#define SLCR_OFF_UNLOCK 0x008
#define SLCR_OFF_LOCK   0x004
#define SLCR_APER_CLK_CTRL  0x12C
#define SLCR_SPI_CLK_CTRL   0x158
#define SLCR_SPI_RST_CTRL   0x21C
#define SLCR_UNLOCK_KEY 0xDF0D
#define SLCR_LOCK_KEY   0x767B

/* ===== MCP2518FD SPI 指令（16 位指令字）===== */
#define MCP2518_INSTR_RESET  0x0000
#define MCP2518_INSTR_WRITE  0x2000
#define MCP2518_INSTR_READ   0x3000
#define MCP2518_ADDR_MASK    0x0FFF

/* ===== MCP2518FD 寄存器（Linux mcp251xfd 驱动权威地址）===== */
#define MCP2518_REG_C1CON     0x000
#define MCP2518_REG_C1NBTCFG  0x004
#define MCP2518_REG_C1INT     0x01C
#define MCP2518_REG_C1TEFCON  0x040
#define MCP2518_REG_C1TXQCON  0x050
#define MCP2518_REG_FIFOCON(x) (0x050 + 0xC * (x))
#define MCP2518_REG_FIFOSTA(x) (0x054 + 0xC * (x))
#define MCP2518_REG_FIFOUA(x)  (0x058 + 0xC * (x))
#define MCP2518_REG_FLTCON(x)  (0x1D0 + 0x4 * (x))
#define MCP2518_REG_FLTOBJ(x)  (0x1F0 + 0x8 * (x))
#define MCP2518_REG_FLTMASK(x) (0x1F4 + 0x8 * (x))
#define MCP2518_REG_OSC        0xE00
#define MCP2518_REG_IOCON      0xE04
#define MCP2518_REG_DEVID      0xE14

/* FIFOCON 位定义 */
#define FIFOCON_PLSIZE_MASK    0xE0000000U    /* bits[31:29] */
#define FIFOCON_FSIZE_MASK     0x1F000000U    /* bits[28:24] */
#define FIFOCON_TXEN           0x00000080U    /* bit7 */
#define FIFOCON_FRESET         0x00000400U    /* bit10 */
#define FIFOCON_UINC           0x00000100U    /* bit8 */

/* FIFOSTA 位定义 */
#define FIFOSTA_TFNRFNIF       0x00000001U    /* FIFO 非空 */

/* 中断位（C1INT，32 位） */
#define C1INT_RXIE             0x00020000U    /* bit17 */
#define C1INT_RXIF             0x00000002U    /* bit1 */

/* FLTCON/FLTOBJ/FLTMASK 位定义 */
#define FLTCON_FLTEN(x)        (0x80U << (8 * ((x) & 0x3)))
#define FLTCON_FBP(x, fifo)    ((uint32_t)(fifo) << (8 * ((x) & 0x3)))
#define FLTMASK_MIDE            0x40000000U    /* bit30：屏蔽 IDE 比较 */

/* 操作模式：REQOP=请求模式(bits[26:24])，OPMOD=当前模式(bits[23:21]) */
#define OPMODE_OPMOD_MASK      0x00E00000U    /* bits[23:21] */
#define REQOP_MIXED            0x00000000U    /* 0<<24 混合(正常)模式 */
#define REQOP_INT_LOOPBACK     0x02000000U    /* 2<<24 内部回环 */
#define REQOP_CONFIG           0x04000000U    /* 4<<24 配置模式 */
#define OPMOD_MIXED            0x00000000U
#define OPMOD_INT_LOOPBACK     (2U << 21)     /* 0x00400000 */
#define OPMOD_CONFIG           (4U << 21)     /* 0x00800000 */

/* ===== CAN 波特率/时钟配置（需按模块晶振核对！）=====
 * 小梅哥 ACM_CANFD_RS485 模块晶振常见为 40MHz（也支持 20MHz）。
 * 默认不使能 PLL、直接用晶振作为 SYSCLK（40/20MHz 通用）。
 * 若晶振为 4MHz，需改 OSC=0x01(PLL×10) 且 SYSCLK=40MHz。
 * 回环自检(loopback)收发用同一内部时钟，晶振为准 40 还是 20MHz 不影响自检通过。*/
#define CAN_SYSCLK_HZ          40000000UL   /* 默认按 40MHz 晶振计算位时序 */
#define CAN_NOMINAL_BPS        500000UL
#define OSC_CONFIG             0x00U        /* 不使能PLL，直接用晶振 */

/* 协议帧 ID（29 位扩展帧）*/
#define CAN_ID_TRACKBALL      0x01180118
#define CAN_ID_VER_QUERY      0x01180119
#define CAN_ID_VER_REPLY      0x01180117
#define CAN_ID_PBIT           0x01180116
#define CAN_ID_MODEL          0x01180115

/* SPI 单次事务最大字节（2 指令 + 76 消息对象）*/
#define MAX_SPI_XFER          96

/* 统一 DDR 转发槽位格式（32 字节，对齐 cache line）*/
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

/* ===== 全局映射指针 ===== */
static volatile uint32_t *spi0 = NULL;
static volatile uint32_t *slcr = NULL;
static volatile uint32_t *axi_gpio_reg = NULL;
static volatile share_slot_t *can_slot = NULL;
static uint32_t can_seq = 0;
static uint32_t g_sysclk = CAN_SYSCLK_HZ;   /* 可被 -s 参数覆盖 */

static inline uint32_t sprd(uint32_t off) { return spi0[off / 4]; }
static inline void     spwr(uint32_t off, uint32_t v) { spi0[off / 4] = v; }

/* ===== /dev/mem mmap 辅助 ===== */
static void *map_devmem(uint32_t base, size_t len, const char *name)
{
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    void *p;
    if (fd < 0) { perror("open /dev/mem"); return NULL; }
    p = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, base);
    close(fd);
    if (p == MAP_FAILED) { fprintf(stderr, "[FAIL] mmap %s\n", name); return NULL; }
    printf("[OK] 映射 %s @ 0x%08X\n", name, base);
    return p;
}

/* ===== SLCR：使能 SPI0 时钟/释放复位（值经验证）===== */
static int init_spi0_clock(void)
{
    slcr = (volatile uint32_t *)map_devmem(SLCR_BASE, 0x1000, "SLCR");
    if (!slcr) return -1;

    slcr[SLCR_OFF_UNLOCK / 4] = SLCR_UNLOCK_KEY;
    slcr[SLCR_APER_CLK_CTRL / 4] = 0x01EC400D;   /* bit14 = SPI0 时钟激活 */
    slcr[SLCR_SPI_CLK_CTRL / 4]  = 0x00003F01;   /* bit0 = SPI0 使能 */
    slcr[SLCR_OFF_LOCK / 4] = SLCR_LOCK_KEY;
    usleep(50000);

    slcr[SLCR_OFF_UNLOCK / 4] = SLCR_UNLOCK_KEY;
    slcr[SLCR_SPI_RST_CTRL / 4] = 0xF;           /* 复位 SPI0 */
    usleep(10000);
    slcr[SLCR_SPI_RST_CTRL / 4] = 0x0;           /* 释放复位 */
    slcr[SLCR_OFF_LOCK / 4] = SLCR_LOCK_KEY;
    usleep(50000);
    return 0;
}

/* ===== XSPIPS 初始化（主模式、mode0、预分频）===== */
static int init_spi0_controller(void)
{
    spi0 = (volatile uint32_t *)map_devmem(SPI0_BASE, 0x1000, "SPI0");
    if (!spi0) return -1;

    /* MSTREN | PRESC=3 | MODF_GEN_EN（mode0：CPOL=0, CPHA=0）*/
    uint32_t cr = XSPIPS_CR_MSTREN_MASK | (3 << 3) | XSPIPS_CR_MODF_GEN_EN;
    spwr(XSPIPS_CR_OFF, cr);
    printf("SPI0 CR = 0x%08X\n", sprd(XSPIPS_CR_OFF));

    spwr(XSPIPS_ER_OFF, XSPIPS_ER_ENABLE_MASK);   /* 使能 SPI */
    return 0;
}

/* ===== SPI 全双工事务（写满整个事务再读回，保持 CS 拉低）===== */
static int spi_xfer(const uint8_t *tx, uint8_t *rx, int len)
{
    int i;
    if (len > MAX_SPI_XFER) return -1;

    /* 1. 连续写入 TX FIFO（TX FIFO 不空 => SS 保持拉低，跨整个事务）*/
    for (i = 0; i < len; i++) {
        int t = 2000000;
        while ((sprd(XSPIPS_SR_OFF) & XSPIPS_SR_TXFULL_MASK) && --t) ;
        if (t <= 0) { fprintf(stderr, "SPI TX 超时\n"); return -1; }
        spwr(XSPIPS_TXD_OFF, tx ? tx[i] : 0x00);
    }

    /* 2. 读回同样字节数 */
    for (i = 0; i < len; i++) {
        int t = 2000000;
        while (!(sprd(XSPIPS_SR_OFF) & XSPIPS_SR_RXNEMPTY_MASK) && --t) ;
        if (t <= 0) { fprintf(stderr, "SPI RX 超时\n"); return -1; }
        if (rx) rx[i] = (uint8_t)(sprd(XSPIPS_RXD_OFF) & 0xFF);
        else    (void)sprd(XSPIPS_RXD_OFF);
    }
    return 0;
}

/* ===== MCP2518FD 寄存器读写（16 位指令字 + 小端数据）===== */
static int mcp2518_reset(void)
{
    uint8_t tx[2] = {0x00, 0x00};   /* RESET 指令 = 0x0000 */
    uint8_t rx[2];
    if (spi_xfer(tx, rx, 2) < 0) return -1;
    usleep(10000);                  /* 复位稳定 */
    return 0;
}

static int mcp2518_read_reg(uint16_t addr, uint8_t *buf, int len)
{
    uint8_t tx[MAX_SPI_XFER] = {0};
    uint8_t rx[MAX_SPI_XFER] = {0};
    uint16_t instr = MCP2518_INSTR_READ | (addr & MCP2518_ADDR_MASK);

    tx[0] = (uint8_t)(instr >> 8);
    tx[1] = (uint8_t)(instr & 0xFF);
    memset(tx + 2, 0, len);                 /* 数据以 0 填充（dummy clock）*/
    if (spi_xfer(tx, rx, 2 + len) < 0) return -1;
    memcpy(buf, rx + 2, len);
    return 0;
}

static int mcp2518_write_reg(uint16_t addr, const uint8_t *buf, int len)
{
    uint8_t tx[MAX_SPI_XFER] = {0};
    uint8_t rx[MAX_SPI_XFER] = {0};
    uint16_t instr = MCP2518_INSTR_WRITE | (addr & MCP2518_ADDR_MASK);

    tx[0] = (uint8_t)(instr >> 8);
    tx[1] = (uint8_t)(instr & 0xFF);
    memcpy(tx + 2, buf, len);
    if (spi_xfer(tx, rx, 2 + len) < 0) return -1;
    return 0;
}

static uint32_t mcp2518_read32(uint16_t addr)
{
    uint8_t b[4] = {0};
    if (mcp2518_read_reg(addr, b, 4) < 0) return 0;
    return (uint32_t)b[0] | ((uint32_t)b[1] << 8) |
           ((uint32_t)b[2] << 16) | ((uint32_t)b[3] << 24);
}

static void mcp2518_write32(uint16_t addr, uint32_t val)
{
    uint8_t b[4];
    b[0] = (uint8_t)(val & 0xFF);
    b[1] = (uint8_t)((val >> 8) & 0xFF);
    b[2] = (uint8_t)((val >> 16) & 0xFF);
    b[3] = (uint8_t)((val >> 24) & 0xFF);
    mcp2518_write_reg(addr, b, 4);
}

/* ===== 模式切换：写 REQOP、轮询 OPMOD（修正旧代码 OPMOD 掩码比较错误）===== */
static int mcp2518_set_mode(uint32_t reqop, uint32_t opmod_expect)
{
    int retry;
    uint32_t v = 0;

    mcp2518_write32(MCP2518_REG_C1CON, reqop);
    for (retry = 0; retry < 100; retry++) {
        usleep(1000);
        v = mcp2518_read32(MCP2518_REG_C1CON);
        if ((v & OPMODE_OPMOD_MASK) == opmod_expect)
            return 0;
    }
    printf("[FAIL] 模式切换超时 (C1CON=0x%08X)\n", v);
    return -1;
}

/* ===== AXI GPIO 初始化（RS485 方向，默认接收 = 安全）===== */
static int init_axi_gpio(void)
{
    axi_gpio_reg = (volatile uint32_t *)map_devmem(AXI_GPIO_BASE, 4096, "AXI GPIO");
    if (!axi_gpio_reg) return -1;
    axi_gpio_reg[AXI_GPIO_TRI / 4]  = GPIO_TRI_DIR;
    axi_gpio_reg[AXI_GPIO_DATA / 4] = RS485_RX_MODE;
    return 0;
}

/* ===== MCP2518FD 初始化（500kbps CAN 2.0B，接收全部帧）===== */
static int init_mcp2518fd(void)
{
    uint32_t devid, osc;
    uint32_t tq_total, tseg1, tseg2, sjw, nbtcfg;
    int retry;

    /* 1. 软复位 */
    if (mcp2518_reset() < 0) { printf("[FAIL] MCP2518FD 复位失败\n"); return -1; }

    /* 2. 读 DEVID —— 芯片在线验证（也能暴露 SPI 链路/接线问题）*/
    devid = mcp2518_read32(MCP2518_REG_DEVID);
    printf("DEVID = 0x%08X (ID=0x%X REV=0x%X)\n",
           devid, (devid >> 4) & 0xF, devid & 0xF);
    if (devid == 0x00000000 || devid == 0xFFFFFFFF) {
        printf("[FAIL] DEVID 读取异常：SPI 链路或 CAN 模块未就绪/未接线\n");
        printf("       请检查：1) 模块已扣排针(1脚对齐) 2) SPI SS/SCK/MOSI/MISO 接线 3) 供电 3.3V\n");
        return -1;
    }

    /* 3. 配置振荡器（不使能 PLL，直接用晶振）*/
    osc = mcp2518_read32(MCP2518_REG_OSC);
    printf("OSC(复位后) = 0x%08X\n", osc);
    mcp2518_write32(MCP2518_REG_OSC, OSC_CONFIG);
    for (retry = 0; retry < 100; retry++) {
        usleep(1000);
        osc = mcp2518_read32(MCP2518_REG_OSC);
        /* OSCRDY=bit10（无 PLL 时只看振荡器就绪）*/
        if ((osc & 0x400) == 0x400) break;
    }
    printf("OSC(配置后) = 0x%08X %s\n", osc, (retry < 100) ? "[OK] 就绪" : "[WARN] 未就绪");

    /* 4. 进入配置模式 */
    if (mcp2518_set_mode(REQOP_CONFIG, OPMOD_CONFIG) < 0) return -1;

    /* 5. 标称位时序 500kbps（运行时计算，SYNC_SEG 固定 1）*/
    tq_total = g_sysclk / CAN_NOMINAL_BPS;
    if (tq_total < 16 || tq_total > 256) {
        printf("[FAIL] tq_total=%u 越界，请核对 CAN_SYSCLK_HZ\n", tq_total);
        return -1;
    }
    tseg2 = tq_total / 8;                       /* 采样点 ~87.5% */
    tseg1 = tq_total - 1 - tseg2;
    sjw   = 2;
    if (tseg2 < 2) tseg2 = 2;
    if (tseg1 < 1) tseg1 = 1;
    if (sjw > tseg2) sjw = tseg2;
    /* NBTCFG: TSEG1/TSEG2/SJW 均存 value-1，BRP=0 */
    nbtcfg = ((tseg1 - 1) << 16) | ((tseg2 - 1) << 8) | (sjw - 1);
    mcp2518_write32(MCP2518_REG_C1NBTCFG, nbtcfg);
    printf("NBTCFG = 0x%08X (tq=%u, tseg1=%u, tseg2=%u, sjw=%u)\n",
           nbtcfg, tq_total, tseg1, tseg2, sjw);

    /* 6. FIFO1 配置为接收 FIFO（CAN2.0，8 字节数据）*/
    uint32_t fifocon = 0x00000000;              /* PLSIZE=8, FSIZE=0, TXEN=0(RX) */
    mcp2518_write32(MCP2518_REG_FIFOCON(1), fifocon);
    mcp2518_write32(MCP2518_REG_FIFOCON(1), fifocon | FIFOCON_FRESET);
    mcp2518_write32(MCP2518_REG_FIFOCON(1), fifocon);

    /* 7. 过滤器0：接受全部标准+扩展帧，路由到 FIFO1 */
    mcp2518_write32(MCP2518_REG_FLTMASK(0), FLTMASK_MIDE);   /* 屏蔽 IDE，不关心 ID */
    mcp2518_write32(MCP2518_REG_FLTOBJ(0), 0x00000000);
    mcp2518_write32(MCP2518_REG_FLTCON(0), FLTCON_FLTEN(0) | FLTCON_FBP(0, 1));

    /* 8. 使能接收中断（RXIE） */
    mcp2518_write32(MCP2518_REG_C1INT, C1INT_RXIE);

    /* 9. 进入正常模式 */
    if (mcp2518_set_mode(REQOP_MIXED, OPMOD_MIXED) < 0) return -1;

    printf("[OK] MCP2518FD 初始化完成（500kbps CAN 2.0B，接收全部帧）\n");
    return 0;
}

/* ===== 写 CAN 帧到 DDR（seq 最后写 + 刷 cache）===== */
static void write_can_to_ddr(uint32_t can_id, uint8_t dlc, const uint8_t *data)
{
    int n = dlc > 4 ? 4 : dlc;

    can_slot->device_id = DEV_CAN;
    can_slot->data_len  = dlc;
    can_slot->reserved  = (dlc > 4) ? ((uint32_t)data[4] | ((uint32_t)data[5] << 8)) : 0;

    can_slot->data[0] = can_id & 0xFF;
    can_slot->data[1] = (can_id >> 8) & 0xFF;
    can_slot->data[2] = (can_id >> 16) & 0xFF;
    can_slot->data[3] = (can_id >> 24) & 0xFF;

    memset((void *)(can_slot->data + 4), 0, 4);
    if (n > 0) memcpy((void *)(can_slot->data + 4), data, n);

    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    can_slot->tv_sec  = (uint32_t)ts.tv_sec;
    can_slot->tv_nsec = (uint32_t)ts.tv_nsec;

    __sync_synchronize();
    can_slot->seq = ++can_seq;
    dma_wb_slot(can_slot);
}

/* ===== 读接收 FIFO 中的 CAN 帧（返回 1=有帧，0=无，-1=错误）=====
 * MCP2518FD RX 对象布局（无时间戳，PLSIZE=8）：
 *   bytes[0..3] = ID（SID[10:0] | EID[17:0]<<11 | SID11<<29）
 *   bytes[4..7] = FLAGS（IDE/RTR/FDF/DLC）
 *   bytes[8..15] = 数据
 */
static int mcp2518_read_can_frame(uint32_t *can_id, uint8_t *dlc, uint8_t *data)
{
    uint8_t obj[16] = {0};
    uint32_t id_word, flags, fifoua;
    uint32_t sid, eid;
    uint8_t ide, fdf, rtr;
    int n;

    /* 1. FIFO1 状态：非空？ */
    uint32_t sta = mcp2518_read32(MCP2518_REG_FIFOSTA(1));
    if (!(sta & FIFOSTA_TFNRFNIF)) return 0;

    /* 2. 读 FIFO1 用户地址（RAM 12 位地址）*/
    fifoua = mcp2518_read32(MCP2518_REG_FIFOUA(1)) & 0x0FFF;
    if (fifoua == 0) return -1;

    /* 3. 读对象（16 字节）*/
    if (mcp2518_read_reg((uint16_t)fifoua, obj, 16) < 0) return -1;

    /* 4. 解析 ID */
    id_word = (uint32_t)obj[0] | ((uint32_t)obj[1] << 8) |
              ((uint32_t)obj[2] << 16) | ((uint32_t)obj[3] << 24);
    flags   = (uint32_t)obj[4] | ((uint32_t)obj[5] << 8) |
              ((uint32_t)obj[6] << 16) | ((uint32_t)obj[7] << 24);

    ide = (flags >> 4) & 0x1;
    rtr = (flags >> 5) & 0x1;
    fdf = (flags >> 7) & 0x1;
    *dlc = flags & 0x0F;
    if (*dlc > 8) *dlc = 8;                     /* 数据场最大 8 */

    if (ide) {
        sid = id_word & 0x7FF;                  /* SID[10:0] */
        eid = (id_word >> 11) & 0x3FFFF;        /* EID[17:0] */
        *can_id = (sid << 18) | eid;            /* 29 位扩展 ID */
    } else {
        *can_id = id_word & 0x7FF;              /* 11 位标准 ID */
    }

    n = *dlc > 6 ? 6 : *dlc;                    /* 项目协议数据场最多 6 字节 */
    memcpy(data, obj + 8, n);
    (void)rtr; (void)fdf;

    /* 5. 递增 FIFO 用户地址（UINC）*/
    mcp2518_write32(MCP2518_REG_FIFOCON(1), FIFOCON_UINC);
    return 1;
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

/* ===== TXQ 发送一帧（内部回环自检用）=====
 * TXQ RAM 起始 0x400，TXREQ=C1TXQCON bit9。
 * 对象布局与 RX 一致：bytes[0..3]=ID, bytes[4..7]=FLAGS, bytes[8..15]=数据 */
static int mcp2518_txq_send(uint32_t can_id, uint8_t ide, const uint8_t *data, uint8_t dlc)
{
    uint8_t obj[16] = {0};
    uint32_t id_word, flags;

    if (dlc > 8) dlc = 8;

    if (ide) {
        uint32_t sid = (can_id >> 18) & 0x7FF;
        uint32_t eid = can_id & 0x3FFFF;
        id_word = sid | (eid << 11);
    } else {
        id_word = can_id & 0x7FF;
    }
    flags = (dlc & 0x0F) | (ide ? (1u << 4) : 0);

    obj[0] = (uint8_t)(id_word & 0xFF);
    obj[1] = (uint8_t)((id_word >> 8) & 0xFF);
    obj[2] = (uint8_t)((id_word >> 16) & 0xFF);
    obj[3] = (uint8_t)((id_word >> 24) & 0xFF);
    obj[4] = (uint8_t)(flags & 0xFF);
    obj[5] = (uint8_t)((flags >> 8) & 0xFF);
    obj[6] = (uint8_t)((flags >> 16) & 0xFF);
    obj[7] = (uint8_t)((flags >> 24) & 0xFF);
    memcpy(obj + 8, data, dlc);

    if (mcp2518_write_reg(0x400, obj, 16) < 0) return -1;
    mcp2518_write32(MCP2518_REG_C1TXQCON, 0x00000200U);   /* TXREQ=bit9 */
    return 0;
}

/* ===== 主动下发版本查询（测试系统→轨迹球）=====
 * 帧 ID 0x01180119（扩展帧），数据 AA 01 21 AB（4 字节）。
 * 轨迹球收到后回版本回复帧 0x01180117 = 02 00 01（2.01）。 */
static int can_send_version_query(void)
{
    uint8_t data[4] = {0xAA, 0x01, 0x21, 0xAB};
    return mcp2518_txq_send(CAN_ID_VER_QUERY, 1, data, 4);
}

/* ===== 内部回环自检：SPI→寄存器→编码→回环→解码→DDR 全链路验证 =====
 * 不驱动 CAN 总线（不经过收发器），零硬件风险，是模块接上后的第一验证步骤 */
static int self_test_loopback(void)
{
    static const uint32_t test_id = 0x123;               /* 标准帧测试 ID */
    static const uint8_t  test_dlc = 6;                  /* 与项目 6 字节数据场一致 */
    static const uint8_t  test_data[8] = {0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77};
    uint32_t devid, osc, nbtcfg;
    uint32_t tq_total, tseg1, tseg2, sjw;
    uint32_t rx_id  = 0;
    uint8_t  rx_dlc = 0;
    uint8_t  rx_data[8] = {0};
    int retry;

    printf("\n===== MCP2518FD 内部回环自检 =====\n");

    /* 1. 复位 + DEVID（验证 SPI 链路与模块接线）*/
    if (mcp2518_reset() < 0) { printf("[FAIL] 复位失败\n"); return -1; }
    devid = mcp2518_read32(MCP2518_REG_DEVID);
    printf("DEVID = 0x%08X (ID=0x%X REV=0x%X)\n", devid, (devid >> 4) & 0xF, devid & 0xF);
    if (devid == 0 || devid == 0xFFFFFFFF) {
        printf("[FAIL] DEVID 读取异常：SPI 链路或模块未接/未对齐\n");
        return -1;
    }
    if ((devid & 0xFF) != 0x51) {
        printf("[WARN] DEVID 非预期 0x51（期望 ID=5 REV=1），继续尝试\n");
    }

    /* 2. 振荡器（不使能 PLL）*/
    mcp2518_write32(MCP2518_REG_OSC, OSC_CONFIG);
    for (retry = 0; retry < 100; retry++) {
        usleep(1000);
        osc = mcp2518_read32(MCP2518_REG_OSC);
        if ((osc & 0x400) == 0x400) break;
    }
    printf("OSC = 0x%08X %s\n", osc, (retry < 100) ? "[OK] 就绪" : "[WARN] 未就绪");

    /* 3. 配置模式 + NBTCFG 位时序 */
    if (mcp2518_set_mode(REQOP_CONFIG, OPMOD_CONFIG) < 0) return -1;
    tq_total = g_sysclk / CAN_NOMINAL_BPS;
    if (tq_total < 16 || tq_total > 256) {
        printf("[FAIL] tq_total=%u 越界，晶振/SYSCLK 配置不当（可加 -s 覆盖）\n", tq_total);
        return -1;
    }
    tseg2 = tq_total / 8;
    tseg1 = tq_total - 1 - tseg2;
    sjw   = 2;
    if (tseg2 < 2) tseg2 = 2;
    if (sjw > tseg2) sjw = tseg2;
    nbtcfg = ((tseg1 - 1) << 16) | ((tseg2 - 1) << 8) | (sjw - 1);
    mcp2518_write32(MCP2518_REG_C1NBTCFG, nbtcfg);
    printf("NBTCFG = 0x%08X (tq=%u)\n", nbtcfg, tq_total);

    /* 4. FIFO1 配置为 RX（8 字节数据，1 消息）+ 过滤器 0 全接收 */
    mcp2518_write32(MCP2518_REG_FIFOCON(1), 0x00000000U);
    mcp2518_write32(MCP2518_REG_FIFOCON(1), 0x00000000U | FIFOCON_FRESET);
    mcp2518_write32(MCP2518_REG_FIFOCON(1), 0x00000000U);
    mcp2518_write32(MCP2518_REG_FLTMASK(0), FLTMASK_MIDE);
    mcp2518_write32(MCP2518_REG_FLTOBJ(0), 0x00000000U);
    mcp2518_write32(MCP2518_REG_FLTCON(0), FLTCON_FLTEN(0) | FLTCON_FBP(0, 1));

    /* 5. 进入内部回环模式（不驱动总线）*/
    if (mcp2518_set_mode(REQOP_INT_LOOPBACK, OPMOD_INT_LOOPBACK) < 0) return -1;

    /* 6. 配置 TXQ 并发送测试帧 */
    mcp2518_write32(MCP2518_REG_C1TXQCON, 0x00000000U);
    if (mcp2518_txq_send(test_id, 0, test_data, test_dlc) < 0) {
        printf("[FAIL] TXQ 发送失败\n");
        return -1;
    }

    /* 7. 轮询 FIFO1 接收（最多 200ms）*/
    for (retry = 0; retry < 200; retry++) {
        usleep(1000);
        if (mcp2518_read_can_frame(&rx_id, &rx_dlc, rx_data) > 0) break;
    }
    if (retry >= 200) {
        printf("[FAIL] 回环 200ms 内未收到帧\n");
        return -1;
    }

    /* 8. 校验 ID/DLC/数据 */
    printf("回环收到: ID=0x%08X DLC=%d\n", rx_id, rx_dlc);
    if (rx_id != test_id) { printf("[FAIL] ID 不匹配（期望 0x%X）\n", test_id); return -1; }
    if (rx_dlc != test_dlc) { printf("[FAIL] DLC 不匹配（期望 %u）\n", test_dlc); return -1; }
    if (memcmp(rx_data, test_data, test_dlc) != 0) {
        printf("[FAIL] 数据不匹配\n");
        return -1;
    }

    printf("[PASS] 内部回环自检通过：TX→RX 帧完全一致\n");

    /* 9. 写 DDR CAN 槽位，供 PC 端 XDMA 验证 */
    if (can_slot) {
        write_can_to_ddr(rx_id, rx_dlc, rx_data);
        printf("[OK] 已写入 DDR CAN 槽位 seq=%u\n", can_seq);
    }
    return 0;
}

int main(int argc, char **argv)
{
    int mode = 0;    /* 0=normal, 1=probe, 2=loopback */
    int query_version = 0;   /* 主动下发版本查询 */
    int i;

    setvbuf(stdout, NULL, _IOLBF, 0);

    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--probe") == 0)
            mode = 1;
        else if (strcmp(argv[i], "--loopback") == 0)
            mode = 2;
        else if (strcmp(argv[i], "--query-version") == 0)
            query_version = 1;
        else if (strcmp(argv[i], "-s") == 0 && i + 1 < argc)
            g_sysclk = (uint32_t)strtoul(argv[++i], NULL, 0);
    }

    printf("=== CAN 数据采集程序（MCP2518FD，寄存器级 SPI）===\n");
    printf("CAN 槽位: 0x%08X (device_id=%d)  SYSCLK=%uHz 模式=%s\n",
           DDR_BASE + SLOT_CAN, DEV_CAN, g_sysclk,
           mode == 1 ? "probe" : mode == 2 ? "loopback" : "normal");

    /* 1. AXI GPIO（RS485 方向）*/
    if (init_axi_gpio() < 0)
        printf("[WARN] AXI GPIO 初始化失败，RS485 方向控制不可用\n");
    else
        printf("[OK] AXI GPIO 初始化成功（RS485 默认接收模式）\n");

    /* 2. 使能 SPI0 时钟 + 控制器 */
    if (init_spi0_clock() < 0) return 1;
    if (init_spi0_controller() < 0) return 1;

    /* 3. mmap DDR */
    volatile uint8_t *ddr_base = map_devmem(DDR_BASE, DDR_SIZE, "DDR");
    if (!ddr_base) return 1;
    can_slot = (volatile share_slot_t *)(ddr_base + SLOT_CAN);

    /* 4. --probe：只读 DEVID，快速验证 SPI 链路 + 模块接线（晶振无关）*/
    if (mode == 1) {
        uint32_t devid;
        if (mcp2518_reset() < 0) return 1;
        devid = mcp2518_read32(MCP2518_REG_DEVID);
        printf("DEVID = 0x%08X (ID=0x%X REV=0x%X)\n", devid, (devid >> 4) & 0xF, devid & 0xF);
        if ((devid & 0xFF) == 0x51)
            printf("[PASS] MCP2518FD 在线，SPI 链路正常\n");
        else
            printf("[FAIL] DEVID 异常（正常应为 0x51），检查接线/供电/1脚对齐\n");
        return (devid & 0xFF) == 0x51 ? 0 : 1;
    }

    /* 5. --loopback：内部回环自检（不驱动总线，零硬件风险）*/
    if (mode == 2) {
        int r = self_test_loopback();
        printf(r == 0 ? "\n[PASS] 回环自检全部通过\n" : "\n[FAIL] 回环自检失败\n");
        return r == 0 ? 0 : 1;
    }

    /* 6. 正常模式：初始化 + RX 轮询 */
    if (init_mcp2518fd() < 0) return 1;

    /* 可选：主动下发版本查询，轨迹球回版本回复 0x01180117 */
    if (query_version) {
        if (can_send_version_query() == 0)
            printf("[命令] 下发版本查询 0x01180119 = AA 01 21 AB\n");
        else
            printf("[FAIL] 版本查询下发失败\n");
    }

    printf("\n等待 CAN 数据... (Ctrl+C 退出)\n");

    while (1) {
        uint32_t can_id = 0;
        uint8_t dlc = 0;
        uint8_t data[6] = {0};

        int ret = mcp2518_read_can_frame(&can_id, &dlc, data);
        if (ret > 0) {
            write_can_to_ddr(can_id, dlc, data);
            printf("[CAN #%u] ID=0x%08X %s DLC=%d\n",
                   can_seq, can_id, can_id_name(can_id), dlc);
        } else if (ret < 0) {
            printf("[WARN] 读帧错误，跳过\n");
        }
        usleep(1000);
    }

    return 0;
}