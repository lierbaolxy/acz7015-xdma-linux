# FPGA通信开发项目启动指南 - 实施计划

## [ ] Task 1: FPGA选型方案分析与确认
- **Priority**: high
- **Depends On**: None
- **Description**: 
  - 分析当前项目代码中指定的FPGA型号（xc7k325tffg900-2）和开发板（KC705）
  - 对比公板与定制板的优缺点，给出选型建议
  - 明确硬件资源需求（逻辑单元、RAM、高速接口等）
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `human-judgment` TR-1.1: 选型方案文档完整，包含优缺点对比和推荐理由
  - `human-judgment` TR-1.2: 硬件资源评估准确，与项目需求匹配
- **Notes**: KC705公板适合初期开发验证，后期可考虑定制化

## [ ] Task 2: 开发环境部署（Vivado安装与配置）
- **Priority**: high
- **Depends On**: Task 1
- **Description**: 
  - 安装Xilinx Vivado设计工具（建议2019.2或更高版本）
  - 配置仿真工具（Modelsim或Vivado内置仿真）
  - 配置环境变量和项目路径
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-2.1: Vivado可正常启动，版本信息正确
  - `programmatic` TR-2.2: 能够通过Tcl命令行创建项目
- **Notes**: 需要足够的磁盘空间（建议>60GB）和内存（建议>16GB）

## [ ] Task 3: 项目创建与配置
- **Priority**: high
- **Depends On**: Task 2
- **Description**: 
  - 运行create_project.tcl创建Vivado项目
  - 验证项目结构和文件导入情况
  - 检查约束文件和顶层模块配置
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `programmatic` TR-3.1: 项目创建成功，无错误信息
  - `programmatic` TR-3.2: 所有源文件正确导入到项目中
- **Notes**: 创建项目前确保当前目录下文件完整

## [ ] Task 4: 仿真验证
- **Priority**: high
- **Depends On**: Task 3
- **Description**: 
  - 运行run_simulation.tcl执行PCIe DMA和UART仿真
  - 分析仿真波形，验证通信逻辑正确性
  - 检查时序约束和信号完整性
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `programmatic` TR-4.1: 仿真完成，无错误或警告
  - `programmatic` TR-4.2: 关键信号波形符合预期
- **Notes**: 仿真时间较长，建议使用批处理模式

## [ ] Task 5: 综合与实现
- **Priority**: high
- **Depends On**: Task 4
- **Description**: 
  - 运行run_synthesis.tcl执行综合、实现和比特流生成
  - 检查时序报告和资源占用情况
  - 生成可下载的比特流文件
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `programmatic` TR-5.1: 综合完成，无关键错误
  - `programmatic` TR-5.2: 实现完成，时序收敛
  - `programmatic` TR-5.3: 比特流生成成功
- **Notes**: 综合实现耗时较长，建议使用多线程加速

## [ ] Task 6: 通信架构理解与数据流转分析
- **Priority**: medium
- **Depends On**: Task 3
- **Description**: 
  - 分析FPGA顶层模块（fpga_top.v）的信号连接
  - 理解PCIe DMA数据通路：外设→FIFO→DMA→PCIe→上位机
  - 梳理各通信协议模块的接口定义和数据格式
- **Acceptance Criteria Addressed**: AC-3
- **Test Requirements**:
  - `human-judgment` TR-6.1: 能够清晰描述数据从外设到上位机的完整流程
  - `human-judgment` TR-6.2: 理解各模块的职责和接口关系
- **Notes**: 建议使用框图辅助理解

## [ ] Task 7: 通信协议实现验证
- **Priority**: medium
- **Depends On**: Task 4
- **Description**: 
  - 分析RS422控制器（rs422_ctrl.v）的收发逻辑
  - 分析CAN控制器（can_controller.v）的帧格式处理
  - 分析以太网MAC（eth_mac_wrapper.v）的数据封装
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `human-judgment` TR-7.1: 理解各协议的FPGA端实现细节
  - `human-judgment` TR-7.2: 识别潜在的协议实现问题和优化点
- **Notes**: 需要对照通信协议文档进行验证

## [ ] Task 8: 硬件部署与调试
- **Priority**: medium
- **Depends On**: Task 5
- **Description**: 
  - 将比特流下载到KC705开发板
  - 连接外设（RS422/CAN/Ethernet）进行硬件测试
  - 使用ChipScope或ILA进行在线调试
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `human-judgment` TR-8.1: 比特流成功下载到FPGA
  - `human-judgment` TR-8.2: 硬件测试能够收发数据
- **Notes**: 需要KC705开发板和相关外设硬件