# FPGA通信开发项目规格说明(V2.0 — Zynq7015 + XDMA)

> **变更说明**:V1.0基于Kintex-7 + 自研PCIe DMA + Windows上位机方案已废弃。本版改为Zynq7015 + XDMA IP + Ubuntu2204主机端,数据面旁路PS Linux以保证±1ms低延时。

---

## Overview
- **Summary**: 基于Xilinx Zynq7015(AX7015B开发板)的多协议FPGA通信系统,通过PS-PCIe + PL端XDMA IP实现PCIe高速数据传输,采集PS2/CAN(CANFD)/RS422(stream+remote)/USB HID四路外设数据,经PL端AXI-Stream旁路PS Linux,以<10ms端到端延迟(±1ms精度)送达Ubuntu2204主机。
- **Purpose**: 为轨迹球组件测试验证系统提供低延时FPGA通信基础设施
- **Target Users**: FPGA通信开发工程师、嵌入式系统集成工程师

## Goals
- 搭建Zynq7015 + XDMA的Vivado工程(PS-PCIe EP + PL XDMA IP)
- 实现PS2/CANFD/RS422双模式/USB HID四路外设PL端采集
- 数据面旁路PS Linux,通过AXI-Stream直连XDMA C2H通道
- Ubuntu2204主机端XDMA驱动编译、用户态接收与四路数据解析
- 端到端延迟<10ms,精度±1ms(需PREEMPT_RT内核+CPU隔离)

## Non-Goals (Out of Scope)
- 麒麟国产系统移植(后续阶段)
- 定制PCB设计(后续阶段)
- 上位机业务应用层(本阶段仅提供数据接收解析API)
- USB非HID类设备支持

