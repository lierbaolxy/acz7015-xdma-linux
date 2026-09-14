# USB/PS2 鼠标数据区分与解析指南（C++ 开发者）

> 更新日期：2026-08-25
> 变更说明：PS2 路从"PS/2扫描码4字节"改为"input_event 8字节"格式，与 USB 路统一。C++ 端只需一种解析逻辑。

## 一、总览

ACZ7015 采集卡通过 PCIe/XDMA 将四路外设数据转发到 PC 端。USB 鼠标和 PS2 鼠标是两个独立数据源，写入 DDR 不同地址区域，PC 端按地址读取即可区分。

**核心设计：USB 和 PS2 两路数据格式完全统一**，均使用 Linux `input_event` 结构体（8 字节），C++ 端按 `device_id` 区分来源，解析逻辑完全相同。

## 二、DDR 内存布局

### 基地址

```
DDR_BASE = 0x20000000（物理地址，XDMA 映射到 PC 端 BAR）
```

### 单槽区（最新值，32 字节/路）

| 地址 | device_id | 接口 | 说明 |
|------|-----------|------|------|
| 0x20000000 | 0 | USB | USB 鼠标最新事件 |
| 0x20000020 | 1 | CAN | CAN 最新帧 |
| 0x20000040 | 2 | PS2 | PS2 鼠标最新事件 |
| 0x20000060 | 3 | RS422 | RS422 最新报文 |

### 环形缓冲区（历史帧，2KB/路 = 64 槽 × 32 字节）

| 地址 | device_id | 接口 | 大小 |
|------|-----------|------|------|
| 0x20000100 | 0 | USB | 2KB |
| 0x20000900 | 2 | PS2 | 2KB |
| 0x20001100 | 3 | RS422 | 2KB |
| 0x20001900 | 1 | CAN | 2KB |

> **PC 端推荐读环形区**：一次 DMA 读 2KB（64 槽），按 seq 升序回放，避免高速事件覆盖丢帧。

## 三、统一槽位格式（32 字节，所有路共用）

```c
#pragma pack(push, 1)
struct ShareSlot {
    uint32_t seq;        // 0x00 序号，每次更新 +1
    uint32_t device_id;  // 0x04 接口类型: 0=USB, 1=CAN, 2=PS2, 3=RS422
    uint32_t data_len;   // 0x08 有效数据长度（字节）
    uint32_t reserved;   // 0x0C 保留（RS422 型号分片用）
    uint8_t  data[8];    // 0x10 原始数据（最多 8 字节）
    uint32_t tv_sec;     // 0x18 时间戳秒
    uint32_t tv_nsec;    // 0x1C 时间戳纳秒
};
#pragma pack(pop)
// sizeof(ShareSlot) == 32
```

## 四、USB 和 PS2 统一数据格式（8 字节 input_event）

**两路数据格式完全一致**，只是 device_id 不同：

| 路 | device_id | data 格式 | data_len |
|----|-----------|-----------|----------|
| USB | 0 | {type:2B, code:2B, value:4B} | 8 |
| PS2 | 2 | {type:2B, code:2B, value:4B} | 8 |

### input_event 结构体定义

```c
#pragma pack(push, 1)
struct InputEvent {
    uint16_t type;   // 事件类型: EV_REL=0x0002(相对坐标), EV_KEY=0x0001(按键)
    uint16_t code;   // 事件代码: REL_X=0, REL_Y=1, REL_WHEEL=8, BTN_LEFT=272, BTN_RIGHT=273, BTN_MIDDLE=274
    int32_t  value;  // 值: 位移量(正负), 按键(1=按下, 0=松开)
};
#pragma pack(pop)
// sizeof(InputEvent) == 8
```

### 事件类型与代码表

| type | code | 名称 | value 含义 |
|------|------|------|-----------|
| 0x0002 (EV_REL) | 0 | REL_X | X 轴位移量（右为正） |
| 0x0002 (EV_REL) | 1 | REL_Y | Y 轴位移量（下为正） |
| 0x0002 (EV_REL) | 8 | REL_WHEEL | 滚轮位移量（上为正） |
| 0x0001 (EV_KEY) | 272 | BTN_LEFT | 1=按下, 0=松开 |
| 0x0001 (EV_KEY) | 273 | BTN_RIGHT | 1=按下, 0=松开 |
| 0x0001 (EV_KEY) | 274 | BTN_MIDDLE | 1=按下, 0=松开 |

