/*
 * uart_level_test.c - UART1电平测试（万用表配合）
 * 用法: sudo ./uart_level_test zero|one
 *   zero = 300bps连续发0x00 → pin26应≈0V
 *   one  = 300bps连续发0xFF → pin26应≈3.3V
 * Ctrl+C退出
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <signal.h>

static int fd = -1;
static volatile sig_atomic_t running = 1;

static void on_sigint(int s) { running = 0; }

int main(int argc, char **argv)
{
    if (argc < 2 || (strcmp(argv[1], "zero") && strcmp(argv[1], "one"))) {
        fprintf(stderr, "用法: %s zero|one\n", argv[0]);
        return 1;
    }
    int send_zero = (strcmp(argv[1], "zero") == 0);

    signal(SIGINT, on_sigint);

    fd = open("/dev/ttyPS0", O_RDWR | O_NOCTTY);
    if (fd < 0) { perror("open"); return 1; }

    struct termios tio;
    tcgetattr(fd, &tio);
    cfmakeraw(&tio);
    tio.c_cflag |= (CLOCAL | CREAD);
    tio.c_cc[VMIN] = 0; tio.c_cc[VTIME] = 0;
    cfsetispeed(&tio, B300);      /* 最低波特率：每bit 3.3ms */
    cfsetospeed(&tio, B300);
    tcsetattr(fd, TCSANOW, &tio);
    tcflush(fd, TCIOFLUSH);

    unsigned char byte = send_zero ? 0x00 : 0xFF;
    printf("300bps 连续发送 0x%02X ... (pin26应≈%s) Ctrl+C退出\n",
           byte, send_zero ? "0V" : "3.3V");

    while (running) {
        if (write(fd, &byte, 1) != 1) perror("write");
        usleep(40000);   /* 40ms/字节 ≈ 33ms传输+间隔 */
    }

    printf("\n退出，恢复串口\n");
    close(fd);
    return 0;
}
