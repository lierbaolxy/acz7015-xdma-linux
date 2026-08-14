# ACZ7015 XDMA + Linux 共存方案

基于 ACZ7015（Zynq7015）开发板，实现 PS 侧 Linux 系统与 PL 侧 XDMA PCIe 共存，支持 USB 鼠标数据通过 PCIe 实时传输到 Windows PC。

## 功能特性

- PS 侧运行 Ubuntu 16.04.4 LTS（内核 4.14.0-xilinx）
- PL 侧 XDMA PCIe EP 模式，Windows PC 通过 PCIe 访问 FPGA
- USB Host 模式，支持 USB 鼠标热插拔
- USB 鼠标数据通过 DDR 共享内存 + XDMA 实时传输到 PC
- 端到端延时约 0.5-1ms

## 硬件平台

- 开发板：ACZ7015（Zynq7015 SoC：双核 Cortex-A9 + Artix-7 FPGA）
- DDR：1GB（其中 512MB 预留给 XDMA DMA 缓冲区）
- PCIe：PL 侧 GTP 收发器（XDMA EP 模式）
- USB：PS 侧 USB3320 PHY + CH334H HUB，3×Type-A Host
- 网络：RTL8211F 千兆以太网 + RTL8188FU USB WiFi

## 目录结构

```
acz7015-xdma-linux/
├── linux/                    # 开发板 Linux 侧
│   ├── device_tree/         # 设备树改造脚本
│   │   └── patch_dtb3.py   #   禁用11个PL节点 + USB Host模式
│   ├── sd_patch/            # SD卡文件替换脚本
│   │   └── final_replace.py #   替换system.bit/system.dtb/uEnv.txt
│   └── arm_apps/            # 开发板 C 程序
│       ├── arm_mouse_sender.c    # 鼠标数据发送（poll无限等待）
│       └── arm_mouse_latency.c   # 乒乓法响应程序
├── pc/                       # Windows PC 侧
│   ├── win_mouse_receiver.py     # 鼠标数据接收显示
│   └── win_xdma_latency_v3.py    # 乒乓法延时测试
└── README.md
```

## 数据链路

```
USB鼠标 → PS侧USB控制器 → Linux内核input子系统 → /dev/input/event1
    ↓
开发板C程序读取事件 + 时间戳
    ↓
/dev/mem写入DDR共享内存(0x20000000)
    ↓
XDMA PCIe C2H DMA
    ↓
Windows PC读取DDR → 显示鼠标事件
```

## DDR 共享内存结构

物理地址：0x20000000（reserved-memory 区域）

```
偏移  字段      大小    说明
0x00  seq       4字节   序号（每次事件+1）
0x04  type      4字节   事件类型（EV_REL=2/EV_KEY=1）
0x08  code      4字节   代码（X轴=0/Y轴=1/左键=0x110/右键=0x111/中键=0x112）
0x0C  value     4字节   值（有符号int32，移动距离或按键状态）
0x10  tv_sec    4字节   开发板时间戳（秒）
0x14  tv_nsec   4字节   开发板时间戳（纳秒）
```

## PC 端 XDMA 设备节点

| 设备节点 | 方向 | 用途 |
|----------|------|------|
| c2h_0 | PC读DDR | 读鼠标事件数据 |
| h2c_0 | PC写DDR | 写乒乓法请求 |
| user | 读写寄存器 | 访问ps2_host_axi模块 |

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

### 3. 开发板运行鼠标发送程序

```bash
gcc -O2 -o arm_mouse_sender arm_mouse_sender.c
sudo ./arm_mouse_sender
```

### 4. PC 端接收鼠标数据

```bash
python win_mouse_receiver.py
```

### 5. 延时测试

```bash
python win_xdma_latency_v3.py 100
```

## 延时测试结果

| 指标 | 值 |
|------|-----|
| 平均往返延时 | 1.09 ms |
| 平均单程延时 | 0.55 ms |
| 最小单程延时 | 0.45 ms |
| 最大单程延时 | 0.85 ms |

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
4. 开发板和 PC 时钟不同步，延时测试用乒乓法（往返/2）
5. HDMI 无显示（XDMA bitstream 无 VDMA/VTC IP）

## 许可证

MIT License
