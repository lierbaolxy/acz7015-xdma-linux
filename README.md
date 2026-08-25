# ACZ7015 XDMA + Linux 共存方案

基于 ACZ7015（Zynq7015）开发板，实现 PS 侧 Linux 系统与 PL 侧 XDMA PCIe 共存，支持 **USB 鼠标 / PS2 鼠标 / RS422 / CAN 四路外设**数据同时采集，通过 PCIe 实时传输到 Windows PC。

## 功能特性

- PS 侧运行 Ubuntu 16.04.4 LTS（内核 4.14.0-xilinx）
- PL 侧 XDMA PCIe EP 模式，Windows PC 通过 PCIe 访问 FPGA
- USB Host 模式，支持 USB 鼠标热插拔
- PS2 鼠标经 USB 转接模块接入
- RS422 经 PS UART1(EMIO) + TTL 转 RS422 模块
- CAN 经 CH343 USB-CANFD 模块（包模式 MODE2，500kbps 扩展帧）
- 四路数据通过 DDR 共享内存 + XDMA 实时传输到 PC
- PCIe 单次 DMA 延时约 0.55ms

## 硬件平台

- 开发板：ACZ7015（Zynq7015 SoC：双核 Cortex-A9 + Artix-7 FPGA）
- DDR：1GB（其中 512MB 预留给 XDMA DMA 缓冲区）
- PCIe：PL 侧 GTP 收发器（XDMA EP 模式）
- USB：PS 侧 USB3320 PHY + CH334H HUB，3×Type-A Host
- RS422：PS UART1 通过 EMIO 引出至 PL 侧 E5(TX)/B1(RX)，接 TTL 转 RS422 模块
- CAN：USB-CANFD-V1（泥人科技，CH343 芯片）插 PS 侧 USB Host 口
- 网络：RTL8211F 千兆以太网 + RTL8188FU USB WiFi

## 目录结构

```
acz7015-xdma-linux/
├── linux/                    # 开发板 Linux 侧
│   ├── device_tree/         # 设备树改造脚本
│   ├── sd_patch/            # SD卡文件替换脚本
│   └── arm_apps/            # 开发板 C 程序
│       ├── arm_all_four.c       # ★ 四路单进程采集程序（USB/PS2/RS422/CAN）
│       ├── start_four.sh        # ★ 统一启动脚本（释放UART1 + 清旧进程 + 启动采集）
│       ├── ch343.ko             # CH343 USB转串口驱动（CAN模块用）
│       ├── deploy_four_senders.py  # 编译+上传+启动一键脚本
│       └── arm_usb_ps2_rs422_sender.c  # 旧版三路采集（无CAN，保留备份）
├── pc/                       # Windows PC 侧
│   ├── win_mouse_receiver.py     # ★ 四路数据接收显示（环形缓冲零丢帧）
│   ├── win_can_receiver.py      # CAN 单路接收显示
│   ├── win_rs422_receiver.py    # RS422 单路接收显示
│   ├── win_xdma_latency_v3.py   # 乒乓法延时测试
│   └── pc_can_peer.py           # PC端CAN对等测试工具（模拟轨迹球对端）
├── pc_tools/                # PC端模拟发送工具
│   ├── rs422_pc_send.py        # RS422协议帧发送（模拟轨迹球上报D1~D5）
│   └── rs422_pc_send.cpp       # 同上C++版
├── docs/                    # 协议与对接文档
│   ├── protocol_spec.md        # 通信协议规范（RS422/CAN/USB/PS2 + DDR布局）
│   ├── PC端对接指南.md          # PC端XDMA读取与解析指南
│   ├── USB接口对接文档.md
│   └── RS422接口对接文档.md
├── driver/                  # XDMA Windows驱动
└── README.md
```

## 数据链路

```
USB鼠标   → PS侧USB控制器     → /dev/input/event1  ─┐
PS2鼠标   → USB转PS2模块     → /dev/input/event3  ─┤
RS422设备 → TTL转RS422模块   → PS UART1(EMIO)     ─┼─→ 单进程arm_all_four
CAN设备   → USB-CANFD(CH343) → /dev/ttyCH343USB0 ─┘     ↓ 写DDR共享内存(0x20000000)
                                                            ↓ 各路独立槽位+64槽环形缓冲区
Windows PC ← XDMA PCIe C2H DMA ← DDR共享内存 ←────────────┘
```

