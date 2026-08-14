/*
 * 开发板Linux侧：USB鼠标延时测试程序
 * 功能：1. 乒乓法响应PC的延时测量请求 2. 持续把USB鼠标数据写入DDR共享内存
 * 编译：arm-linux-gnueabihf-gcc -O2 -o arm_mouse_latency arm_mouse_latency.c
 * 运行：sudo ./arm_mouse_latency
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <poll.h>
#include <time.h>
#include <sys/mman.h>
#include <linux/input.h>

/* DDR共享内存物理地址（reserved-memory区域） */
#define DDR_BASE       0x20000000
#define DDR_MAP_SIZE   4096

/* 共享内存寄存器偏移 */
#define OFF_REQ_SEQ    0x00  /* PC写的请求序号 */
#define OFF_RSP_SEQ    0x04  /* 开发板写的响应序号 */
#define OFF_MOUSE_DATA 0x08  /* 鼠标数据 */
#define OFF_TS_LO      0x0C  /* 时间戳低32位 */
#define OFF_TS_HI      0x10  /* 时间戳高32位 */

#define MOUSE_DEV "/dev/input/event1"

/* volatile指针，确保每次直接读写内存 */
static volatile unsigned int *reg;

int main(int argc, char **argv)
{
    int fd_mem, fd_mouse;
    void *map_base;
    struct pollfd pfd;
    struct input_event ev;
    unsigned int last_req_seq = 0;
    unsigned int rsp_seq = 0;
    unsigned int mouse_data = 0;
    int ret;

    printf("=== 开发板USB鼠标延时测试程序 ===\n");

    /* 1. 打开/dev/mem，映射DDR共享内存 */
    fd_mem = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd_mem < 0) {
        perror("打开/dev/mem失败");
        return 1;
    }
    map_base = mmap(NULL, DDR_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DDR_BASE);
    if (map_base == MAP_FAILED) {
        perror("mmap失败");
        close(fd_mem);
        return 1;
    }
    reg = (volatile unsigned int *)map_base;

    /* 初始化共享内存 */
    reg[OFF_REQ_SEQ / 4]    = 0;
    reg[OFF_RSP_SEQ / 4]    = 0;
    reg[OFF_MOUSE_DATA / 4] = 0;
    reg[OFF_TS_LO / 4]      = 0;
    reg[OFF_TS_HI / 4]      = 0;

    printf("DDR共享内存映射成功: phys=0x%08X virt=%p\n", DDR_BASE, map_base);

    /* 2. 打开USB鼠标event设备 */
    fd_mouse = open(MOUSE_DEV, O_RDONLY);
    if (fd_mouse < 0) {
        perror("打开" MOUSE_DEV "失败");
        munmap(map_base, DDR_MAP_SIZE);
        close(fd_mem);
        return 1;
    }
    printf("USB鼠标设备打开成功: %s\n", MOUSE_DEV);

    /* 设置poll */
    pfd.fd = fd_mouse;
    pfd.events = POLLIN;

    printf("开始运行（乒乓法响应 + 鼠标数据转发）...\n");
    printf("请移动/点击鼠标，PC端运行测延时程序\n\n");

    /* 3. 主循环：同时处理鼠标事件和乒乓法响应 */
    while (1) {
        /* 检查PC的延时测量请求（乒乓法） */
        unsigned int req_seq = reg[OFF_REQ_SEQ / 4];
        if (req_seq != last_req_seq) {
            /* 收到新请求，立即写响应 */
            struct timespec ts;
            clock_gettime(CLOCK_MONOTONIC, &ts);
            reg[OFF_RSP_SEQ / 4]    = req_seq;
            reg[OFF_TS_LO / 4]      = (unsigned int)(ts.tv_nsec & 0xFFFFFFFF);
            reg[OFF_TS_HI / 4]      = (unsigned int)ts.tv_sec;
            last_req_seq = req_seq;
            printf("[乒乓] 收到请求 seq=%u, 已响应\n", req_seq);
        }

        /* 轮询鼠标事件（1ms超时，快速响应乒乓法请求） */
        ret = poll(&pfd, 1, 1);
        if (ret < 0) {
            if (errno == EINTR) continue;
            perror("poll失败");
            break;
        }
        if (ret == 0) continue; /* 超时，继续检查乒乓法 */

        if (pfd.revents & POLLIN) {
            /* 读鼠标事件 */
            ret = read(fd_mouse, &ev, sizeof(ev));
            if (ret == sizeof(ev)) {
                struct timespec ts;
                clock_gettime(CLOCK_MONOTONIC, &ts);

                /* 打包鼠标数据：[16位type] [16位code] [32位value] */
                mouse_data = (ev.type << 16) | (ev.code & 0xFFFF);

                /* 写入共享内存 */
                reg[OFF_MOUSE_DATA / 4] = mouse_data;
                reg[OFF_TS_LO / 4]      = (unsigned int)(ts.tv_nsec & 0xFFFFFFFF);
                reg[OFF_TS_HI / 4]      = (unsigned int)ts.tv_sec;

                /* 只打印有效事件 */
                if (ev.type == EV_KEY || ev.type == EV_REL) {
                    printf("[鼠标] type=%d code=%d value=%d\n",
                           ev.type, ev.code, ev.value);
                }
            }
        }
    }

    /* 清理 */
    munmap(map_base, DDR_MAP_SIZE);
    close(fd_mouse);
    close(fd_mem);
    return 0;
}
