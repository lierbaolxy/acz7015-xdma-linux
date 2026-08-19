/*
 * arm_rs422_loopback.c - UART1 RS422回环测试程序
 *
 * 测试原理：开发板UART1的TX发送数据，经TTL模块转RS422差分信号，
 *           在RS422侧短接TX↔RX后，数据回环到RX，程序读取并对比。
 *
 * 接线（RS422侧短接，验证完整链路）：
 *   4线RS422模块: TX+ ↔ RX+, TX- ↔ RX-
 *   2线RS485模块: A ↔ B（半双工，需有自动收发切换电路）
 *
 * 备用（仅验证UART1本身，绕过TTL模块）：
 *   开发板排针 pin26(TX) ↔ pin28(RX) 直接短接
 *
 * 编译：gcc -O2 -o arm_rs422_loopback arm_rs422_loopback.c
 * 运行：sudo ./arm_rs422_loopback [/dev/ttyPS0]
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <termios.h>
#include <sys/select.h>
#include <stdint.h>

static int setup_serial(int fd)
{
    struct termios tty;
    if (tcgetattr(fd, &tty) != 0) { perror("tcgetattr"); return -1; }
    cfsetispeed(&tty, B115200);
    cfsetospeed(&tty, B115200);
    tty.c_cflag &= ~PARENB;
    tty.c_cflag &= ~CSTOPB;
    tty.c_cflag &= ~CSIZE;
    tty.c_cflag |= CS8;
    tty.c_cflag |= CLOCAL | CREAD;  /* 关键：否则收不到 */
    tty.c_cflag &= ~CRTSCTS;
    tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
    tty.c_iflag &= ~(IXON | IXOFF | IXANY | IGNBRK | BRKINT | INLCR | ICRNL);
    tty.c_oflag &= ~(OPOST | ONLCR);
    tty.c_cc[VMIN]  = 0;
    tty.c_cc[VTIME] = 0;  /* 立即返回，用select控制超时 */
    if (tcsetattr(fd, TCSANOW, &tty) != 0) { perror("tcsetattr"); return -1; }
    return 0;
}

int main(int argc, char *argv[])
{
    const char *dev = (argc > 1) ? argv[1] : "/dev/ttyPS0";
    int fd, i, j;
    int success = 0;
    int total_bytes = 0;

    printf("=== RS422 回环测试 ===\n");
    printf("串口: %s  波特率: 115200 8N1\n", dev);
    printf("请在RS422侧短接 TX+<->RX+, TX-<->RX-\n");
    printf("（或在排针侧短接 pin26<->pin28 验证UART1本身）\n\n");

    fd = open(dev, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        perror("打开串口失败");
        printf("提示: 可能被其他进程占用，执行 sudo pkill -f arm_rs422_sender\n");
        return 1;
    }
    if (setup_serial(fd) < 0) { close(fd); return 1; }
    printf("串口打开成功，开始测试 10 次...\n\n");

    uint8_t tx_buf[16];
    uint8_t rx_buf[64];

    for (i = 0; i < 10; i++) {
        /* 生成测试帧：0x55 + cmd + 3字节数据 + 校验和 */
        uint8_t cmd = 0xD1 + (uint8_t)(i % 5);
        uint8_t d1 = (uint8_t)(i + 0x10);
        uint8_t d2 = (uint8_t)(i + 0x20);
        uint8_t d3 = (uint8_t)(i + 0x30);
        uint8_t sum = (uint8_t)(0x55 + cmd + d1 + d2 + d3);
        tx_buf[0] = 0x55;
        tx_buf[1] = cmd;
        tx_buf[2] = d1;
        tx_buf[3] = d2;
        tx_buf[4] = d3;
        tx_buf[5] = sum;
        int tx_len = 6;

        /* 清空输入输出缓冲 */
        tcflush(fd, TCIOFLUSH);

        /* 发送 */
        ssize_t wn = write(fd, tx_buf, tx_len);
        /* 等待数据从TX发回RX（回环路径有延迟） */
        usleep(20000);  /* 20ms */

        /* 读取回环数据，最多等 500ms */
        int total_rx = 0;
        int retry = 0;
        while (total_rx < tx_len && retry < 50) {
            fd_set rfds;
            struct timeval tv;
            FD_ZERO(&rfds);
            FD_SET(fd, &rfds);
            tv.tv_sec = 0;
            tv.tv_usec = 10000;  /* 10ms */
            int ret = select(fd + 1, &rfds, NULL, NULL, &tv);
            if (ret <= 0) { retry++; continue; }
            ssize_t n = read(fd, rx_buf + total_rx, sizeof(rx_buf) - total_rx);
            if (n > 0) total_rx += (int)n;
            else if (n < 0 && errno != EAGAIN && errno != EINTR) break;
            else retry++;
        }
        total_bytes += total_rx;

        /* 对比 */
        printf("[#%2d] 发送: ", i + 1);
        for (j = 0; j < tx_len; j++) printf("%02X ", tx_buf[j]);
        printf("\n      收到: ");
        if (total_rx == 0) {
            printf("(无数据)");
        } else {
            for (j = 0; j < total_rx; j++) printf("%02X ", rx_buf[j]);
        }
        printf(" (%d字节)\n", total_rx);

        if (total_rx == tx_len && memcmp(tx_buf, rx_buf, tx_len) == 0) {
            printf("      [OK] 匹配\n");
            success++;
        } else {
            printf("      [FAIL] 不匹配\n");
        }
        printf("\n");
        usleep(100000);  /* 100ms间隔 */
    }

    printf("=== 结果: %d/10 成功 (共收到 %d 字节) ===\n", success, total_bytes);
    if (success == 10) {
        printf("\n[PASS] 回环测试完全通过！RS422链路正常。\n");
    } else if (success > 0) {
        printf("\n[PARTIAL] 部分成功，检查接线和干扰。\n");
    } else {
        printf("\n[FAIL] 完全失败。请按顺序排查：\n");
        printf("  1. RS422侧是否短接了 TX+<->RX+, TX-<->RX- (4线)\n");
        printf("     或 A<->B (2线RS485)\n");
        printf("  2. TTL模块供电：3.3V接pin29(不是pin11的5V), GND接pin30\n");
        printf("  3. 排针接线：pin26(UART1_TX)->TTL模块RX, pin28(UART1_RX)->TTL模块TX\n");
        printf("  4. 先做排针侧回环 pin26<->pin28 验证UART1本身是否正常\n");
        printf("  5. 若排针侧回环OK但RS422侧不行，说明TTL模块故障或接线错\n");
    }

    close(fd);
    return 0;
}
