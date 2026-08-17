# USB接口对接文档

> ACZ7015 XDMA采集卡 USB接口数据格式说明
> 适用版本：V2协议（32字节槽位）
> 编写日期：2026-08-17

---

## 1. 系统架构概述

### 1.1 数据流

```
USB鼠标 ──> ACZ7015开发板(PS端Linux) ──> DDR共享内存 ──PCIe/XDMA──> PC上位机
              /dev/input/event2            0x20000000            c2h_0读取
```

> **重要说明**：USB数据格式是 **Linux input event**（/dev/input/eventX），**不是 USB HID 原始报文**。
> 开发板Linux内核已将USB HID报文解析为统一的input event格式，PS端程序读取的是 input event。

### 1.2 硬件连接

| 端 | 硬件 | 接口 |
|----|------|------|
| 采集卡 | ACZ7015开发板（Zynq7015） | USB Type-A Host × 3 |
| 上位机 | Windows PC | PCIe x1 slot |
| 连接 | PCIe总线 | XDMA IP（PCIe EP模式） |

### 1.3 关键参数

| 参数 | 值 |
|------|-----|
| Vendor ID | 10ee (Xilinx) |
| Device ID | 7021 |
| 设备接口GUID | {74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d} |
| DDR共享内存基址 | 0x20000000 |
| 单次DMA传输延时 | 约0.55ms |

---

## 2. USB数据格式详解

### 2.1 DDR槽位结构（32字节）

PC端从DDR读出的32字节按以下结构解析（小端序）：

```c
#pragma pack(push, 1)
typedef struct {
    uint32_t seq;         /* 0x00: 序号，每次写+1 */
    uint32_t device_id;   /* 0x04: 接口标识 0=USB 1=CAN 2=PS2 3=RS422 */
    uint32_t data_len;    /* 0x08: data区有效字节数（USB固定8） */
    uint32_t reserved;    /* 0x0C: 保留，填0 */
    uint8_t  data[8];     /* 0x10: 原始数据（见2.2节） */
    uint32_t tv_sec;      /* 0x18: 开发板时间戳-秒 */
    uint32_t tv_nsec;     /* 0x1C: 开发板时间戳-纳秒 */
} slot_t;  /* 共32字节 */
#pragma pack(pop)
```

### 2.2 USB数据字段映射（data[8]）

当 `device_id=0`（USB）时，`data[8]` 内容为 **Linux input event** 的三个字段（非USB HID原始报文）：

> **格式说明**：开发板Linux内核已将USB鼠标的HID报文解析为标准input event格式（type/code/value），PS端程序通过 `/dev/input/event2` 读取的就是input event，直接存入data[8]。

| 偏移 | 长度 | 字段 | 类型 | 说明 |
|------|------|------|------|------|
| 0x00 | 2B | type | uint16 (LE) | 事件类型 |
| 0x02 | 2B | code | uint16 (LE) | 事件代码 |
| 0x04 | 4B | value | int32 (LE, 有符号) | 事件值 |

### 2.3 USB事件类型表

#### 按键事件（type=0x0001 EV_KEY）

| type | code | 含义 | value |
|------|------|------|-------|
| 0x0001 | 0x0110 | 左键 | 1=按下, 0=松开 |
| 0x0001 | 0x0111 | 右键 | 1=按下, 0=松开 |
| 0x0001 | 0x0112 | 中键 | 1=按下, 0=松开 |

#### 位移事件（type=0x0002 EV_REL）

| type | code | 含义 | value |
|------|------|------|-------|
| 0x0002 | 0x0000 | X轴位移 | 正=向右, 负=向左 |
| 0x0002 | 0x0001 | Y轴位移 | 正=向下, 负=向上 |
| 0x0002 | 0x0008 | 滚轮 | 正=向上, 负=向下 |

> 注意：value 是**有符号** int32，负数用补码表示，移动量大小取决于鼠标速度。

---

## 3. DDR共享内存布局

### 3.1 四路接口槽位分配

```
DDR物理地址         接口      大小      状态
0x20000000         USB       32字节    已实现
0x20000020         CAN       32字节    预留
0x20000040         PS2       32字节    预留
0x20000060         RS422     32字节    预留
```

### 3.2 seq机制（判断新数据）

