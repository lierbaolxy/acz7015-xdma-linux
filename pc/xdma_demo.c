/*
 * xdma_demo.c - 最简XDMA读写demo（遍历所有板卡）
 *
 * 编译：cl /O2 xdma_demo.c /Fe:xdma_demo.exe setupapi.lib
 * 运行：xdma_demo.exe
 */
#include <windows.h>
#include <setupapi.h>
#include <initguid.h>
#include <stdio.h>
#include <stdint.h>

#pragma comment(lib, "setupapi.lib")

DEFINE_GUID(GUID_XDMA, 0x74c7e4a9, 0x6d5d, 0x4a70,
    0xbc, 0x0d, 0x20, 0x69, 0x1d, 0xff, 0x9e, 0x9d);

#pragma pack(push, 1)
typedef struct {
    uint32_t seq, device_id, data_len, reserved;
    uint8_t  data[8];
    uint32_t tv_sec, tv_nsec;
} slot_t;
#pragma pack(pop)

/* 读DDR指定地址32字节 */
static int read_slot(HANDLE h, uint64_t addr, slot_t *s)
{
    LARGE_INTEGER off; off.QuadPart = (LONGLONG)addr;
    SetFilePointerEx(h, off, NULL, FILE_BEGIN);
    uint8_t buf[64] = {0};
    DWORD got = 0;
    if (!ReadFile(h, buf, 64, &got, NULL) || got < 32) return 0;
    memcpy(s, buf, 32);
    return 1;
}

int main(void)
{
    /* 1. 枚举所有XDMA设备 */
    HDEVINFO h = SetupDiGetClassDevs(&GUID_XDMA, NULL, NULL,
        DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
    if (h == INVALID_HANDLE_VALUE) { printf("未找到XDMA设备\n"); return 1; }

    /* 2. 遍历每张卡 */
    for (int i = 0; ; i++) {
        SP_DEVICE_INTERFACE_DATA did = {0};
        did.cbSize = sizeof(did);
        if (!SetupDiEnumDeviceInterfaces(h, NULL, &GUID_XDMA, i, &did)) break;

        /* 获取设备路径 */
        ULONG size = 0;
        SetupDiGetDeviceInterfaceDetailA(h, &did, NULL, 0, &size, NULL);
        PSP_DEVICE_INTERFACE_DETAIL_DATA_A d = (PSP_DEVICE_INTERFACE_DETAIL_DATA_A)malloc(size);
        d->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_A);
        SetupDiGetDeviceInterfaceDetailA(h, &did, d, size, NULL, NULL);

        char path[512];
        snprintf(path, sizeof(path), "%s\\c2h_0", d->DevicePath);
        free(d);

        printf("=== 板卡 %d ===\n", i);
        printf("路径: %s\n", path);

        /* 打开并读USB槽位 */
        HANDLE fh = CreateFileA(path, GENERIC_READ | GENERIC_WRITE, 0, NULL,
            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
        if (fh == INVALID_HANDLE_VALUE) {
            printf("打开失败\n\n");
            continue;
        }

        slot_t s;
        if (read_slot(fh, 0x20000000, &s)) {
            printf("USB: seq=%u dev=%u data=", s.seq, s.device_id);
            for (int j = 0; j < 8; j++) printf("%02X ", s.data[j]);
            printf("\n");
        }
        CloseHandle(fh);
        printf("\n");
    }

    SetupDiDestroyDeviceInfoList(h);
    return 0;
}
