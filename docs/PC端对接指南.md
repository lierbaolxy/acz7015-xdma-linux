# PC端对接指南（USB / PS2 / RS422）

> ACZ7015 XDMA 采集卡 → 上位机（Windows PC）数据对接说明
> 适用版本：V4 协议（32字节统一槽位 + 64槽环形缓冲）
> 依据：`docs/protocol_spec.md`、`docs/USB接口对接文档.md`、`docs/RS422接口对接文档.md`、`pc/win_mouse_receiver.py`

---

## 1. 系统架构

```
USB鼠标  ──> /dev/input/eventX ─┐
PS2鼠标  ──> PS2扫描码         ─┼──> ACZ7015(PS端Linux) ──> DDR共享内存 ──PCIe/XDMA──> PC上位机
轨迹球   ──RS422──> /dev/ttyPS0 ─┘           0x20000000              c2h_0读取
```

- 板端（ACZ7015，Zynq7015）负责采集三路数据并写入 DDR 共享内存。
- PC 端通过 XDMA 的 `c2h_0` 设备用 **DMA 方式**直接读 DDR，无需逐字节串口/IO 交互。
- 单次 DMA 传输延时约 0.55ms。

---

## 2. XDMA 读取 DDR 方式

### 2.1 设备节点

| XDMA 通道 | 方向 | 用途 |
|-----------|------|------|
| `c2h_0` | Card-to-Host | **PC 读 DDR（本指南只用它）** |
| `h2c_0` | Host-to-Card | PC 写 DDR（命令下发预留） |
| `user` | AXI-Lite | 寄存器访问 |

- 设备接口 GUID：`{74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d}`
- Vendor ID `10ee`（Xilinx），Device ID `7021`
- 设备路径形如：`\\?\pci#ven_10ee...#{GUID}`

### 2.2 读取三步流程（同步 I/O）

1. **枚举设备**：SetupAPI 按 GUID 枚举，得到设备接口路径；
2. **打开 c2h_0**：`CreateFileA(path + "\\c2h_0", GENERIC_READ|GENERIC_WRITE, 0, ..., OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)`；
3. **设地址 + 读取**：`SetFilePointerEx(h, 目标DDR地址, FILE_BEGIN)` 后用 `ReadFile` 读。

### 2.3 关键约束（对接必读）

- **必须同步 I/O**：`FILE_ATTRIBUTE_NORMAL`，**不要**用 `FILE_FLAG_OVERLAPPED`；
- **必须同时具备读写权限**：`GENERIC_READ | GENERIC_WRITE`，仅 `GENERIC_READ` 会读失败；
- **单槽区读 64 字节**：XDMA 驱动对齐要求，即使只需前 32 字节，取前 32 字节解析即可；
- **环形区一次读整块 2KB**：64槽 × 32B = 2048 字节，一次 DMA 读回再本地解析；
- **正常退出**：Ctrl+C；强杀进程会导致 DMA 引擎卡死（ReadFile 永久阻塞），只能重启 PC。

---

## 3. DDR 地址映射

### 3.1 单槽区（legacy，同步写最新值）

| 接口 | DDR 地址 | device_id | 说明 |
|------|----------|-----------|------|
| USB   | `0x20000000` | 0 | 最新 1 帧 |
| PS2   | `0x20000040` | 2 | 最新 1 帧 |
| RS422 | `0x20000060` | 3 | 最新 1 帧 |

> CAM/CAN（device_id=1）地址 `0x20000020` 为预留，本指南不涉及。

### 3.2 环形缓冲区（V4，记录历史帧，防覆盖丢帧）

| 接口 | 环形区地址 | 槽数 | 字节数 |
|------|-----------|------|--------|
| USB   | `0x20000100` | 64 | 2048 (2KB) |
| PS2   | `0x20000900` | 64 | 2048 (2KB) |
| RS422 | `0x20001100` | 64 | 2048 (2KB) |

> 表中数值为 **相对 DDR 基址（0x20000000）的偏移**，绝对地址 = `0x20000000 + offset`。
> 偏移值即 `win_mouse_receiver.py` 中 `RING_USB=0x100`、`RING_PS2=0x900`、`RING_RS422=0x1100`。