> **注意**：EV_SYN(0x0000) 和 EV_MSC(0x0004) 事件被板端过滤，不会写入 DDR。

## 五、C++ 统一解析代码

### 解析函数（USB 和 PS2 共用）

```cpp
#pragma pack(push, 1)
struct ShareSlot {
    uint32_t seq;
    uint32_t device_id;
    uint32_t data_len;
    uint32_t reserved;
    uint8_t  data[8];
    uint32_t tv_sec;
    uint32_t tv_nsec;
};
#pragma pack(pop)
static_assert(sizeof(ShareSlot) == 32, "ShareSlot must be 32 bytes");

#pragma pack(push, 1)
struct InputEvent {
    uint16_t type;
    uint16_t code;
    int32_t  value;
};
#pragma pack(pop)
static_assert(sizeof(InputEvent) == 8, "InputEvent must be 8 bytes");

// USB 和 PS2 共用此解析函数
void parseInputEvent(const ShareSlot& slot, const char* ifaceName) {
    if (slot.data_len < 8) return;
    InputEvent ev;
    memcpy(&ev, slot.data, sizeof(ev));

    if (ev.type == 0x0002) {  // EV_REL
        switch (ev.code) {
            case 0:   printf("[%s] X %+d\n", ifaceName, ev.value); break;   // REL_X
            case 1:   printf("[%s] Y %+d\n", ifaceName, ev.value); break;   // REL_Y
            case 8:   printf("[%s] 滚轮 %+d\n", ifaceName, ev.value); break; // REL_WHEEL
            default:  printf("[%s] REL code=%d value=%d\n", ifaceName, ev.code, ev.value); break;
        }
    } else if (ev.type == 0x0001) {  // EV_KEY
        const char* btn = "未知";
        switch (ev.code) {
            case 272: btn = "左键"; break;  // BTN_LEFT
            case 273: btn = "右键"; break;  // BTN_RIGHT
            case 274: btn = "中键"; break;  // BTN_MIDDLE
        }
        printf("[%s] %s %s\n", ifaceName, btn, ev.value ? "按下" : "松开");
    }
}
```

### 按地址分发

```cpp
// 读取一个槽位后，按 device_id 分发
void dispatchSlot(const ShareSlot& slot) {
    switch (slot.device_id) {
        case 0:  parseInputEvent(slot, "USB");  break;
        case 2:  parseInputEvent(slot, "PS2");  break;
        case 1:  /* CAN 帧解析，见 CAN 协议文档 */ break;
        case 3:  /* RS422 报文解析，见 RS422 协议文档 */ break;
    }
}
```

## 六、环形缓冲区读取

### 读取示例

```cpp
// 环形区地址偏移（相对 DDR_BASE）
#define DDR_BASE        0x20000000ULL
#define RING_USB_OFF    0x0100   // USB 环形区
#define RING_PS2_OFF    0x0900   // PS2 环形区
#define RING_SIZE       0x0800   // 2KB = 64 槽

void readRing(HANDLE hC2H, uint64_t ringOffset, const char* name) {
    ShareSlot slots[64];
    LARGE_INTEGER offset;
    offset.QuadPart = DDR_BASE + ringOffset;
    SetFilePointerEx(hC2H, offset, NULL, FILE_BEGIN);

    DWORD bytesReturned = 0;
    ReadFile(hC2H, slots, RING_SIZE, &bytesReturned, NULL);

    if (bytesReturned < RING_SIZE) return;

    // 找最大 seq 的槽位
    int maxIdx = 0;
    for (int i = 1; i < 64; i++) {
        if (slots[i].seq > slots[maxIdx].seq)
            maxIdx = i;
    }

    // 从 maxIdx+1 开始环形回放所有新帧
    for (int i = 0; i < 64; i++) {
        int idx = (maxIdx + 1 + i) % 64;
        if (slots[idx].seq == 0) continue;
        dispatchSlot(slots[idx]);
    }
}
```

