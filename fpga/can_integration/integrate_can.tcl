# ============================================================
# ACZ7015 XDMA工程 集成 CAN/CANFD/RS485模块 TCL脚本 (修复版v6-AXI GPIO)
# 功能：在现有XDMA工程的Block Design里启用PS SPI0/UART1的EMIO
#       并用 AXI GPIO IP 替代 PS GPIO EMIO 控制CAN模块的8个GPIO信号
# 修复要点：
#   1. 禁用PS7 GPIO EMIO（硬件固定64位会撑宽wrapper端口，烧板风险）
#   2. 用 AXI GPIO IP 配置8位双向三态，wrapper只生成8位GPIO_0_tri_io
#   3. AXI GPIO 通过 axi_interconnect 连接到 PS7 M_AXI_GP0
#   4. SPI0/UART1 仍用 PS7 EMIO（接口宽度固定，无撑宽问题）
#   5. T 信号悬空（PS7 EMIO内部三态逻辑已处理）
#   6. SS_I 用 const_one 驱动（tie 到 1，表示SS未被外部拉低）
# 用法：Vivado打开xdma工程后，Tcl Console执行 source integrate_can.tcl
# ============================================================

# 1. 打开Block Design
open_bd_design [get_files design_1.bd]

# 1.5 移除PS2模块（ps2_host_axi_0）
set ps2_cell [get_bd_cells -quiet ps2_host_axi_0]
if {$ps2_cell ne ""} {
    delete_bd_objs [get_bd_cells ps2_host_axi_0]
    puts "已删除ps2_host_axi_0 cell"
} else {
    puts "ps2_host_axi_0不存在，跳过删除"
}

# 删除PS2专用的顶层端口
foreach port {ps2_clk ps2_data} {
    if {[get_bd_ports -quiet $port] ne ""} {
        catch {delete_bd_objs [get_bd_ports $port]}
        puts "已删除PS2端口: $port"
    }
}

# 2. 删除旧的PS7 GPIO_0_0外部端口（必须在禁用GPIO EMIO之前删除，避免悬空连接）
# 关键：禁用PS7 GPIO EMIO后PS7的GPIO_0接口pin会消失，若端口还连着会报错
set existing_gpio_port [get_bd_intf_ports -quiet GPIO_0_0]
if {$existing_gpio_port ne ""} {
    set nets [get_bd_intf_nets -of_objects $existing_gpio_port -quiet]
    if {$nets ne ""} { catch {delete_bd_objs $nets} }
    catch {delete_bd_objs $existing_gpio_port}
    puts "已删除PS7 GPIO_0_0外部端口（64位版本）"
}
# 兼容：如果端口名是GPIO_0也删除
set existing_gpio_port2 [get_bd_intf_ports -quiet GPIO_0]
if {$existing_gpio_port2 ne ""} {
    set nets2 [get_bd_intf_nets -of_objects $existing_gpio_port2 -quiet]
    if {$nets2 ne ""} { catch {delete_bd_objs $nets2} }
    catch {delete_bd_objs $existing_gpio_port2}
    puts "已删除旧GPIO_0外部端口"
}

# 3. 修改processing_system7_0配置，启用SPI0/UART1的EMIO，禁用GPIO EMIO
# 关键修复v6：禁用PS GPIO EMIO（硬件固定64位会撑宽wrapper端口，烧板风险）
#              GPIO改用 AXI GPIO IP（8位可配置宽度）
set_property -dict [list \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
    CONFIG.PCW_SPI0_GRP_SS0_ENABLE {1} \
    CONFIG.PCW_SPI0_GRP_SS0_IO {EMIO} \
    CONFIG.PCW_SPI0_GRP_SS1_ENABLE {0} \
    CONFIG.PCW_SPI0_GRP_SS2_ENABLE {0} \
    \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {EMIO} \
    \
    CONFIG.PCW_EN_EMIO_GPIO {0} \
] [get_bd_cells processing_system7_0]
puts "PS7 SPI0/UART1 EMIO已启用，GPIO EMIO已禁用（改用AXI GPIO）"

# 关键修复1：set_property 后立即 regenerate_bd_layout 刷新PS7 IP端口
regenerate_bd_layout

