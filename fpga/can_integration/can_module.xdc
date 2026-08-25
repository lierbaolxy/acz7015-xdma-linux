# ============================================================
# ACZ7015 XDMA工程 CAN/CANFD/RS485模块 引脚约束 (修复版v3)
# 功能：分配PL引脚给SPI0/GPIO/UART1的EMIO外部引脚
# 依据：ACZ7015的GPIO0 40pin排针物理pin位置（EDA扩展板验证）
#       pin1-10=GPIO[0:9], pin11-12=VCC/GND, pin13-28=GPIO[10:25]
#       CAN模块(ACM_CANFD_RS485)直接扣到40pin排针（1脚对齐）
# ============================================================

# ==================== IOSTANDARD ====================
# SPI0（3引脚：SCLK_O/MOSI_O/SS_O输出 + MISO_I输入）
set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SCLK_O]
set_property IOSTANDARD LVCMOS33 [get_ports SPI0_MOSI_O]
set_property IOSTANDARD LVCMOS33 [get_ports SPI0_MISO_I]
set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SS_O]

# GPIO EMIO（8位合并三态端口 GPIO_0_tri_io[7:0]）
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_io[7]}]

# UART1（2引脚：TX_O输出 + RX_I输入）
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_TX_O]
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_RX_I]

# ==================== PACKAGE_PIN ====================
# 引脚分配依据：CAN模块40pin排针物理pin → ACZ7015 GPIO0_0_tri_io映射
# pin1-10=GPIO[0:9], pin11-12=VCC/GND, pin13-28=GPIO[10:25]

# SPI0（CAN模块pin3-7）
# pin3=CAN_SDI_0/SPI0_MOSI, pin4=CAN_SCK_0/SPI0_SCLK
# pin5=CAN_SDO_0/SPI0_MISO, pin7=CAN_nCS_0/SPI0_SS
set_property PACKAGE_PIN C4 [get_ports SPI0_SCLK_O]   ;# GPIO0_0[3] pin4 CAN_SCK_0
set_property PACKAGE_PIN D5 [get_ports SPI0_MOSI_O]   ;# GPIO0_0[2] pin3 CAN_SDI_0
set_property PACKAGE_PIN G8 [get_ports SPI0_MISO_I]   ;# GPIO0_0[4] pin5 CAN_SDO_0
set_property PACKAGE_PIN C8 [get_ports SPI0_SS_O]    ;# GPIO0_0[6] pin7 CAN_nCS_0

# GPIO EMIO 8位（CAN模块中断+RS485方向控制）
# bit0=INT0_0(pin1)  bit1=INT1_0(pin2)  bit2=CAN_INT_0(pin6)
# bit3=INT1_1(pin13) bit4=INT0_1(pin14) bit5=CAN_INT_1(pin17)
# bit6=RS485A_RE(pin24) bit7=RS485B_RE(pin27)
set_property PACKAGE_PIN B7 [get_ports {GPIO_0_tri_io[0]}]   ;# GPIO0_0[0]  pin1  INT0_0
set_property PACKAGE_PIN B6 [get_ports {GPIO_0_tri_io[1]}]   ;# GPIO0_0[1]  pin2  INT1_0
set_property PACKAGE_PIN G7 [get_ports {GPIO_0_tri_io[2]}]   ;# GPIO0_0[5]  pin6  CAN_INT_0
set_property PACKAGE_PIN G6 [get_ports {GPIO_0_tri_io[3]}]   ;# GPIO0_0[10] pin13 INT1_1
set_property PACKAGE_PIN F6 [get_ports {GPIO_0_tri_io[4]}]   ;# GPIO0_0[11] pin14 INT0_1
set_property PACKAGE_PIN G3 [get_ports {GPIO_0_tri_io[5]}]   ;# GPIO0_0[14] pin17 CAN_INT_1
set_property PACKAGE_PIN C1 [get_ports {GPIO_0_tri_io[6]}]   ;# GPIO0_0[21] pin24 RS485A_RE
set_property PACKAGE_PIN B2 [get_ports {GPIO_0_tri_io[7]}]   ;# GPIO0_0[24] pin27 RS485B_RE

# UART1（CAN模块pin26/pin28，RS485B通道）
# pin26=RS485B_TX/UART1_TX, pin28=RS485B_RX/UART1_RX
set_property PACKAGE_PIN E5 [get_ports UART_1_TX_O]   ;# GPIO0_0[23] pin26 RS485B_TX
set_property PACKAGE_PIN B1 [get_ports UART_1_RX_I]   ;# GPIO0_0[25] pin28 RS485B_RX
