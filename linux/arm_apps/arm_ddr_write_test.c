/*
 * arm_ddr_write_test.c - 板端向 DDR 0x20000000 写固定 pattern 并 cache flush
 * 用途：验证 XDMA 读 DDR 通路（cache 一致性修复），不依赖鼠标
 *
 * 槽位格式(32B)：{seq, device_id, data_len, reserved, data[8], tv_sec, tv_nsec}
 * data 字段写固定 USB 事件：type=EV_REL(2), code=REL_X(0), value=1 -> PC端显示"X轴=1"
 *
 * 编译：gcc -O2 -o arm_ddr_write_test arm_ddr_write_test.c
 * 运行：sudo ./arm_ddr_write_test   (Ctrl+C 退出)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdint.h>
#include <time.h>
#include <sys/syscall.h>

#define DDR_BASE    0x20000000
#define DDR_SIZE    4096

#ifndef __ARM_NR_cacheflush
#define __ARM_NR_cacheflush (0x0f0000 + 2)
#endif

typedef struct {
    volatile uint32_t seq;
    volatile uint32_t device_id;
    volatile uint32_t data_len;
    volatile uint32_t reserved;
    volatile uint8_t  data[8];
    volatile uint32_t tv_sec;
    volatile uint32_t tv_nsec;
} slot_t;

/* D-cache clean(写回，flags=0)，确保 XDMA via AXI 能读到最新数据 */
static inline void dma_wb(const void *p, size_t n)
{
    syscall(__ARM_NR_cacheflush, (long)p, (long)((const char *)p + n), 0);
}

int main(void)
{
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open /dev/mem"); return 1; }
    volatile slot_t *s = (volatile slot_t *)mmap(NULL, DDR_SIZE,
                           PROT_READ | PROT_WRITE, MAP_SHARED, fd, DDR_BASE);
    if (s == MAP_FAILED) { perror("mmap DDR"); return 1; }
    close(fd);

    uint32_t seq = 0;
    struct timespec ts;
    printf("写入 pattern 到 DDR 0x%08X，每200ms seq+1，Ctrl+C退出\n", DDR_BASE);
    fflush(stdout);

    while (1) {
        clock_gettime(CLOCK_MONOTONIC, &ts);
        /* 先写数据字段，最后写 seq（原子就绪标志） */
        s->device_id = 0;                 /* USB */
        s->data_len  = 8;
        s->reserved  = 0;
        /* data: type=EV_REL(2) code=REL_X(0) value=1 (小端) */
        s->data[0] = 0x02; s->data[1] = 0x00;   /* type  = 0x0002 = EV_REL */
        s->data[2] = 0x00; s->data[3] = 0x00;   /* code  = 0x0000 = REL_X  */
        s->data[4] = 0x01; s->data[5] = 0x00;   /* value = 0x00000001      */
        s->data[6] = 0x00; s->data[7] = 0x00;
        s->tv_sec  = (uint32_t)ts.tv_sec;
        s->tv_nsec = (uint32_t)ts.tv_nsec;
        __sync_synchronize();
        s->seq = ++seq;
        dma_wb((const void *)s, sizeof(slot_t));  /* 刷回 DDR */
        usleep(200000);
    }
    return 0;
}