# 4. 删除之前可能创建的 _T 端口和 SS_I 端口（改为内部处理，不引到顶层）
# 注意：要先删除 SS_I 顶层端口，让 PS7 的 SS_I pin 悬空，再用 const_one 驱动
foreach port {SPI0_SCLK_T SPI0_MOSI_T SPI0_SS_T SPI0_SS_I UART_1_TX_T} {
    set p [get_bd_ports -quiet $port]
    if {$p ne ""} {
        set nets [get_bd_nets -of_objects $p -quiet]
        if {$nets ne ""} {
            catch {delete_bd_objs $nets}
        }
        delete_bd_objs $p
        puts "已删除旧端口: $port"
    }
}

# 5. PS7 _T 信号处理
# PS7 SPI0 的 _T pin 是 OUTPUT（PS7输出三态使能信号给外部buffer用）
# 不能用 const_zero 驱动（会冲突：两个source在同一net）
# EMIO模式下PS7内部已处理三态逻辑，_T信号不需要外部使用
# 正确做法：让 _T 信号在BD内部悬空（不连接到任何sink，不引出到顶层）
puts "PS7 _T 信号（SPI0_SCLK_T/MOSI_T/SS_T）保持悬空，不引出到顶层（EMIO内部三态逻辑已处理）"

# 6. SPI0_SS_I 用 const_one 驱动（tie 到 1，表示SS未被外部拉低）
set ss_i_pin [get_bd_pins -quiet "processing_system7_0/SPI0_SS_I"]
if {$ss_i_pin ne ""} {
    # 先删除现有连接（如果 SS_I 还连着已删除的顶层端口）
    set existing [get_bd_nets -of_objects $ss_i_pin -quiet]
    if {$existing ne ""} {
        catch {delete_bd_objs $existing}
        puts "已断开 SPI0_SS_I 旧连接"
    }
    # 创建 const_one 并连接到 SS_I
    set const_one [get_bd_cells -quiet const_one_4can]
    if {$const_one eq ""} {
        set const_one [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_one_4can]
        set_property -dict [list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}] $const_one
        puts "已创建const_one_4can单元"
    }
    connect_bd_net [get_bd_pins const_one_4can/dout] $ss_i_pin
    puts "已将 SPI0_SS_I tie 到 const_one (VDD，表示SS未被外部拉低)"
} else {
    puts "ERROR: processing_system7_0/SPI0_SS_I pin 未找到！"
}

# 7. 创建顶层端口并连接（用 PS7 真实 pin 名，BD 顶层端口名保持兼容）
# 注意：connect_top 的 ps7_pin 是 PS7 cell 的真实 pin 名，port_name 是 BD 顶层端口名
proc connect_top {ps7_pin port_name dir} {
    if {[get_bd_ports -quiet $port_name] eq ""} {
        create_bd_port -dir $dir $port_name
    }
    set pin [get_bd_pins -quiet "processing_system7_0/$ps7_pin"]
    if {$pin eq ""} {
        puts "ERROR: pin processing_system7_0/$ps7_pin 未找到！"
        return -code error "pin not found: $ps7_pin"
    }
    set existing [get_bd_nets -of_objects $pin -quiet]
    if {$existing eq ""} {
        if {$dir eq "I"} {
            connect_bd_net [get_bd_ports $port_name] $pin
        } else {
            connect_bd_net $pin [get_bd_ports $port_name]
        }
        puts "已连接 $ps7_pin → 顶层端口 $port_name ($dir)"
    } else {
        puts "$ps7_pin 已有连接，跳过"
    }
}

# SPI0 顶层端口（PS7 pin 名 SPI0_*，BD 顶层端口名 SPI0_*）
connect_top SPI0_SCLK_O SPI0_SCLK_O O
connect_top SPI0_MOSI_O SPI0_MOSI_O O
connect_top SPI0_MISO_I SPI0_MISO_I I
connect_top SPI0_SS_O   SPI0_SS_O   O

# UART1 顶层端口（PS7 pin 名 UART1_TX/UART1_RX，BD 顶层端口名 UART_1_TX_O/UART_1_RX_I）
connect_top UART1_TX UART_1_TX_O O
connect_top UART1_RX UART_1_RX_I I