- 开发板每次写入数据，`seq` 字段自动+1
- PC端轮询读取，比较 seq 是否变化：

```c
if (slot.seq != last_seq) {
    last_seq = slot.seq;
    // 处理新数据
}
```

### 3.3 时间戳用途

`tv_sec` + `tv_nsec` 是开发板 Linux 的 `CLOCK_MONOTONIC` 时间戳，可用于计算端到端延时：

```c
double arm_time = slot.tv_sec + slot.tv_nsec / 1e9;
double pc_time  = GetSystemTimeAsFileTime转Unix秒;
double latency  = pc_time - arm_time;  // 延时(秒)
```

> 注意：开发板和PC时钟不同步，需首次事件校准 offset。

---

## 4. PC端访问XDMA流程

### 4.1 三个设备节点

| 节点 | 用途 | 访问方式 |
|------|------|----------|
| c2h_0 | Card to Host，PC读DDR | CreateFileA + ReadFile |
| h2c_0 | Host to Card，PC写DDR | CreateFileA + WriteFile |
| user | AXI-Lite寄存器访问 | CreateFileA + ReadFile/WriteFile |

USB数据读取只用 **c2h_0**。

### 4.2 访问三步流程

```c
// 第1步：SetupAPI枚举找到XDMA设备路径
HDEVINFO h = SetupDiGetClassDevs(&GUID, ...);
SetupDiEnumDeviceInterfaces(h, ..., 0, &did);
SetupDiGetDeviceInterfaceDetailA(h, &did, ...);
// 得到路径: \\?\pci#ven_10ee...#{...}

// 第2步：拼路径打开c2h_0
char full_path[MAX_PATH];
sprintf(full_path, "%s\\c2h_0", device_path);
HANDLE hdev = CreateFileA(full_path,
    GENERIC_READ | GENERIC_WRITE,
    0, NULL, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, NULL);

// 第3步：设DDR地址 + ReadFile
LARGE_INTEGER off; off.QuadPart = 0x20000000;  // USB槽位
SetFilePointerEx(hdev, off, NULL, FILE_BEGIN);
uint8_t buf[64] = {0};
DWORD got = 0;
ReadFile(hdev, buf, 64, &got, NULL);  // 读64字节
// 取前32字节即为slot_t结构
```

---

## 5. C++完整示例代码

### 5.1 XdmaReader类（封装版）

```cpp
// xdma_reader.h
#pragma once
#include <windows.h>
#include <setupapi.h>
#include <cstdint>
#include <string>

#pragma pack(push, 1)
struct Slot {
    uint32_t seq;
    uint32_t device_id;
    uint32_t data_len;
    uint32_t reserved;
    uint8_t  data[8];
    uint32_t tv_sec;
    uint32_t tv_nsec;
};
#pragma pack(pop)

// {74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d}
static const GUID XDMA_GUID = {
    0x74c7e4a9, 0x6d5d, 0x4a70,
    {0xbc, 0x0d, 0x20, 0x69, 0x1d, 0xff, 0x9e, 0x9d}};

class XdmaReader {
public:
    bool open(int card_index = 0) {
        // 枚举设备
        HDEVINFO h = SetupDiGetClassDevs(&XDMA_GUID, NULL, NULL,
            DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
        if (h == INVALID_HANDLE_VALUE) return false;

        SP_DEVICE_INTERFACE_DATA did = {sizeof(did)};
        if (!SetupDiEnumDeviceInterfaces(h, NULL, &XDMA_GUID, card_index, &did)) {
            SetupDiDestroyDeviceInfoList(h);
            return false;
        }

        ULONG size = 0;
        SetupDiGetDeviceInterfaceDetailA(h, &did, NULL, 0, &size, NULL);
        auto detail = (SP_DEVICE_INTERFACE_DETAIL_DATA_A*)malloc(size);
        detail->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_A);
        SetupDiGetDeviceInterfaceDetailA(h, &did, detail, size, NULL, NULL);

        std::string path = detail->DevicePath;
        path += "\\c2h_0";
        free(detail);
        SetupDiDestroyDeviceInfoList(h);

        hdev_ = CreateFileA(path.c_str(),
            GENERIC_READ | GENERIC_WRITE,
            0, NULL, OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL, NULL);
        return hdev_ != INVALID_HANDLE_VALUE;
    }

    bool readSlot(uint64_t addr, Slot& slot) {
        LARGE_INTEGER off; off.QuadPart = (LONGLONG)addr;
        if (!SetFilePointerEx(hdev_, off, NULL, FILE_BEGIN)) return false;

        uint8_t buf[64] = {0};
        DWORD got = 0;
        if (!ReadFile(hdev_, buf, 64, &got, NULL) || got < 32) return false;

        memcpy(&slot, buf, 32);
        return true;
    }

    void close() {
        if (hdev_ != INVALID_HANDLE_VALUE) {
            CloseHandle(hdev_);
            hdev_ = INVALID_HANDLE_VALUE;
        }
    }

    ~XdmaReader() { close(); }

private:
    HANDLE hdev_ = INVALID_HANDLE_VALUE;
};
```

