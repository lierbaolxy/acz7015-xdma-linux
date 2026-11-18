/*
 * relay_test.c - 面板 MENU 继电器（XS1-25/26 无源触点）控制与验证工具
 *
 * 硬件：单路继电器模块（SRD-03VDC-SL-C，3V 线圈，光耦隔离，高电平触发）
 *   DC+  -> GPIO1 (P9) pin29 (3.3V)     注意：不是 GPIO0 pin29（已被编码器占用）
 *   DC-  -> GPIO1 (P9) pin30 (GND)
 *   IN   -> GPIO0 pin35 (FPGA 球 E8)
 *   COM  -> XS1-25 (DSO)
 *   NO   -> XS1-26 (DSO_RTN)
 *   NC   -> 悬空
 *   S1 跳线 -> high（高电平触发）
 *
 * 寄存器：0x83C0000C bit0   1=吸合（25/26 导通，面板认为 MENU 按下）  0=释放
 *
 * 用法：
 *   relay_test on            吸合
 *   relay_test off           释放
 *   relay_test click [ms]    按一下（默认 200ms）
 *   relay_test blink [次] [ms]  反复吸合/释放，便于万用表测通断
 *   relay_test read          只读当前状态
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define ENC_KEY_BASE 0x83C00000UL
#define MAP_SIZE     0x1000UL
#define REG_RELAY    0x0C

static volatile uint32_t* reg = NULL;

static int map_reg(void)
{
	int fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (fd < 0) { perror("open /dev/mem"); return -1; }
	void* p = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, ENC_KEY_BASE);
	if (p == MAP_FAILED) { perror("mmap"); close(fd); return -1; }
	reg = (volatile uint32_t*)p;
	close(fd);
	return 0;
}

static void set_relay(int on)
{
	uint32_t v = reg[REG_RELAY / 4];
	if (on) v |= 0x1;
	else    v &= ~0x1u;
	reg[REG_RELAY / 4] = v;
	__sync_synchronize();
}

static int get_relay(void)
{
	return (int)(reg[REG_RELAY / 4] & 0x1);
}

int main(int argc, char* argv[])
{
	const char* cmd = (argc > 1) ? argv[1] : "read";

	if (map_reg() != 0)
		return 1;

	printf("继电器寄存器 0x%08lX = 0x%08X（当前 %s）\n",
		(unsigned long)(ENC_KEY_BASE + REG_RELAY),
		reg[REG_RELAY / 4], get_relay() ? "吸合/25-26导通" : "释放/25-26断开");

	if (strcmp(cmd, "on") == 0) {
		set_relay(1);
		printf("-> 已吸合：XS1-25 与 XS1-26 导通（面板应识别为 MENU 按下）\n");
	}
	else if (strcmp(cmd, "off") == 0) {
		set_relay(0);
		printf("-> 已释放：XS1-25 与 XS1-26 断开\n");
	}
	else if (strcmp(cmd, "click") == 0) {
		int ms = (argc > 2) ? atoi(argv[2]) : 200;
		if (ms < 20) ms = 20;
		set_relay(1);
		printf("-> 按下 %d ms ...\n", ms);
		usleep(ms * 1000);
		set_relay(0);
		printf("-> 已松开\n");
	}
	else if (strcmp(cmd, "blink") == 0) {
		int n = (argc > 2) ? atoi(argv[2]) : 10;
		int ms = (argc > 3) ? atoi(argv[3]) : 500;
		if (n <= 0) n = 10;
		printf("-> 翻转 %d 次，间隔 %d ms（可用万用表通断档测 XS1-25/26）\n", n, ms);
		for (int i = 0; i < n; i++) {
			set_relay(1);
			printf("   [%d] 吸合 25-26=%d\n", i + 1, get_relay());
			usleep(ms * 1000);
			set_relay(0);
			printf("   [%d] 释放 25-26=%d\n", i + 1, get_relay());
			usleep(ms * 1000);
		}
	}
	else if (strcmp(cmd, "read") != 0) {
		printf("用法: %s {on|off|click [ms]|blink [次] [ms]|read}\n", argv[0]);
		return 1;
	}

	printf("结束状态: %s（寄存器=0x%08X）\n",
		get_relay() ? "吸合" : "释放", reg[REG_RELAY / 4]);
	return 0;
}