### 3.3 环形缓冲区工作机制

- 板端写 `ring[seq % 64]`，`seq` 为每路**全局递增**序号（跨重启不清零语义）；
- 板端**最后写 seq**（前置内存屏障 + cache clean），PC 读到新 seq 即代表该槽数据已就绪（防撕裂）；
- 单槽区（0x00~0x7F）仍同步写最新值，兼容旧版 PC 程序；
- PC 端一次 DMA 读回整块 2KB，按 seq 升序回放；仅当 seq 跳变 > 64 才判定为环形覆盖丢帧。

---

## 4. 统一槽位结构（32 字节，对齐 cache line）

所有接口共用同一结构，小端序：

```c
#pragma pack(push, 1)
typedef struct {
    uint32_t seq;        /* 0x00: 序号，每次写+1（PC端靠它检测新数据） */
    uint32_t device_id;  /* 0x04: 接口类型 0=USB 2=PS2 3=RS422 */
    uint32_t data_len;   /* 0x08: 有效数据长度 */
    uint32_t reserved;   /* 0x0C: 保留/分片编码（RS422 D7 型号用） */
    uint8_t  data[8];    /* 0x10: 原始数据，见第5节 */
    uint32_t tv_sec;     /* 0x18: 板端时间戳-秒（CLOCK_MONOTONIC） */
    uint32_t tv_nsec;    /* 0x1C: 板端时间戳-纳秒 */
} share_slot_t;          /* 共 0x20 = 32 字节 */
#pragma pack(pop)
```

### device_id 定义

| device_id | 接口 | 状态 |
|-----------|------|------|
| 0 | USB | 已实现 |
| 1 | CAN | 预留，不参与本指南 |
| 2 | PS2 | 已实现 |
| 3 | RS422 | 已实现 |

### 时间戳说明

`tv_sec` + `tv_nsec` 为板端 Linux `CLOCK_MONOTONIC` 时间戳。PC 与板端时钟不同步，计算端到端延时需用首帧校准 offset：

```text
clock_offset = pc_time - arm_time         # 首帧校准
latency      = pc_time - arm_time - clock_offset
```

---

## 5. 三路数据格式（data[8]）

### 5.1 USB（device_id=0）

`data[8]` 为 **Linux input event 三字段**（非 USB HID 原始报文），`data_len` 固定 8：

| data 偏移 | 长度 | 字段 | 类型 | 说明 |
|-----------|------|------|------|------|
| 0x00 | 2B | type | uint16 LE | 事件类型 |
| 0x02 | 2B | code | uint16 LE | 事件代码 |
| 0x04 | 4B | value | int32 LE（有符号） | 事件值 |

事件类型：

| type | 含义 | code/含义 | value |
|------|------|-----------|-------|
| 0x0001 EV_KEY | 按键 | 0x0110左键 / 0x0111右键 / 0x0112中键 | 1=按下, 0=松开 |
| 0x0002 EV_REL | 位移 | 0x0000 X轴 / 0x0001 Y轴 / 0x0008 滚轮 | X正=右, Y正=下, 滚轮正=上（有符号） |

### 5.2 PS2（device_id=2）

`data[8]` 存标准 PS/2 鼠标 3 字节数据包，`data_len` = 3：

| 字节 | 位定义 |
|------|--------|
| Byte0 | [Y溢出][X溢出][Y符号][X符号][1][中键][右键][左键] |
| Byte1 | X 位移（9 位补码低 8 位，右为正） |
| Byte2 | Y 位移（9 位补码低 8 位，PS/2 约定上为正） |

- X 符号位 = `Byte0 & 0x10`；Y 符号位 = `Byte0 & 0x20`；
- 左键 = `Byte0 & 0x01`；右键 = `(Byte0>>1) & 0x01`；中键 = `(Byte0>>2) & 0x01`。

### 5.3 RS422（device_id=3）

`data[8]` 布局（D1~D6 常规报文）：**`data[0]` = 报文标识（0xD1~0xD6），`data[1..]` = 有效数据**；`data_len` = 1（标识字节）+ 有效数据长度，剩余字节清零。D7（设备型号）为裸字节分片，`data` 全部存型号字节、不含标识，判断依据是 `reserved`（见第 6 节）。