# ============================================================
# 8. GPIO方案：用 AXI GPIO IP 替代 PS GPIO EMIO（避免64位撑宽烧板风险）
# 根因：PS7 GPIO EMIO接口硬件固定64位，wrapper生成64位GPIO_0_0_tri_io
#       clg485封装放不下64个约束，未约束引脚会随机分配导致烧板
# 方案：用AXI GPIO IP配置8位双向三态，wrapper只生成8位GPIO_0_tri_io
# 参考：PG144 AXI GPIO v2.0 Product Guide
# ============================================================

# 8b. 创建 AXI GPIO IP（8位双向三态）
set axi_gpio [get_bd_cells -quiet axi_gpio_0]
if {$axi_gpio eq ""} {
    set axi_gpio [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0]
    puts "已创建axi_gpio_0"
}

# 8c. 配置 AXI GPIO：8位双向三态
# C_GPIO_WIDTH=8 8位宽度
# C_ALL_INPUTS=0 非全输入（支持双向）
# C_ALL_OUTPUTS=0 非全输出（支持双向）
# C_DOUT_DEFAULT=0x00 复位时输出全0（RS485_RE低=接收模式，安全）
#   注：参数名是C_DOUT_DEFAULT（PG144），旧写法C_GPIO_DOUT_DEFAULT会报参数不存在
# C_TRI_DEFAULT=0xFF 复位时三态全1（输入模式，安全）
set_property -dict [list \
    CONFIG.C_GPIO_WIDTH {8} \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_OUTPUTS {0} \
    CONFIG.C_DOUT_DEFAULT {0x00000000} \
    CONFIG.C_TRI_DEFAULT {0x000000FF} \
] $axi_gpio
puts "已配置axi_gpio_0为8位双向三态（DOUT默认0x00，TRI默认0xFF输入模式）"

# 8d. 创建 axi_interconnect 连接 AXI GPIO 到 PS7 M_AXI_GP0
set axi_ic [get_bd_cells -quiet axi_gp0_ic]
if {$axi_ic eq ""} {
    set axi_ic [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_gp0_ic]
    set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] $axi_ic
    puts "已创建axi_gp0_ic（1主1从）"
}

# 8e. 连接 PS7 M_AXI_GP0 → axi_gp0_ic → axi_gpio_0 S_AXI
# 先删除现有连接（避免重复连接报错）
catch {delete_bd_objs [get_bd_intf_nets -of_objects [get_bd_intf_pins processing_system7_0/M_AXI_GP0] -quiet]}
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins axi_gp0_ic/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_gp0_ic/M00_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
puts "已连接 PS7 M_AXI_GP0 → axi_gp0_ic → axi_gpio_0/S_AXI"

# 8f. 连接时钟（复用现有xdma_0/axi_aclk，PS7 M_AXI_GP0_ACLK已连接）
# 幂等修复：方案A bit已连接过这些时钟，重复connect_bd_net会报BD 5-4错误
proc connect_clk_if_needed {src_pin dst_pin} {
    set existing [get_bd_nets -of_objects $dst_pin -quiet]
    if {$existing eq ""} {
        connect_bd_net $src_pin $dst_pin
        puts "已连接时钟 [get_property NAME $src_pin] → [get_property NAME $dst_pin]"
    } else {
        puts "时钟 [get_property NAME $dst_pin] 已有连接($existing)，跳过"
    }
}
set aclk_pin [get_bd_pins xdma_0/axi_aclk]
connect_clk_if_needed $aclk_pin [get_bd_pins axi_gp0_ic/ACLK]
connect_clk_if_needed $aclk_pin [get_bd_pins axi_gp0_ic/S00_ACLK]
connect_clk_if_needed $aclk_pin [get_bd_pins axi_gp0_ic/M00_ACLK]
connect_clk_if_needed $aclk_pin [get_bd_pins axi_gpio_0/s_axi_aclk]