### 关键实现要点

1. **ReadFile 必须读 64 字节对齐**：即使只读一个槽位(32B)，也要读 64 字节取前 32 字节，否则会阻塞
2. **环形区一次读 2KB**：64 槽 × 32 字节，一次性 DMA 读完
3. **seq 是递增计数器**：每路独立，PC 端记录上次最大 seq，只处理 seq > lastSeq 的槽
4. **seq 跳变 > 64** = 环形覆盖丢帧

## 七、区分原理总结

```
┌──────────────────────────────────────────────────────┐
│                  DDR 0x20000000                      │
│                                                      │
│  0x20000100 ── USB 环形区 (device_id=0)             │
│  │  data[8] = {type, code, value}  ← InputEvent      │
│  │  data_len = 8                                     │
│  │                                                   │
│  0x20000900 ── PS2 环形区 (device_id=2)             │
│  │  data[8] = {type, code, value}  ← InputEvent      │
│  │  data_len = 8                                     │
│  │                                                   │
│  格式完全一致，仅 device_id 和地址不同               │
│  C++ 端用同一个 parseInputEvent() 解析               │
│  按 device_id 区分来源名称                           │
└──────────────────────────────────────────────────────┘
```

## 八、常见问题

### Q1: 为什么 USB 和 PS2 数据格式一样？
PS2 转 USB 鼠标在 Linux 下走 input subsystem，产生的事件和 USB 鼠标完全相同（都是 `struct input_event`）。板端程序不再做 PS/2 扫描码转换，直接原样打包，简化 PC 端解析。

### Q2: 为什么之前 PS2 读出来全是 0？
之前 PS2 路用 PS/2 扫描码格式（3~4 字节），需要移动鼠标触发 SYN_REPORT 才打包。如果鼠标不动或 event 节点选错，单槽区就是启动时清零的值。现在改为每个 input_event 独立打包，移动即产生数据。

### Q3: PS2 的滚轮数据在哪里？
和 USB 一样，在 `type=EV_REL, code=REL_WHEEL(8), value=±N` 事件中。滚动滚轮会产生独立的 REL_WHEEL 事件。

### Q4: USB 和 PS2 能同时工作吗？
可以。两路独立 event 节点、独立 DDR 区域、独立 seq 计数。板端单进程 poll 同时监听两路 fd，PC 端按地址分别读取，互不干扰。

### Q5: 协议合规性
协议第 148 行："USB、PS2采用标准通信格式即可，无自定义内容"。input_event 是 Linux 标准输入事件格式，属于"标准通信格式"。第 203 行写"PS2 最多3字节"是旧版描述，已更新为 8 字节统一格式，需与上位机同事确认。

## 九、如何快速识别 USB 鼠标和 PS2 鼠标的 event 节点

每次插拔 USB 设备后 event 编号可能变化，启动前必须确认。

### 一行命令快速识别

```bash
cat /proc/bus/input/devices | awk '/Name/{name=$0} /Handlers/{h=$0} /REL=/{print name; print h}'
```

输出示例：
```
N: Name="Barcode Reader "
H: Handlers=kbd event2
N: Name="HP USB MOUSE"
H: Handlers=event4
```

### 识别规则

- 有 `B: REL=` 的设备才是鼠标数据接口（有相对位移）
- `Name="Barcode Reader"` = PS2 转 USB 鼠标
- `Name="HP USB MOUSE"` = USB 鼠标
- Handlers 里的 event 号就是该鼠标的鼠标数据接口

### 启动命令参数顺序

```bash
sudo ./arm_all_four <第1个参数USB> <第2个参数PS2>
```

- **第1个参数 = USB 鼠标**（上例 event4）
- **第2个参数 = PS2 转 USB 鼠标**（上例 event2）

```bash
sudo ./arm_all_four /dev/input/event4 /dev/input/event2
#                      ↑ USB鼠标      ↑ PS2转USB鼠标
```

### 同一设备为什么有两个 event？

