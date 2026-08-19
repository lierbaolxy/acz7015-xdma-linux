/*
 * arm_usb_rs422_sender.c - USB鼠标 + RS422 双路数据采集程序（协议标准格式，寄存器级）
 *
 * 功能：单进程并行采集两路数据，分别写入 DDR 共享内存不同槽位：
 *   - USB 鼠标：poll()/dev/input/eventX 读 Linux input_event，写槽位 0x20000000 (device_id=0)
 *   - RS422   ：寄存器级轮询 PS UART1(EMIO) FIFO，解析协议帧，写槽位 0x20000060 (device_id=3)
 *
 * 并发模型：单线程 —— poll 鼠标 fd 用 5ms 短超时；超时即轮询 UART1 RX FIFO。
 *   两路槽位地址独立、seq 各自递增，无需加锁。115200 波特率下 5ms 轮询远快于 FIFO 溢出。
 *
 * 硬件连接（同各单独程序）：
 *   USB  ：鼠标插开发板 USB Host 口，设备节点 /dev/input/eventX
 *   RS422：pin26(E5)=UART1_TX, pin28(B1)=UART1_RX, pin29=3.3V, pin30=GND
 *
 * 协议依据：docs/USB接口对接文档.md + docs/RS422接口对接文档.md
 *   DDR 槽位 : 统一32字节 {seq,device_id,data_len,reserved,data[8],tv_sec,tv_nsec}
 *   RS422帧  : 帧头0x55 | 标识0xD1~0xD5 | 有效数据 | 校验和(累加取低8位)
 *
 * 编译：gcc -O2 -o arm_usb_rs422_sender arm_usb_rs422_sender.c
 * 运行：sudo systemctl stop serial-getty@ttyPS0.service   # RS422 占用 UART1，需先停 console
 *       sudo ./arm_usb_rs422_sender [/dev/input/eventX]
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <sys/mman.h>
#include <linux/input.h>
#include <poll.h>
#include <stdint.h>
#include <time.h>
#include <sys/syscall.h>

/* ===== DDR共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    4096

/* 四路接口槽位地址（每路32字节，对齐cache line，互不竞争） */
#define SLOT_USB     0x00   /* 0x20000000 USB */
#define SLOT_CAN     0x20   /* 0x20000020 CAN（预留） */
#define SLOT_PS2     0x40   /* 0x20000040 PS2（预留） */
#define SLOT_RS422   0x60   /* 0x20000060 RS422 */

/* 接口类型标识 */
#define DEV_USB    0
#define DEV_CAN    1
#define DEV_PS2    2
#define DEV_RS422  3

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

/* ===== RS422协议常量 ===== */
#define RS422_FRAME_HEAD       0x55
#define RS422_CMD_DISPLACEMENT 0xD1   /* 位移信息，3字节数据 */
#define RS422_CMD_STATUS       0xD2   /* 状态信息，3字节数据 */
#define RS422_CMD_TEMP         0xD3   /* 温度，1字节数据 */
#define RS422_CMD_VOLTAGE      0xD4   /* 电压，2字节数据 */
#define RS422_CMD_VERSION      0xD5   /* 版本，3字节数据 */

/* 统一DDR转发槽位格式（32字节，对齐cache line） */
typedef struct {
    volatile uint32_t seq;        /* 0x00: 序号，每次事件+1（PC端检测变化） */
    volatile uint32_t device_id;  /* 0x04: 0=USB 1=CAN 2=PS2 3=RS422 */
    volatile uint32_t data_len;   /* 0x08: 有效数据长度 */
    volatile uint32_t reserved;   /* 0x0C: 保留对齐 */
    volatile uint8_t  data[8];    /* 0x10: 原始数据（见各接口封装） */
    volatile uint32_t tv_sec;     /* 0x18: 时间戳-秒 */
    volatile uint32_t tv_nsec;    /* 0x1C: 时间戳-纳秒 */
} share_slot_t;  /* 共32字节 */

/* ARM cacheflush 系统调用号 */
#ifndef __ARM_NR_cacheflush
#define __ARM_NR_cacheflush (0x0f0000 + 2)
#endif

/* 将共享槽位写回 DDR（D-cache clean，flags=0），确保 XDMA via AXI 能读到最新数据 */
static inline void dma_wb_slot(const volatile void *p)
{
    syscall(__ARM_NR_cacheflush, (long)p,
            (long)((const char *)p + sizeof(share_slot_t)), 0);
}

/* USB data字段封装（8字节）：type(2B)+code(2B)+value(4B) */
typedef struct {
    uint16_t type;
    uint16_t code;
    int32_t  value;
} __attribute__((packed)) usb_event_t;

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