| 报文 | 标识 data[0] | 有效数据长度 | data_len | 内容 |
|------|-------------|-------------|----------|------|
| 位移信息 | 0xD1 | 3 | 4 | data[1]=按键/符号位, data[2]=X(补码), data[3]=Y(补码) |
| 状态信息 | 0xD2 | 3 | 4 | data[1]=模式(bit6), data[2]=分辨率, data[3]=采样率 |
| BIT温度 | 0xD3 | 1 | 2 | data[1]=signed char ℃ |
| BIT电压 | 0xD4 | 2 | 3 | data[1]=低8位, data[2]=高8位, 单位10mV |
| 软件版本 | 0xD5 | 3 | 4 | data[1..3]=版本号 |
| 上电PBIT | 0xD6 | 6 | 7 | 6字节 CHAR |
| 设备型号 | 0xD7 | 16 | 8×2片 | 拆 2 片存储，见第 6 节 |

---

## 6. RS422 设备型号（0xD7，16 字节）分片拼接规则

型号为 16 字节 CHAR（如 `"IDCH20-427"`），而统一槽位 `data[8]` 上限 8 字节，故拆 **2 片**，用 `reserved` 字段编码分片信息：

```
reserved = (片序号 << 16) | 总长度(0x10 = 16)
  片0: reserved = 0x00000010  data[0..7] = 型号前 8 字节
  片1: reserved = 0x00010010  data[0..7] = 型号后 8 字节
```

**约定要点：**

- 两片共用 `device_id=3`（RS422），写入环形缓冲区**连续两个槽**（seq = n、n+1）；
- 均为**裸字节**存储——不含 0x55 帧头、不含 0xD7 标识、不含校验和，`data[8]` 里全部放型号字节；
- 上位机读到 `reserved` 低位 = 16（0x10）时判定为设备型号分片，按 `reserved` 高 16 位片序号拼接回完整 16 字节；
- **单槽区（legacy）只存片 0 的前 8 字节**（槽位只有 32 字节空间），完整 16 字节型号必须从环形缓冲区读取拼接。

---

## 7. Python 解析示例

