/*
 * ACZ7015 CAN数据采集程序（PS侧Linux）
 * 功能：通过SPI0读取MCP2518FD CANFD芯片，封装32字节槽位写入DDR
 * 协议：依据 d:\workspace\trae\day01\0702\protocol_spec.md（CAN device_id=1, 槽位0x20000020）
 * 硬件：ACZ7015 + 小梅哥ACM_CANFD_RS485模块（SPI0驱动MCP2518FD）
 *
 * 两种驱动方式（可选）：
 *   方式A: spidev（/dev/spidev0.0）— 用户态直接操作SPI，需设备树配置spidev节点
 *   方式B: socketcan（can0）— 内核mcp251xfd驱动，标准Linux CAN接口
 *
 * 编译：arm-xilinx-linux-gnueabi-gcc -O2 -o arm_can_sender arm_can_sender.c
 * 运行：sudo ./arm_can_sender [--help] [--socketcan can0]
 *
 * 前置条件：
 * 1. bitstream已包含SPI0 EMIO配置（执行integrate_can.tcl后重新综合）
 * 2. CAN模块已插到JE/JF扩展口（SPI0/GPIO/UART1引脚对应连接）
 * 3. 方式A: 设备树添加SPI0+spidev节点，/dev/spidev0.0存在
 *    方式B: 内核有mcp251xfd驱动，设备树添加MCP2518FD节点，can0接口存在
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>
#include <time.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <sys/socket.h>
#include <net/if.h>
#include <sys/ioctl.h>

// ========== 协议规范定义（32字节统一槽位格式）==========
#define DDR_BASE        0x20000000   // DDR共享内存基址
#define SLOT_SIZE       32            // 槽位大小（字节）
#define SLOT_CAN        0x20          // CAN槽位偏移（device_id=1）
#define DEV_CAN         1             // CAN的device_id

#pragma pack(push, 1)
typedef struct {
    uint16_t type;    // input_event type（EV_KEY/EV_REL等），CAN用CAN帧ID
    uint16_t code;    // input_event code，CAN用DLC
    int32_t  value;   // input_event value，CAN用前4字节数据
} can_data_t;         // 8字节

typedef struct {
    uint32_t seq;        // 0x00 序号
    uint32_t device_id;  // 0x04 设备ID（CAN=1）
    uint32_t data_len;   // 0x08 数据长度
    uint32_t reserved;   // 0x0C 保留
    uint8_t  data[8];    // 0x10 数据（CAN帧ID+DLC+前4字节）
    uint32_t tv_sec;     // 0x18 时间戳秒
    uint32_t tv_nsec;    // 0x1C 时间戳纳秒
} share_slot_t;          // 32字节
#pragma pack(pop)

// ========== MCP2518FD SPI命令 ==========
#define MCP2518_CMD_RESET       0x00
#define MCP2518_CMD_READ        0x03
#define MCP2518_CMD_WRITE       0x02
#define MCP2518_CMD_READ_CRC   0x3B

// MCP2518FD 关键寄存器地址（Channel 1）
#define MCP2518_REG_C1CON       0x400   // 控制寄存器（含OPMODE/REQOP）
#define MCP2518_REG_C1NBTCFG    0x40C   // 标称位时序配置（4字节）
#define MCP2518_REG_C1DBTCFG    0x410   // 数据位时序配置（4字节，CANFD用）
#define MCP2518_REG_C1INT       0x434   // 中断使能（2字节）
#define MCP2518_REG_C1FIFOCON1  0x4A0   // FIFO1控制（接收）
#define MCP2518_REG_C1FIFOSTA1  0x4C4   // FIFO1状态
#define MCP2518_REG_C1FIFOUA1   0x4C8   // FIFO1用户地址
#define MCP2518_REG_C1FIFOCON2  0x4A8   // FIFO2控制（发送）
#define MCP2518_REG_C1FIFOSTA2  0x4CC   // FIFO2状态

// C1CON位定义
#define C1CON_OPMODE_CFG        0x0400  // bit10=1 请求配置模式
#define C1CON_OPMODE_NORMAL     0x0000  // bit8-10=0 请求正常模式
#define C1CON_OPMODE_MASK       0x0700  // OPMODE位掩码

// ========== 全局变量 ==========
static int spi_fd = -1;           // SPI设备文件
static volatile uint8_t *ddr_mem = NULL;  // DDR映射
static int ddr_fd = -1;
static uint32_t can_seq = 0;
static volatile share_slot_t *can_slot = NULL;

// SPI配置
static const uint8_t spi_mode = SPI_MODE_0;
static const uint8_t spi_bits = 8;
static const uint32_t spi_speed = 10000000;  // 10MHz

// ========== AXI GPIO定义（控制CAN中断输入+RS485方向）==========
#define AXI_GPIO_BASE   0x41200000   // AXI GPIO基地址（BD中assign_bd_address分配）
#define AXI_GPIO_DATA   0x00          // 数据寄存器偏移
#define AXI_GPIO_TRI    0x04          // 三态控制寄存器（1=输入高阻，0=输出）
#define GPIO_TRI_DIR    0x3F          // bit0-5=1输入(INT), bit6-7=0输出(RE)
#define RS485_RX_MODE   0x00          // RS485_RE=0 接收模式（低电平有效RE）
#define RS485_TX_MODE   0xC0          // RS485_RE=1 发送模式（bit6,7=1）

static volatile uint32_t *axi_gpio_reg = NULL;  // AXI GPIO寄存器映射
static int gpio_fd = -1;

// ========== AXI GPIO初始化 ==========
int init_axi_gpio(void) {
    gpio_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (gpio_fd < 0) { perror("open /dev/mem for gpio"); return -1; }
    axi_gpio_reg = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, gpio_fd, AXI_GPIO_BASE);
    if (axi_gpio_reg == MAP_FAILED) { perror("mmap axi_gpio"); return -1; }
    // 配置方向：bit0-5=输入(INT中断), bit6-7=输出(RS485_RE)
    axi_gpio_reg[AXI_GPIO_TRI/4] = GPIO_TRI_DIR;
    // 输出默认0（RS485接收模式，安全）
    axi_gpio_reg[AXI_GPIO_DATA/4] = RS485_RX_MODE;
    printf("AXI GPIO初始化: TRI=0x%08X DATA=0x%08X\n",
           axi_gpio_reg[AXI_GPIO_TRI/4], axi_gpio_reg[AXI_GPIO_DATA/4]);
    return 0;
}

// RS485方向控制（发送时调用）
void rs485_set_tx(void) {
    if (axi_gpio_reg) axi_gpio_reg[AXI_GPIO_DATA/4] = RS485_TX_MODE;
}

void rs485_set_rx(void) {
    if (axi_gpio_reg) axi_gpio_reg[AXI_GPIO_DATA/4] = RS485_RX_MODE;
}

// 读取CAN中断状态（bit0-5）
uint8_t read_can_int(void) {
    if (axi_gpio_reg) return (uint8_t)(axi_gpio_reg[AXI_GPIO_DATA/4] & 0x3F);
    return 0;
}

// ========== MCP2518FD SPI读写 ==========
int mcp2518_read_reg(uint16_t addr, uint8_t *buf, int len) {
    uint8_t tx[3 + 32] = {0};
    uint8_t rx[3 + 32] = {0};
    tx[0] = MCP2518_CMD_READ;
    tx[1] = (addr >> 8) & 0xFF;
    tx[2] = addr & 0xFF;
    struct spi_ioc_transfer tr = {
        .tx_buf = (unsigned long)tx,
        .rx_buf = (unsigned long)rx,
        .len = 3 + len,
        .speed_hz = spi_speed,
        .bits_per_word = spi_bits,
    };
    if (ioctl(spi_fd, SPI_IOC_MESSAGE(1), &tr) < 0) return -1;
    memcpy(buf, rx + 3, len);
    return 0;
}

int mcp2518_write_reg(uint16_t addr, uint8_t *buf, int len) {
    uint8_t tx[3 + 32] = {0};
    tx[0] = MCP2518_CMD_WRITE;
    tx[1] = (addr >> 8) & 0xFF;
    tx[2] = addr & 0xFF;
    memcpy(tx + 3, buf, len);
    struct spi_ioc_transfer tr = {
        .tx_buf = (unsigned long)tx,
        .rx_buf = 0,
        .len = 3 + len,
        .speed_hz = spi_speed,
        .bits_per_word = spi_bits,
    };
    if (ioctl(spi_fd, SPI_IOC_MESSAGE(1), &tr) < 0) return -1;
    return 0;
}

// ========== CAN数据写入DDR ==========
void write_can_to_ddr(uint16_t can_id, uint8_t dlc, uint8_t *data) {
    can_seq++;
    can_slot->seq = can_seq;          // 最后写seq，PC端检测变化
    can_slot->device_id = DEV_CAN;
    can_slot->data_len = dlc > 8 ? 8 : dlc;
    can_slot->reserved = 0;
    // data[8]：前2字节CAN_ID，1字节DLC，后5字节数据
    can_slot->data[0] = can_id & 0xFF;
    can_slot->data[1] = (can_id >> 8) & 0xFF;
    can_slot->data[2] = dlc;
    memcpy(can_slot->data + 3, data, dlc > 5 ? 5 : dlc);

    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    can_slot->tv_sec = (uint32_t)ts.tv_sec;
    can_slot->tv_nsec = (uint32_t)ts.tv_nsec;
}

// ========== MCP2518FD 初始化（500kbps CAN 2.0B，40MHz时钟）==========
int init_mcp2518fd(void) {
    uint8_t buf[4] = {0};
    uint8_t status[4] = {0};
    int retry = 0;

    // 1. 软复位（单字节命令）
    uint8_t cmd_reset = MCP2518_CMD_RESET;
    struct spi_ioc_transfer tr = {
        .tx_buf = (unsigned long)&cmd_reset,
        .rx_buf = 0,
        .len = 1,
        .speed_hz = spi_speed,
        .bits_per_word = spi_bits,
    };
    if (ioctl(spi_fd, SPI_IOC_MESSAGE(1), &tr) < 0) {
        perror("MCP2518FD reset ioctl"); return -1;
    }
    usleep(20000);  // 等待复位完成（约10ms+裕量）

    // 2. 请求配置模式（REQOP=100 → C1CON bit10=1）
    buf[0] = 0x00; buf[1] = 0x04; buf[2] = 0x00; buf[3] = 0x00;
    if (mcp2518_write_reg(MCP2518_REG_C1CON, buf, 4) < 0) {
        printf("C1CON写失败\n"); return -1;
    }
    // 轮询OPMODE是否进入配置模式（bit2-0=100）
    for (retry = 0; retry < 50; retry++) {
        usleep(2000);
        if (mcp2518_read_reg(MCP2518_REG_C1CON + 2, status, 2) < 0) continue;
        if ((status[1] & 0x07) == 0x04) break;  // OPMODE=100 配置模式
    }
    if (retry >= 50) {
        printf("MCP2518FD进入配置模式超时 (OPMODE=0x%02X)\n", status[1] & 0x07);
        return -1;
    }
    printf("MCP2518FD已进入配置模式\n");

    // 3. 配置标称位时序 500kbps（40MHz时钟，NBT=40TQ）
    // C1NBTCFG: [31:24]=BRP-1, [23:16]=TSEG1-1, [15:8]=TSEG2-1, [7:0]=SJW-1
    // BRP=1(TQ=50ns), TSEG1=23, TSEG2=8, SJW=1 → NBT=(1+23+8)*50ns=1600ns... 用40TQ
    // 500kbps → 2000ns bit → 40TQ：SyncSeg=1, PropSeg=7, PhaseSeg1=16, PhaseSeg2=16
    // TSEG1=PropSeg+PhaseSeg1-1=22, TSEG2=PhaseSeg2-1=15, SJW-1=0
    buf[0] = 0x00;  // SJW-1 = 0
    buf[1] = 0x0F;  // TSEG2-1 = 15
    buf[2] = 0x16;  // TSEG1-1 = 22 (PropSeg7+PhaseSeg1-1=22)
    buf[3] = 0x00;  // BRP-1 = 0
    if (mcp2518_write_reg(MCP2518_REG_C1NBTCFG, buf, 4) < 0) {
        printf("C1NBTCFG写失败\n"); return -1;
    }
    printf("C1NBTCFG配置: 500kbps (BRP=1, TSEG1=23, TSEG2=16, SJW=1)\n");

    // 4. 配置FIFO1为接收（RxEN=1, RTSEL=0）
    // C1FIFOCON1: [31]=TxEN(0=接收), [30]=RTSEL, [7:0]=FIFO Size-1
    buf[0] = 0x00;  // FIFO大小=1
    buf[1] = 0x00;
    buf[2] = 0x00;
    buf[3] = 0x00;  // bit31=0 接收模式
    if (mcp2518_write_reg(MCP2518_REG_C1FIFOCON1, buf, 4) < 0) {
        printf("C1FIFOCON1写失败\n"); return -1;
    }
    printf("C1FIFOCON1配置: FIFO1=接收模式\n");

    // 5. 启用接收中断（RXFULIE=1）
    // C1INT: [7:0]=IE0, [15:8]=IF0; bit4=RXIE, bit3=TREIE
    buf[0] = 0x01;  // 启用接收中断
    buf[1] = 0x00;
    if (mcp2518_write_reg(MCP2518_REG_C1INT, buf, 2) < 0) {
        printf("C1INT写失败\n"); return -1;
    }
    printf("C1INT配置: 启用接收中断\n");

    // 6. 请求正常模式（REQOP=000）
    buf[0] = 0x00; buf[1] = 0x00; buf[2] = 0x00; buf[3] = 0x00;
    if (mcp2518_write_reg(MCP2518_REG_C1CON, buf, 4) < 0) {
        printf("C1CON写正常模式失败\n"); return -1;
    }
    // 轮询OPMODE是否进入正常模式
    for (retry = 0; retry < 50; retry++) {
        usleep(2000);
        if (mcp2518_read_reg(MCP2518_REG_C1CON + 2, status, 2) < 0) continue;
        if ((status[1] & 0x07) == 0x00) break;  // OPMODE=000 正常模式
    }
    if (retry >= 50) {
        printf("MCP2518FD进入正常模式超时 (OPMODE=0x%02X)\n", status[1] & 0x07);
        return -1;
    }
    printf("MCP2518FD已进入正常模式（500kbps CAN 2.0B）\n");
    return 0;
}

// ========== MCP2518FD 读取接收FIFO中的CAN帧 ==========
int mcp2518_read_can_frame(uint16_t *can_id, uint8_t *dlc, uint8_t *data) {
    uint8_t sta[4] = {0};
    uint8_t fifo_data[16] = {0};

    // 1. 读取FIFO1状态
    if (mcp2518_read_reg(MCP2518_REG_C1FIFOSTA1, sta, 1) < 0) return -1;
    if (!(sta[0] & 0x01)) return 0;  // RXFUL=0 无数据

    // 2. 读取FIFO用户地址（实际数据存放位置）
    uint8_t ua[3] = {0};
    if (mcp2518_read_reg(MCP2518_REG_C1FIFOUA1, ua, 3) < 0) return -1;

    // 3. 读取CAN帧（简化：直接读FIFO数据寄存器0x4D0+）
    if (mcp2518_read_reg(0x4D0, fifo_data, 8) < 0) return -1;

    // 4. 解析CAN ID和DLC（MCP2518FD帧格式）
    *can_id = fifo_data[0] | (fifo_data[1] << 8);
    *dlc = fifo_data[2] & 0x0F;
    memcpy(data, fifo_data + 3, *dlc > 5 ? 5 : *dlc);

    // 5. 清除RXFUL标志（FIFO1控制寄存器 bit0=1 清除）
    uint8_t clr[4] = {0x01, 0x00, 0x00, 0x00};
    mcp2518_write_reg(MCP2518_REG_C1FIFOCON1, clr, 4);
    return 1;
}

// ========== 初始化 ==========
int init_spi(void) {
    spi_fd = open("/dev/spidev0.0", O_RDWR);
    if (spi_fd < 0) { perror("open spidev0.0"); return -1; }
    ioctl(spi_fd, SPI_IOC_WR_MODE, &spi_mode);
    ioctl(spi_fd, SPI_IOC_WR_BITS_PER_WORD, &spi_bits);
    ioctl(spi_fd, SPI_IOC_WR_MAX_SPEED_HZ, &spi_speed);
    return 0;
}

int init_ddr(void) {
    ddr_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (ddr_fd < 0) { perror("open /dev/mem"); return -1; }
    ddr_mem = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, ddr_fd, DDR_BASE);
    if (ddr_mem == MAP_FAILED) { perror("mmap DDR"); return -1; }
    can_slot = (share_slot_t *)(ddr_mem + SLOT_CAN);
    return 0;
}

// ========== CAN接收轮询 ==========
int can_receive_poll(void) {
    uint16_t can_id = 0;
    uint8_t dlc = 0;
    uint8_t data[8] = {0};

    int ret = mcp2518_read_can_frame(&can_id, &dlc, data);
    if (ret > 0) {
        write_can_to_ddr(can_id, dlc, data);
        return 1;
    }
    return 0;
}

// ========== 帮助信息 ==========
void show_help(void) {
    printf("ACZ7015 CAN数据采集程序 V2（协议标准格式）\n");
    printf("用法: sudo ./arm_can_sender [选项]\n");
    printf("选项:\n");
    printf("  --help        显示帮助\n");
    printf("  --spidev X    用spidev方式（默认 /dev/spidev0.0）\n");
    printf("  --socketcan X 用socketcan方式（如 can0，需内核mcp251xfd驱动）\n");
    printf("功能: 通过SPI0或socketcan读取CAN数据，封装32字节槽位写入DDR\n");
    printf("协议: CAN device_id=%d, 槽位偏移=0x%02X\n", DEV_CAN, SLOT_CAN);
    printf("DDR基址: 0x%08X\n", DDR_BASE);
    printf("CAN槽位: 0x%08X\n", DDR_BASE + SLOT_CAN);
    printf("槽位大小: %d字节\n", SLOT_SIZE);
}

// ========== socketcan方式 ==========
int init_socketcan(const char *ifname) {
    int sock = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (sock < 0) { perror("socket(PF_CAN)"); return -1; }

    struct ifreq ifr;
    strcpy(ifr.ifr_name, ifname);
    if (ioctl(sock, SIOCGIFINDEX, &ifr) < 0) {
        perror("SIOCGIFINDEX"); close(sock); return -1;
    }

    struct sockaddr_can addr;
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (bind(sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind"); close(sock); return -1;
    }
    return sock;
}

void socketcan_receive_loop(int sock) {
    struct can_frame frame;
    printf("等待CAN数据... (Ctrl+C退出)\n");
    while (1) {
        int nbytes = read(sock, &frame, sizeof(frame));
        if (nbytes < 0) { perror("read can"); break; }
        if (nbytes < sizeof(frame)) continue;

        // 写入DDR
        can_seq++;
        can_slot->seq = can_seq;
        can_slot->device_id = DEV_CAN;
        can_slot->data_len = frame.can_dlc > 5 ? 5 : frame.can_dlc;
        can_slot->reserved = 0;
        can_slot->data[0] = frame.can_id & 0xFF;
        can_slot->data[1] = (frame.can_id >> 8) & 0xFF;
        can_slot->data[2] = frame.can_dlc;
        memcpy(can_slot->data + 3, frame.data, can_slot->data_len);

        struct timespec ts;
        clock_gettime(CLOCK_REALTIME, &ts);
        can_slot->tv_sec = (uint32_t)ts.tv_sec;
        can_slot->tv_nsec = (uint32_t)ts.tv_nsec;

        printf("[发送 #%u] CAN ID=0x%03X DLC=%d (data_len=%u)\n",
               can_seq, frame.can_id, frame.can_dlc, can_slot->data_len);
    }
}

// ========== 主函数 ==========
int main(int argc, char *argv[]) {
    char *spi_dev = "/dev/spidev0.0";
    char *can_if = NULL;
    int use_socketcan = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--help") == 0) { show_help(); return 0; }
        if (strcmp(argv[i], "--spidev") == 0 && i+1 < argc) spi_dev = argv[++i];
        if (strcmp(argv[i], "--socketcan") == 0 && i+1 < argc) {
            can_if = argv[++i];
            use_socketcan = 1;
        }
    }

    printf("=== CAN数据采集程序 V2（协议标准格式）===\n");
    printf("DDR基址: 0x%08X\n", DDR_BASE);
    printf("CAN槽位: 0x%08X (device_id=%d)\n", DDR_BASE + SLOT_CAN, DEV_CAN);
    printf("槽位大小: %d字节\n", SLOT_SIZE);
    printf("AXI GPIO: 0x%08X (8位双向三态)\n", AXI_GPIO_BASE);

    // 初始化AXI GPIO（控制RS485方向 + 读取CAN中断）
    if (init_axi_gpio() < 0) {
        printf("AXI GPIO初始化失败，RS485方向控制不可用（继续运行）\n");
    } else {
        printf("AXI GPIO初始化成功（RS485默认接收模式）\n");
    }

    if (init_ddr() < 0) {
        printf("DDR映射失败\n");
        return 1;
    }
    printf("DDR映射成功\n");

    if (use_socketcan) {
        // 方式B: socketcan
        printf("使用socketcan接口: %s\n", can_if);
        int sock = init_socketcan(can_if);
        if (sock < 0) {
            printf("socketcan初始化失败，请确认：\n");
            printf("1. 内核有mcp251xfd驱动\n");
            printf("2. 设备树添加了MCP2518FD节点\n");
            printf("3. can0接口存在（ifconfig -a）\n");
            printf("4. ip link set can0 up type can bitrate 500000\n");
            return 1;
        }
        printf("socketcan初始化成功\n");
        socketcan_receive_loop(sock);
        close(sock);
    } else {
        // 方式A: spidev
        printf("使用spidev接口: %s\n", spi_dev);
        if (init_spi() < 0) {
            printf("SPI初始化失败，请确认：\n");
            printf("1. bitstream已包含SPI0 EMIO配置\n");
            printf("2. 设备树已添加spidev节点\n");
            printf("3. %s 设备存在\n", spi_dev);
            return 1;
        }
        printf("SPI初始化成功\n");
        // MCP2518FD寄存器初始化（500kbps CAN 2.0B）
        if (init_mcp2518fd() < 0) {
            printf("MCP2518FD初始化失败，请确认：\n");
            printf("1. CAN模块已插到GPIO0排针（1脚对齐）\n");
            printf("2. bitstream已加载SPI0 EMIO配置\n");
            printf("3. pin11(VCC)供电正常（5V）\n");
            return 1;
        }
        printf("MCP2518FD初始化成功，等待CAN数据... (Ctrl+C退出)\n");
        while (1) {
            int ret = can_receive_poll();
            if (ret > 0) {
                printf("[发送 #%u] CAN ID=0x%03X DLC=%d (data_len=%u)\n",
                       can_seq, can_slot->data[0] | (can_slot->data[1] << 8),
                       can_slot->data[2], can_slot->data_len);
            }
            usleep(1000);
        }
        close(spi_fd);
    }

    // 释放资源
    if (axi_gpio_reg) { munmap((void*)axi_gpio_reg, 4096); close(gpio_fd); }
    munmap((void*)ddr_mem, 4096);
    close(ddr_fd);
    return 0;
}
