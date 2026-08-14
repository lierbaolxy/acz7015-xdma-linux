vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/blk_mem_gen_v8_4_2
vlib modelsim_lib/msim/fifo_generator_v13_1_4
vlib modelsim_lib/msim/xdma_v4_1_2
vlib modelsim_lib/msim/axi_infrastructure_v1_1_0
vlib modelsim_lib/msim/axi_vip_v1_1_4
vlib modelsim_lib/msim/processing_system7_vip_v1_0_6
vlib modelsim_lib/msim/xlconstant_v1_1_5
vlib modelsim_lib/msim/lib_cdc_v1_0_2
vlib modelsim_lib/msim/proc_sys_reset_v5_0_13
vlib modelsim_lib/msim/smartconnect_v1_0

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm
vmap blk_mem_gen_v8_4_2 modelsim_lib/msim/blk_mem_gen_v8_4_2
vmap fifo_generator_v13_1_4 modelsim_lib/msim/fifo_generator_v13_1_4
vmap xdma_v4_1_2 modelsim_lib/msim/xdma_v4_1_2
vmap axi_infrastructure_v1_1_0 modelsim_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_4 modelsim_lib/msim/axi_vip_v1_1_4
vmap processing_system7_vip_v1_0_6 modelsim_lib/msim/processing_system7_vip_v1_0_6
vmap xlconstant_v1_1_5 modelsim_lib/msim/xlconstant_v1_1_5
vmap lib_cdc_v1_0_2 modelsim_lib/msim/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 modelsim_lib/msim/proc_sys_reset_v5_0_13
vmap smartconnect_v1_0 modelsim_lib/msim/smartconnect_v1_0

vlog -work xilinx_vip -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/workspace/fpga/myinstall/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_clock.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_eq.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_drp.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_rate.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_reset.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_sync.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gtp_pipe_rate.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gtp_pipe_drp.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gtp_pipe_reset.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_user.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pipe_wrapper.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_qpll_drp.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_qpll_reset.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_qpll_wrapper.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_rxeq_scan.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_top.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_core_top.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_axi_basic_rx_null_gen.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_axi_basic_rx_pipeline.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_axi_basic_rx.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_axi_basic_top.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_axi_basic_tx_pipeline.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_axi_basic_tx_thrtl_ctl.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_axi_basic_tx.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_7x.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_bram_7x.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_bram_top_7x.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_brams_7x.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_pipe_lane.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_pipe_misc.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie_pipe_pipeline.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gt_top.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gt_common.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gtp_cpllpd_ovrd.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gtx_cpllpd_ovrd.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gt_rx_valid_filter_7x.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_gt_wrapper.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/source/design_1_xdma_0_0_pcie2_ip_pcie2_top.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_0/sim/design_1_xdma_0_0_pcie2_ip.v" \

vlog -work blk_mem_gen_v8_4_2 -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/37c2/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_1/sim/xdma_v4_1_2_blk_mem_64_reg_be.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_2/sim/xdma_v4_1_2_blk_mem_64_noreg_be.v" \

vlog -work fifo_generator_v13_1_4 -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/e6d5/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_1_4 -64 -93 \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/e6d5/hdl/fifo_generator_v13_1_rfs.vhd" \

vlog -work fifo_generator_v13_1_4 -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/e6d5/hdl/fifo_generator_v13_1_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_3/sim/pcie2_fifo_generator_dma_cpl.v" \
"../../../bd/design_1/ip/design_1_xdma_0_0/ip_4/sim/pcie2_fifo_generator_tgt_brdg.v" \

vlog -work xdma_v4_1_2 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/xdma_v4_1_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_dma_cpl.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_dma_req.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_rx_destraddler.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_rx_demux.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_tgt_cpl.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_tgt_req.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_tx_mux.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_axi_stream_intf.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_cfg_sideband.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_pcie2_to_pcie3_wrapper.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_dma_bram_wrap.sv" \
"../../../bd/design_1/ip/design_1_xdma_0_0/xdma_v4_1/hdl/verilog/design_1_xdma_0_0_core_top.sv" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xdma_0_0/sim/design_1_xdma_0_0.v" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_4 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/98af/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_6 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_processing_system7_0_0/sim/design_1_processing_system7_0_0.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_util_ds_buf_0_0/util_ds_buf.vhd" \
"../../../bd/design_1/ip/design_1_util_ds_buf_0_0/sim/design_1_util_ds_buf_0_0.vhd" \

vlog -work xlconstant_v1_1_5 -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/4649/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_0/sim/bd_6f02_one_0.v" \

vcom -work lib_cdc_v1_0_2 -64 -93 \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -64 -93 \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_1/sim/bd_6f02_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/f85e/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_2/sim/bd_6f02_s00mmu_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ca72/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_3/sim/bd_6f02_s00tr_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/9ade/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_4/sim/bd_6f02_s00sic_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b89e/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_5/sim/bd_6f02_s00a2s_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_6/sim/bd_6f02_sarn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_7/sim/bd_6f02_srn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_8/sim/bd_6f02_sawn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_9/sim/bd_6f02_swn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_10/sim/bd_6f02_sbn_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/7005/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_11/sim/bd_6f02_m00s2a_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b387/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_4 -L processing_system7_vip_v1_0_6 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/ip/ip_12/sim/bd_6f02_m00e_0.sv" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/54bd/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/70cf/hdl" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/979d/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ipshared/b2d0/hdl/verilog" "+incdir+../../../../xdma.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0" "+incdir+D:/workspace/fpga/myinstall/Vivado/2018.3/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_1/bd_0/sim/bd_6f02.v" \
"../../../bd/design_1/ip/design_1_axi_smc_1/sim/design_1_axi_smc_1.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

