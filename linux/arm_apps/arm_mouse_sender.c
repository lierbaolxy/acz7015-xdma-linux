/*
 * arm_mouse_sender.c - 开发板侧USB鼠标数据发送程序（协议标准格式V2）
 *
 * 改动说明（V1→V2）：
 *   - DDR结构从24字节单路格式升级为32字节统一槽位格式
 *   - 增加device_id字段区分USB/CAN/PS2/RS422四路接口
 *   - data字段封装input_event原始数据，符合协议"USB标准通信格式"要求
 *   - USB槽位固定在0x20000000，为CAN/PS2/RS422预留0x20000020/40/60
 *
 * 协议依据：d:\workspace\trae\day01\0702\protocol_spec.md
 *   - USB接口：标准通信格式即可，无自定义内容
 *   - DDR转发：统一32字节槽位{seq,device_id,data_len,reserved,data[8],tv_sec,tv_nsec}
 *
 * 编译：gcc -O2 -o arm_mouse_sender arm_mouse_sender.c
 * 运行：sudo ./arm_mouse_sender [设备路径]
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <linux/input.h>
#include <poll.h>
#include <stdint.h>

/* ===== DDR共享内存配置 ===== */
#define DDR_BASE    0x20000000
#define DDR_SIZE    4096

/* 四路接口槽位地址（每路32字节，对齐cache line，互不竞争） */
#define SLOT_USB     0x00   /* 0x20000000 USB */
#define SLOT_CAN     0x20   /* 0x20000020 CAN（预留） */
#define SLOT_PS2     0x40   /* 0x20000040 PS2（预留） */
#define SLOT_RS422   0x60   /* 0x20000060 RS422（预留） */

/* 接口类型标识 */
#define DEV_USB    0
#define DEV_CAN    1
#define DEV_PS2    2
#define DEV_RS422  3

/* 统一DDR转发槽位格式（32字节，对齐cache line，和protocol_spec.md一致） */
typedef struct {
    volatile uint32_t seq;        /* 0x00: 序号，每次事件+1（PC端检测变化） */
    volatile uint32_t device_id;  /* 0x04: 接口类型 0=USB 1=CAN 2=PS2 3=RS422 */
    volatile uint32_t data_len;   /* 0x08: 有效数据长度 */
    volatile uint32_t reserved;   /* 0x0C: 保留对齐 */
    volatile uint8_t  data[8];    /* 0x10: 原始数据（各接口上限8B，USB存input_event） */
    volatile uint32_t tv_sec;     /* 0x18: 时间戳-秒 */
    volatile uint32_t tv_nsec;    /* 0x1C: 时间戳-纳秒 */
} share_slot_t;  /* 共32字节 */

/* USB data字段封装格式（8字节）：type(2B)+code(2B)+value(4B)，正好填满data[8] */
typedef struct {
    uint16_t type;
    uint16_t code;
    int32_t  value;
} __attribute__((packed)) usb_event_t;

/* 事件类型名称 */
static const char *ev_type_name(uint16_t type)
{
    switch (type) {
        case EV_SYN:  return "SYN";
        case EV_KEY:  return "KEY";
        case EV_REL:  return "REL";
        default:      return "???";
    }
}

/* 事件代码名称 */
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

