# 只读诊断：XDMA 读 DDR 数据通路连接状态
set proj_dir {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.xpr}
open_project -quiet $proj_dir
open_bd_design [get_files design_1.bd]

puts "========== XDMA 读 DDR 数据通路诊断 =========="

# 1. XDMA M_AXI（DMA数据主口）连到哪
puts "\n[1] xdma_0/M_AXI 连接:"
set mnet [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins xdma_0/M_AXI]]
if {$mnet ne ""} {
    puts "  -> $mnet"
    foreach ep [get_bd_intf_pins -of_objects $mnet -quiet] { puts "     端: $ep" }
} else { puts "  *** 悬空 ***" }

# 2. axi_smc 全部接口连接状态
puts "\n[2] axi_smc 接口:"
foreach if [get_bd_intf_pins -quiet -of_objects [get_bd_cells axi_smc]] {
    set n [get_bd_intf_nets -of_objects $if -quiet]
    puts "  $if : [expr {$n ne "" ? "已连 $n" : "*** 未连接 ***"}]"
}

# 3. PS7 S_AXI_HP0（DDR入口）
puts "\n[3] PS7 S_AXI_HP0 连接:"
set hp [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins processing_system7_0/S_AXI_HP0]]
if {$hp ne ""} {
    puts "  -> $hp"
    foreach ep [get_bd_intf_pins -of_objects $hp -quiet] { puts "     端: $ep" }
} else { puts "  *** 悬空 ***" }

# 4. 关键时钟
puts "\n[4] 时钟连接:"
foreach clk {xdma_0/axi_aclk axi_smc/aclk processing_system7_0/S_AXI_HP0_ACLK processing_system7_0/M_AXI_GP0_ACLK} {
    set n [get_bd_nets -quiet -of_objects [get_bd_pins $clk]]
    puts "  $clk : [expr {$n ne "" ? "已连 $n" : "*** 未连接 ***"}]"
}

# 5. XDMA M_AXI 地址段
puts "\n[5] xdma_0/M_AXI 地址段:"
set segs [get_bd_addr_segs -of_objects [get_bd_intf_pins xdma_0/M_AXI] -quiet]
if {$segs ne ""} {
    foreach s $segs { puts "  [get_property OFFSET $s] [get_property RANGE $s] -> $s" }
} else { puts "  *** 无地址段 ***" }

close_project
puts "\nDONE"