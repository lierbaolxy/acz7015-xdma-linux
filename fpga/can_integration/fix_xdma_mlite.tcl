# ============================================================
# 方案A：修复 xdma_0/M_AXI_LITE 悬空（可能破坏 XDMA DMA 引擎）
# 原理：ps2_host_axi_0 被删后，xdma_0/M_AXI_LITE（user BAR 的 AXI-Lite 主）
#       失去唯一从机，地址段归零，XDMA 驱动在 DMA 引擎初始化阶段失败(Code 10)。
# 做法：把 M_AXI_LITE 接一个最小 AXI-Lite 从机(AXI GPIO)，恢复非零地址段。
#       保留 UART1 EMIO 不动，不动 DMA 数据通路，不动 PS7 HP0/DDR 配置。
# 用法：
#   cd /d D:\workspace\fpga\myinstall\Vivado\2018.3\bin
#   .\vivado.bat -mode batch -source D:\workspace\trae\day01\0702\acz7015-xdma-linux\fpga\can_integration\fix_xdma_mlite.tcl -log fix_xdma_mlite.log -journal fix_xdma_mlite.jou
# ============================================================

set proj_dir  {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.xpr}
set tcl_dir   {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/can_integration}
set uart1_xdc {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/can_integration/uart1_pure.xdc}

# ===== 1. 打开工程与 BD =====
puts "========== 1. 打开工程与 BD =========="
open_project -quiet $proj_dir
open_bd_design [get_files design_1.bd]

# ===== 2. 诊断：当前 M_AXI_LITE 连接状态 =====
puts "========== 2. 诊断 M_AXI_LITE 当前状态 =========="
set mlite [get_bd_intf_pins -quiet xdma_0/M_AXI_LITE]
if {$mlite eq ""} {
    puts "FATAL: xdma_0/M_AXI_LITE 接口不存在，检查 XDMA IP 配置"
    close_project
    exit 1
}
set mlite_nets [get_bd_intf_nets -of_objects $mlite -quiet]
puts "M_AXI_LITE 当前连接: [expr {$mlite_nets ne "" ? $mlite_nets : "悬空(无连接)"}]"

# ===== 3. 创建/复用最小 AXI-Lite 从机（AXI GPIO）=====
puts "========== 3. 创建 AXI-Lite 从机 =========="
set slave [get_bd_cells -quiet xdma_lite_slave]
if {$slave eq ""} {
    set slave [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 xdma_lite_slave]
    puts "已创建 xdma_lite_slave"
} else {
    puts "xdma_lite_slave 已存在，复用"
}
# 8位全输出（GPIO 接口悬空，不引到顶层，仅作 AXI-Lite 从机占位；
# 全输出无 gpio_io_i 输入，避免产生悬空输入脚）
set_property -dict [list \
    CONFIG.C_GPIO_WIDTH {8} \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_DOUT_DEFAULT {0x00000000} \
] $slave

# ===== 4. 连接 M_AXI_LITE → AXI GPIO S_AXI =====
puts "========== 4. 连接 M_AXI_LITE =========="
# 若已有旧连接（指向别的从机），断开重建
set mlite_nets [get_bd_intf_nets -quiet -of_objects $mlite]
foreach n $mlite_nets {
    set eps [get_bd_intf_pins -of_objects $n -quiet]
    if {[lsearch -exact $eps "xdma_lite_slave/S_AXI"] < 0} {
        puts "断开旧连接: $n"
        delete_bd_objs $n
    }
}
if {[get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins xdma_0/M_AXI_LITE]] eq ""} {
    connect_bd_intf_net [get_bd_intf_pins xdma_0/M_AXI_LITE] [get_bd_intf_pins xdma_lite_slave/S_AXI]
    puts "已连接 xdma_0/M_AXI_LITE → xdma_lite_slave/S_AXI"
}