### 5.2 使用示例

```cpp
// main.cpp
#include <cstdio>
#include "xdma_reader.h"

int main() {
    XdmaReader reader;
    if (!reader.open(0)) {
        printf("打开XDMA设备失败\n");
        return 1;
    }

    const uint64_t USB_SLOT = 0x20000000;
    uint32_t last_seq = 0;

    printf("等待USB事件...\n");
    for (int i = 0; i < 100; i++) {  // 读100次
        Slot s;
        if (reader.readSlot(USB_SLOT, s) && s.seq != last_seq) {
            last_seq = s.seq;
            uint16_t type = *(uint16_t*)&s.data[0];
            uint16_t code = *(uint16_t*)&s.data[2];
            int32_t  value = *(int32_t*)&s.data[4];
            printf("#%u USB type=0x%04x code=0x%04x value=%d\n",
                s.seq, type, code, value);
        }
        Sleep(10);
    }

    reader.close();
    return 0;
}
```

### 5.3 编译方法

```cmd
cl /O2 main.cpp /Fe:usb_demo.exe setupapi.lib
```

---

## 6. 数据解析示例

### 6.1 左键按下事件

开发板写入DDR的32字节（小端十六进制）：
```
0F 00 00 00  00 00 00 00  08 00 00 00  00 00 00 00
01 00 10 01  01 00 00 00  D2 04 00 00  00 65 04 1D
```

解析：
```
seq=15        device_id=0(USB)   data_len=8
type=0x0001   code=0x0110(左键)  value=1(按下)
tv_sec=1234   tv_nsec=500000000
```

### 6.2 鼠标右移事件

```
10 00 00 00  00 00 00 00  08 00 00 00  00 00 00 00
02 00 00 00  05 00 00 00  D3 04 00 00  00 C2 EB 52
```

解析：
```
seq=16        device_id=0(USB)   data_len=8
type=0x0002   code=0x0000(X轴)   value=5(向右5像素)
```

### 6.3 滚轮向下事件

```
11 00 00 00  00 00 00 00  08 00 00 00  00 00 00 00
02 00 08 00  FF FF FF FF  D4 04 00 00  00 1D CD 35
```

解析：
```
seq=17        device_id=0(USB)   data_len=8
type=0x0002   code=0x0008(滚轮)  value=-1(向下1格)
```

---

## 7. 运行步骤

### 7.1 PS端（开发板）

```bash
# 1. 编译
gcc -O2 -o arm_mouse_sender arm_mouse_sender.c

# 2. 运行（event2为USB鼠标设备节点）
sudo ./arm_mouse_sender /dev/input/event2
```

输出示例：
```
=== USB鼠标数据发送程序 V2（协议标准格式）===
输入设备: /dev/input/event2
DDR基址: 0x20000000
等待鼠标事件... (Ctrl+C退出)

[发送 #1] USB REL 滚轮 = -1 (data_len=8)
[发送 #2] USB KEY 左键 = 1 (data_len=8)
```

### 7.2 PC端（上位机）

#### Python版（验证用）
```cmd
python -u win_mouse_receiver.py
```

#### C++版（集成用）
```cmd
cl /O2 main.cpp /Fe:usb_demo.exe setupapi.lib
usb_demo.exe
```

---

## 8. 启动顺序说明

### 8.1 建议顺序：先PS后PC