# 8g. 复位信号：用 const_vcc_reset 保持复位无效（tie到1=不复位）
# 安全性说明：AXI GPIO不复位时寄存器状态不确定，但已配置C_GPIO_DOUT_DEFAULT=0x00
#             和C_TRI_DEFAULT=0xFF，上电后输出全0（RS485接收模式），输入模式（高阻）
#             PS端软件初始化时会写GPIO_TRI和GPIO_DATA寄存器配置方向和电平
set const_vcc [get_bd_cells -quiet const_vcc_reset]
if {$const_vcc eq ""} {
    set const_vcc [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_vcc_reset]
    set_property -dict [list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}] $const_vcc
    puts "已创建const_vcc_reset单元"
}
# 幂等修复：已连接的复位pin跳过
proc connect_rst_if_needed {src_pin dst_pin} {
    set existing [get_bd_nets -of_objects $dst_pin -quiet]
    if {$existing eq ""} {
        connect_bd_net $src_pin $dst_pin
        puts "已连接复位 [get_property NAME $dst_pin]"
    } else {
        puts "复位 [get_property NAME $dst_pin] 已有连接($existing)，跳过"
    }
}
set rst_pin [get_bd_pins const_vcc_reset/dout]
connect_rst_if_needed $rst_pin [get_bd_pins axi_gp0_ic/ARESETN]
connect_rst_if_needed $rst_pin [get_bd_pins axi_gp0_ic/S00_ARESETN]
connect_rst_if_needed $rst_pin [get_bd_pins axi_gp0_ic/M00_ARESETN]
connect_rst_if_needed $rst_pin [get_bd_pins axi_gpio_0/s_axi_aresetn]

# 8h. make external AXI GPIO 的 GPIO 接口（生成外部端口）
# AXI GPIO 的 GPIO 接口是 gpio_rtl 类型，make external 后端口名为 GPIO_0
# wrapper 将生成 inout [7:0]GPIO_0_tri_io（匹配 can_module.xdc 约束）
set gpio_intf [get_bd_intf_pins -quiet axi_gpio_0/GPIO]
if {$gpio_intf ne ""} {
    # 幂等修复：若GPIO接口已连到外部端口则跳过（方案A bit已生成GPIO_0外部端口）
    set gpio_nets [get_bd_intf_nets -of_objects $gpio_intf -quiet]
    set old_port [get_bd_intf_ports -quiet GPIO_0]
    if {$old_port ne "" && $gpio_nets ne ""} {
        puts "GPIO_0 外部端口已存在且已连接，跳过make external"
    } else {
        # GPIO接口悬空：删除旧端口（若有）后make external
        if {$old_port ne ""} {
            set old_nets [get_bd_intf_nets -of_objects $old_port -quiet]
            if {$old_nets ne ""} { catch {delete_bd_objs $old_nets} }
            catch {delete_bd_objs $old_port}
        }
        make_bd_intf_pins_external $gpio_intf
        puts "已生成 GPIO_0 外部端口（wrapper 将生成 inout [7:0]GPIO_0_tri_io）"
    }
} else {
    puts "ERROR: axi_gpio_0/GPIO 接口未找到！"
}

# 8i. 分配地址空间（AXI GPIO 需要 4KB 地址空间）
assign_bd_address
puts "已分配地址空间给 axi_gpio_0"

# ============================================================
# 9. 重新布局、保存、校验BD
# ============================================================
regenerate_bd_layout
save_bd_design
set bd_warn [validate_bd_design]
puts "BD校验结果: $bd_warn"

# 10. 重新生成顶层wrapper（包含新端口）
generate_target all [get_files design_1.bd]

# 11. 更新顶层wrapper文件
catch {make_wrapper -files [get_files design_1_wrapper.v] -top} err
puts "make_wrapper结果: $err"
update_compile_order -fileset sources_1
puts "wrapper已更新"

puts "============================================"
puts "CAN模块BD集成完成（修复版v6-AXI GPIO）"
puts "  - SPI0/UART1 用PS7 EMIO（BD内部连接完整）"
puts "  - GPIO 用AXI GPIO IP（8位双向三态，无64位撑宽风险）"
puts "  - T 信号悬空（EMIO内部三态逻辑已处理）"
puts "  - SS_I 由 const_one 驱动（VDD）"
puts "  - AXI GPIO 通过 axi_gp0_ic 连接到 PS7 M_AXI_GP0"
puts "  - 顶层端口: SPI0_{SCLK,MOSI,SS}_O, SPI0_MISO_I, UART_1_{TX_O,RX_I}, GPIO_0_tri_io[7:0]"
puts "  - 安全：wrapper只生成8位GPIO_0_tri_io（无64位未约束引脚烧板风险）"
puts "============================================"
