/*
 * arm_can_pkt.c - CH343 USB-CANFD 包模式(MODE2)回环自测程序（板端）
 *
 * 功能：验证包模式收发格式。先配置设备为包模式+回环(CAN_MODE=1)，
 *       发送一帧 29 位扩展帧(包模式 17 字节)，回环自收并打印。
 *
 * 包模式 CAN 帧格式(17字节, 含包尾)：
 *   [0]   0xAA       包头(固定)
 *   [1]   0x00/0x01  扩展帧标识(0标准 1扩展)
 *   [2]   0x00/0x01  远程帧标识(0数据 1远程)
 *   [3]   DLC        有效数据长度 0~8
 *   [4..7] 帧ID(4B大端, 扩展帧低29bit有效)
 *   [8..15] 帧数据(8B, 不足补0x00)
 *   [16]  0x7A       包尾(可配置)
 *
 * 编译(板端): gcc -O2 -o arm_can_pkt arm_can_pkt.c
 * 运行(板端): echo root | sudo -S /tmp/arm_can_pkt [串口波特率]
 *
 * 参考: 泥人科技《CAN转换器系列使用手册V2.7》6.3 包模式
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
    if (fd < 0) { perror("open"); return -1; }
    tcgetattr(fd, &t);
    cfmakeraw(&t);
    t.c_cflag |= (CLOCAL | CREAD);
    t.c_cflag &= ~CSIZE;
    t.c_cflag |= CS8;
    t.c_cflag &= ~PARENB;
    t.c_cflag &= ~CSTOPB;
    cfsetispeed(&t, sp);
    cfsetospeed(&t, sp);
    tcsetattr(fd, TCSANOW, &t);
    tcflush(fd, TCIOFLUSH);
    return 0;
}

static int read_bytes(unsigned char *buf, int max, int timeout_ms)
{
    int total = 0;
    struct timeval tv;
    fd_set rfds;
    int ret;

    while (total < max) {
        tv.tv_sec = timeout_ms / 1000;
        tv.tv_usec = (timeout_ms % 1000) * 1000;
        FD_ZERO(&rfds);
        FD_SET(fd, &rfds);
        ret = select(fd + 1, &rfds, NULL, NULL, &tv);
        if (ret < 0) return -1;
        if (ret == 0) break;
        ret = read(fd, buf + total, max - total);
        if (ret <= 0) break;
        total += ret;
        timeout_ms = 30; /* 后续字节短超时 */
    }
    return total;
}

static void dump_hex(const unsigned char *b, int n)
{
    int i;
    for (i = 0; i < n; i++)
        printf("%02X ", b[i]);
    printf("\n");
}

/* 发送 AT 指令并读回复 */
static void at_cmd(const char *s)
{
    unsigned char buf[128];
    usleep(20000);
    if (strcmp(s, "+++") == 0) {
        write(fd, s, 3);
    } else {
        write(fd, s, strlen(s));
        write(fd, "\r\n", 2);
    }
    tcdrain(fd);
    usleep(300000);
    {
        int n = read_bytes(buf, sizeof(buf), 300);
        printf("  >> %s  ->  ", s);
        if (n > 0) { buf[n] = 0; printf("%s", (char *)buf); }
        else printf("(无回复)");
        printf("\n");
    }
}

static int configure_packet_loopback(void)
{
    printf("[配置] 进入配置模式 + 包模式 + 回环\n");
    at_cmd("+++");
    at_cmd("AT+CAN_BAUD=500000");
    at_cmd("AT+CANFD_EN=0");
    at_cmd("AT+CAN_MODE=1");         /* 回环模式 */
    at_cmd("AT+MODE=2");             /* 包模式 */
    at_cmd("AT+MODE2=1,122");        /* 使能包尾 0x7A */
    at_cmd("AT+CAN_FILTER0=1,0,4,0,0"); /* 过滤器0：允许所有帧 */
    at_cmd("ATO");                   /* 进入数据模式 */
    return 0;
}

int main(int argc, char **argv)
{
    int baud = (argc > 1) ? atoi(argv[1]) : 9600;
    unsigned char tx[17];
    unsigned char rx[256];
    int n;

    if (open_uart(DEV, baud) < 0)
        return 1;
    printf("串口 %s 波特率=%d 已打开\n", DEV, baud);

    configure_packet_loopback();
    usleep(300000);
    tcflush(fd, TCIOFLUSH); /* 清掉配置阶段的残留 */

    /* 构造一帧扩展帧: ID=0x01180118, DLC=4, 数据=11 22 33 44 */
    memset(tx, 0, sizeof(tx));
    tx[0] = 0xAA;                       /* 包头 */
    tx[1] = 0x01;                       /* 扩展帧 */
    tx[2] = 0x00;                       /* 数据帧 */
    tx[3] = 0x04;                       /* DLC=4 */
    tx[4] = 0x01; tx[5] = 0x18;         /* 帧ID 4B大端 = 0x01180118 */
    tx[6] = 0x01; tx[7] = 0x18;
    tx[8] = 0x11; tx[9] = 0x22;         /* 数据 */
    tx[10] = 0x33; tx[11] = 0x44;
    tx[16] = 0x7A;                      /* 包尾 */

    printf("[发送] 回环帧(17B): ");
    dump_hex(tx, 17);
    write(fd, tx, 17);
    tcdrain(fd);

    usleep(500000);
    n = read_bytes(rx, sizeof(rx), 800);
    printf("[接收] %d 字节:\n", n);
    if (n > 0) dump_hex(rx, n);

    /* 解析回环帧 */
    if (n >= 17) {
        unsigned int id = ((unsigned int)rx[4] << 24) | ((unsigned int)rx[5] << 16) |
                          ((unsigned int)rx[6] << 8) | rx[7];
        printf("[解析] 包头=0x%02X(应AA) 扩展=0x%02X(应01) DLC=%d ID=0x%08X(应01180118)\n",
               rx[0], rx[1], rx[3], id);
        printf("[解析] 数据=");
        dump_hex(rx + 8, rx[3] > 8 ? 8 : rx[3]);
        printf("[解析] 包尾=0x%02X(应7A)\n", rx[16]);
        if (rx[0] == 0xAA && rx[1] == 0x01 && id == 0x01180118 && rx[16] == 0x7A)
            printf("[结果] 包模式回环自测 PASS\n");
        else
            printf("[结果] 包模式回环自测 FAIL（格式不匹配）\n");
    } else {
        printf("[结果] 未收到完整回环帧\n");
    }

    close(fd);
    return 0;
}