/*
 * arm_rs422_sender.c - 开发板侧RS422数据采集程序（协议标准格式V2）
 *
 * 功能：从PS UART1(EMIO)读取轨迹球RS422数据，解析协议帧，写入DDR共享内存
 *
 * 硬件连接：
 *   轨迹球 ──RS422──> TTL转RS422模块 ──TTL──> ACZ7015 40pin排针
 *     pin26(E5)=UART1_TX, pin28(B1)=UART1_RX, pin11=3.3V, pin12=GND
 *
 * 协议依据：protocol_spec.md 第一章RS422接口
 *   - 115200 8N1，自定义帧
 *   - 帧格式: 帧头(0x55) | 报文标识 | 有效数据 | 校验和
 *   - 5种报文: 位移(0xD1,3B) 状态(0xD2,3B) 温度(0xD3,1B) 电压(0xD4,2B) 版本(0xD5,3B)
 *
 * 编译：gcc -O2 -o arm_rs422_sender arm_rs422_sender.c
 * 运行：sudo ./arm_rs422_sender [/dev/ttyPS0]
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <termios.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <stdint.h>
#include <time.h>

/* ===== DDR共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    4096
#define SLOT_RS422  0x60   /* 0x20000060 RS422槽位 */

/* 接口类型标识 */
#define DEV_RS422  3

/* RS422协议常量 */
#define RS422_FRAME_HEAD   0x55
#define RS422_CMD_DISPLACEMENT  0xD1  /* 位移信息，3字节数据 */
#define RS422_CMD_STATUS        0xD2  /* 状态信息，3字节数据 */
#define RS422_CMD_TEMP          0xD3  /* 温度，1字节数据 */
#define RS422_CMD_VOLTAGE       0xD4  /* 电压，2字节数据 */
#define RS422_CMD_VERSION       0xD5  /* 版本，3字节数据 */

/* 统一DDR转发槽位格式（32字节） */
typedef struct {
    volatile uint32_t seq;        /* 0x00: 序号 */
    volatile uint32_t device_id;  /* 0x04: 3=RS422 */
    volatile uint32_t data_len;   /* 0x08: 有效数据长度 */
    volatile uint32_t reserved;   /* 0x0C: 保留 */
    volatile uint8_t  data[8];    /* 0x10: data[0]=标识, data[1..]=有效数据 */
    volatile uint32_t tv_sec;     /* 0x18: 时间戳-秒 */
    volatile uint32_t tv_nsec;    /* 0x1C: 时间戳-纳秒 */
} share_slot_t;