```
1. 开发板启动Linux + 运行 arm_mouse_sender
2. PC端运行 usb_demo.exe
3. 动鼠标，PC端立即显示数据
```

### 8.2 为什么建议先PS后PC

- PC端靠 `seq` 变化检测新数据
- 如果PS端未启动，DDR里 seq 恒为0，PC端读不到变化
- PS端先启动后，seq 从1开始递增，PC端能立即捕获

### 8.3 反向启动也可以

- 先启动PC端：会一直等待（seq不变）
- 再启动PS端：PS端写入数据后，PC端立即开始接收
- 无功能问题，只是PC端会"空转"一段时间

---

## 9. 已知限制和注意事项

### 9.1 DMA引擎卡死规避

| 操作 | 后果 | 规避 |
|------|------|------|
| Ctrl+C 正常退出 | ✅ 下次启动正常 | 推荐方式 |
| 任务管理器强杀进程 | ❌ DMA引擎卡死，下次ReadFile永久阻塞 | 禁止 |
| 关闭终端窗口 | ⚠️ 可能触发强杀 | 避免 |

如果意外卡死，需**重启PC**（冷启动）恢复DMA引擎。

### 9.2 双卡场景

一台PC插2张ACZ7015开发板时：
- `SetupDiEnumDeviceInterfaces` 第3个参数 `card_index` 区分卡
- card_index=0 → 第1张卡
- card_index=1 → 第2张卡
- 设备路径含PCIe slot位置信息，天然区分两张卡

### 9.3 读取长度建议

- 协议槽位是32字节
- 建议ReadFile读64字节（XDMA驱动对齐要求）
- 只取前32字节解析，后32字节忽略

### 9.4 轮询频率建议

- 建议 10ms 轮询一次（`Sleep(10)`）
- 鼠标事件频率约 100-500Hz，10ms轮询不会丢事件
- 过快轮询（<1ms）会增加CPU占用，无实际收益

---

## 10. FAQ

### Q1：ReadFile 卡住不返回怎么办？

**A**：可能是DMA引擎卡死。检查是否有强杀进程历史。解决：重启PC。

### Q2：SetupAPI找不到设备怎么办？

**A**：检查：
1. XDMA驱动是否安装（设备管理器看 Xilinx DMA 设备）
2. 设备是否有黄色感叹号（驱动异常）
3. GUID是否正确：{74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d}

### Q3：读到的seq一直是0怎么办？

**A**：PS端未启动或未写入数据。检查：
1. 开发板是否运行 `arm_mouse_sender`
2. `/dev/input/event2` 是否正确（用 `cat /proc/bus/input/devices` 确认）

### Q4：value为什么是负数？

**A**：value 是**有符号** int32：
- X轴：正=右，负=左
- Y轴：正=下，负=上
- 滚轮：正=上，负=下
解析时必须用 `int32_t` 而非 `uint32_t`。

### Q5：如何计算端到端延时？

**A**：
```c
double arm_time = slot.tv_sec + slot.tv_nsec / 1e9;
double pc_time  = 当前PC时间(Unix秒);
double latency  = (pc_time - arm_time - clock_offset) * 1000;  // 毫秒
```
`clock_offset` 用首次事件校准：`clock_offset = pc_time - arm_time`

### Q6：如何区分两张卡的数据？

**A**：用 `card_index` 参数。每张卡的DDR地址独立（物理隔离），数据互不影响。

### Q7：后续CAN/PS2/RS422接口怎么对接？

**A**：数据格式相同（slot_t结构），只是：
- DDR地址不同（0x20000020/0x40/0x60）
- device_id不同（1/2/3）
- data[8]内容格式按协议规范定义

PC端只需改读地址即可，解析逻辑框架不变。

### Q8：协议规范的PBIT和命令响应在哪？

**A**：协议对USB接口未规定PBIT和命令响应（仅RS422/CAN有）。USB接口只负责透传鼠标事件。

---

## 附录：文件清单

| 文件 | 说明 |
|------|------|
| linux/arm_apps/arm_mouse_sender.c | PS端USB采集源码 |
| pc/win_mouse_receiver.py | PC端Python参考实现 |
| pc/xdma_demo.c | PC端C语言最简demo（双卡遍历） |
| docs/protocol_spec.md | 完整协议规范（4个Word文档提取） |

---

**文档结束**
