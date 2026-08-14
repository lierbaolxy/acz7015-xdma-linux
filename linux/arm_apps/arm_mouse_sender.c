/*
 * arm_mouse_sender.c - 开发板侧鼠标数据发送程序
 * 功能：读USB鼠标事件，有事件时写DDR共享内存，没事件不上报
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

#define DDR_BASE    0x20000000
#define DDR_SIZE    4096

/* DDR共享内存结构 */
typedef struct {
    volatile uint32_t seq;      /* 0x00: 序号，每次事件+1 */
    volatile uint32_t type;     /* 0x04: 事件类型 */
    volatile uint32_t code;     /* 0x08: 事件代码 */
    volatile uint32_t value;    /* 0x0C: 事件值 */
    volatile uint32_t tv_sec;   /* 0x10: 时间戳-秒 */
    volatile uint32_t tv_nsec;  /* 0x14: 时间戳-纳秒 */
} mouse_share_t;

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
    volatile mouse_share_t *share;
    struct input_event ev;
    struct pollfd pfd;
    uint32_t seq = 0;
    const char *input_dev = "/dev/input/event1";

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

    share = (volatile mouse_share_t *)mmap(NULL, DDR_SIZE,
             PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DDR_BASE);
    if (share == MAP_FAILED) {
        perror("mmap失败");
        close(fd_mem);
        close(fd_input);
        return 1;
    }

    /* 初始化共享内存 */
    share->seq = 0;
    share->type = 0;
    share->code = 0;
    share->value = 0;

    printf("=== 鼠标数据发送程序 ===\n");
    printf("输入设备: %s\n", input_dev);
    printf("DDR共享内存: 0x%08X\n", DDR_BASE);
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

        /* 跳过同步事件，只上报关键事件 */
        if (ev.type == EV_SYN) continue;

        seq++;

        /* 先写数据字段 */
        share->type    = (uint32_t)ev.type;
        share->code    = (uint32_t)ev.code;
        share->value   = (uint32_t)ev.value;
        share->tv_sec  = (uint32_t)ev.time.tv_sec;
        share->tv_nsec = (uint32_t)ev.time.tv_usec * 1000;

        /* 内存屏障，确保数据写入完成 */
        __sync_synchronize();

        /* 最后写seq，PC端检测seq变化 */
        share->seq = seq;

        printf("[发送 #%u] %s %s = %d\n",
               seq, ev_type_name(ev.type), ev_code_name(ev.type, ev.code), ev.value);
        fflush(stdout);
    }

    munmap((void*)share, DDR_SIZE);
    close(fd_mem);
    close(fd_input);
    return 0;
}