/* 各报文的有效数据长度 */
static int get_data_len(uint8_t cmd)
{
    switch (cmd) {
        case RS422_CMD_DISPLACEMENT: return 3;
        case RS422_CMD_STATUS:       return 3;
        case RS422_CMD_TEMP:         return 1;
        case RS422_CMD_VOLTAGE:      return 2;
        case RS422_CMD_VERSION:      return 3;
        default:                     return -1; /* 未知报文 */
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
static void print_displacement(const uint8_t *data)
{
    /* data[0]=BYTE1: bit0=左键, bit1=右键, bit4=X符号, bit5=Y符号 */
    /* data[1]=X位移(补码), data[2]=Y位移(补码) */
    uint8_t b1 = data[0];
    int8_t x = (int8_t)data[1];
    int8_t y = (int8_t)data[2];
    int left  = b1 & 0x01;
    int right = (b1 >> 1) & 0x01;
    printf("  位移: X=%d Y=%d 左键=%d 右键=%d", x, y, left, right);
}

/* 状态信息解析显示 */
static void print_status(const uint8_t *data)
{
    uint8_t mode = (data[0] >> 6) & 0x01;
    uint8_t res  = data[1];
    uint8_t rate = data[2];
    printf("  状态: 模式=%s 分辨率=%d 采样率=%d",
           mode ? "Remote" : "Stream", res, rate);
}

/* 温度解析显示 */
static void print_temp(const uint8_t *data)
{
    int8_t temp = (int8_t)data[0];
    printf("  温度: %d℃", temp);
}

/* 电压解析显示 */
static void print_voltage(const uint8_t *data)
{
    /* 低8位在前，高8位在后，单位10mV */
    uint16_t vol = data[0] | (data[1] << 8);
    printf("  电压: %d.%dV", vol / 100, (vol % 100) / 10);
}

/* 版本解析显示 */
static void print_version(const uint8_t *data)
{
    printf("  版本: %d.%02d.%02d", data[0], data[1], data[2]);
}

/* 设置串口参数：115200 8N1 raw模式 */
static int setup_serial(int fd)
{
    struct termios tty;
    if (tcgetattr(fd, &tty) != 0) {
        perror("tcgetattr");
        return -1;
    }

    /* 波特率 */
    cfsetispeed(&tty, B115200);
    cfsetospeed(&tty, B115200);

    /* 8N1 + 启用接收 + 忽略调制解调器控制线（必须） */
    tty.c_cflag &= ~PARENB;
    tty.c_cflag &= ~CSTOPB;
    tty.c_cflag &= ~CSIZE;
    tty.c_cflag |= CS8;
    tty.c_cflag |= CLOCAL | CREAD;  /* 关键：否则串口无法收数据 */
    tty.c_cflag &= ~CRTSCTS;        /* 禁用硬件流控（RS422无RTS/CTS） */

    /* raw模式 */
    tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
    tty.c_iflag &= ~(IXON | IXOFF | IXANY | IGNBRK | BRKINT | INLCR | ICRNL);
    tty.c_oflag &= ~(OPOST | ONLCR);

    /* 阻塞读，至少1字节就返回 */
    tty.c_cc[VMIN]  = 1;
    tty.c_cc[VTIME] = 0;

    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        perror("tcsetattr");
        return -1;
    }
    return 0;
}

/* RS422帧解析状态机 */
typedef struct {
    int state;          /* 0=等帧头, 1=等标识, 2=读数据, 3=等校验和 */
    uint8_t cmd;        /* 当前报文标识 */
    int data_len;       /* 期望数据长度 */
    int data_idx;       /* 已读数据索引 */
    uint8_t buf[8];     /* 数据缓冲 */
    uint8_t checksum;   /* 累加校验和 */
} rs422_parser_t;

/* 状态机处理1字节，返回1=完整帧, 0=继续 */
static int parser_feed(rs422_parser_t *p, uint8_t b)
{
    switch (p->state) {
    case 0: /* 等待帧头 */
        if (b == RS422_FRAME_HEAD) {
            p->state = 1;
            p->checksum = b;  /* 校验和从帧头开始累加 */
        }
        return 0;

    case 1: /* 读报文标识 */
        p->cmd = b;
        p->data_len = get_data_len(b);
        if (p->data_len < 0) {
            /* 未知标识，重新等帧头 */
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
        if (p->data_idx >= p->data_len) {
            p->state = 3;
        }
        return 0;

    case 3: /* 读校验和 */
        p->state = 0;
        if ((p->checksum & 0xFF) == b) {
            return 1;  /* 校验通过，完整帧 */
        }
        /* 校验失败，丢弃 */
        return 0;

    default:
        p->state = 0;
        return 0;
    }
}

int main(int argc, char *argv[])
{
    const char *dev = (argc > 1) ? argv[1] : "/dev/ttyPS0";
    int fd, mem_fd;
    void *ddr;
    share_slot_t *slot;
    uint32_t seq = 0;
    rs422_parser_t parser;
    uint8_t buf[256];
    ssize_t n;
    int i;

    printf("=== RS422数据采集程序 V2（协议标准格式）===\n");
    printf("串口设备: %s\n", dev);
    printf("波特率: 115200 8N1\n");
    printf("DDR基址: 0x%08X\n", DDR_BASE);
    printf("RS422槽位: 0x%08X (device_id=%d)\n", DDR_BASE + SLOT_RS422, DEV_RS422);

    /* 打开串口 */
    fd = open(dev, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        perror("打开串口失败");
        printf("提示: 检查设备路径是否正确，或执行 sudo systemctl stop serial-getty@ttyPS0.service\n");
        return 1;
    }
    if (setup_serial(fd) < 0) {
        close(fd);
        return 1;
    }
    printf("串口打开成功\n");

    /* 映射DDR共享内存 */
    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) {
        perror("打开/dev/mem失败");
        close(fd);
        return 1;
    }
    ddr = mmap(NULL, DDR_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, DDR_BASE);
    if (ddr == MAP_FAILED) {
        perror("mmap失败");
        close(mem_fd);
        close(fd);
        return 1;
    }
    slot = (share_slot_t *)((uint8_t *)ddr + SLOT_RS422);
    printf("DDR映射成功，等待RS422数据... (Ctrl+C退出)\n\n");

    /* 清空串口缓冲 */
    tcflush(fd, TCIOFLUSH);

    /* 初始化解析器 */
    memset(&parser, 0, sizeof(parser));

    /* 主循环 */
    while (1) {
        n = read(fd, buf, sizeof(buf));
        if (n <= 0) {
            if (errno == EINTR) continue;
            perror("读取串口失败");
            break;
        }

        /* 逐字节喂给状态机 */
        for (i = 0; i < n; i++) {
            if (parser_feed(&parser, buf[i])) {
                /* 收到完整RS422帧，写入DDR */
                struct timespec ts;
                clock_gettime(CLOCK_MONOTONIC, &ts);

                /* 写入顺序：先写所有数据字段，最后写seq（提交标志）
                 * PC端检测seq变化时，前面字段已全部写入完成，避免DMA读取撕裂 */
                slot->device_id = DEV_RS422;
                slot->data_len  = parser.data_len;
                slot->reserved  = 0;
                /* data[0]=标识, data[1..]=有效数据（逐字节写入volatile内存） */
                slot->data[0]   = parser.cmd;
                {
                    int k;
                    for (k = 0; k < parser.data_len; k++) {
                        slot->data[1 + k] = parser.buf[k];
                    }
                    for (; k < 7; k++) {
                        slot->data[1 + k] = 0;  /* 剩余字节清零 */
                    }
                }
                slot->tv_sec    = (uint32_t)ts.tv_sec;
                slot->tv_nsec   = (uint32_t)ts.tv_nsec;
                /* 内存屏障：确保前面写入对其他观察者可见后再更新seq */
                __sync_synchronize();
                slot->seq       = ++seq;  /* 最后写seq，作为"数据已就绪"标志 */

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
    }

    munmap(ddr, DDR_SIZE);
    close(mem_fd);
    close(fd);
    return 0;
}
