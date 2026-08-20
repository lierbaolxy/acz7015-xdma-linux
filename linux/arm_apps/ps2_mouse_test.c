/*
 * ps2_mouse_test.c - PS/2转USB鼠标数据实时验证（板端）
 *
 * 用法: sudo ./ps2_mouse_test [/dev/input/eventN]
 *       默认监听 /dev/input/event4（PS/2转USB鼠标 13ba:0018 鼠标接口）
 *       对照: /dev/input/event1（HP原生USB鼠标）
 * 操作: 移动/点击/滚动鼠标，实时打印；Ctrl+C 退出并打印统计
 */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/input.h>

static volatile sig_atomic_t g_run = 1;

static void sig_handler(int sig)
{
	(void)sig;
	g_run = 0;
}

int main(int argc, char **argv)
{
	const char *dev = (argc > 1) ? argv[1] : "/dev/input/event4";
	struct input_event ev;
	long frames = 0, keys = 0, total = 0;
	int fd, dx, dy, wh, dirty;

	signal(SIGINT, sig_handler);

	fd = open(dev, O_RDONLY);
	if (fd < 0) {
		fprintf(stderr, "open %s failed: %s (try sudo)\n",
			dev, strerror(errno));
		return 1;
	}

	printf("listening on %s, move/click/scroll mouse, Ctrl+C to exit...\n", dev);

	dx = dy = wh = 0;
	dirty = 0;
	while (g_run) {
		ssize_t n = read(fd, &ev, sizeof(ev));

		if (n != sizeof(ev)) {
			if (n < 0 && errno == EINTR)
				continue;
			break;
		}
		total++;

		switch (ev.type) {
		case EV_REL:
			/* 位移/滚轮事件，帧内累计 */
			if (ev.code == REL_X) {
				dx += ev.value; dirty = 1;
			} else if (ev.code == REL_Y) {
				dy += ev.value; dirty = 1;
			} else if (ev.code == REL_WHEEL) {
				wh += ev.value; dirty = 1;
			}
			break;
		case EV_KEY:
			/* 按键事件，立即打印 */
			if (ev.code == BTN_LEFT || ev.code == BTN_RIGHT ||
			    ev.code == BTN_MIDDLE) {
				const char *name = ev.code == BTN_LEFT  ? "L-btn" :
						   ev.code == BTN_RIGHT ? "R-btn" : "M-btn";
				printf("[key #%ld] %s %s\n", ++keys, name,
				       ev.value ? "DOWN" : "UP");
				fflush(stdout);
			}
			break;
		case EV_SYN:
			/* 一帧结束，聚合输出一行，避免刷屏 */
			if (ev.code == SYN_REPORT && dirty) {
				printf("[move #%ld] X%+d Y%+d", ++frames, dx, dy);
				if (wh)
					printf(" wheel%+d", wh);
				printf("\n");
				fflush(stdout);
				dx = dy = wh = 0;
				dirty = 0;
			}
			break;
		default:
			break;
		}
	}

	printf("\n===== summary =====\n");
	printf("raw events : %ld\n", total);
	printf("move frames: %ld\n", frames);
	printf("key events : %ld\n", keys);
	if (total == 0)
		printf("NO DATA: check you moved the right mouse\n");
	close(fd);
	return 0;
}
