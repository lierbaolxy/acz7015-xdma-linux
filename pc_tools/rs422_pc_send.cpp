/*
 * rs422_pc_send.cpp - PC 端 RS422 协议帧发送程序（Windows，模拟轨迹球发送端）
 *
 * 功能：通过 PC 串口（USB转RS422 / USB转TTL+422模块）按协议发送标准 RS422 帧，
 *       115200 8N1，用于对开发板 PS 端 arm_rs422_sender 接收程序做链路与协议验证。
 *
 * 帧格式: 帧头(0x55) | 报文标识(0xD1~0xD5) | 有效数据 | 校验和
 * 校验和 = (帧头 + 标识 + 有效数据各字节) 累加取低 8 位
 *
 * 5 种报文:
 *   位移 0xD1 数据3字节 | 状态 0xD2 数据3字节 | 温度 0xD3 数据1字节
 *   电压 0xD4 数据2字节 | 版本 0xD5 数据3字节
 *
 * 编译（VS2022 开发者命令行 x64/x86 Native Tools）:
 *   cl /O2 /EHsc rs422_pc_send.cpp
 * 运行:
 *   rs422_pc_send.exe COM5 10 200
 */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define FRAME_HEAD       0x55
#define CMD_DISPLACEMENT 0xD1
#define CMD_STATUS       0xD2
#define CMD_TEMP         0xD3
#define CMD_VOLTAGE      0xD4
#define CMD_VERSION      0xD5

/* 组装一帧：帧头 + 标识 + 有效数据 + 校验和（与 PS 端 build_frame 一致） */
static void build_frame(uint8_t cmd, const uint8_t *d, int dlen, uint8_t *f, int *len)
{
    uint32_t s = FRAME_HEAD + cmd;   /* 校验和从帧头+标识开始累加 */
    int i;
    f[0] = FRAME_HEAD;
    f[1] = cmd;
    for (i = 0; i < dlen; i++) {
        f[2 + i] = d[i];
        s += d[i];
    }
    int total = 2 + dlen + 1;
    f[total - 1] = (uint8_t)(s & 0xFF);
    *len = total;
}

static void dump_hex(const uint8_t *f, int len)
{
    int i;
    for (i = 0; i < len; i++) printf("%02X ", f[i]);
}

int main(int argc, char *argv[])
{
    const char *port = (argc > 1) ? argv[1] : "COM5";
    int rounds   = (argc > 2) ? atoi(argv[2]) : 10;
    int interval = (argc > 3) ? atoi(argv[3]) : 200;
    if (rounds < 1) rounds = 1;

    char path[64];
    snprintf(path, sizeof(path), "\\\\.\\%s", port);

    HANDLE h = CreateFileA(path, GENERIC_READ | GENERIC_WRITE, 0, NULL,
                           OPEN_EXISTING, 0, NULL);
    if (h == INVALID_HANDLE_VALUE) {
        printf("[错误] 打开 %s 失败，错误码=%lu\n", port, GetLastError());
        printf("  请确认: 1)串口未被占用 2)COM号正确(设备管理器查看)\n");
        return 1;
    }

    DCB dcb = { 0 };
    dcb.DCBlength = sizeof(DCB);
    if (!GetCommState(h, &dcb)) { printf("GetCommState 失败\n"); CloseHandle(h); return 1; }
    dcb.BaudRate = CBR_115200;
    dcb.ByteSize = 8;
    dcb.Parity   = NOPARITY;
    dcb.StopBits = ONESTOPBIT;
    dcb.fBinary  = TRUE;
    dcb.fParity  = FALSE;
    dcb.fOutxCtsFlow = FALSE;
    dcb.fOutxDsrFlow = FALSE;
    dcb.fDtrControl  = DTR_CONTROL_ENABLE;
    dcb.fRtsControl  = RTS_CONTROL_ENABLE;
    dcb.fAbortOnError= FALSE;
    if (!SetCommState(h, &dcb)) { printf("SetCommState 失败\n"); CloseHandle(h); return 1; }

    COMMTIMEOUTS to = { 0 };
    to.WriteTotalTimeoutConstant = 1000;
    SetCommTimeouts(h, &to);
    PurgeComm(h, PURGE_TXCLEAR | PURGE_RXCLEAR);

    printf("=== RS422 协议帧发送程序(PC) ===\n");
    printf("端口: %s  115200 8N1  轮数: %d  帧间隔: %dms\n\n", port, rounds, interval);

    for (int r = 0; r < rounds; r++) {
        uint8_t f[8]; int len; uint8_t d[3]; DWORD w;

        /* 位移 D1（3字节） */
        d[0] = (uint8_t)((r & 1) ? 0x01 : 0x00);
        d[1] = (uint8_t)((int8_t)((r % 30) - 15));
        d[2] = (uint8_t)((int8_t)(((r * 3) % 20) - 10));
        build_frame(CMD_DISPLACEMENT, d, 3, f, &len);
        WriteFile(h, f, len, &w, NULL);
        printf("[#%d] 位移 ", r + 1); dump_hex(f, len); printf("\n");
        Sleep(interval);

        /* 状态 D2（3字节） */
        d[0] = 0x40; d[1] = 0x02; d[2] = 0x01;
        build_frame(CMD_STATUS, d, 3, f, &len);
        WriteFile(h, f, len, &w, NULL);
        printf("[#%d] 状态 ", r + 1); dump_hex(f, len); printf("\n");
        Sleep(interval);

        /* 温度 D3（1字节）：37℃ */
        d[0] = 0x25;
        build_frame(CMD_TEMP, d, 1, f, &len);
        WriteFile(h, f, len, &w, NULL);
        printf("[#%d] 温度 ", r + 1); dump_hex(f, len); printf("\n");
        Sleep(interval);

        /* 电压 D4（2字节）：0x0140=320 => 3.2V */
        d[0] = 0x40; d[1] = 0x01;
        build_frame(CMD_VOLTAGE, d, 2, f, &len);
        WriteFile(h, f, len, &w, NULL);
        printf("[#%d] 电压 ", r + 1); dump_hex(f, len); printf("\n");
        Sleep(interval);

        /* 版本 D5（3字节）：2.01 */
        d[0] = 0x02; d[1] = 0x00; d[2] = 0x01;
        build_frame(CMD_VERSION, d, 3, f, &len);
        WriteFile(h, f, len, &w, NULL);
        printf("[#%d] 版本 ", r + 1); dump_hex(f, len); printf("\n");
        Sleep(interval);
    }

    CloseHandle(h);
    printf("\n=== 发送完成: %d 帧（%d轮 x 5）===\n", rounds * 5, rounds);
    return 0;
}