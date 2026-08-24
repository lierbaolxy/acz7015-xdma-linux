# USB + RS422 端到端数据通路实现原理与解决方案

> 本文档描述 PS 端（ARM Linux）USB 鼠标与 RS422 轨迹球数据采集，经 DDR 共享内存 + XDMA（PCIe）传输到 PC 端（Windows）的完整实现原理，以及开发过程中踩坑根因与解决方案。

## 一、总体架构

```
┌─────────────────────────── 开发板(PS端, ARM Linux) ───────────────────────────┐
│                                                                              │
│  USB鼠标 ──> /dev/input/event1 ──> poll()读取input_event ──┐                 │
│                                                              ├─> DDR共享内存  │
│  RS422轨迹球 ──> TTL转422模块 ──> UART1(EMIO: E5/B1) ──> 寄存器轮询FIFO ┘  │
│                                                                    │          │
│                              DDR槽位 0x20000000 (USB) / 0x20000060 (RS422)   │
│                              (32字节统一槽位 + D-cache clean刷回DDR)          │
└────────────────────────────────┬─────────────────────────────────────────────┘
                                 │ XDMA (PCIe, 经 axi_smc → S_AXI_HP0 → DDR)
┌────────────────────────────────▼─────────────────────────────────────────────┐
│  PC端(Windows): SetupAPI枚举XDMA → CreateFileA打开c2h_0 → ReadFile读64字节  │
│  → 解析前32字节 {seq,device_id,data_len,data[8]} → 还原鼠标/RS422事件        │
└──────────────────────────────────────────────────────────────────────────────┘
```

核心代码：

- PS 端：[arm_usb_rs422_sender.c](../linux/arm_apps/arm_usb_rs422_sender.c)
- PC 端：[win_mouse_receiver.py](../pc/win_mouse_receiver.py)

## 二、USB 鼠标采集（PS 端）

**原理：Linux input 子系统 + poll() 单进程双路复用**

1. 打开设备节点 `/dev/input/event1`（`open(input_dev, O_RDONLY)`，参数可覆盖）。
2. `poll(&pfd, 1, 5)` 监听 `POLLIN`，**5ms 短超时**——超时后让出 CPU 转去轮询 RS422 FIFO，实现单线程双通道采集。
3. `read()` 读 `struct input_event`，过滤 `EV_SYN`（帧分隔）和 `EV_MSC`（杂项）。
4. 压缩成 8 字节紧凑结构写入 DDR：

```c
typedef struct {
    uint16_t type;    // EV_KEY/EV_REL
    uint16_t code;    // BTN_LEFT/REL_X...
    int32_t  value;   // 位移量/按键态
} __attribute__((packed)) usb_event_t;  // 2+2+4=8字节
```

事件映射：

- `EV_REL`(0x02)：X 轴 `REL_X=0`、Y 轴 `REL_Y=1`、滚轮 `REL_WHEEL=8`
- `EV_KEY`(0x01)：左键 `BTN_LEFT=0x110`、右键 `BTN_RIGHT=0x111`、中键 `BTN_MIDDLE=0x112`

## 三、RS422 采集（PS 端）

### 3.1 物理链路

- PS UART1（`0xE0001000`）配 **EMIO** 引出：`UART_1_TX_O=E5`、`UART_1_RX_I=B1`，对应 40pin 排针 **pin26/pin28**，电平 `LVCMOS33`（3.3V）。
- 接线（交叉 + 共地）：
  - 板 TX(pin26/E5) → 模块 RX
  - 板 RX(pin28/B1) → 模块 TX
  - 模块用 3.3V（**严禁 5V，会烧 FPGA**），并必须与板卡共地。

### 3.2 核心根因（本项目最关键的坑）

> **UART1 RX 硬件上 = MIO49 输入 OR EMIO_RX（相或）**

板上 USB 转串口芯片（console 用）的 TX 恒驱动 MIO49 为高（UART 空闲态 = 1），导致 OR 结果恒为 1，EMIO RX 的真实数据被污染，收到的全是 0xFF 空帧。

### 3.3 解决方案（运行时，无需改 bitstream）

用 `/dev/mem` + mmap 写 SLCR，把 MIO48/49 从 UART 切为 GPIO 三态：

```c
wr(slcr, 0x008, 0xDF0D);  // SLCR UNLOCK
wr(slcr, 0x7C4, 0x1200);  // MIO49 -> GPIO 三态
wr(slcr, 0x7C0, 0x1200);  // MIO48 -> GPIO 三态
wr(slcr, 0x004, 0x767B);  // SLCR LOCK
```

### 3.4 采集：寄存器级轮询 FIFO（不能用 tty read）

| 寄存器 | 偏移 | 说明 |
|---|---|---|
| CR | 0x00 | 控制 |
| MR | 0x04 | 模式，**CHMODE=bits[9:8]**（0x20=NORMAL） |
| IDR | 0x0C | 中断屏蔽（写全 1，防 serial-getty 抢占 FIFO） |
| SR | **0x2C** | 状态（**不是 0x28**），bit1=RXEMPTY(0x02) |
| FIFO | 0x30 | 收发 FIFO |

