# ACZ7015 CAN 集成方案（修正版）

> 本文档**取代** `fpga/can_integration/集成说明.md`（初稿）。
> 初稿写于规划阶段，其中 GPIO 接线方式、UART1 引脚、SPI 引脚均与最终落地（`can_module.xdc` v3、`integrate_can.tcl` v6）不一致，且对「SPI0 EMIO 会破坏 XDMA」的因果描述有误。本文档按修正后的实际方案重写。

---

## 1. 硬件模块

| 项 | 内容 |
|---|---|
| 模块型号 | 小梅哥 `ACM_CANFD_RS485` |
| CAN 芯片 | **MCP2518FD**（SPI 接口 CAN FD 控制器） |
| 附加功能 | RS485 收发器（走 UART1） |
| 接口 | SPI0（CAN）+ UART1（RS485）+ 8 位 GPIO（中断 + 收发方向控制） |
| 供电 | 3.3V（40pin 排针 pin29/pin30，切勿接 5V） |
| CAN 波特率 | 500kbps 标准帧，`MCP251xFD_can_init(CAN_500K)` |

---

## 2. 关键修正点（初稿 → 修正版）

| # | 项目 | 初稿（集成说明.md） | 修正版（实际落地） | 修正原因 |
|---|---|---|---|---|
| 1 | GPIO 接线 | PS7 GPIO EMIO（64 位） | **AXI GPIO IP（8 位双向三态）** | PS7 GPIO EMIO 硬件固定 64 位，wrapper 会撑出 64 位 `GPIO_0_tri_io`，clg485 封装放不下约束，未约束引脚随机分配 → **烧板风险** |
| 2 | UART1 引脚 | TX=F5 / RX=E5 | **TX=E5 / RX=B1** | E5/B1 与 RS422 已统一的 UART1 EMIO 一致，避免冲突 |
| 3 | SPI 引脚 | SCLK=G6 / MOSI=F6 / MISO=H1 / SS=G1 | **SCLK=C4 / MOSI=D5 / MISO=G8 / SS=C8** | 按 40pin 排针物理位置（Zigzag 布局）重新核对修正 |
| 4 | 驱动方式 | socketcan + 内核 mcp251xfd | **spidev（/dev/spidev0.0）+ 小梅哥例程** | 内核 mcp251xfd 驱动与裸 SPI 操作冲突，用 spidev 更可控 |
| 5 | 生成脚本 | 需 GUI 手点 | **`integrate_can.tcl` v6 + `fix_xdma_mlite.tcl` 批处理** | 全自动综合，避免 GUI 文件锁 |

---

## 3. 根因澄清（最容易踩的坑）

**错误认知**：「启用 SPI0 EMIO 会导致 XDMA Code 10」。

**真实根因**：删除 `ps2_host_axi_0` 模块后，`xdma_0/M_AXI_LITE` 接口**悬空**，导致 user BAR 地址段（`0x40000000[64K]`）归零，DMA 引擎初始化失败（Code 10）。

**结论**：
- SPI0 EMIO 本身**不会**破坏 XDMA。
- 会破坏 XDMA 的是 **M_AXI_LITE 悬空**。
- 只要保持 `xdma_lite_slave`（AXI GPIO 从机）挂在 `M_AXI_LITE` 上，**再启用 SPI0 EMIO 是安全的**。

> 方案 A bit（`11ac4f4e`）之所以禁用 SPI0，是为了「最小化改动、只保留 UART1 EMIO」保守起见，而非「SPI0 有害」。

---

## 4. 最终架构

```
ACZ7015 PS 侧                          PL 侧                 ACM_CANFD_RS485
┌──────────────────────┐   ┌──────────────────────────┐   ┌─────────────────┐
│ M_AXI_LITE → xdma_lite_slave │  ← 修复 XDMA Code 10（必须保留）          │
│                      │   │                          │   │                 │
│ PS SPI0 (EMIO)       │→→│ SPI0_SCLK/MOSI/MISO/SS    │→→│ MCP2518FD       │
│                      │   │   (C4/D5/G8/C8)          │   │                 │
│ M_AXI_GP0 → axi_gp0_ic│→→│ axi_gpio_0 (8位三态)      │→→│ INT/RS485_RE    │
│   → axi_gpio_0       │   │   (B7/B6/G7/G6/F6/G3/C1/B2)│  │                 │
│ PS UART1 (EMIO)      │→→│ UART_1_TX(E5) / RX(B1)    │→→│ RS485 收发器     │
└──────────────────────┘   └──────────────────────────┘   └─────────────────┘
```