USB HID 鼠标注册两个接口：
- input0（键盘接口，无 REL，发按键事件）→ 忽略
- input1（鼠标接口，有 REL，发位移事件）→ 用这个

## 十、RS422 通信（PC 应用开发）

RS422 路分两个方向：**数据上行**（PC 读轨迹球上报数据）和 **命令下行**（PC 发命令给轨迹球）。

### 10.1 数据上行（PC 读）

| 参数 | 值 |
|---|---|
| 读取地址 | `0x20001100`（环形区，**推荐**） |
| 每次读取 | 2048 字节（64 槽 × 32B） |
| 单槽（legacy） | `0x20000060`（仅最新帧，高速丢帧，不建议用） |
| device_id | `3` |

槽位格式同 `ShareSlot`（32 字节）。**标准报文（0xD1~0xD5）为完整原始帧透传**：`data[]` 含 0x55 帧头 + 命令 + 有效数据 + 校验和，PC 可二次校验：

| 帧类型 | data_len | data[] 内容 |
|---|---|---|
| 位移信息 (0xD1) | 6 | `55 D1` + X Y 按键 + 校验 |
| 状态信息 (0xD2) | 6 | `55 D2` + 模式/分辨率/采样率 + 校验 |
| BIT 温度 (0xD3) | 4 | `55 D3` + 温度值(℃) + 校验 |
| BIT 电压 (0xD4) | 5 | `55 D4` + 电压(2B) + 校验 |
| 软件版本 (0xD5) | 6 | `55 D5` + 版本号(3B) + 校验 |
| 上电 PBIT (0xD6) | 7 | **精简格式**：`D6` + PBIT 数据(6B) |
| 设备型号 (0xD7) | 8×2片 | 16 字节拆 2 槽 |

**解析要点**：`data[0]==0x55` 即完整帧，`data[1]`=命令码，有效数据=`data[2..data_len-2]`，末字节=校验和（算法：`(0x55+命令+数据)&0xFF`）；`data[0]` 为命令码则是精简格式（PBIT）。

**位移有效数据位定义**（完整帧 data[2..4]）：data[2].bit7=X符号，data[3].bit7=Y符号，data[4].bit6=模式(1=Remote)，bit1=右键，bit0=左键。

**设备型号分片**：16 字节超 data[8] 上限拆 2 片，`reserved=(片序<<16)|16`，片0=前8字节、片1=后8字节。

```cpp
// 读 RS422 环形区（device_id=3）
void readRs422(HANDLE hC2H) {
    ShareSlot slots[64];
    LARGE_INTEGER off; off.QuadPart = 0x20000000ULL + 0x1100;
    SetFilePointerEx(hC2H, off, NULL, FILE_BEGIN);
    DWORD ret = 0;
    ReadFile(hC2H, slots, 2048, &ret, NULL);
    // 遍历 slots，筛 device_id==3 且 seq>lastSeq，按 seq 升序回放
}
```

### 10.1.1 RS422 完整接收示例（C++）