/* ===== USB 事件名称辅助 ===== */
static const char *ev_type_name(uint16_t type)
{
    switch (type) {
        case EV_KEY:  return "KEY";
        case EV_REL:  return "REL";
        default:      return "???";
    }
}

static const char *ev_code_name(uint16_t type, uint16_t code)
{
    if (type == EV_KEY) {
        switch (code) {
            case BTN_LEFT:   return "左键";
            case BTN_RIGHT:  return "右键";
            case BTN_MIDDLE: return "中键";
            default:         return "其他键";
        }
    }
    if (type == EV_REL) {
        switch (code) {
            case REL_X:      return "X轴";
            case REL_Y:      return "Y轴";
            case REL_WHEEL:  return "滚轮";
            default:         return "其他";
        }
    }
    return "-";
}

/* ===== RS422 帧解析 ===== */
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

static const char *rs422_cmd_name(uint8_t cmd)
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
static void print_rs422_displacement(const uint8_t *bf)
{
    int8_t x = (int8_t)bf[1];
    int8_t y = (int8_t)bf[2];
    printf("  位移: X=%d Y=%d 左键=%d 右键=%d",
           x, y, bf[0] & 0x01, (bf[0] >> 1) & 0x01);
}

static void print_rs422_status(const uint8_t *bf)
{
    printf("  状态: 模式=%s 分辨率=%d 采样率=%d",
           (bf[0] >> 6) & 0x01 ? "Remote" : "Stream", bf[1], bf[2]);
}

static void print_rs422_temp(const uint8_t *bf)
{
    printf("  温度: %d℃", (int8_t)bf[0]);
}

static void print_rs422_voltage(const uint8_t *bf)
{
    uint16_t vol = bf[0] | (bf[1] << 8);
    printf("  电压: %d.%dV", vol / 100, (vol % 100) / 10);
}