# ===== 5. 连接时钟与复位（复用 XDMA axi_aclk/axi_aresetn）=====
puts "========== 5. 连接时钟与复位 =========="
connect_bd_net [get_bd_pins xdma_0/axi_aclk]    [get_bd_pins xdma_lite_slave/s_axi_aclk]
connect_bd_net [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins xdma_lite_slave/s_axi_aresetn]
puts "已连接时钟/复位"

# ===== 6. 分配地址（恢复 M_AXI_LITE 非零地址段）=====
puts "========== 6. 分配地址 =========="
assign_bd_address
regenerate_bd_layout
save_bd_design

# 打印地址空间，确认 M_AXI_LITE 已有段
puts "=== M_AXI_LITE 地址空间 ==="
set segs [get_bd_addr_segs -of_objects [get_bd_intf_pins xdma_0/M_AXI_LITE] -quiet]
if {$segs ne ""} {
    foreach s $segs {
        puts "  [get_property OFFSET $s] [get_property RANGE $s] -> $s"
    }
} else {
    puts "ERROR: M_AXI_LITE 未分配任何地址段！"
    close_project
    exit 1
}

set bd_warn [validate_bd_design]
puts "BD校验: $bd_warn"

# ===== 7. 生成 wrapper + 设置顶层与约束 =====
puts "========== 7. 生成 wrapper =========="
generate_target all [get_files design_1.bd]
catch {make_wrapper -files [get_files design_1_wrapper.v] -top} err
puts "make_wrapper: $err"

set_property source_mgmt_mode None [current_project]
set_property top design_1_wrapper [get_filesets sources_1]

# 移除旧约束，添加 UART1 约束（保留原 UART1 EMIO 功能）
foreach xdc_file [list "${tcl_dir}/can_module.xdc" "${tcl_dir}/uart1_only.xdc" "${tcl_dir}/uart1_pure.xdc"] {
    set f [get_files -quiet -of_objects [get_filesets constrs_1] $xdc_file]
    if {$f ne ""} { catch {remove_files $f} }
}
set ps2_xdc "D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.srcs/constrs_1/new/ps2_pins.xdc"
set ps2_file [get_files -quiet -of_objects [get_filesets constrs_1] $ps2_xdc]
if {$ps2_file ne ""} { catch {remove_files $ps2_file} }

catch {add_files -fileset constrs_1 -norecurse $uart1_xdc}
set_property target_constrs_file $uart1_xdc [get_filesets constrs_1]
puts "约束文件:"
foreach f [get_files -quiet -of_objects [get_filesets constrs_1]] { puts "  $f" }

# ===== 8. 综合 =====
puts "========== 8. 综合 =========="
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
set synth_status [get_property STATUS [get_runs synth_1]]
puts "综合状态: $synth_status"
if {![string match "*Complete*" $synth_status]} {
    puts "ERROR: 综合失败"
    close_project
    exit 1
}

# ===== 9. 实现 + bitstream =====
puts "========== 9. 实现 + bitstream =========="
reset_run impl_1
launch_runs impl_1 -jobs 4 -to_step write_bitstream
wait_on_run impl_1
set impl_status [get_property STATUS [get_runs impl_1]]
puts "实现状态: $impl_status"

# ===== 10. 验证 bitstream =====
puts "========== 10. 验证 bitstream =========="
set bit_file {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.runs/impl_1/design_1_wrapper.bit}
if {[file exists $bit_file]} {
    puts "SUCCESS: bitstream 大小 [file size $bit_file] 字节"
} else {
    puts "ERROR: bitstream 未生成"
}

close_project
puts "============================================"
puts "方案A 完成：M_AXI_LITE 已接 xdma_lite_slave(AXI GPIO)"
puts "  - 保留 UART1 EMIO"
puts "  - 未动 DMA 数据通路 / PS7 HP0 / DDR"
puts "请烧录 bit 后验证 XDMA 是否恢复 Code 0"
puts "============================================"