## DDR 共享内存结构

物理地址：0x20000000（reserved-memory 区域）

### 统一槽位格式（32 字节，对齐 cache line）

```
偏移  字段        大小    说明
0x00  seq         4字节   序号（每次事件+1，PC端检测变化）
0x04  device_id   4字节   接口类型: 0=USB 1=CAN 2=PS2 3=RS422
0x08  data_len    4字节   有效数据长度
0x0C  reserved    4字节   保留/分片编码（RS422 D7型号用）
0x10  data[8]     8字节   原始数据
0x18  tv_sec      4字节   开发板时间戳（秒）
0x1C  tv_nsec     4字节   开发板时间戳（纳秒）
合计              32字节
```

### 四路单槽位 + 环形缓冲区布局

| 接口 | 单槽地址 | 环形区地址 | 环形区大小 | device_id |
|------|----------|-----------|-----------|-----------|
| USB   | 0x20000000 | 0x20000100 | 2KB(64槽) | 0 |
| CAN   | 0x20000020 | 0x20001900 | 2KB(64槽) | 1 |
| PS2   | 0x20000040 | 0x20000900 | 2KB(64槽) | 2 |
| RS422 | 0x20000060 | 0x20001100 | 2KB(64槽) | 3 |

环形缓冲区：每路 64 槽 × 32B = 2KB，板端写 `ring[seq % 64]`，PC 端一次 DMA 读整块 2KB 后按 seq 升序回放，解决单槽覆盖丢帧。

## 外设接线

### USB 鼠标 / PS2 鼠标（即插即用）

- **USB 鼠标**：直接插板卡 USB Host 口（Type-A），Linux 自动枚举为 `/dev/input/eventN`
- **PS2 鼠标**（实为 USB 转接模块）：同样插 USB Host 口，系统自动识别为 input 设备
- 查节点编号：`cat /proc/bus/input/devices | grep -B1 -A5 -i mouse`

### RS422（需三段连线）

RS422 不能即插即用，需要 **PC 串口 → TTL 转 RS422 模块 → 板卡排针** 三段连线，且板端为被动接收（需 PC 端主动发数据）。

#### 器件清单

| 器件 | 说明 |
|------|------|
| TTL 转 RS422 模块 | TTL 侧 3.3V 逻辑，接板卡排针；RS422 侧差分信号，接 PC 线缆 |
| 摩可灵 USB 转 RS422 线缆 | CH348 芯片，PC 端枚举为 COM 口（如 COM13），4 线全双工 |

#### 连线图

```
PC USB口                        开发板 GPIO0 排针(P7)
  │                                │
  摩可灵USB转RS422线(COM13)        │
  │  T/R+(发送+)──────────────────→ 模块 Y/T+(TX+)   │
  │  T/R-(发送-)──────────────────→ 模块 Z/T-(TX-)   │
  │  R+(接收+) ←─────────────────── 模块 A/R+(RX+)   │
  │  R-(接收-) ←─────────────────── 模块 B/R-(RX-)   │
  │  GND ────────────────────────── 模块 GND          │
  │                                │                  │
  │                                模块TTL侧(交叉接法)│
  │                                模块 RXD ←── pin26(E5, UART1_TX)
  │                                模块 TXD ──→ pin28(B1, UART1_RX)
  │                                模块 VCC ──  pin29(3.3V)
  │                                模块 GND ──  pin30(GND)
```

#### 接线要点

1. **板卡↔模块 TTL 侧（交叉接法）**：模块 RXD→pin26(E5=UART1_TX)，模块 TXD→pin28(B1=UART1_RX)，**交叉不是直连**
2. **模块↔摩可灵 RS422 侧（全双工交叉）**：模块 TX+→摩可灵 R+，模块 TX-→摩可灵 R-，模块 RX+←摩可灵 T/R+，模块 RX-←摩可灵 T/R-
3. **供电**：模块用板卡 pin29(3.3V) + pin30(GND)，**不要用 pin11(5V) 会烧 Bank35**
4. **上电前量电压**：模块 VCC 对 GND 应为 3.3V±0.1V，TTL 空闲应为 3.3V 逻辑（5V 则烧芯片）

