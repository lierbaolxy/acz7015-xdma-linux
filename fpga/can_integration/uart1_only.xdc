# ============================================================
# ACZ7015 XDMA工程 UART1 + GPIO 引脚约束（修复UCIO-1）
# 功能：约束 UART1 TX/RX + AXI GPIO 8位到 40pin 排针
# 依据：ACZ7015 GPIO0 40pin 排针 Zigzag 布局
# ============================================================

# ==================== UART1 ====================
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_TX_O]
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_RX_I]
set_property PACKAGE_PIN E5 [get_ports UART_1_TX_O]   ;# GPIO0_0[23] pin26
set_property PACKAGE_PIN B1 [get_ports UART_1_RX_I]  ;# GPIO0_0[25] pin28

# ==================== AXI GPIO 8位 ====================
# AXI GPIO 的 GPIO_0_tri_io[7:0] 必须约束，否则 UCIO-1 错误
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[7]}]

# GPIO 引脚分配（40pin排针）
set_property PACKAGE_PIN B7 [get_ports {GPIO_0_tri_io[0]}]   ;# GPIO0_0[0]  pin1
set_property PACKAGE_PIN B6 [get_ports {GPIO_0_tri_io[1]}]   ;# GPIO0_0[1]  pin2
set_property PACKAGE_PIN G7 [get_ports {GPIO_0_tri_io[2]}]   ;# GPIO0_0[5]  pin6
set_property PACKAGE_PIN G6 [get_ports {GPIO_0_tri_io[3]}]   ;# GPIO0_0[10] pin13
set_property PACKAGE_PIN F6 [get_ports {GPIO_0_tri_io[4]}]   ;# GPIO0_0[11] pin14
set_property PACKAGE_PIN G3 [get_ports {GPIO_0_tri_io[5]}]   ;# GPIO0_0[14] pin17
set_property PACKAGE_PIN C1 [get_ports {GPIO_0_tri_io[6]}]   ;# GPIO0_0[21] pin24
set_property PACKAGE_PIN B2 [get_ports {GPIO_0_tri_io[7]}]   ;# GPIO0_0[24] pin27
