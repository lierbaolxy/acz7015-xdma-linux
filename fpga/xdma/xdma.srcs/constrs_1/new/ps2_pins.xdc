# PS2 引脚约束 - �?动生�? by modify_bd_add_ps2.tcl
set_property PACKAGE_PIN B7 [get_ports ps2_clk]
set_property PACKAGE_PIN B6 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_data]
set_property PULLUP TRUE [get_ports ps2_clk]
set_property PULLUP TRUE [get_ports ps2_data]
