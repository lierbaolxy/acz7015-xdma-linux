# ============================================================
# ACZ7015 XDMA工程 恢复脚本 - 撤销SPI0修改，保留UART1 EMIO
# 功能：禁用PS7 SPI0 EMIO，保留UART1 EMIO（原始工程已启用）
#       保留AXI GPIO（避免M_AXI_GP0悬空），删除SPI0相关端口
# 目标：恢复PCIe正常工作，同时保留UART1功能
# 用法：
#   cd /d D:\workspace\fpga\myinstall\Vivado\2018.3\bin
#   .\vivado.bat -mode batch -source restore_uart1_only.tcl -log restore.log -journal restore.jou
# ============================================================

# ===== 路径配置 =====
set proj_dir  {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.xpr}
set tcl_dir   {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/can_integration}
set uart1_xdc {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/can_integration/uart1_only.xdc}

# ===== 1. 打开工程 =====
puts "========== 1. 打开工程 =========="
open_project -quiet $proj_dir

# ===== 2. 打开 BD =====
puts "========== 2. 打开 BD =========="
open_bd_design [get_files design_1.bd]

# ===== 3. 禁用 PS7 SPI0（撤销 integrate_can.tcl 的修改）=====
puts "========== 3. 禁用 PS7 SPI0 EMIO =========="
# 关键：只禁用SPI0，保留UART1 EMIO（原始工程已启用）
# 保留 GPIO EMIO 禁用状态（避免64位未约束引脚）
set_property -dict [list \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SPI0_SPI0_IO {<Select>} \
    CONFIG.PCW_SPI0_GRP_SS0_ENABLE {0} \
    CONFIG.PCW_SPI0_GRP_SS0_IO {<Select>} \
] [get_bd_cells processing_system7_0]
puts "已禁用 PS7 SPI0 EMIO（保留 UART1 EMIO，保留 GPIO EMIO 禁用）"

# 刷新 BD 布局
regenerate_bd_layout

# ===== 4. 删除 SPI0 相关顶层端口 =====
puts "========== 4. 删除 SPI0 顶层端口 =========="
foreach port {SPI0_SCLK_O SPI0_MOSI_O SPI0_MISO_I SPI0_SS_O} {
    set p [get_bd_ports -quiet $port]
    if {$p ne ""} {
        set nets [get_bd_nets -of_objects $p -quiet]
        if {$nets ne ""} {
            catch {delete_bd_objs $nets}
        }
        catch {delete_bd_objs $p}
        puts "已删除端口: $port"
    } else {
        puts "端口 $port 不存在，跳过"
    }
}

# ===== 5. 删除 const_one_4can（SPI0 SS_I 的驱动）=====
puts "========== 5. 删除 const_one_4can =========="
set const_one [get_bd_cells -quiet const_one_4can]
if {$const_one ne ""} {
    # 先断开连接
    set ss_i_net [get_bd_nets -of_objects [get_bd_pins -quiet "processing_system7_0/SPI0_SS_I"] -quiet]
    if {$ss_i_net ne ""} {
        catch {delete_bd_objs $ss_i_net}
    }
    catch {delete_bd_objs $const_one}
    puts "已删除 const_one_4can"
} else {
    puts "const_one_4can 不存在，跳过"
}

# ===== 6. 保留 UART1 EMIO 端口（原始工程已有，不需要修改）=====
puts "========== 6. 确认 UART1 端口 =========="
set uart_tx [get_bd_ports -quiet UART_1_TX_O]
set uart_rx [get_bd_ports -quiet UART_1_RX_I]
if {$uart_tx ne "" && $uart_rx ne ""} {
    puts "UART1 端口存在: UART_1_TX_O, UART_1_RX_I"
} else {
    puts "WARNING: UART1 端口缺失，可能需要手动添加"
}

# ===== 7. 保留 AXI GPIO（避免 M_AXI_GP0 悬空）=====
puts "========== 7. 保留 AXI GPIO（M_AXI_GP0 连接完整）========="
set axi_gpio [get_bd_cells -quiet axi_gpio_0]
if {$axi_gpio ne ""} {
    puts "AXI GPIO 存在，保留（M_AXI_GP0 连接完整）"
} else {
    puts "WARNING: AXI GPIO 不存在，M_AXI_GP0 可能悬空"
}

# ===== 8. 校验并保存 BD =====
puts "========== 8. 校验并保存 BD =========="
regenerate_bd_layout
save_bd_design
set bd_warn [validate_bd_design]
puts "BD校验结果: $bd_warn"