以下为可独立运行的解析函数和主流程骨架，含 XDMA 读取与 RS422 D7 分片拼接。可直接对照 `pc/win_mouse_receiver.py` 使用。

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""PC端对接解析示例：32字节槽位 + 环形缓冲 + RS422 D7分片拼接"""
import ctypes, struct
from ctypes import wintypes

DDR_BASE   = 0x20000000
SLOT_SIZE  = 32
RING_SLOTS = 64
RING_BYTES = RING_SLOTS * SLOT_SIZE  # 2048

# 环形区偏移（相对DDR基址）
RING_USB   = 0x100
RING_PS2   = 0x900
RING_RS422 = 0x1100

DEV_USB, DEV_PS2, DEV_RS422 = 0, 2, 3


def parse_slot(buf: bytes, off: int = 0):
    """解析一个32字节槽位为字典"""
    seq, device_id, data_len, reserved = struct.unpack_from(
        '<IIII', buf, off)
    data = buf[off + 0x10:off + 0x18]
    tv_sec, tv_nsec = struct.unpack_from('<II', buf, off + 0x18)
    return dict(seq=seq, device_id=device_id, data_len=data_len,
                reserved=reserved, data=data, tv_sec=tv_sec, tv_nsec=tv_nsec)


def parse_usb(data: bytes):
    """USB: input_event type(2B)+code(2B)+value(4B)"""
    typ, code = struct.unpack_from('<HH', data, 0)
    value = struct.unpack_from('<i', data, 4)[0]
    return typ, code, value


def parse_ps2(data: bytes):
    """PS/2 3字节包 -> (x, y, left, right, middle)"""
    b0, b1, b2 = data[0], data[1], data[2]
    x = b1 - 256 if (b0 & 0x10) else b1
    y = b2 - 256 if (b0 & 0x20) else b2
    return x, y, b0 & 0x01, (b0 >> 1) & 0x01, (b0 >> 2) & 0x01


def parse_rs422(slot: dict):
    """RS422: data[0]=标识, data[1:]=有效数据"""
    pkt = slot['data']
    tag = pkt[0]
    payload = pkt[1:slot['data_len']]
    return tag, payload


def concat_d7(entries: list) -> bytes | None:
    """按 reserved 高低16位拼接 RS422 设备型号(16字节)

    entries: 由 parse_ring_entries 得到的同 seq 升序的槽位字典列表
    返回拼接后的16字节型号，不完整返回 None
    """
    frags = {}
    for e in entries:
        if e['device_id'] != DEV_RS422:
            continue
        total = e['reserved'] & 0xFFFF
        frag_no = (e['reserved'] >> 16) & 0xFFFF
        if total == 16:  # 判定为设备型号分片
            frags[frag_no] = e['data'][:8]
    if 0 in frags and 1 in frags and len(frags) == 2:
        model = frags[0] + frags[1]
        return model.rstrip(b'\x00')
    return None


def parse_ring_entries(ring: bytes, expect_dev: int) -> list:
    """解析整块2KB环形缓冲，返回按seq升序的槽位字典列表"""
    out = []
    for i in range(RING_SLOTS):
        s = parse_slot(ring, i * SLOT_SIZE)
        if s['seq'] == 0 or s['device_id'] != expect_dev:
            continue
        if s['data_len'] == 0 or s['data_len'] > 8:
            continue
        out.append(s)
    out.sort(key=lambda e: e['seq'])
    return out


def read_ring(handle, ring_offset: int) -> bytes:
    """XDMA c2h_0 同步读整块2KB（本函数仅示意，句柄由外部打开）"""
    buf = (ctypes.c_ubyte * RING_BYTES)()
    read = wintypes.DWORD(0)
    kernel32 = ctypes.windll.kernel32
    kernel32.SetFilePointerEx(handle, ctypes.c_longlong(DDR_BASE + ring_offset),
                              None, 0)
    if not kernel32.ReadFile(handle, buf, RING_BYTES, ctypes.byref(read), None):
        return b''
    return bytes(buf) if read.value >= RING_BYTES else b''


def demo_parse():
    # 示例：构造相邻两片 RS422 D7 槽位（seq=10,11）
    model = b'IDCH20-427'      # 前10字节
    frag0 = bytes([0xD7]) + model[:7]  # 片0：前8字节
    frag1 = bytes([0xD7]) + model[7:]  # 片1：未知，仅示意
    # 实际裸字节存储不含 0xD7 标识，这里仅演示拼接流程，真实数据直接用 model[:8]/model[8:]
    f0 = model[:8].ljust(8, b'\x00')
    f1 = model[8:].ljust(8, b'\x00')
    e0 = dict(seq=10, device_id=3, data_len=8, reserved=0x00000010, data=f0)
    e1 = dict(seq=11, device_id=3, data_len=8, reserved=0x00010010, data=f1)
    print("拼接出型号:", concat_d7([e0, e1]).decode('ascii', 'replace'))


if __name__ == '__main__':
    demo_parse()
```

> 通用接收主流程（设备枚举 → 打开 c2h_0 → 轮询三路环形区 → seq 升序回放 → 丢帧检测）请直接参考 `pc/win_mouse_receiver.py`，本文不再重复。

---

## 8. 对接注意事项

1. **启动顺序**：建议先启动板端采集程序，再启动 PC 端；反向启动亦可，PC 端会空转等待。
2. **seq 检测**：PC 端以 `seq` 变化判断新数据，单槽区轮询 10ms 即可（USB 事件 100~500Hz）。
3. **丢帧判定**：环形区按 `max(seq) - last_seq - 收到帧数` 计算丢失帧，仅 seq 跳变超过 64 才视为环形覆盖。
4. **读取长度**：单槽读 64 字节（取前 32B），环形区读 2048 字节（64 的倍数，满足 XDMA 要求）。
5. **符号位**：USB value 为有符号 int32；PS2 X/Y 需按符号位做补码扩展；切勿用无符号解析。
6. **退出方式**：Ctrl+C 正常退出；强杀进程会导致 DMA 引擎卡死，需重启 PC。

---

**文档结束**