关键点：
- **SPI0 / UART1 走 PS7 EMIO**（接口宽度固定，无撑宽风险）
- **GPIO 走 AXI GPIO IP**（8 位可配置，避免 64 位撑宽）
- **`xdma_lite_slave` 必须保留**（M_AXI_LITE 有从机，XDMA 才正常）

---

## 5. 最终引脚分配（以 `can_module.xdc` v3 为准）

### SPI0（PS7 EMIO）
| 信号 | PACKAGE_PIN | GPIO编号 | 排针pin | CAN模块 |
|---|---|---|---|---|
| SPI0_SCLK_O | C4 | GPIO0_0[3] | pin4 | CAN_SCK_0 |
| SPI0_MOSI_O | D5 | GPIO0_0[2] | pin3 | CAN_SDI_0 |
| SPI0_MISO_I | G8 | GPIO0_0[4] | pin5 | CAN_SDO_0 |
| SPI0_SS_O | C8 | GPIO0_0[6] | pin7 | CAN_nCS_0 |

### GPIO（AXI GPIO IP，8 位双向三态）
| bit | PACKAGE_PIN | 排针pin | 功能 |
|---|---|---|---|
| 0 | B7 | pin1 | INT0_0 |
| 1 | B6 | pin2 | INT1_0 |
| 2 | G7 | pin6 | CAN_INT_0 |
| 3 | G6 | pin13 | INT1_1 |
| 4 | F6 | pin14 | INT0_1 |
| 5 | G3 | pin17 | CAN_INT_1 |
| 6 | C1 | pin24 | RS485A_RE（接收使能）|
| 7 | B2 | pin27 | RS485B_RE（接收使能）|

### UART1（PS7 EMIO，与 RS422 共用 E5/B1）
| 信号 | PACKAGE_PIN | 排针pin | 功能 |
|---|---|---|---|
| UART_1_TX_O | E5 | pin26 | RS485B_TX |
| UART_1_RX_I | B1 | pin28 | RS485B_RX |

---

## 6. 当前方案 A bit 里已有 CAN 的基础

方案 A bit（`11ac4f4e`）虽然禁用了 SPI0，但**已经包含**：
- `xdma_lite_slave`（M_AXI_LITE 从机，修复 XDMA）
- `axi_gpio_0`（8 位三态 GPIO，挂 M_AXI_GP0，用于 CAN 控制）

所以做 CAN 的**剩余工作**仅是：
1. 重新启用 SPI0 EMIO（撤销 `restore_uart1_only.tcl` 第 3 步的禁用）
2. 恢复 SPI0 引脚约束（`can_module.xdc` 的 SPI 部分）
3. 设备树加 spidev 节点
4. PS 软件写 AXI GPIO + spidev 收发

---

## 7. PL 集成步骤

### 前提
- Vivado 2018.3 批处理可用，工程未在 GUI 打开（避免文件锁）。

### 步骤
1. **启用 SPI0 EMIO**（在 `integrate_can.tcl` v6 中已写明，SPI 参数如下）：
   ```tcl
   set_property -dict [list \
       CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
       CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
       CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} \
       CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
   ] [get_bd_cells processing_system7_0]
   ```
2. **保持 `xdma_lite_slave` 在位**（不要删除，否则 XDMA 崩）。
3. **GPIO 用 AXI GPIO IP**（`integrate_can.tcl` v6 已实现，勿回退到 PS7 GPIO EMIO）。
4. **SPI0_SS_I tie 到 const_one**（SS 未被外部拉低）。
5. **校验并综合**：
   ```tcl
   validate_bd_design
   generate_target all [get_files design_1.bd]
   make_wrapper -files [get_files design_1_wrapper.v] -top
   ```