> 详细引脚位置见 [docs/RS422接口对接文档.md](docs/RS422接口对接文档.md)

### CAN（USB-CANFD-V1 模块）

- 将 USB-CANFD-V1（泥人科技，CH343 芯片）插板卡 USB Host 口
- 板端自动枚举为 `/dev/ttyCH343USB0`（需先 `insmod ch343.ko`）
- CAN 侧（CANH/CANL）无对端设备时收不到数据，需回环模式或第二个 CAN 模块

## 快速开始

### 1. 烧录 SD 卡

用 Win32DiskImager 烧录原厂 Ubuntu 镜像到 SD 卡。

### 2. 替换启动文件

```bash
python final_replace.py
```

替换 3 个文件：
- `system.bit` → XDMA bitstream（3,510,780 字节）
- `system.dtb` → 改造设备树（禁用11个PL节点 + USB Host）
- `uEnv.txt` → 启动配置（bitstream_size=0x400000，无BOM）

### 3. 开发板运行四路采集程序

#### 方式一：手动编译运行（调试用）

```bash
# 编译（板上 gcc）
cd /tmp && gcc -O2 -o arm_all_four arm_all_four.c

# 运行（需 root，mmap /dev/mem）
# 参数：usb节点 ps2节点（event编号以实际为准）
sudo ./a.out /dev/input/event1 /dev/input/event3 > /tmp/all_four2.log
```

> **注意**：上面 `a.out` 是默认输出名，也可以指定 `-o arm_all_four` 编译。
> event 节点号需先查：`cat /proc/bus/input/devices | grep -B1 -A5 -i mouse`

#### 方式二：一键启动脚本（推荐，自动释放 UART1 + 清旧进程）

```bash
sudo sh /tmp/start_four.sh /dev/input/event1 /dev/input/event3
```

##### start_four.sh 脚本内容说明

`start_four.sh` 做了以下 3 件事：

1. **释放 UART1 console**（RS422 复用 ttyPS0，先 stop 再 disable 防 systemd 自动重启）：
   ```sh
   systemctl stop serial-getty@ttyPS0.service
   systemctl disable serial-getty@ttyPS0.service
   ```

2. **清理旧进程**（按命令行匹配，防止多实例并存抢 DDR 环形缓冲区）：
   ```sh
   pkill -9 -f arm_all_four
   pkill -9 -f arm_can_sender
   pkill -9 -f arm_multi
   pkill -9 -f arm_usb_ps2_rs422
   pkill -9 -f arm_rs422
   pkill -9 -f hexdump
   ```

3. **后台启动四路单进程**（默认 stream 模式被动接收；依赖 ch343.ko 已加载）：
   ```sh
   nohup /tmp/arm_all_four "$USB_DEV" "$PS2_DEV" > /tmp/all_four.log 2>&1 &
   ```

#### 方式三：PC 端远程一键部署（自动编译+上传+启动）

```powershell
cd acz7015-xdma-linux\linux\arm_apps
python deploy_four_senders.py --probe   # 先验证CAN驱动链路
python deploy_four_senders.py --start   # 上传+编译+启动
```

### 4. PC 端接收 PCIe 四路数据

```powershell
cd acz7015-xdma-linux\pc
python -u win_mouse_receiver.py
```

程序会自动轮询四路环形缓冲区（USB→CAN→PS2→RS422），按 seq 升序回放，显示延时和丢帧检测。

**输出格式示例**：

```
序号    | 接口 | 数据内容                    | 延时(us) | 开发板时间戳
--------------------------------------------------------------------------------
#24    | PS2  | X+0 Y+0 [L:1 R:0 M:0]       |        0 | 1787644100.604
#13    | USB  | KEY 左键=按下                |      206 | 1787644105.186
#1     | RS422 | 位移: 00 F1 F6              |    39523 | 1787645610.236
#1     | CAN  | ID=0x01180118 数据: 01 02 03  |      85 | 1787645700.123
```

**操作**：启动后保持窗口不关，同时做下面 RS422/CAN 的发送操作，数据会实时滚动显示。Ctrl+C 退出。

### 5. RS422 数据模拟（PC 端主动发送）

RS422 是被动接口，板端不会自己产生数据，需要 PC 端通过串口主动发协议帧。

