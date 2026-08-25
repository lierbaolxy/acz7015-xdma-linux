/*
 * arm_can_tty.c - CH343 USB-CANFD 串口 AT 指令验证程序（板端）
 *
 * 功能：打开 /dev/ttyCH343USB0，进入配置模式，查询并配置 CAN 参数。
 *   1. +++            进入配置模式（不带 LF，前后空闲 >=3ms）
 *   2. AT             测试是否在配置模式
 *   3. AT+VER=?       查询固件版本
 *   4. AT+USART_PARAM=?  查询串口参数
 *   5. AT+CAN_BAUD=?  查询 CAN 仲裁域波特率
 *   6. AT+CAN_FRAMEFORMAT=? 查询数据透传帧格式
 *   7. AT+MODE=?      查询数据模式
 *   8. AT+CAN_MODE=?  查询 CAN 工作模式
 *
 * 编译(板端): gcc -O2 -o arm_can_tty arm_can_tty.c
 * 运行(板端): echo root | sudo -S /tmp/arm_can_tty [串口波特率]
 *   默认 9600；若设备被改过波特率，可传参覆盖，如 /tmp/arm_can_tty 115200
 *
 * 参考: 泥人科技《CAN转换器-AT指令表》
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <sys/select.h>

#define DEV "/dev/ttyCH343USB0"

static int fd;

static speed_t baud_to_speed(int baud)
{
    switch (baud) {
    case 2400:   return B2400;
    case 4800:   return B4800;
    case 9600:   return B9600;
    case 19200:  return B19200;
    case 38400:  return B38400;
    case 57600:  return B57600;
    case 115200: return B115200;
    case 230400: return B230400;
    case 460800: return B460800;
    case 921600: return B921600;
    default:     return B9600;
    }
}

static int open_uart(const char *dev, int baud)
{
    struct termios t;
    speed_t sp = baud_to_speed(baud);

    fd = open(dev, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fd < 0) {
        perror("open");
        return -1;
    }
    if (tcgetattr(fd, &t) < 0) {
        perror("tcgetattr");
        return -1;
    }
    cfmakeraw(&t);
    t.c_cflag |= (CLOCAL | CREAD);
    t.c_cflag &= ~CSIZE;
    t.c_cflag |= CS8;
    t.c_cflag &= ~PARENB;
    t.c_cflag &= ~CSTOPB;
    cfsetispeed(&t, sp);
    cfsetospeed(&t, sp);
    if (tcsetattr(fd, TCSANOW, &t) < 0) {
        perror("tcsetattr");
        return -1;
    }
    tcflush(fd, TCIOFLUSH);
    return 0;
}

/* 读回复（非阻塞 + select 超时），带十六进制/ASCII 混合打印 */
static void read_reply(int timeout_ms)
{
    unsigned char buf[512];
    int total = 0;
    struct timeval tv;
    fd_set rfds;
    int ret;

    tv.tv_sec = timeout_ms / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;
    FD_ZERO(&rfds);
    FD_SET(fd, &rfds);
    ret = select(fd + 1, &rfds, NULL, NULL, &tv);
    if (ret <= 0) {
        printf("    (无回复, ret=%d)\n", ret);
        return;
    }
    while ((ret = read(fd, buf + total, sizeof(buf) - 1 - total)) > 0) {
        total += ret;
        if (total >= (int)sizeof(buf) - 1)
            break;
        /* 短暂再等一轮，收完剩余字节 */
        tv.tv_sec = 0;
        tv.tv_usec = 50000;
        FD_ZERO(&rfds);
        FD_SET(fd, &rfds);
        if (select(fd + 1, &rfds, NULL, NULL, &tv) <= 0)
            break;
    }
    if (total > 0) {
        int i;
        printf("    [%dB] \"", total);
        for (i = 0; i < total; i++) {
            if (buf[i] >= 0x20 && buf[i] < 0x7f)
                printf("%c", buf[i]);
            else
                printf("\\x%02X", buf[i]);
        }
        printf("\"\n");
    } else {
        printf("    (无回复, read=%d errno=%d)\n", total, errno);
    }
}

/* 发送 AT 指令；is_plus=1 表示 +++ (不带 CRLF)，否则带 CRLF */
static void send_cmd(const char *s, int is_plus)
{
    usleep(20000); /* 发送前空闲，确保 >3ms */
    write(fd, s, strlen(s));
    if (!is_plus)
        write(fd, "\r\n", 2);
    tcdrain(fd);
}

int main(int argc, char **argv)
{
    int baud = (argc > 1) ? atoi(argv[1]) : 9600;

    if (open_uart(DEV, baud) < 0)
        return 1;
    printf("串口 %s 波特率=%d 已打开\n", DEV, baud);

    printf("=== 1. +++ 进入配置模式 ===\n");
    send_cmd("+++", 1);
    read_reply(500);
    usleep(500000);

    printf("=== 2. AT 测试 ===\n");
    send_cmd("AT", 0);
    read_reply(500);

    printf("=== 3. AT+VER=? ===\n");
    send_cmd("AT+VER=?", 0);
    read_reply(500);

    printf("=== 4. AT+USART_PARAM=? ===\n");
    send_cmd("AT+USART_PARAM=?", 0);
    read_reply(500);

    printf("=== 5. AT+CAN_BAUD=? ===\n");
    send_cmd("AT+CAN_BAUD=?", 0);
    read_reply(500);

    printf("=== 6. AT+CAN_FRAMEFORMAT=? ===\n");
    send_cmd("AT+CAN_FRAMEFORMAT=?", 0);
    read_reply(500);

    printf("=== 7. AT+MODE=? ===\n");
    send_cmd("AT+MODE=?", 0);
    read_reply(500);

    printf("=== 8. AT+CAN_MODE=? ===\n");
    send_cmd("AT+CAN_MODE=?", 0);
    read_reply(500);

    close(fd);
    return 0;
}