```cpp
#include <windows.h>
#include <cstdio>
#include <cstring>
#include <cstdint>

#pragma pack(push, 1)
struct ShareSlot {
    uint32_t seq;
    uint32_t device_id;
    uint32_t data_len;
    uint32_t reserved;
    uint8_t  data[8];
    uint32_t tv_sec;
    uint32_t tv_nsec;
};
#pragma pack(pop)
static_assert(sizeof(ShareSlot) == 32, "ShareSlot must be 32 bytes");

#define DEV_RS422    3
#define RING_RS422   0x20001100ULL
#define RING_BYTES   2048        // 64 槽 × 32B
#define RING_SLOTS   64

// 设备型号分片缓存（16 字节拆 2 槽，reserved 高位=片序）
static char    g_model[17] = {0};
static uint8_t g_modelMask = 0;   // bit0=收到片0, bit1=收到片1

// 解析单个 RS422 槽位（device_id==3）
// 标准报文(0xD1~0xD5)为完整帧：data[0]=0x55 data[1]=命令 data[2..n-2]=数据 data[n-1]=校验
// PBIT(0xD6)为精简格式：data[0]=0xD6 data[1..6]=数据
void parseRs422Slot(const ShareSlot& s) {
    const uint8_t* d = s.data;
    uint32_t n = s.data_len;

    if (n >= 4 && d[0] == 0x55) {           // 完整原始帧
        uint8_t cmd = d[1];
        const uint8_t* body = d + 2;         // 有效数据
        uint32_t blen = n - 3;               // 数据长度（去掉帧头/命令/校验）
        uint8_t cks = d[n - 1];
        // 二次校验
        uint32_t sum = 0x55 + cmd;
        for (uint32_t i = 0; i < blen; i++) sum += body[i];
        if ((sum & 0xFF) != cks) { printf("[RS422] 校验错 seq=%u\n", s.seq); return; }

        switch (cmd) {
        case 0xD1: {  // 位移：body[0]=X body[1]=Y body[2]=按键/模式
            int x = body[0] & 0x7F; if (body[0] & 0x80) x = -x;
            int y = body[1] & 0x7F; if (body[1] & 0x80) y = -y;
            printf("[RS422] 位移 X=%+d Y=%+d 模式=%s 左=%d 右=%d\n",
                   x, y, (body[2] & 0x40) ? "Remote" : "Stream",
                   body[2] & 0x01, (body[2] & 0x02) ? 1 : 0);
            break;
        }
        case 0xD3:  // 温度
            printf("[RS422] 温度 %d ℃\n", (int)(int8_t)body[0]);
            break;
        case 0xD4:  // 电压
            printf("[RS422] 电压 raw=%02X %02X\n", body[0], body[1]);
            break;
        case 0xD2:  // 状态
            printf("[RS422] 状态 模式=%d 分辨率=%d 采样率=%d\n",
                   body[0], body[1], body[2]);
            break;
        case 0xD5:  // 版本
            printf("[RS422] 版本 %d.%02d.%02d\n", body[0], body[1], body[2]);
            break;
        default:
            printf("[RS422] cmd=0x%02X len=%u\n", cmd, blen);
            break;
        }
        return;
    }

    if (n == 7 && d[0] == 0xD6) {           // PBIT 精简格式
        printf("[RS422] PBIT %02X %02X %02X %02X %02X %02X\n",
               d[1], d[2], d[3], d[4], d[5], d[6]);
        return;
    }

    if (n == 8 && (s.reserved & 0xFF) == 16) {  // 设备型号分片
        int piece = (s.reserved >> 16) & 0xFF;
        memcpy(g_model + piece * 8, d, 8);
        g_modelMask |= (1 << piece);
        if (g_modelMask == 0x3) {
            g_model[16] = 0;
            printf("[RS422] 设备型号 %s\n", g_model);
            g_modelMask = 0;
        }
        return;
    }

    printf("[RS422] len=%u data=", n);
    for (uint32_t i = 0; i < n && i < 8; i++) printf("%02X ", d[i]);
    printf("\n");
}

// 环形区接收主函数：死循环读 0x20001100，按 seq 回放新帧
void rs422ReceiveLoop(HANDLE hC2H) {
    ShareSlot slots[RING_SLOTS];
    uint32_t lastSeq = 0;
    bool first = true;

    while (true) {
        LARGE_INTEGER off; off.QuadPart = RING_RS422;
        SetFilePointerEx(hC2H, off, NULL, FILE_BEGIN);
        DWORD ret = 0;
        if (!ReadFile(hC2H, slots, RING_BYTES, &ret, NULL) || ret < RING_BYTES)
            continue;

        // 找本块内 device_id==3 的最大 seq
        uint32_t maxSeq = lastSeq;
        for (int i = 0; i < RING_SLOTS; i++)
            if (slots[i].device_id == DEV_RS422 && slots[i].seq > maxSeq)
                maxSeq = slots[i].seq;

        if (first) { lastSeq = maxSeq; first = false; continue; }  // 建立基线
        if (maxSeq <= lastSeq) continue;                           // 无新帧

        if (maxSeq - lastSeq > RING_SLOTS)
            printf("[RS422 提示] 丢帧 %u 帧（环形覆盖）\n", maxSeq - lastSeq - RING_SLOTS);

        // 按 seq 升序回放新帧（环形从 lastSeq+1 开始扫）
        for (uint32_t q = lastSeq + 1; q <= maxSeq; q++) {
            int idx = q % RING_SLOTS;
            if (slots[idx].device_id == DEV_RS422 && slots[idx].seq == q)
                parseRs422Slot(slots[idx]);
        }
        lastSeq = maxSeq;
    }
}
```

