# ============================================================
# ACZ7015 XDMA工程 + CAN模块 自动化综合脚本（batch模式）
# 功能：完整执行CAN模块集成 → 综合实现 → bitstream生成
# 用法：
#   cd /d D:\workspace\fpga\myinstall\Vivado\2018.3\bin
#   .\vivado.bat -mode batch -source D:\workspace\trae\day01\0702\acz7015-xdma-linux\fpga\can_integration\build_can.tcl -log build_can.log -journal build_can.jou
# 预期耗时：5-15分钟（PS7 IP重新综合是大头）
# ============================================================

# ===== 路径配置（按需修改）=====
set proj_dir  {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.xpr}
set tcl_dir   {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/can_integration}
set xdc_file  {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/can_integration/can_module.xdc}
set ps2_src_dir {D:/workspace/trae/day01/0702/fpga_project/src/ps2}

# ===== 1. 打开工程 =====
puts "========== 1. 打开工程 =========="
open_project -quiet $proj_dir

# PS2模块已从BD中移除（integrate_can.tcl中删除ps2_host_axi_0）
puts "PS2模块已移除，CAN模块集成不受阻塞"

# 注：不在此处update_compile_order，因为BD未打开时design_1_wrapper.v会被AutoDisabled
# 改为在BD集成后执行update_compile_order

# 备份原wrapper（避免make_wrapper失败时回退）
file mkdir "${tcl_dir}/backup"
set orig_wrapper [get_files -quiet design_1_wrapper.v]
if {$orig_wrapper ne ""} {
    file copy -force $orig_wrapper "${tcl_dir}/backup/design_1_wrapper.v.bak"
    puts "原wrapper备份至: ${tcl_dir}/backup/"
}

# ===== 2. 执行CAN模块BD集成 =====
puts "========== 2. 执行 CAN 模块 BD 集成 =========="
source ${tcl_dir}/integrate_can.tcl

# ===== 3. 添加 can_module.xdc 约束文件 =====
puts "========== 3. 添加 can_module.xdc 约束 =========="
# 打印constrs_1中的文件列表（调试）
puts "constrs_1当前文件列表:"
foreach f [get_files -quiet -of_objects [get_filesets constrs_1]] {
    puts "  $f"
}
# 移除PS2残留约束文件（ps2模块已从BD删除，约束失效会产生Critical Warning）
set ps2_xdc "D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.srcs/constrs_1/new/ps2_pins.xdc"
set ps2_file [get_files -quiet -of_objects [get_filesets constrs_1] $ps2_xdc]
if {$ps2_file ne ""} {
    catch {remove_files $ps2_file}
    puts "已从constrs_1移除ps2_pins.xdc引用（消除6个Critical Warning）"
} else {
    puts "ps2_pins.xdc未在constrs_1中（可能已移除）"
}

# 强制重新添加约束文件（避免检查逻辑问题）
catch {add_files -fileset constrs_1 -norecurse ${xdc_file}}
set_property target_constrs_file ${xdc_file} [get_filesets constrs_1]
puts "已强制添加约束文件: ${xdc_file}"

# 关键：BD集成后，切换到手动compile order模式 + 设置顶层
# 自动模式（All）下Vivado会AutoDisabled design_1_wrapper.v，导致综合时找不到模块
# 手动模式（None）下不会AutoDisabled，set_property top可正常工作
# PS2已删除，不再依赖module_ref，手动模式安全
set_property source_mgmt_mode None [current_project]
set_property top design_1_wrapper [get_filesets sources_1]
puts "已切换到手动模式，top设置为design_1_wrapper"
# 验证顶层
set top_mod [get_property top [get_filesets sources_1]]
puts "当前顶层模块: $top_mod"

# ===== 4. 重置并启动综合 =====
puts "========== 4. 重置并启动综合 =========="
# PS7 IP配置已变化，必须重新综合（OOC模式下PS7会自动重综合）
reset_run synth_1

# 启动综合（同步等待完成）
launch_runs synth_1 -jobs 4
wait_on_run synth_1
set synth_status [get_property STATUS [get_runs synth_1]]
puts "综合状态: $synth_status"
# Vivado 2018.3综合完成状态是"synth_design Complete!"（不是"synth complete!"）
if {![string match "*Complete*" $synth_status]} {
    puts "ERROR: 综合失败，请查看日志"
    exit 1
}

# ===== 5. 启动实现+bitstream生成 =====
puts "========== 5. 启动实现 + bitstream生成 =========="
# 修复版v2：BD内部T信号已tie 0、SS_I已内部回环，wrapper无_T/_I顶层端口
# 顶层端口只有 _O 和 _I，全部在xdc中约束，不应再有UCIO-1错误
# 因此不再需要pre-hook降低UCIO-1严重级别

reset_run impl_1
launch_runs impl_1 -jobs 4 -to_step write_bitstream
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
puts "实现状态: $impl_status"

# ===== 6. 验证bitstream =====
puts "========== 6. 验证 bitstream =========="
set bit_file [file normalize {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.runs/impl_1/design_1_wrapper.bit}]
if {[file exists $bit_file]} {
    set bit_size [file size $bit_file]
    set bit_time [file mtime $bit_file]
    puts "SUCCESS: bitstream 生成成功"
    puts "  路径: $bit_file"
    puts "  大小: $bit_size 字节 ([expr {$bit_size / 1024}] KB)"
    puts "  时间: [clock format $bit_time -format {%Y-%m-%d %H:%M:%S}]"
    puts "  bitstream_size需求: >= [expr {($bit_size + 0xFFF) & 0xFFFFF000}] (向上对齐4KB)"
} else {
    puts "ERROR: bitstream 未生成"
    puts "  预期路径: $bit_file"
    puts "  请查看 impl_1 日志: [file normalize {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.runs/impl_1/runme.log}]"
}

puts "============================================"
puts "全部流程完成"
puts "============================================"

# 关闭工程
close_project