6. **约束文件**：`can_module.xdc`（v3，含 SPI + GPIO + UART1 全部引脚）。
7. **DRC 检查**（部署前必须满足）：
   - 0 个 Critical Warning
   - 0 个 UCIO-1 未约束引脚
   - 0 个 NSTD-1 未指定 IO 标准

### 综合脚本（参考）
- `integrate_can.tcl` v6：启用 SPI0 + 挂 AXI GPIO
- `fix_xdma_mlite.tcl`：补 `xdma_lite_slave`（若新工程需重补）
- `run_fix_xdma_mlite.bat`：批处理自动综合入口

---

## 8. 设备树（spidev）

需在设备树加 `spi0` 节点 + `spidev@0` 子节点，才能在用户态用 `/dev/spidev0.0`：

```dts
&spi0 {
    status = "okay";
    spidev@0 {
        compatible = "spidev";
        reg = <0>;
        spi-max-frequency = <10000000>;
    };
};
```

> 老内核无 pinctrl，SPI0 的引脚路由由 FSBL 配置，内核不重配。

---

## 9. PS 软件

### 9.1 AXI GPIO 控制（CAN 中断 + RS485 方向）
- 通过 `/dev/mem` + mmap 读写 AXI GPIO 寄存器：
  - `GPIO_DATA`（偏移 0x00）、`GPIO_TRI`（偏移 0x04）
- **AXI GPIO 基地址需在 Address Editor 确认**（历史 CAN 集成曾分配为 `0x41200000`）。
- 上电默认：DOUT=0x00（RS485 接收模式）、TRI=0xFF（输入模式），安全。
- PS 软件初始化时写 GPIO_TRI/GPIO_DATA 配方向。

### 9.2 CAN 收发（spidev）
- 打开 `/dev/spidev0.0`，用 spidev 接口收发 MCP2518FD 寄存器/报文。
- 复用小梅哥例程代码，`MCP251xFD_can_init(CAN_500K)`。

### 9.3 数据写入 DDR 槽位
- CAN 数据走 `SLOT_CAN = 0x20000020`，`device_id = 1`，32 字节统一槽位格式。
- 写完后 `dma_wb_slot()` 做 D-cache clean（XDMA 才能读到最新数据）。

---

## 10. 上板验证步骤

1. 部署新 bit → `md5sum` 校验 → 断电重启。
2. 确认 XDMA 仍为 Code 0（`Get-PnpDevice` 查 `VEN_10EE` 无黄色感叹号）。
3. 确认 `/dev/spidev0.0` 存在。
4. 用 AXI GPIO 拉低/拉高 RS485_RE 验证方向控制。
5. 回环测试：CAN 模块 CANH 短接 CANL（或接 CAN 分析仪）验证收发。
6. PC 端 `win_can_receiver.py` 验证端到端数据。

---

## 11. 防坑 Checklist

- [ ] `xdma_lite_slave` 保留在 `M_AXI_LITE` 上（否则 XDMA Code 10）
- [ ] GPIO 用 AXI GPIO IP，**禁用** `CONFIG.PCW_EN_EMIO_GPIO`
- [ ] SPI0/UART1 用 PS7 EMIO（不要用 GPIO EMIO）
- [ ] `SPI0_SS_I` tie 到 const_one
- [ ] SPI0 `_T` 信号保持悬空（EMIO 内部三态已处理）
- [ ] 引脚以 `can_module.xdc` v3 为准（非集成说明.md 初稿）
- [ ] 部署前 DRC 通过（0 Critical / 0 UCIO-1 / 0 NSTD-1）
- [ ] 改 bit 前先备份 SD 卡当前正常版
- [ ] 生成脚本含 `generate_target all` + `make_wrapper`（否则 PS7 修改后综合失败）
- [ ] 3.3V 供电，禁接 5V

---

## 附：与 RS422 的 UART1 复用关系

CAN 模块的 RS485 和 RS422 都走 UART1 EMIO（E5/B1）。两者**共用同一对物理引脚**，无法同时用：
- 用 CAN 的 RS485 时，UART1 接 ACM_CANFD_RS485 模块
- 用 RS422 时，UART1 接 TTL 转 RS422 模块

运行时同样需要：写 SLCR 把 MIO48/49 切 GPIO（解决 MIO49 恒高污染），`systemctl stop serial-getty@ttyPS0.service`。