**要点**：
- 每次从 `0x20001100` 读 2048 字节（整环），不能只读单槽
- 用 `lastSeq` 去重，只回放 `seq > lastSeq` 的新槽
- 槽下标 = `seq % 64`（板端按此写环）
- `seq` 跳变 >64 说明环形覆盖丢帧
- 设备型号 16 字节拆 2 槽，用 `reserved` 拼片
- 完整帧带命令码（data[1]），位移/状态/版本不再混淆，且 PC 可用末字节校验和二次校验

### 10.2 命令下行（PC 发）

PC 经 XDMA **H2C** 通道写命令信箱，ARM 轮询后转发到 UART1 TX 发给轨迹球。

| 参数 | 值 |
|---|---|
| 写入地址 | `0x20000080` |
| 每次写入 | 32 字节 |
| 通道 | h2c_0（GENERIC_WRITE 打开） |

信箱格式（32 字节，复用槽位结构）：

```cpp
#pragma pack(push, 1)
struct CmdMailbox {
    uint32_t seq;        // 命令序号，每发一条+1（ARM 据此判断新命令）
    uint32_t device_id;  // 固定 0xCC（信箱标识）
    uint32_t data_len;   // 命令码（见下表）
    uint32_t reserved;   // 参数长度（无参数=0）
    uint8_t  data[8];    // 参数字节
    uint32_t tv_sec;     // 0
    uint32_t tv_nsec;    // 0
};
#pragma pack(pop)
```

**命令码对照表**：

| 命令 | 命令码(data_len) | 参数 | 轨迹球收到 |
|---|---|---|---|
| 切 Stream | `0xEA` | 无 | 0xEA×3 |
| 切 Remote | `0xF0` | 无 | 0xF0×3 |
| 位移查询(Remote) | `0xEB` | 无 | 0xEB×2 |
| 状态查询 | `0xE9` | 无 | 0xE9×3 |
| 温度查询 | `0xE4` | 无 | 0xE4×3 |
| 电压查询 | `0xE3` | 无 | 0xE3×3 |
| 版本查询 | `0xE2` | 无 | 0xE2×3 |
| 采样率配置 | `0xF3` | reserved=1, data[0]=Hz/10 | 0xF3×3+参数 |
| 分辨率配置 | `0xE8` | reserved=1, data[0]=档位0-10 | 0xE8×3+参数 |

```cpp
// PC 下发命令示例：切 Remote 模式
void sendRs422Cmd(HANDLE hH2C, uint32_t& seq, uint32_t cmd, uint8_t param=0, uint32_t plen=0) {
    CmdMailbox mb = {};
    mb.seq = seq++;           // 递增，ARM 检测变化
    mb.device_id = 0xCC;
    mb.data_len = cmd;
    mb.reserved = plen;
    mb.data[0] = param;
    LARGE_INTEGER off; off.QuadPart = 0x20000000ULL + 0x80;
    SetFilePointerEx(hH2C, off, NULL, FILE_BEGIN);
    DWORD ret = 0;
    WriteFile(hH2C, &mb, 32, &ret, NULL);  // 一次写 32 字节
}
```

### 10.3 工作模式

| 模式 | 触发 | 轨迹球行为 |
|---|---|---|
| Stream（默认） | 发 `0xEA` | 移动/按键实时主动上报 |
| Remote | 发 `0xF0` | 被动等 `0xEB` 查询才回帧（3-5ms 周期） |

### 10.4 参考实现

- PC 接收：`pc/win_mouse_receiver.py`（四路，含 RS422 解析）
- PC 命令下发：`pc/rs422_pc_cmd.py`（H2C 写信箱，支持 9 种命令）
- 详细协议：`docs/PC_RS422_Communication_Protocol.md`