static void print_rs422_version(const uint8_t *bf)
{
    printf("  版本: %d.%02d.%02d", bf[0], bf[1], bf[2]);
}

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
    case 0:
        if (b == RS422_FRAME_HEAD) {
            p->state = 1;
            p->checksum = b;
        }
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
        if (p->data_idx >= p->data_len)
            p->state = 3;
        return 0;
    case 3:
        p->state = 0;
        return ((p->checksum & 0xFF) == b) ? 1 : 0;
    default:
        p->state = 0;
        return 0;
    }
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IOLBF, 0);

    int fd_input, fd_mem;
    volatile uint8_t *ddr_base;
    volatile share_slot_t *usb_slot;
    volatile share_slot_t *rs422_slot;
    struct input_event ev;
    struct pollfd pfd;
    uint32_t usb_seq = 0;
    uint32_t rs422_seq = 0;
    const char *input_dev = "/dev/input/event1";

    if (argc > 1)
        input_dev = argv[1];

    printf("=== USB鼠标 + RS422 双路数据采集程序（协议标准格式，寄存器级）===\n");

    /* 1. 切 MIO49/48 -> GPIO，释放 UART1 EMIO RX 污染（RS422 接收前提） */
    volatile uint32_t *slcr = map_phys(SLCR_BASE);
    if (!slcr) return 1;
    wr(slcr, 0x008, 0xDF0D);   /* UNLOCK */
    __sync_synchronize();
    wr(slcr, 0x7C0, 0x1200);   /* MIO48 -> GPIO */
    wr(slcr, 0x7C4, 0x1200);   /* MIO49 -> GPIO */
    __sync_synchronize();
    wr(slcr, 0x004, 0x767B);   /* LOCK */
    __sync_synchronize();
    printf("[SLCR] MIO48/49 已切 GPIO (0x1200)\n");

    /* 2. mmap UART1，禁中断，NORMAL 模式（RS422 寄存器级接收） */
    volatile uint32_t *uart = map_phys(UART1_BASE);
    if (!uart) return 1;
    wr(uart, IDR, 0xFFFFFFFF);
    wr(uart, MR, 0x20);

    /* 3. mmap DDR 共享内存 */
    fd_mem = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd_mem < 0) { perror("open /dev/mem (DDR)"); return 1; }
    ddr_base = (volatile uint8_t *)mmap(NULL, DDR_SIZE,
             PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DDR_BASE);
    if (ddr_base == MAP_FAILED) { perror("mmap DDR"); close(fd_mem); return 1; }
    usb_slot   = (volatile share_slot_t *)(ddr_base + SLOT_USB);
    rs422_slot = (volatile share_slot_t *)(ddr_base + SLOT_RS422);

    /* 4. 打开鼠标设备 */
    fd_input = open(input_dev, O_RDONLY);
    if (fd_input < 0) {
        perror("打开鼠标设备失败");
        printf("用法: %s [/dev/input/eventX，默认%s]\n", argv[0], input_dev);
        printf("提示: cat /proc/bus/input/devices 查看鼠标对应 event 节点\n");
        close(fd_mem);
        return 1;
    }

    printf("USB 槽位: 0x%08X (device_id=%d)  输入设备: %s\n",
           DDR_BASE + SLOT_USB, DEV_USB, input_dev);
    printf("RS422槽位: 0x%08X (device_id=%d)\n", DDR_BASE + SLOT_RS422, DEV_RS422);
    printf("两路并行收集中... (Ctrl+C 退出)\n\n");

    pfd.fd = fd_input;
    pfd.events = POLLIN;

    rs422_parser_t parser;
    parser_reset(&parser);

    /* 5. 主循环：poll 鼠标(5ms超时) + 超时轮询 UART1 FIFO */
    while (1) {
        /* 5.1 USB：读鼠标事件 */
        int ret = poll(&pfd, 1, 5);
        if (ret > 0 && (pfd.revents & POLLIN)) {
            ssize_t n = read(fd_input, &ev, sizeof(ev));
            if (n == sizeof(ev)) {
                if (ev.type != EV_SYN && ev.type != EV_MSC) {
                    usb_event_t usb_ev;
                    usb_ev.type  = ev.type;
                    usb_ev.code  = ev.code;
                    usb_ev.value = ev.value;

                    usb_slot->device_id = DEV_USB;
                    usb_slot->data_len  = sizeof(usb_event_t);
                    usb_slot->reserved  = 0;
                    memset((void *)usb_slot->data, 0, 8);
                    memcpy((void *)usb_slot->data, &usb_ev, sizeof(usb_ev));
                    usb_slot->tv_sec  = (uint32_t)ev.time.tv_sec;
                    usb_slot->tv_nsec = (uint32_t)ev.time.tv_usec * 1000;
                    __sync_synchronize();
                    usb_slot->seq = ++usb_seq;
                    dma_wb_slot(usb_slot);   /* 刷回DDR，XDMA才能读到 */

                    printf("[USB #%u] %s %s = %d\n",
                           usb_seq, ev_type_name(ev.type),
                           ev_code_name(ev.type, ev.code), ev.value);
                }
            }
        }

        /* 5.2 RS422：轮询 UART1 RX FIFO，逐字节喂状态机 */
        int cnt = 0;
        while (!(rd(uart, SR) & SR_RXEMPTY) && cnt < 256) {
            uint8_t b = (uint8_t)(rd(uart, FIFO) & 0xFF);
            cnt++;

            if (parser_feed(&parser, b)) {
                struct timespec ts;
                clock_gettime(CLOCK_MONOTONIC, &ts);

                rs422_slot->device_id = DEV_RS422;
                rs422_slot->data_len  = (uint32_t)parser.data_len;
                rs422_slot->reserved  = 0;
                rs422_slot->data[0]   = parser.cmd;
                {
                    int k;
                    for (k = 0; k < parser.data_len; k++)
                        rs422_slot->data[1 + k] = parser.buf[k];
                    for (; k < 7; k++)
                        rs422_slot->data[1 + k] = 0;
                }
                rs422_slot->tv_sec  = (uint32_t)ts.tv_sec;
                rs422_slot->tv_nsec = (uint32_t)ts.tv_nsec;
                __sync_synchronize();
                rs422_slot->seq = ++rs422_seq;
                dma_wb_slot(rs422_slot);   /* 刷回DDR，XDMA才能读到 */

                printf("[RS422 #%u] %s", rs422_seq, rs422_cmd_name(parser.cmd));
                switch (parser.cmd) {
                    case RS422_CMD_DISPLACEMENT: print_rs422_displacement(parser.buf); break;
                    case RS422_CMD_STATUS:       print_rs422_status(parser.buf); break;
                    case RS422_CMD_TEMP:         print_rs422_temp(parser.buf); break;
                    case RS422_CMD_VOLTAGE:      print_rs422_voltage(parser.buf); break;
                    case RS422_CMD_VERSION:      print_rs422_version(parser.buf); break;
                }
                printf("\n");
            }
        }
    }

    munmap((void *)ddr_base, DDR_SIZE);
    close(fd_mem);
    close(fd_input);
    return 0;
}