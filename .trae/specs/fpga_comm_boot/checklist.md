# FPGA通信开发项目启动验证检查清单

- [x] Checkpoint 1: FPGA选型方案确认 - 明确推荐使用KC705公板，包含选型理由和资源评估
- [x] Checkpoint 2: Vivado安装完成 - 版本信息正确，可正常启动
- [x] Checkpoint 3: 项目创建成功 - 运行create_project.tcl无错误，项目结构完整
- [x] Checkpoint 4: 仿真验证通过 - 运行run_simulation.tcl，PCIe DMA和UART仿真完成
- [x] Checkpoint 5: 综合实现成功 - 运行run_synthesis.tcl，综合、实现、比特流生成完成
- [x] Checkpoint 6: 通信架构理解 - 能够描述数据从外设→FPGA→PCIe→上位机的完整流程
- [x] Checkpoint 7: 协议实现验证 - 理解RS422/CAN/Ethernet等协议的FPGA端实现细节
- [x] Checkpoint 8: 硬件部署调试 - 比特流成功下载，硬件测试能够收发数据