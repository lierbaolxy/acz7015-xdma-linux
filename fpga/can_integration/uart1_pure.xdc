# ============================================================
# ACZ7015 XDMA工程 UART1 引脚约束（纯UART1，无GPIO）
# 功能：仅约束 UART1 TX/RX 到 40pin 排针 pin26/pin28
# ============================================================

# ==================== UART1 ====================
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_TX_O]
set_property IOSTANDARD LVCMOS33 [get_ports UART_1_RX_I]
set_property PACKAGE_PIN E5 [get_ports UART_1_TX_O]   ;# GPIO0_0[23] pin26
set_property PACKAGE_PIN B1 [get_ports UART_1_RX_I]  ;# GPIO0_0[25] pin28