int main(int argc, char *argv[])
{
    int fd_input, fd_mem;
    volatile uint8_t *ddr_base;
    volatile share_slot_t *usb_slot;  /* USB槽位指针 */
    struct input_event ev;
    struct pollfd pfd;
    uint32_t seq = 0;
    const char *input_dev = "/dev/input/event0";  /* 默认鼠标设备 */

    /* --help 参数说明 */
    if (argc > 1 && (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0)) {
        printf("=== USB鼠标数据发送程序 V2（协议标准格式）===\n\n");
        printf("用法: sudo %s [选项] [设备路径]\n\n", argv[0]);
        printf("选项:\n");
        printf("  -h, --help    显示此帮助信息并退出\n\n");
        printf("参数:\n");
        printf("  设备路径       鼠标input设备路径（默认: %s）\n\n", input_dev);
        printf("功能:\n");
        printf("  采集USB鼠标事件（移动/按键/滚轮），写入DDR共享内存\n");
        printf("  通过XDMA DMA传输到PC端（c2h_0设备节点读取）\n\n");
        printf("DDR槽位格式（32字节，符合协议规范）:\n");
        printf("  0x20000000: USB槽位（device_id=0）\n");
        printf("  0x20000020: CAN槽位（预留，device_id=1）\n");
        printf("  0x20000040: PS2槽位（预留，device_id=2）\n");
        printf("  0x20000060: RS422槽位（预留，device_id=3）\n\n");
        printf("查找鼠标设备:\n");
        printf("  cat /proc/bus/input/devices | grep -A6 'Usb Mouse'\n");
        printf("  查看 Handlers=eventX 的X值\n\n");
        printf("示例:\n");
        printf("  sudo %s                          # 使用默认设备 %s\n", argv[0], input_dev);
        printf("  sudo %s /dev/input/event0        # 指定设备\n", argv[0]);
        printf("  sudo %s /dev/input/event2        # 其他设备号\n", argv[0]);
        return 0;
    }

    if (argc > 1)
        input_dev = argv[1];

    /* 打开鼠标设备 */
    fd_input = open(input_dev, O_RDONLY);
    if (fd_input < 0) {
        perror("打开鼠标设备失败");
        printf("用法: %s [设备路径，默认/dev/input/event1]\n", argv[0]);
        return 1;
    }

    /* 映射DDR共享内存 */
    fd_mem = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd_mem < 0) {
        perror("打开/dev/mem失败");
        close(fd_input);
        return 1;
    }

    ddr_base = (volatile uint8_t *)mmap(NULL, DDR_SIZE,
             PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DDR_BASE);
    if (ddr_base == MAP_FAILED) {
        perror("mmap失败");
        close(fd_mem);
        close(fd_input);
        return 1;
    }

    /* USB槽位指针：DDR基址 + USB偏移 */
    usb_slot = (volatile share_slot_t *)(ddr_base + SLOT_USB);

    /* 初始化USB槽位 */
    usb_slot->seq = 0;
    usb_slot->device_id = DEV_USB;
    usb_slot->data_len = 0;
    memset((void *)usb_slot->data, 0, 8);

    printf("=== USB鼠标数据发送程序 V2（协议标准格式）===\n");
    printf("输入设备: %s\n", input_dev);
    printf("DDR基址: 0x%08X\n", DDR_BASE);
    printf("USB槽位: 0x%08X (device_id=%d)\n", DDR_BASE + SLOT_USB, DEV_USB);
    printf("槽位大小: %d字节\n", (int)sizeof(share_slot_t));
    printf("等待鼠标事件... (Ctrl+C退出)\n\n");

    pfd.fd = fd_input;
    pfd.events = POLLIN;

    while (1) {
        /* 无限等待鼠标事件，没事件不消耗CPU */
        int ret = poll(&pfd, 1, -1);
        if (ret <= 0) continue;

        /* 读取鼠标事件 */
        ssize_t n = read(fd_input, &ev, sizeof(ev));
        if (n != sizeof(ev)) continue;

        /* 跳过同步事件（EV_SYN），只上报关键事件 */
        if (ev.type == EV_SYN) continue;

        /* 跳过MSC_SCAN扫描码事件（EV_MSC），它是USB HID的辅助信息，
         * 上位机只需KEY按键/REL移动/REL滚轮等实际动作数据。
         * 如后续需要MSC扫描码（如按键来源追踪），去掉此判断即可 */
        if (ev.type == EV_MSC) continue;

        seq++;

        /* 封装USB data字段：type+code+value 共8字节 */
        usb_event_t usb_ev;
        usb_ev.type  = ev.type;
        usb_ev.code  = ev.code;
        usb_ev.value = ev.value;

        /* 先写数据字段 */
        usb_slot->device_id = DEV_USB;
        usb_slot->data_len  = sizeof(usb_event_t);  /* 8字节 */
        memset((void *)usb_slot->data, 0, 8);
        memcpy((void *)usb_slot->data, &usb_ev, sizeof(usb_ev));
        usb_slot->tv_sec  = (uint32_t)ev.time.tv_sec;
        usb_slot->tv_nsec = (uint32_t)ev.time.tv_usec * 1000;

        /* 内存屏障，确保数据写入完成 */
        __sync_synchronize();

        /* 最后写seq，PC端检测seq变化 */
        usb_slot->seq = seq;

        printf("[发送 #%u] USB %s %s = %d (data_len=%u)\n",
               seq, ev_type_name(ev.type), ev_code_name(ev.type, ev.code),
               ev.value, (uint32_t)sizeof(usb_event_t));
        fflush(stdout);
    }

    munmap((void*)ddr_base, DDR_SIZE);
    close(fd_mem);
    close(fd_input);
    return 0;
}