**前提**：按上面「RS422 连线」接好线，确认摩可灵线缆在 PC 端的 COM 号（设备管理器查看，如 COM13）。

```powershell
cd acz7015-xdma-linux\pc_tools
pip install pyserial          # 首次需安装串口库
python rs422_pc_send.py COM13 10 200
```

**参数说明**：

| 参数 | 含义 | 示例 |
|------|------|------|
| COM13 | 摩可灵线缆的 COM 号（设备管理器查） | COM13 |
| 10 | 发送轮数（每轮 5 帧） | 10 |
| 200 | 帧间隔毫秒 | 200 |

**发送的 5 种协议帧**：

| 标识 | 报文 | 数据 | 说明 |
|------|------|------|------|
| 0xD1 | 位移 | 左键状态 + X位移 + Y位移 | 模拟轨迹球移动 |
| 0xD2 | 状态 | Remote/分辨率/采样率 | 设备工作状态 |
| 0xD3 | 温度 | 1 字节温度值 | 如 37℃ |
| 0xD4 | 电压 | 2 字节电压值 | 如 3.2V |
| 0xD5 | 版本 | 3 字节版本号 | 如 2.00.01 |

**验证**：发送后回到第 4 步的 `win_mouse_receiver.py` 窗口，应看到 `RS422` 行滚动，显示位移/状态/温度/电压/版本等报文。

### 6. CAN 数据模拟

需第二个 USB-CANFD-V1 模块插 PC，CANH/CANL 互连板端模块：

```powershell
cd acz7015-xdma-linux\pc
python pc_can_peer.py --port COM14 --stream
```

### 7. 延时测试

```powershell
python win_xdma_latency_v3.py 100
```

## 延时测试结果

| 指标 | 值 |
|------|-----|
| PCIe 平均往返延时 | 1.09 ms |
| PCIe 平均单程延时 | 0.55 ms |
| PCIe 最小单程延时 | 0.45 ms |
| PCIe 最大单程延时 | 0.85 ms |

## 协议规范

详见 [docs/protocol_spec.md](docs/protocol_spec.md)，要点：

- **RS422**：115200 8N1，自定义帧（0x55帧头+标识+数据+校验和），7种报文(D1~D7)，Stream/Remote 两种模式
- **CAN**：500kbps，29位扩展帧，5种帧ID(0x01180115~0x01180119)
- **USB/PS2**：标准通信格式（USB HID / PS2 扫描码）

## 设备树改造说明

禁用 11 个 PL 节点（路径 `/amba_pl/`，XDMA bitstream 中无这些硬件）：

| 节点 | 地址 | 说明 |
|------|------|------|
| axi_vdma_0 | 0x43000000 | VDMA |
| v_tc_0 | 0x43c10000 | 视频时序控制器 |
| v_tc_1 | 0x43c20000 | 视频时序控制器 |
| vdma_out | 0x43c30000 | VDMA输出 |
| axi_dynclk | 0x43c40000 | 动态时钟 |
| HDMI | 0x43c50000 | HDMI发送器 |
| axi_vdma_1 | 0x43010000 | VDMA(摄像头) |
| v_tc_2 | 0x43c60000 | 视频时序(摄像头) |
| v_cap | 0x43c70000 | 视频捕获 |
| axi_i2s_0 | 0x43c80000 | I2S音频 |
| fpga-axi | - | AXI总线 |

USB 节点改造：`dr_mode` 从 `otg` 改为 `host`。

## 注意事项

1. uEnv.txt 不能有 BOM 头，否则 u-boot 报 syntax error
2. bitstream_size 必须 >= 实际 bitstream 大小（0x400000 = 4MB）
3. 替换 SD 卡文件后需 MD5 校验确保复制成功
4. 开发板和 PC 时钟不同步，延时测试用乒乓法（往返/2）或首帧校准 offset
5. HDMI 无显示（XDMA bitstream 无 VDMA/VTC IP）
6. RS422 占用 UART1(ttyPS0)，运行前必须 `systemctl stop serial-getty@ttyPS0`
7. CAN 依赖 ch343.ko 驱动，板卡重启后需重新 `insmod`（/tmp 丢失）
8. Ctrl+C 正常退出采集程序，强杀会导致 XDMA DMA 引擎卡死

## 许可证

MIT License