主循环 `while (!(rd(uart, SR) & SR_RXEMPTY) && cnt<256)` 轮询读字节，喂给 4 态状态机 `parser_feed()`。

> 注意：EMIO 模式下 tty 驱动的 RX 中断路径不触发，`read()` 会永远阻塞，因此只能用寄存器级轮询 FIFO。

### 3.5 协议帧（0x55 帧头 + 标识 + 数据 + 校验和）

| 报文 | 标识 | 长度 |
|---|---|---|
| 位移 | 0xD1 | 3 |
| 状态 | 0xD2 | 3 |
| 温度 | 0xD3 | 1 |
| 电压 | 0xD4 | 2 |
| 版本 | 0xD5 | 3 |

校验和 = 从帧头到数据末字节累加取低 8 位。

## 四、共享内存协议（DDR 槽位）

### 4.1 槽位布局（四路，各 32 字节）

```
基址 0x20000000
  USB   偏移 0x00  → 0x20000000
  CAN   偏移 0x20  → 0x20000020 (预留)
  PS2   偏移 0x40  → 0x20000040 (预留)
  RS422 偏移 0x60  → 0x20000060
```

```c
typedef struct {
    uint32_t seq;        // 0x00 序号
    uint32_t device_id;  // 0x04 0=USB 1=CAN 2=PS2 3=RS422
    uint32_t data_len;   // 0x08
    uint32_t reserved;   // 0x0C
    uint8_t  data[8];    // 0x10
    uint32_t tv_sec;     // 0x18
    uint32_t tv_nsec;    // 0x1C
} share_slot_t;  // 32字节，对齐一条 cache line
```

### 4.2 写入顺序（关键：防止 PC 端读到撕裂数据）

```
写 data_len/reserved/data/tv_sec
  → __sync_synchronize()   (DMB 内存屏障，保证先落地)
  → seq = ++xxx            (seq 最后写，作为"新数据"标志)
  → dma_wb_slot()          (D-cache clean 刷回 DDR)
```

### 4.3 Cache 一致性（XDMA 读 DDR 的必做项）

- ARM CPU 写 DDR 走 **D-cache write-back**，数据滞留在 cache，物理 DDR 是旧值。
- XDMA 走 **AXI 主口直接读物理 DDR**，不经过 CPU cache。
- 故每次写槽位后必须做 D-cache clean，把 32 字节脏行刷回 DDR，XDMA 才能读到最新数据：

```c
#ifndef __ARM_NR_cacheflush
#define __ARM_NR_cacheflush (0x0f0000 + 2)   // ARM cacheflush 系统调用号
#endif

static inline void dma_wb_slot(const volatile void *p) {
    syscall(__ARM_NR_cacheflush, (long)p,
            (long)((const char *)p + sizeof(share_slot_t)), 0);
}
```

## 五、PC 端 XDMA 接收（Windows）

1. **枚举**：SetupAPI 按设备接口 GUID `{74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d}` 枚举（`SetupDiGetClassDevs` → `SetupDiEnumDeviceInterfaces` → 取 DevicePath）。
2. **打开**：`CreateFileA(base_path + "\c2h_0", GENERIC_READ|GENERIC_WRITE, 0, None, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, None)` —— **同步 I/O，禁止 `FILE_FLAG_OVERLAPPED`**。
3. **读取**：`SetFilePointerEx(0x20000000+offset)` 设 DMA 源地址，`ReadFile(h, buf, 64, ...)` 读 **64 字节**（XDMA burst 对齐要求），取前 32 字节解析。
4. **解析**：`struct.unpack_from('<IIII', data, 0)` 小端解出 seq/device_id/len/reserved，`data[0x10:0x18]` 还原 input_event。
5. **退出机制**：`Ctrl+C` 后 `os._exit(0)` 强制退出（同步 ReadFile 阻塞在驱动内无法优雅打断，避免 XDMA 引擎卡死）——**绝不能强杀进程**。

## 六、关键注意事项（防踩坑）

1. **XDMA Code 10 根因**：`M_AXI_LITE` 悬空导致 user BAR 地址段归零。方案 A 用 `fix_xdma_mlite.tcl` 挂最小 AXI GPIO 从机（`xdma_lite_slave`）恢复 `0x40000000[64K]`。当前最优 bit = `11ac4f4e`（XDMA 正常 + UART1 EMIO 共存）。
2. **RS422 必须先停 console**：`sudo systemctl stop serial-getty@ttyPS0.service`，否则 tty 驱动抢 FIFO。
3. **UART1 状态寄存器是 CSR=0x2C**，不是 0x28（0x28 是 FLOW 寄存器）。
4. **XDMA ReadFile 必须读 64 字节**（即使槽位 32 字节），读 32 会阻塞。
5. **改 bitstream 前先备份 SD 卡**当前正常版。
6. **多进程冲突**：测试程序和正式程序不能同写一个槽位，否则 seq 乱跳。
7. **XDMA 版本 MD5 档案**：
   - `a5e24acd` = XDMA 正常工作版（无 UART1 EMIO）
   - `11ac4f4e` = 方案 A 修复版（XDMA 正常 + UART1 EMIO E5/B1）★最优