# 关闭 BD
close_bd_design [get_files design_1.bd]

# ===== 9. 重新生成 wrapper =====
puts "========== 9. 重新生成 wrapper =========="
generate_target all [get_files design_1.bd]
catch {make_wrapper -files [get_files design_1_wrapper.v] -top} err
puts "make_wrapper结果: $err"

# ===== 10. 设置顶层和约束 =====
puts "========== 10. 设置顶层和约束 =========="
set_property source_mgmt_mode None [current_project]
set_property top design_1_wrapper [get_filesets sources_1]
puts "顶层设置为 design_1_wrapper"

# 移除旧的 can_module.xdc 约束（如果存在）
set old_xdc [get_files -quiet -of_objects [get_filesets constrs_1] "${tcl_dir}/can_module.xdc"]
if {$old_xdc ne ""} {
    catch {remove_files $old_xdc}
    puts "已移除 can_module.xdc"
}

# 移除 ps2_pins.xdc（如果存在）
set ps2_xdc "D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.srcs/constrs_1/new/ps2_pins.xdc"
set ps2_file [get_files -quiet -of_objects [get_filesets constrs_1] $ps2_xdc]
if {$ps2_file ne ""} {
    catch {remove_files $ps2_file}
    puts "已移除 ps2_pins.xdc"
}

# 添加 UART1 约束
catch {add_files -fileset constrs_1 -norecurse $uart1_xdc}
set_property target_constrs_file $uart1_xdc [get_filesets constrs_1]
puts "已添加约束: $uart1_xdc"

# 验证约束文件列表
puts "constrs_1 当前文件列表:"
foreach f [get_files -quiet -of_objects [get_filesets constrs_1]] {
    puts "  $f"
}

# ===== 11. 重新综合 =====
puts "========== 11. 重新综合 =========="
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
set synth_status [get_property STATUS [get_runs synth_1]]
puts "综合状态: $synth_status"
if {![string match "*Complete*" $synth_status]} {
    puts "ERROR: 综合失败，请查看日志"
    close_project
    exit 1
}

# ===== 12. 实现 + bitstream 生成 =====
puts "========== 12. 实现 + bitstream 生成 =========="
reset_run impl_1
launch_runs impl_1 -jobs 4 -to_step write_bitstream
wait_on_run impl_1
set impl_status [get_property STATUS [get_runs impl_1]]
puts "实现状态: $impl_status"

# ===== 13. 验证 bitstream =====
puts "========== 13. 验证 bitstream =========="
set bit_file [file normalize {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.runs/impl_1/design_1_wrapper.bit}]
if {[file exists $bit_file]} {
    set bit_size [file size $bit_file]
    set bit_time [file mtime $bit_file]
    puts "SUCCESS: bitstream 生成成功"
    puts "  路径: $bit_file"
    puts "  大小: $bit_size 字节 ([expr {$bit_size / 1024}] KB)"
    puts "  时间: [clock format $bit_time -format {%Y-%m-%d %H:%M:%S}]"
} else {
    puts "ERROR: bitstream 未生成"
    puts "  预期路径: $bit_file"
}

# ===== 14. 检查时序和DRC =====
puts "========== 14. 检查时序 =========="
# 读取时序总结报告
set timing_rpt [file normalize {D:/workspace/trae/day01/0702/acz7015-xdma-linux/fpga/xdma/xdma.runs/impl_1/design_1_wrapper_timing_summary_routed.rpt}]
if {[file exists $timing_rpt]} {
    set fh [open $timing_rpt r]
    set content [read $fh]
    close $fh
    # 搜索 WNS
    if {[regexp {WNS\(ns\)\s+TNS\(ns\)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+} $content]} {
        puts "时序报告存在"
    }
    # 检查 no_clock
    if {[regexp {9 register/latch pins with no clock} $content]} {
        puts "WARNING: 仍有9个寄存器没有时钟（ref_clk_clk_p）"
    } elseif {[regexp {no clock} $content]} {
        puts "INFO: no_clock 警告已变化"
    } else {
        puts "INFO: no_clock 警告可能已解决"
    }
}

puts "============================================"
puts "恢复+综合流程完成"
puts "  - SPI0 EMIO 已禁用"
puts "  - UART1 EMIO 保留（原始工程配置）"
puts "  - AXI GPIO 保留（M_AXI_GP0 连接完整）"
puts "  - UART1 约束: E5(TX), B1(RX)"
puts "  - PCIe 约束: PCIE_REST.xdc（U9/Y8/R4）"
puts "============================================"

# 关闭工程
close_project