## Background & Context
项目早期设计基于Kintex-7(已废弃),现切换至Zynq7015架构。现有FPGA工程中仅 [ps2_host.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/ps2/ps2_host.v) 状态机可复用,其余PCIe/CAN/UART/USB模块需重构以适配Zynq7015 PS+PL架构与XDMA IP。详见 [fpga_zynq7015_architecture.md](file:///d:/workspace/trae/day01/0702/fpga_project/docs/fpga_zynq7015_architecture.md)。

## Functional Requirements
- **FR-1**: Zynq7015 Vivado工程搭建,PS-PCIe配置为Endpoint,PL端集成XDMA IP(PG195)、AXI CAN FD IP(PG245)、AXI Interconnect
- **FR-2**: PS2外设采集,复用 [ps2_host.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/ps2/ps2_host.v),输出AXI-Stream
- **FR-3**: CAN/CANFD双模式,通过寄存器配置切换,支持CAN2.0A/B(1Mbps)与CANFD(仲裁1Mbps/数据8Mbps)
- **FR-4**: RS422 stream/remote双模式,stream模式透明流式传输,remote模式主机命令触发+超时重传
- **FR-5**: USB HID设备采集,PS端DWC2 HOST + 内核HID驱动,关键数据通过PL旁路通道上传
- **FR-6**: XDMA C2H通道聚合四路数据,统一打包格式 `[Sync][ChID][Timestamp][Len][Payload][CRC]`
- **FR-7**: Ubuntu2204编译XDMA内核驱动,生成/dev/xdma* 设备节点
- **FR-8**: 主机端用户态程序,通过VFIO/poll模式零拷贝接收,四线程分通道解析
- **FR-9**: PL端48bit时间戳(125MHz,8ns分辨率)用于端到端延迟测量

## Non-Functional Requirements
- **NFR-1**: 端到端延迟<10ms,精度±1ms(PREEMPT_RT内核+CPU隔离+poll模式)
- **NFR-2**: 数据面不进PS Linux内存,全程PL硬件流水线
- **NFR-3**: PCIe Gen2 x1带宽利用率<70%(预留余量)
- **NFR-4**: PL资源占用<60%(预留扩展余量)
- **NFR-5**: 免焊接,全部外设通过板载接口或PMOD子卡接入

## Constraints
- **Hardware**: Zynq7015(AX7015B)、PCIe Gen2 x1、PMOD子卡
- **Software**: Vivado 2019.1+/2022.1、PetaLinux 2022.1、Ubuntu2204(内核5.15+PREEMPT_RT)
- **Driver**: Xilinx XDMA官方开源驱动(dma_ip_drivers)
- **Language**: Verilog HDL(FPGA)、C(驱动与应用)

## Assumptions
- USB外设限定为HID类(键盘/鼠标/轨迹球)
- 主机具备空闲PCIe x1及以上插槽
- 开发环境可关闭Secure Boot

## 现有代码处置清单

| 文件 | 处置 | 原因 |
|------|------|------|
| [ps2_host.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/ps2/ps2_host.v) | ✅复用 | 协议层与芯片无关,状态机可直接移植到PL |
| [pcie_dma_top.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/pcie/pcie_dma_top.v) | ❌废弃 | 自研PCIe DMA,改用Xilinx XDMA IP |
| [dma_engine.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/pcie/dma_engine.v) | ❌废弃 | 同上 |
| [dma_fifo.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/pcie/dma_fifo.v) | ⚠️保留参考 | FIFO逻辑可参考,XDMA内部已含 |
| [pcie_regs.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/pcie/pcie_regs.v) | ❌废弃 | XDMA寄存器由IP管理 |
| [can_controller.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/can/can_controller.v) | ❌废弃 | 改用MCP2518FD子卡+PS SPI+Linux主线mcp251xfd驱动 |
| [can_ip_wrapper.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/can/can_ip_wrapper.v) | ❌废弃 | 同上,CAN FD走PS端,不占PL资源 |
| [uart_core.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/uart\uart_core.v) | ⚠️保留参考 | PS端xuartps替代,PL逻辑可参考 |
| [rs422_ctrl.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/uart/rs422_ctrl.v) | ⚠️重构 | 新增stream/remote双模式状态机 |
| [usb_host_ctrl.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/usb/usb_host_ctrl.v) | ❌废弃 | 改用PS端DWC2 + Linux HID驱动 |
| [eth_mac_wrapper.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/eth/eth_mac_wrapper.v) | ⏸️暂缓 | 本期非必需,后续按需 |
| [eth_ip_wrapper.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/eth/eth_ip_wrapper.v) | ⏸️暂缓 | 同上 |
| [pwm_generator.v](file:///d:\workspace\trae\day01\0702\fpga_project\src\pwm\pwm_generator.v) | ⏸️暂缓 | 本期非必需 |
| [spi_ctrl.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/pwm/spi_ctrl.v) | ⏸️暂缓 | 同上 |
| [fpga_top.v](file:///d:/workspace/trae/day01/0702/fpga_project/src/top/fpga_top.v) | ⚠️重构 | 顶层改为Zynq BD + PL外设互联 |
| [constraints.xdc](file:///d:/workspace/trae/day01/0702/fpga_project/constraints/constraints.xdc) | ⚠️重构 | 适配AX7015B引脚 |
| [create_project.tcl](file:///d:/workspace/trae/day01/0702/fpga_project/create_project.tcl) | ⚠️重构 | 改为Zynq BD工程脚本 |
| [tb_pcie_dma.v](file:///d:/workspace/trae/day01/0702/fpga_project/testbench/tb_pcie_dma.v) | ❌废弃 | 改为XDMA仿真TB |
| [tb_uart.v](file:///d:/workspace/trae/day01/0702/fpga_project/testbench/tb_uart.v) | ⚠️保留参考 | UART TB可复用 |

**统计**:复用1个、重构5个、废弃6个、暂缓4个、保留参考3个。

## Acceptance Criteria

### AC-1: Vivado工程搭建完成
- **Given**: AX7015B开发板与Vivado环境
- **When**: 执行create_project.tcl
- **Then**: 生成Zynq BD(PS-PCIe EP + XDMA IP + AXI CAN FD + AXI Interconnect),综合实现生成bit流
- **Verification**: programmatic

### AC-2: XDMA驱动在Ubuntu2204编译通过
- **Given**: Ubuntu2204 + linux-headers-5.15
- **When**: make XDMA驱动源码
- **Then**: 生成xdma.ko,insmod后出现/dev/xdma0_c2h_0等节点,lspci识别10ee:7011
- **Verification**: programmatic

### AC-3: 四路外设采集验证
- **Given**: 各外设子卡插入PMOD,USB HID设备插入板载USB
- **When**: 运行FPGA工程并启动主机接收程序
- **Then**: 四路数据按统一包格式接收,通道ID正确
- **Verification**: programmatic

### AC-4: 延迟指标达标
- **Given**: PREEMPT_RT内核 + CPU隔离 + poll模式
- **When**: PL时间戳与主机接收时间戳对比
- **Then**: 端到端延迟<10ms,连续1000包抖动<±1ms
- **Verification**: programmatic

## 已确认参数(2026-08-03 用户确认)

| 项 | 确认值 | 说明 |
|----|--------|------|
| **板卡** | ALINX AX7015B(淘宝id:721878524425) | 底板含PCIe x2物理槽、4路USB2.0 HOST、2路千兆、HDMI、40针扩展 |
| **USB PHY** | USB3320 ULPI | 经查证同系列Zynq7015板卡(小梅哥等)标配,采购到货实拍最终确认 |
| **PCIe** | Gen2 x1 | 用户确认;AX7015B物理槽为x2,Zynq7015 PS-PCIe芯片限制x1有效 |
| **USB HID设备** | 轨迹球 | 报告格式类似鼠标(Button+X+Y),需解析报告描述符获取实际字段 |
| **CAN FD子卡** | MCP2518FD + TJA1044 | 用户确认(淘宝id:738121199903);走PS SPI + Linux主线mcp251xfd驱动,不占PL资源 |
| **CAN协议** | A825(ARINC825) | 29位扩展帧,500kbps,5种帧ID(0x01180115-0x01180119);详见[can_protocol_spec.md](file:///d:/workspace/trae/day01/0702/fpga_project/docs/can_protocol_spec.md) |
| **CAN工作模式** | CAN 2.0B扩展帧 | 本协议最大6字节数据,不需要CAN FD;MCP2518FD硬件兼容CAN FD备用 |
| **RS422波特率** | 115200 bps | PS端xuartps,stream与remote模式共用 |
| **RS422 remote超时** | 5ms(默认) | 后续可调整 |

## 待硬件到货后实测确认

- [ ] AX7015B板载USB PHY实拍型号(确认USB3320)
- [ ] 4路USB HOST是否经USB HUB(如USB2514)扩展(影响延迟分析)
- [ ] PMOD扩展口数量与引脚定义(查AX7015B用户手册)
- [ ] 轨迹球HID报告描述符实际字段(插上后lsusb -v读取)

---

**文档版本**: V2.0
**更新日期**: 2026-08-03
**取代版本**: V1.0(Kintex-7方案,已废弃)
