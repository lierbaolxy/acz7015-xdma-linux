// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Aug 13 10:31:07 2026
// Host        : zx-lxy running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               G:/fpga/0708/0810/xdma/xdma/xdma.srcs/sources_1/bd/design_1/ip/design_1_ps2_host_axi_0_0/design_1_ps2_host_axi_0_0_sim_netlist.v
// Design      : design_1_ps2_host_axi_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z015clg485-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_ps2_host_axi_0_0,ps2_host_axi,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "ps2_host_axi,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module design_1_ps2_host_axi_0_0
   (clk,
    rst_n,
    ps2_clk,
    ps2_data,
    s_axi_aclk,
    s_axi_aresetn,
    s_axi_awaddr,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_araddr,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_bready,
    s_axi_rready);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF s_axi, FREQ_HZ 62500000, PHASE 0.000, CLK_DOMAIN design_1_xdma_0_0_axi_aclk, INSERT_VIP 0" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input rst_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ps2_clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ps2_clk, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) inout ps2_clk;
  inout ps2_data;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aclk, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 62500000, PHASE 0.000, CLK_DOMAIN design_1_xdma_0_0_axi_aclk, INSERT_VIP 0" *) input s_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *) input [7:0]s_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *) input s_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *) output s_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *) input [31:0]s_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *) input [3:0]s_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *) input s_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *) output s_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *) output [1:0]s_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *) output s_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *) input [7:0]s_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *) input s_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *) output s_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *) output [31:0]s_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *) output [1:0]s_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *) output s_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *) input s_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 62500000, ID_WIDTH 0, ADDR_WIDTH 8, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN design_1_xdma_0_0_axi_aclk, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s_axi_rready;

  wire \<const0> ;
  wire ps2_clk;
  wire ps2_data;
  wire rst_n;
  wire s_axi_aclk;
  wire [7:0]s_axi_araddr;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [7:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire s_axi_rready;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wvalid;

  assign s_axi_bresp[1] = \<const0> ;
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_rresp[1] = \<const0> ;
  assign s_axi_rresp[0] = \<const0> ;
  assign s_axi_wready = s_axi_awready;
  GND GND
       (.G(\<const0> ));
  design_1_ps2_host_axi_0_0_ps2_host_axi inst
       (.E(s_axi_arready),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .r_valid_reg_reg_0(s_axi_rvalid),
        .rst_n(rst_n),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_wdata(s_axi_wdata[7:0]),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

(* ORIG_REF_NAME = "ps2_host" *) 
module design_1_ps2_host_axi_0_0_ps2_host
   (E,
    parity_err_reg,
    \s_axi_awaddr[5] ,
    Q,
    D,
    rx_valid_reg_reg_0,
    tx_active_reg_0,
    ps2_clk,
    ps2_data,
    s_axi_aclk,
    tx_en_reg_reg,
    s_axi_awaddr,
    tx_en_reg_reg_0,
    \tx_shift_reg_reg[7]_0 ,
    \r_data_reg_reg[2] ,
    rx_data_new_reg,
    s_axi_araddr,
    \r_data_reg_reg[2]_0 ,
    rx_data_new_reg_0,
    rx_data_new,
    tx_en_reg_reg_1,
    rst_n,
    soft_rst_n);
  output [0:0]E;
  output parity_err_reg;
  output [0:0]\s_axi_awaddr[5] ;
  output [7:0]Q;
  output [0:0]D;
  output rx_valid_reg_reg_0;
  output tx_active_reg_0;
  inout ps2_clk;
  inout ps2_data;
  input s_axi_aclk;
  input tx_en_reg_reg;
  input [3:0]s_axi_awaddr;
  input tx_en_reg_reg_0;
  input [7:0]\tx_shift_reg_reg[7]_0 ;
  input \r_data_reg_reg[2] ;
  input rx_data_new_reg;
  input [4:0]s_axi_araddr;
  input [0:0]\r_data_reg_reg[2]_0 ;
  input rx_data_new_reg_0;
  input rx_data_new;
  input tx_en_reg_reg_1;
  input rst_n;
  input soft_rst_n;

  wire [0:0]D;
  wire [0:0]E;
  wire \FSM_sequential_state[0]_i_1_n_0 ;
  wire \FSM_sequential_state[1]_i_1_n_0 ;
  wire \FSM_sequential_state[1]_i_2_n_0 ;
  wire \FSM_sequential_state[1]_i_3_n_0 ;
  wire \FSM_sequential_state[1]_i_4_n_0 ;
  wire \FSM_sequential_state[1]_i_5_n_0 ;
  wire \FSM_sequential_state[1]_i_6_n_0 ;
  wire \FSM_sequential_state[2]_i_1_n_0 ;
  wire \FSM_sequential_state[2]_i_2_n_0 ;
  wire \FSM_sequential_state[2]_i_3_n_0 ;
  wire \FSM_sequential_state[2]_i_4_n_0 ;
  wire \FSM_sequential_state[2]_i_5_n_0 ;
  wire \FSM_sequential_state[2]_i_6_n_0 ;
  wire \FSM_sequential_state[2]_i_7_n_0 ;
  wire \FSM_sequential_state[2]_i_8_n_0 ;
  wire \FSM_sequential_state[2]_i_9_n_0 ;
  wire [7:0]Q;
  wire [3:0]bit_cnt;
  wire \bit_cnt[1]_i_1_n_0 ;
  wire \bit_cnt[3]_i_1_n_0 ;
  wire \bit_cnt[3]_i_3_n_0 ;
  wire \bit_cnt[3]_i_4_n_0 ;
  wire \bit_cnt[3]_i_5_n_0 ;
  wire \bit_cnt_reg_n_0_[0] ;
  wire \bit_cnt_reg_n_0_[1] ;
  wire \bit_cnt_reg_n_0_[2] ;
  wire \bit_cnt_reg_n_0_[3] ;
  wire data_en_reg_i_1_n_0;
  wire data_en_reg_i_2_n_0;
  wire data_en_reg_i_3_n_0;
  wire data_en_reg_i_4_n_0;
  wire data_en_reg_i_5_n_0;
  wire parity_err_reg;
  wire parity_err_reg_i_1_n_0;
  wire parity_err_reg_i_2_n_0;
  wire parity_err_reg_i_3_n_0;
  wire ps2_clk;
  wire ps2_clk_en;
  wire ps2_clk_meta;
  wire ps2_clk_prev;
  wire ps2_clk_sync;
  wire ps2_data;
  wire ps2_data_en;
  wire ps2_data_meta;
  wire ps2_data_sync;
  wire \r_data_reg[2]_i_3_n_0 ;
  wire \r_data_reg_reg[2] ;
  wire [0:0]\r_data_reg_reg[2]_0 ;
  wire rst_n;
  wire rx_data_new;
  wire rx_data_new_reg;
  wire rx_data_new_reg_0;
  wire \rx_shift_reg[7]_i_1_n_0 ;
  wire rx_valid_reg_i_1_n_0;
  wire rx_valid_reg_reg_0;
  wire s_axi_aclk;
  wire [4:0]s_axi_araddr;
  wire [3:0]s_axi_awaddr;
  wire [0:0]\s_axi_awaddr[5] ;
  wire soft_rst_n;
  wire [2:0]state__0;
  wire \timeout_cnt[0]_i_2_n_0 ;
  wire \timeout_cnt[0]_i_3_n_0 ;
  wire \timeout_cnt[0]_i_4_n_0 ;
  wire \timeout_cnt[0]_i_5_n_0 ;
  wire \timeout_cnt[0]_i_6_n_0 ;
  wire \timeout_cnt[12]_i_2_n_0 ;
  wire \timeout_cnt[12]_i_3_n_0 ;
  wire \timeout_cnt[12]_i_4_n_0 ;
  wire \timeout_cnt[12]_i_5_n_0 ;
  wire \timeout_cnt[16]_i_2_n_0 ;
  wire \timeout_cnt[16]_i_3_n_0 ;
  wire \timeout_cnt[16]_i_4_n_0 ;
  wire \timeout_cnt[16]_i_5_n_0 ;
  wire \timeout_cnt[4]_i_2_n_0 ;
  wire \timeout_cnt[4]_i_3_n_0 ;
  wire \timeout_cnt[4]_i_4_n_0 ;
  wire \timeout_cnt[4]_i_5_n_0 ;
  wire \timeout_cnt[8]_i_2_n_0 ;
  wire \timeout_cnt[8]_i_3_n_0 ;
  wire \timeout_cnt[8]_i_4_n_0 ;
  wire \timeout_cnt[8]_i_5_n_0 ;
  wire [19:6]timeout_cnt_reg;
  wire \timeout_cnt_reg[0]_i_1_n_0 ;
  wire \timeout_cnt_reg[0]_i_1_n_1 ;
  wire \timeout_cnt_reg[0]_i_1_n_2 ;
  wire \timeout_cnt_reg[0]_i_1_n_3 ;
  wire \timeout_cnt_reg[0]_i_1_n_4 ;
  wire \timeout_cnt_reg[0]_i_1_n_5 ;
  wire \timeout_cnt_reg[0]_i_1_n_6 ;
  wire \timeout_cnt_reg[0]_i_1_n_7 ;
  wire \timeout_cnt_reg[12]_i_1_n_0 ;
  wire \timeout_cnt_reg[12]_i_1_n_1 ;
  wire \timeout_cnt_reg[12]_i_1_n_2 ;
  wire \timeout_cnt_reg[12]_i_1_n_3 ;
  wire \timeout_cnt_reg[12]_i_1_n_4 ;
  wire \timeout_cnt_reg[12]_i_1_n_5 ;
  wire \timeout_cnt_reg[12]_i_1_n_6 ;
  wire \timeout_cnt_reg[12]_i_1_n_7 ;
  wire \timeout_cnt_reg[16]_i_1_n_1 ;
  wire \timeout_cnt_reg[16]_i_1_n_2 ;
  wire \timeout_cnt_reg[16]_i_1_n_3 ;
  wire \timeout_cnt_reg[16]_i_1_n_4 ;
  wire \timeout_cnt_reg[16]_i_1_n_5 ;
  wire \timeout_cnt_reg[16]_i_1_n_6 ;
  wire \timeout_cnt_reg[16]_i_1_n_7 ;
  wire \timeout_cnt_reg[4]_i_1_n_0 ;
  wire \timeout_cnt_reg[4]_i_1_n_1 ;
  wire \timeout_cnt_reg[4]_i_1_n_2 ;
  wire \timeout_cnt_reg[4]_i_1_n_3 ;
  wire \timeout_cnt_reg[4]_i_1_n_4 ;
  wire \timeout_cnt_reg[4]_i_1_n_5 ;
  wire \timeout_cnt_reg[4]_i_1_n_6 ;
  wire \timeout_cnt_reg[4]_i_1_n_7 ;
  wire \timeout_cnt_reg[8]_i_1_n_0 ;
  wire \timeout_cnt_reg[8]_i_1_n_1 ;
  wire \timeout_cnt_reg[8]_i_1_n_2 ;
  wire \timeout_cnt_reg[8]_i_1_n_3 ;
  wire \timeout_cnt_reg[8]_i_1_n_4 ;
  wire \timeout_cnt_reg[8]_i_1_n_5 ;
  wire \timeout_cnt_reg[8]_i_1_n_6 ;
  wire \timeout_cnt_reg[8]_i_1_n_7 ;
  wire \timeout_cnt_reg_n_0_[0] ;
  wire \timeout_cnt_reg_n_0_[1] ;
  wire \timeout_cnt_reg_n_0_[2] ;
  wire \timeout_cnt_reg_n_0_[3] ;
  wire \timeout_cnt_reg_n_0_[4] ;
  wire \timeout_cnt_reg_n_0_[5] ;
  wire tx_active_i_1_n_0;
  wire tx_active_i_2_n_0;
  wire tx_active_i_3_n_0;
  wire tx_active_reg_0;
  wire tx_en_reg_reg;
  wire tx_en_reg_reg_0;
  wire tx_en_reg_reg_1;
  wire [7:0]tx_shift_reg;
  wire \tx_shift_reg[7]_i_1_n_0 ;
  wire [7:0]\tx_shift_reg_reg[7]_0 ;
  wire \tx_shift_reg_reg_n_0_[0] ;
  wire \tx_shift_reg_reg_n_0_[1] ;
  wire \tx_shift_reg_reg_n_0_[2] ;
  wire \tx_shift_reg_reg_n_0_[3] ;
  wire \tx_shift_reg_reg_n_0_[4] ;
  wire \tx_shift_reg_reg_n_0_[5] ;
  wire \tx_shift_reg_reg_n_0_[6] ;
  wire \tx_shift_reg_reg_n_0_[7] ;
  wire [3:3]\NLW_timeout_cnt_reg[16]_i_1_CO_UNCONNECTED ;

  LUT6 #(
    .INIT(64'h00FF00004F000000)) 
    \FSM_sequential_state[0]_i_1 
       (.I0(\FSM_sequential_state[1]_i_2_n_0 ),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(\FSM_sequential_state[1]_i_3_n_0 ),
        .I4(\FSM_sequential_state[2]_i_6_n_0 ),
        .I5(state__0[0]),
        .O(\FSM_sequential_state[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h13FF0000CC000000)) 
    \FSM_sequential_state[1]_i_1 
       (.I0(state__0[2]),
        .I1(state__0[0]),
        .I2(\FSM_sequential_state[1]_i_2_n_0 ),
        .I3(\FSM_sequential_state[1]_i_3_n_0 ),
        .I4(\FSM_sequential_state[2]_i_6_n_0 ),
        .I5(state__0[1]),
        .O(\FSM_sequential_state[1]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hB)) 
    \FSM_sequential_state[1]_i_2 
       (.I0(ps2_clk_sync),
        .I1(ps2_clk_prev),
        .O(\FSM_sequential_state[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF0010)) 
    \FSM_sequential_state[1]_i_3 
       (.I0(\bit_cnt_reg_n_0_[3] ),
        .I1(\FSM_sequential_state[1]_i_4_n_0 ),
        .I2(state__0[1]),
        .I3(\FSM_sequential_state[1]_i_2_n_0 ),
        .I4(\FSM_sequential_state[1]_i_5_n_0 ),
        .I5(\FSM_sequential_state[1]_i_6_n_0 ),
        .O(\FSM_sequential_state[1]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h7F)) 
    \FSM_sequential_state[1]_i_4 
       (.I0(\bit_cnt_reg_n_0_[1] ),
        .I1(\bit_cnt_reg_n_0_[0] ),
        .I2(\bit_cnt_reg_n_0_[2] ),
        .O(\FSM_sequential_state[1]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000F0FD00000000)) 
    \FSM_sequential_state[1]_i_5 
       (.I0(ps2_data_sync),
        .I1(state__0[2]),
        .I2(state__0[0]),
        .I3(state__0[1]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\FSM_sequential_state[1]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00010000)) 
    \FSM_sequential_state[1]_i_6 
       (.I0(state__0[0]),
        .I1(state__0[2]),
        .I2(state__0[1]),
        .I3(ps2_clk_en),
        .I4(tx_en_reg_reg),
        .O(\FSM_sequential_state[1]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'h57005400)) 
    \FSM_sequential_state[2]_i_1 
       (.I0(\FSM_sequential_state[2]_i_3_n_0 ),
        .I1(\FSM_sequential_state[2]_i_4_n_0 ),
        .I2(\FSM_sequential_state[2]_i_5_n_0 ),
        .I3(\FSM_sequential_state[2]_i_6_n_0 ),
        .I4(state__0[2]),
        .O(\FSM_sequential_state[2]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \FSM_sequential_state[2]_i_2 
       (.I0(rst_n),
        .I1(soft_rst_n),
        .O(\FSM_sequential_state[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFF5555AEAA5555AE)) 
    \FSM_sequential_state[2]_i_3 
       (.I0(state__0[0]),
        .I1(tx_en_reg_reg),
        .I2(ps2_clk_en),
        .I3(state__0[1]),
        .I4(state__0[2]),
        .I5(\FSM_sequential_state[1]_i_2_n_0 ),
        .O(\FSM_sequential_state[2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h3303330A3303330B)) 
    \FSM_sequential_state[2]_i_4 
       (.I0(\bit_cnt[3]_i_4_n_0 ),
        .I1(\FSM_sequential_state[1]_i_2_n_0 ),
        .I2(state__0[1]),
        .I3(state__0[0]),
        .I4(state__0[2]),
        .I5(ps2_data_sync),
        .O(\FSM_sequential_state[2]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \FSM_sequential_state[2]_i_5 
       (.I0(\FSM_sequential_state[1]_i_2_n_0 ),
        .I1(state__0[1]),
        .I2(\bit_cnt_reg_n_0_[1] ),
        .I3(\bit_cnt_reg_n_0_[0] ),
        .I4(\bit_cnt_reg_n_0_[2] ),
        .I5(\bit_cnt_reg_n_0_[3] ),
        .O(\FSM_sequential_state[2]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF15155515)) 
    \FSM_sequential_state[2]_i_6 
       (.I0(\FSM_sequential_state[2]_i_7_n_0 ),
        .I1(timeout_cnt_reg[16]),
        .I2(timeout_cnt_reg[17]),
        .I3(\FSM_sequential_state[2]_i_8_n_0 ),
        .I4(\FSM_sequential_state[2]_i_9_n_0 ),
        .I5(\bit_cnt[3]_i_3_n_0 ),
        .O(\FSM_sequential_state[2]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \FSM_sequential_state[2]_i_7 
       (.I0(timeout_cnt_reg[19]),
        .I1(timeout_cnt_reg[18]),
        .O(\FSM_sequential_state[2]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'h777777777F7F7FFF)) 
    \FSM_sequential_state[2]_i_8 
       (.I0(timeout_cnt_reg[10]),
        .I1(timeout_cnt_reg[11]),
        .I2(timeout_cnt_reg[8]),
        .I3(timeout_cnt_reg[7]),
        .I4(timeout_cnt_reg[6]),
        .I5(timeout_cnt_reg[9]),
        .O(\FSM_sequential_state[2]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_sequential_state[2]_i_9 
       (.I0(timeout_cnt_reg[12]),
        .I1(timeout_cnt_reg[13]),
        .I2(timeout_cnt_reg[14]),
        .I3(timeout_cnt_reg[15]),
        .O(\FSM_sequential_state[2]_i_9_n_0 ));
  (* FSM_ENCODED_STATES = "TX_DATA:010,TX_PARITY:011,TX_STOP:100,RX_DATA:110,RX_START:101,TX_START:001,IDLE:000,RX_PARITY:111" *) 
  FDCE \FSM_sequential_state_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\FSM_sequential_state[0]_i_1_n_0 ),
        .Q(state__0[0]));
  (* FSM_ENCODED_STATES = "TX_DATA:010,TX_PARITY:011,TX_STOP:100,RX_DATA:110,RX_START:101,TX_START:001,IDLE:000,RX_PARITY:111" *) 
  FDCE \FSM_sequential_state_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\FSM_sequential_state[1]_i_1_n_0 ),
        .Q(state__0[1]));
  (* FSM_ENCODED_STATES = "TX_DATA:010,TX_PARITY:011,TX_STOP:100,RX_DATA:110,RX_START:101,TX_START:001,IDLE:000,RX_PARITY:111" *) 
  FDCE \FSM_sequential_state_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\FSM_sequential_state[2]_i_1_n_0 ),
        .Q(state__0[2]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h3A)) 
    \bit_cnt[0]_i_1 
       (.I0(state__0[2]),
        .I1(\bit_cnt_reg_n_0_[0] ),
        .I2(state__0[1]),
        .O(bit_cnt[0]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h60)) 
    \bit_cnt[1]_i_1 
       (.I0(\bit_cnt_reg_n_0_[1] ),
        .I1(\bit_cnt_reg_n_0_[0] ),
        .I2(state__0[1]),
        .O(\bit_cnt[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h2A80)) 
    \bit_cnt[2]_i_1 
       (.I0(state__0[1]),
        .I1(\bit_cnt_reg_n_0_[0] ),
        .I2(\bit_cnt_reg_n_0_[1] ),
        .I3(\bit_cnt_reg_n_0_[2] ),
        .O(bit_cnt[2]));
  LUT6 #(
    .INIT(64'h00000008AAAAAAAA)) 
    \bit_cnt[3]_i_1 
       (.I0(\FSM_sequential_state[2]_i_6_n_0 ),
        .I1(\bit_cnt[3]_i_3_n_0 ),
        .I2(ps2_data_sync),
        .I3(\FSM_sequential_state[1]_i_2_n_0 ),
        .I4(\bit_cnt[3]_i_4_n_0 ),
        .I5(\bit_cnt[3]_i_5_n_0 ),
        .O(\bit_cnt[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h2AAA8000)) 
    \bit_cnt[3]_i_2 
       (.I0(state__0[1]),
        .I1(\bit_cnt_reg_n_0_[1] ),
        .I2(\bit_cnt_reg_n_0_[0] ),
        .I3(\bit_cnt_reg_n_0_[2] ),
        .I4(\bit_cnt_reg_n_0_[3] ),
        .O(bit_cnt[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h01)) 
    \bit_cnt[3]_i_3 
       (.I0(state__0[1]),
        .I1(state__0[2]),
        .I2(state__0[0]),
        .O(\bit_cnt[3]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \bit_cnt[3]_i_4 
       (.I0(tx_en_reg_reg),
        .I1(ps2_clk_en),
        .O(\bit_cnt[3]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'hFDDF)) 
    \bit_cnt[3]_i_5 
       (.I0(ps2_clk_prev),
        .I1(ps2_clk_sync),
        .I2(state__0[1]),
        .I3(state__0[0]),
        .O(\bit_cnt[3]_i_5_n_0 ));
  FDCE \bit_cnt_reg[0] 
       (.C(s_axi_aclk),
        .CE(\bit_cnt[3]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(bit_cnt[0]),
        .Q(\bit_cnt_reg_n_0_[0] ));
  FDCE \bit_cnt_reg[1] 
       (.C(s_axi_aclk),
        .CE(\bit_cnt[3]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\bit_cnt[1]_i_1_n_0 ),
        .Q(\bit_cnt_reg_n_0_[1] ));
  FDCE \bit_cnt_reg[2] 
       (.C(s_axi_aclk),
        .CE(\bit_cnt[3]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(bit_cnt[2]),
        .Q(\bit_cnt_reg_n_0_[2] ));
  FDCE \bit_cnt_reg[3] 
       (.C(s_axi_aclk),
        .CE(\bit_cnt[3]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(bit_cnt[3]),
        .Q(\bit_cnt_reg_n_0_[3] ));
  LUT4 #(
    .INIT(16'hC404)) 
    data_en_reg_i_1
       (.I0(data_en_reg_i_2_n_0),
        .I1(\FSM_sequential_state[2]_i_6_n_0 ),
        .I2(data_en_reg_i_3_n_0),
        .I3(ps2_data_en),
        .O(data_en_reg_i_1_n_0));
  LUT6 #(
    .INIT(64'h66000F0066FF0FFF)) 
    data_en_reg_i_2
       (.I0(data_en_reg_i_4_n_0),
        .I1(data_en_reg_i_5_n_0),
        .I2(\tx_shift_reg_reg_n_0_[0] ),
        .I3(state__0[1]),
        .I4(state__0[0]),
        .I5(tx_active_i_3_n_0),
        .O(data_en_reg_i_2_n_0));
  LUT6 #(
    .INIT(64'hFFFFFF0DFF00F00D)) 
    data_en_reg_i_3
       (.I0(tx_en_reg_reg),
        .I1(ps2_clk_en),
        .I2(state__0[0]),
        .I3(state__0[2]),
        .I4(state__0[1]),
        .I5(\FSM_sequential_state[1]_i_2_n_0 ),
        .O(data_en_reg_i_3_n_0));
  LUT4 #(
    .INIT(16'h6996)) 
    data_en_reg_i_4
       (.I0(\tx_shift_reg_reg[7]_0 [3]),
        .I1(\tx_shift_reg_reg[7]_0 [2]),
        .I2(\tx_shift_reg_reg[7]_0 [1]),
        .I3(\tx_shift_reg_reg[7]_0 [0]),
        .O(data_en_reg_i_4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    data_en_reg_i_5
       (.I0(\tx_shift_reg_reg[7]_0 [7]),
        .I1(\tx_shift_reg_reg[7]_0 [6]),
        .I2(\tx_shift_reg_reg[7]_0 [5]),
        .I3(\tx_shift_reg_reg[7]_0 [4]),
        .O(data_en_reg_i_5_n_0));
  FDCE data_en_reg_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(data_en_reg_i_1_n_0),
        .Q(ps2_data_en));
  LUT6 #(
    .INIT(64'hBFFFFFFF80000000)) 
    parity_err_reg_i_1
       (.I0(parity_err_reg_i_2_n_0),
        .I1(\FSM_sequential_state[2]_i_6_n_0 ),
        .I2(tx_active_i_3_n_0),
        .I3(state__0[0]),
        .I4(state__0[1]),
        .I5(parity_err_reg),
        .O(parity_err_reg_i_1_n_0));
  LUT6 #(
    .INIT(64'h9669699669969669)) 
    parity_err_reg_i_2
       (.I0(ps2_data_sync),
        .I1(parity_err_reg_i_3_n_0),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(Q[3]),
        .I5(Q[2]),
        .O(parity_err_reg_i_2_n_0));
  LUT4 #(
    .INIT(16'h6996)) 
    parity_err_reg_i_3
       (.I0(Q[5]),
        .I1(Q[4]),
        .I2(Q[7]),
        .I3(Q[6]),
        .O(parity_err_reg_i_3_n_0));
  FDCE parity_err_reg_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(parity_err_reg_i_1_n_0),
        .Q(parity_err_reg));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    ps2_clk_INST_0
       (.I0(1'b0),
        .I1(ps2_clk_en),
        .I2(1'b0),
        .I3(1'b0),
        .I4(1'b0),
        .I5(1'b0),
        .O(ps2_clk));
  FDPE ps2_clk_meta_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ps2_clk),
        .PRE(\FSM_sequential_state[2]_i_2_n_0 ),
        .Q(ps2_clk_meta));
  FDPE ps2_clk_prev_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ps2_clk_sync),
        .PRE(\FSM_sequential_state[2]_i_2_n_0 ),
        .Q(ps2_clk_prev));
  FDPE ps2_clk_sync_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ps2_clk_meta),
        .PRE(\FSM_sequential_state[2]_i_2_n_0 ),
        .Q(ps2_clk_sync));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    ps2_data_INST_0
       (.I0(1'b0),
        .I1(ps2_data_en),
        .I2(1'b0),
        .I3(1'b0),
        .I4(1'b0),
        .I5(1'b0),
        .O(ps2_data));
  FDPE ps2_data_meta_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ps2_data),
        .PRE(\FSM_sequential_state[2]_i_2_n_0 ),
        .Q(ps2_data_meta));
  FDPE ps2_data_sync_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ps2_data_meta),
        .PRE(\FSM_sequential_state[2]_i_2_n_0 ),
        .Q(ps2_data_sync));
  LUT6 #(
    .INIT(64'h8888CC8C88880080)) 
    \r_data_reg[2]_i_1 
       (.I0(\r_data_reg_reg[2] ),
        .I1(rx_data_new_reg),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[0]),
        .I4(s_axi_araddr[1]),
        .I5(\r_data_reg[2]_i_3_n_0 ),
        .O(D));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h0838)) 
    \r_data_reg[2]_i_3 
       (.I0(\r_data_reg_reg[2]_0 ),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(ps2_clk_en),
        .O(\r_data_reg[2]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hEFAA)) 
    rx_data_new_i_1
       (.I0(E),
        .I1(rx_data_new_reg_0),
        .I2(rx_data_new_reg),
        .I3(rx_data_new),
        .O(rx_valid_reg_reg_0));
  LUT6 #(
    .INIT(64'h0000008000800000)) 
    \rx_shift_reg[7]_i_1 
       (.I0(\FSM_sequential_state[2]_i_6_n_0 ),
        .I1(state__0[2]),
        .I2(ps2_clk_prev),
        .I3(ps2_clk_sync),
        .I4(state__0[1]),
        .I5(state__0[0]),
        .O(\rx_shift_reg[7]_i_1_n_0 ));
  FDCE \rx_shift_reg_reg[0] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(Q[1]),
        .Q(Q[0]));
  FDCE \rx_shift_reg_reg[1] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(Q[2]),
        .Q(Q[1]));
  FDCE \rx_shift_reg_reg[2] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(Q[3]),
        .Q(Q[2]));
  FDCE \rx_shift_reg_reg[3] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(Q[4]),
        .Q(Q[3]));
  FDCE \rx_shift_reg_reg[4] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(Q[5]),
        .Q(Q[4]));
  FDCE \rx_shift_reg_reg[5] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(Q[6]),
        .Q(Q[5]));
  FDCE \rx_shift_reg_reg[6] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(Q[7]),
        .Q(Q[6]));
  FDCE \rx_shift_reg_reg[7] 
       (.C(s_axi_aclk),
        .CE(\rx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(ps2_data_sync),
        .Q(Q[7]));
  LUT6 #(
    .INIT(64'h0080000000000000)) 
    rx_valid_reg_i_1
       (.I0(\FSM_sequential_state[2]_i_6_n_0 ),
        .I1(state__0[2]),
        .I2(ps2_clk_prev),
        .I3(ps2_clk_sync),
        .I4(state__0[0]),
        .I5(state__0[1]),
        .O(rx_valid_reg_i_1_n_0));
  FDCE rx_valid_reg_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(rx_valid_reg_i_1_n_0),
        .Q(E));
  LUT5 #(
    .INIT(32'hDDDDDDD0)) 
    \timeout_cnt[0]_i_2 
       (.I0(ps2_clk_prev),
        .I1(ps2_clk_sync),
        .I2(state__0[0]),
        .I3(state__0[2]),
        .I4(state__0[1]),
        .O(\timeout_cnt[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[0]_i_3 
       (.I0(\timeout_cnt_reg_n_0_[3] ),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[0]_i_4 
       (.I0(\timeout_cnt_reg_n_0_[2] ),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[0]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[0]_i_5 
       (.I0(\timeout_cnt_reg_n_0_[1] ),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[0]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h5554000055545554)) 
    \timeout_cnt[0]_i_6 
       (.I0(\timeout_cnt_reg_n_0_[0] ),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[0]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[12]_i_2 
       (.I0(timeout_cnt_reg[15]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[12]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[12]_i_3 
       (.I0(timeout_cnt_reg[14]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[12]_i_4 
       (.I0(timeout_cnt_reg[13]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[12]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[12]_i_5 
       (.I0(timeout_cnt_reg[12]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[12]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[16]_i_2 
       (.I0(timeout_cnt_reg[19]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[16]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[16]_i_3 
       (.I0(timeout_cnt_reg[18]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[16]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[16]_i_4 
       (.I0(timeout_cnt_reg[17]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[16]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[16]_i_5 
       (.I0(timeout_cnt_reg[16]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[16]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[4]_i_2 
       (.I0(timeout_cnt_reg[7]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[4]_i_3 
       (.I0(timeout_cnt_reg[6]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[4]_i_4 
       (.I0(\timeout_cnt_reg_n_0_[5] ),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[4]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[4]_i_5 
       (.I0(\timeout_cnt_reg_n_0_[4] ),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[4]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[8]_i_2 
       (.I0(timeout_cnt_reg[11]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[8]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[8]_i_3 
       (.I0(timeout_cnt_reg[10]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[8]_i_4 
       (.I0(timeout_cnt_reg[9]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[8]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAAA80000AAA8AAA8)) 
    \timeout_cnt[8]_i_5 
       (.I0(timeout_cnt_reg[8]),
        .I1(state__0[1]),
        .I2(state__0[2]),
        .I3(state__0[0]),
        .I4(ps2_clk_sync),
        .I5(ps2_clk_prev),
        .O(\timeout_cnt[8]_i_5_n_0 ));
  FDCE \timeout_cnt_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[0]_i_1_n_7 ),
        .Q(\timeout_cnt_reg_n_0_[0] ));
  CARRY4 \timeout_cnt_reg[0]_i_1 
       (.CI(1'b0),
        .CO({\timeout_cnt_reg[0]_i_1_n_0 ,\timeout_cnt_reg[0]_i_1_n_1 ,\timeout_cnt_reg[0]_i_1_n_2 ,\timeout_cnt_reg[0]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\timeout_cnt[0]_i_2_n_0 }),
        .O({\timeout_cnt_reg[0]_i_1_n_4 ,\timeout_cnt_reg[0]_i_1_n_5 ,\timeout_cnt_reg[0]_i_1_n_6 ,\timeout_cnt_reg[0]_i_1_n_7 }),
        .S({\timeout_cnt[0]_i_3_n_0 ,\timeout_cnt[0]_i_4_n_0 ,\timeout_cnt[0]_i_5_n_0 ,\timeout_cnt[0]_i_6_n_0 }));
  FDCE \timeout_cnt_reg[10] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[8]_i_1_n_5 ),
        .Q(timeout_cnt_reg[10]));
  FDCE \timeout_cnt_reg[11] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[8]_i_1_n_4 ),
        .Q(timeout_cnt_reg[11]));
  FDCE \timeout_cnt_reg[12] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[12]_i_1_n_7 ),
        .Q(timeout_cnt_reg[12]));
  CARRY4 \timeout_cnt_reg[12]_i_1 
       (.CI(\timeout_cnt_reg[8]_i_1_n_0 ),
        .CO({\timeout_cnt_reg[12]_i_1_n_0 ,\timeout_cnt_reg[12]_i_1_n_1 ,\timeout_cnt_reg[12]_i_1_n_2 ,\timeout_cnt_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\timeout_cnt_reg[12]_i_1_n_4 ,\timeout_cnt_reg[12]_i_1_n_5 ,\timeout_cnt_reg[12]_i_1_n_6 ,\timeout_cnt_reg[12]_i_1_n_7 }),
        .S({\timeout_cnt[12]_i_2_n_0 ,\timeout_cnt[12]_i_3_n_0 ,\timeout_cnt[12]_i_4_n_0 ,\timeout_cnt[12]_i_5_n_0 }));
  FDCE \timeout_cnt_reg[13] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[12]_i_1_n_6 ),
        .Q(timeout_cnt_reg[13]));
  FDCE \timeout_cnt_reg[14] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[12]_i_1_n_5 ),
        .Q(timeout_cnt_reg[14]));
  FDCE \timeout_cnt_reg[15] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[12]_i_1_n_4 ),
        .Q(timeout_cnt_reg[15]));
  FDCE \timeout_cnt_reg[16] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[16]_i_1_n_7 ),
        .Q(timeout_cnt_reg[16]));
  CARRY4 \timeout_cnt_reg[16]_i_1 
       (.CI(\timeout_cnt_reg[12]_i_1_n_0 ),
        .CO({\NLW_timeout_cnt_reg[16]_i_1_CO_UNCONNECTED [3],\timeout_cnt_reg[16]_i_1_n_1 ,\timeout_cnt_reg[16]_i_1_n_2 ,\timeout_cnt_reg[16]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\timeout_cnt_reg[16]_i_1_n_4 ,\timeout_cnt_reg[16]_i_1_n_5 ,\timeout_cnt_reg[16]_i_1_n_6 ,\timeout_cnt_reg[16]_i_1_n_7 }),
        .S({\timeout_cnt[16]_i_2_n_0 ,\timeout_cnt[16]_i_3_n_0 ,\timeout_cnt[16]_i_4_n_0 ,\timeout_cnt[16]_i_5_n_0 }));
  FDCE \timeout_cnt_reg[17] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[16]_i_1_n_6 ),
        .Q(timeout_cnt_reg[17]));
  FDCE \timeout_cnt_reg[18] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[16]_i_1_n_5 ),
        .Q(timeout_cnt_reg[18]));
  FDCE \timeout_cnt_reg[19] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[16]_i_1_n_4 ),
        .Q(timeout_cnt_reg[19]));
  FDCE \timeout_cnt_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[0]_i_1_n_6 ),
        .Q(\timeout_cnt_reg_n_0_[1] ));
  FDCE \timeout_cnt_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[0]_i_1_n_5 ),
        .Q(\timeout_cnt_reg_n_0_[2] ));
  FDCE \timeout_cnt_reg[3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[0]_i_1_n_4 ),
        .Q(\timeout_cnt_reg_n_0_[3] ));
  FDCE \timeout_cnt_reg[4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[4]_i_1_n_7 ),
        .Q(\timeout_cnt_reg_n_0_[4] ));
  CARRY4 \timeout_cnt_reg[4]_i_1 
       (.CI(\timeout_cnt_reg[0]_i_1_n_0 ),
        .CO({\timeout_cnt_reg[4]_i_1_n_0 ,\timeout_cnt_reg[4]_i_1_n_1 ,\timeout_cnt_reg[4]_i_1_n_2 ,\timeout_cnt_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\timeout_cnt_reg[4]_i_1_n_4 ,\timeout_cnt_reg[4]_i_1_n_5 ,\timeout_cnt_reg[4]_i_1_n_6 ,\timeout_cnt_reg[4]_i_1_n_7 }),
        .S({\timeout_cnt[4]_i_2_n_0 ,\timeout_cnt[4]_i_3_n_0 ,\timeout_cnt[4]_i_4_n_0 ,\timeout_cnt[4]_i_5_n_0 }));
  FDCE \timeout_cnt_reg[5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[4]_i_1_n_6 ),
        .Q(\timeout_cnt_reg_n_0_[5] ));
  FDCE \timeout_cnt_reg[6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[4]_i_1_n_5 ),
        .Q(timeout_cnt_reg[6]));
  FDCE \timeout_cnt_reg[7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[4]_i_1_n_4 ),
        .Q(timeout_cnt_reg[7]));
  FDCE \timeout_cnt_reg[8] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[8]_i_1_n_7 ),
        .Q(timeout_cnt_reg[8]));
  CARRY4 \timeout_cnt_reg[8]_i_1 
       (.CI(\timeout_cnt_reg[4]_i_1_n_0 ),
        .CO({\timeout_cnt_reg[8]_i_1_n_0 ,\timeout_cnt_reg[8]_i_1_n_1 ,\timeout_cnt_reg[8]_i_1_n_2 ,\timeout_cnt_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\timeout_cnt_reg[8]_i_1_n_4 ,\timeout_cnt_reg[8]_i_1_n_5 ,\timeout_cnt_reg[8]_i_1_n_6 ,\timeout_cnt_reg[8]_i_1_n_7 }),
        .S({\timeout_cnt[8]_i_2_n_0 ,\timeout_cnt[8]_i_3_n_0 ,\timeout_cnt[8]_i_4_n_0 ,\timeout_cnt[8]_i_5_n_0 }));
  FDCE \timeout_cnt_reg[9] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(\timeout_cnt_reg[8]_i_1_n_6 ),
        .Q(timeout_cnt_reg[9]));
  LUT6 #(
    .INIT(64'hFFF7000000050000)) 
    tx_active_i_1
       (.I0(tx_active_i_2_n_0),
        .I1(tx_active_i_3_n_0),
        .I2(state__0[0]),
        .I3(state__0[1]),
        .I4(\FSM_sequential_state[2]_i_6_n_0 ),
        .I5(ps2_clk_en),
        .O(tx_active_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hEF)) 
    tx_active_i_2
       (.I0(state__0[2]),
        .I1(ps2_clk_en),
        .I2(tx_en_reg_reg),
        .O(tx_active_i_2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h08)) 
    tx_active_i_3
       (.I0(state__0[2]),
        .I1(ps2_clk_prev),
        .I2(ps2_clk_sync),
        .O(tx_active_i_3_n_0));
  FDCE tx_active_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_active_i_1_n_0),
        .Q(ps2_clk_en));
  LUT6 #(
    .INIT(64'h0000000001000000)) 
    \tx_data_reg[7]_i_1 
       (.I0(\bit_cnt[3]_i_4_n_0 ),
        .I1(s_axi_awaddr[3]),
        .I2(s_axi_awaddr[0]),
        .I3(s_axi_awaddr[2]),
        .I4(s_axi_awaddr[1]),
        .I5(tx_en_reg_reg_0),
        .O(\s_axi_awaddr[5] ));
  LUT6 #(
    .INIT(64'h88888888B8888888)) 
    tx_en_reg_i_1
       (.I0(ps2_clk_en),
        .I1(tx_en_reg_reg),
        .I2(tx_en_reg_reg_1),
        .I3(s_axi_awaddr[2]),
        .I4(s_axi_awaddr[1]),
        .I5(tx_en_reg_reg_0),
        .O(tx_active_reg_0));
  LUT3 #(
    .INIT(8'hB8)) 
    \tx_shift_reg[0]_i_1 
       (.I0(\tx_shift_reg_reg_n_0_[1] ),
        .I1(state__0[1]),
        .I2(\tx_shift_reg_reg[7]_0 [0]),
        .O(tx_shift_reg[0]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \tx_shift_reg[1]_i_1 
       (.I0(\tx_shift_reg_reg_n_0_[2] ),
        .I1(state__0[1]),
        .I2(\tx_shift_reg_reg[7]_0 [1]),
        .O(tx_shift_reg[1]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \tx_shift_reg[2]_i_1 
       (.I0(\tx_shift_reg_reg_n_0_[3] ),
        .I1(state__0[1]),
        .I2(\tx_shift_reg_reg[7]_0 [2]),
        .O(tx_shift_reg[2]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \tx_shift_reg[3]_i_1 
       (.I0(\tx_shift_reg_reg_n_0_[4] ),
        .I1(state__0[1]),
        .I2(\tx_shift_reg_reg[7]_0 [3]),
        .O(tx_shift_reg[3]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \tx_shift_reg[4]_i_1 
       (.I0(\tx_shift_reg_reg_n_0_[5] ),
        .I1(state__0[1]),
        .I2(\tx_shift_reg_reg[7]_0 [4]),
        .O(tx_shift_reg[4]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \tx_shift_reg[5]_i_1 
       (.I0(\tx_shift_reg_reg_n_0_[6] ),
        .I1(state__0[1]),
        .I2(\tx_shift_reg_reg[7]_0 [5]),
        .O(tx_shift_reg[5]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \tx_shift_reg[6]_i_1 
       (.I0(\tx_shift_reg_reg_n_0_[7] ),
        .I1(state__0[1]),
        .I2(\tx_shift_reg_reg[7]_0 [6]),
        .O(tx_shift_reg[6]));
  LUT6 #(
    .INIT(64'h0002000002020200)) 
    \tx_shift_reg[7]_i_1 
       (.I0(\FSM_sequential_state[2]_i_6_n_0 ),
        .I1(state__0[0]),
        .I2(state__0[2]),
        .I3(state__0[1]),
        .I4(\bit_cnt[3]_i_4_n_0 ),
        .I5(\FSM_sequential_state[1]_i_2_n_0 ),
        .O(\tx_shift_reg[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \tx_shift_reg[7]_i_2 
       (.I0(\tx_shift_reg_reg[7]_0 [7]),
        .I1(state__0[1]),
        .O(tx_shift_reg[7]));
  FDCE \tx_shift_reg_reg[0] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[0]),
        .Q(\tx_shift_reg_reg_n_0_[0] ));
  FDCE \tx_shift_reg_reg[1] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[1]),
        .Q(\tx_shift_reg_reg_n_0_[1] ));
  FDCE \tx_shift_reg_reg[2] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[2]),
        .Q(\tx_shift_reg_reg_n_0_[2] ));
  FDCE \tx_shift_reg_reg[3] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[3]),
        .Q(\tx_shift_reg_reg_n_0_[3] ));
  FDCE \tx_shift_reg_reg[4] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[4]),
        .Q(\tx_shift_reg_reg_n_0_[4] ));
  FDCE \tx_shift_reg_reg[5] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[5]),
        .Q(\tx_shift_reg_reg_n_0_[5] ));
  FDCE \tx_shift_reg_reg[6] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[6]),
        .Q(\tx_shift_reg_reg_n_0_[6] ));
  FDCE \tx_shift_reg_reg[7] 
       (.C(s_axi_aclk),
        .CE(\tx_shift_reg[7]_i_1_n_0 ),
        .CLR(\FSM_sequential_state[2]_i_2_n_0 ),
        .D(tx_shift_reg[7]),
        .Q(\tx_shift_reg_reg_n_0_[7] ));
endmodule

(* ORIG_REF_NAME = "ps2_host_axi" *) 
module design_1_ps2_host_axi_0_0_ps2_host_axi
   (s_axi_rdata,
    E,
    s_axi_awready,
    s_axi_bvalid,
    r_valid_reg_reg_0,
    ps2_clk,
    ps2_data,
    s_axi_awaddr,
    s_axi_aclk,
    s_axi_wdata,
    s_axi_wvalid,
    s_axi_awvalid,
    s_axi_araddr,
    s_axi_arvalid,
    rst_n,
    s_axi_bready,
    s_axi_rready);
  output [31:0]s_axi_rdata;
  output [0:0]E;
  output s_axi_awready;
  output s_axi_bvalid;
  output r_valid_reg_reg_0;
  inout ps2_clk;
  inout ps2_data;
  input [7:0]s_axi_awaddr;
  input s_axi_aclk;
  input [7:0]s_axi_wdata;
  input s_axi_wvalid;
  input s_axi_awvalid;
  input [7:0]s_axi_araddr;
  input s_axi_arvalid;
  input rst_n;
  input s_axi_bready;
  input s_axi_rready;

  wire [0:0]E;
  wire b_valid_reg_i_1_n_0;
  wire b_valid_reg_i_2_n_0;
  wire [31:0]data3;
  wire [31:0]data5;
  wire parity_err_latched;
  wire parity_err_reg;
  wire ps2_clk;
  wire ps2_data;
  wire ps2_rx_valid;
  wire \r_data_reg[0]_i_1_n_0 ;
  wire \r_data_reg[0]_i_2_n_0 ;
  wire \r_data_reg[0]_i_3_n_0 ;
  wire \r_data_reg[10]_i_1_n_0 ;
  wire \r_data_reg[10]_i_2_n_0 ;
  wire \r_data_reg[11]_i_1_n_0 ;
  wire \r_data_reg[11]_i_2_n_0 ;
  wire \r_data_reg[12]_i_1_n_0 ;
  wire \r_data_reg[12]_i_2_n_0 ;
  wire \r_data_reg[13]_i_1_n_0 ;
  wire \r_data_reg[13]_i_2_n_0 ;
  wire \r_data_reg[14]_i_1_n_0 ;
  wire \r_data_reg[14]_i_2_n_0 ;
  wire \r_data_reg[15]_i_1_n_0 ;
  wire \r_data_reg[15]_i_2_n_0 ;
  wire \r_data_reg[16]_i_1_n_0 ;
  wire \r_data_reg[16]_i_2_n_0 ;
  wire \r_data_reg[17]_i_1_n_0 ;
  wire \r_data_reg[17]_i_2_n_0 ;
  wire \r_data_reg[18]_i_1_n_0 ;
  wire \r_data_reg[18]_i_2_n_0 ;
  wire \r_data_reg[19]_i_1_n_0 ;
  wire \r_data_reg[19]_i_2_n_0 ;
  wire \r_data_reg[1]_i_1_n_0 ;
  wire \r_data_reg[1]_i_2_n_0 ;
  wire \r_data_reg[1]_i_3_n_0 ;
  wire \r_data_reg[20]_i_1_n_0 ;
  wire \r_data_reg[20]_i_2_n_0 ;
  wire \r_data_reg[21]_i_1_n_0 ;
  wire \r_data_reg[21]_i_2_n_0 ;
  wire \r_data_reg[22]_i_1_n_0 ;
  wire \r_data_reg[22]_i_2_n_0 ;
  wire \r_data_reg[23]_i_1_n_0 ;
  wire \r_data_reg[23]_i_2_n_0 ;
  wire \r_data_reg[24]_i_1_n_0 ;
  wire \r_data_reg[24]_i_2_n_0 ;
  wire \r_data_reg[25]_i_1_n_0 ;
  wire \r_data_reg[25]_i_2_n_0 ;
  wire \r_data_reg[26]_i_1_n_0 ;
  wire \r_data_reg[26]_i_2_n_0 ;
  wire \r_data_reg[27]_i_1_n_0 ;
  wire \r_data_reg[27]_i_2_n_0 ;
  wire \r_data_reg[28]_i_1_n_0 ;
  wire \r_data_reg[28]_i_2_n_0 ;
  wire \r_data_reg[28]_i_3_n_0 ;
  wire \r_data_reg[29]_i_1_n_0 ;
  wire \r_data_reg[29]_i_2_n_0 ;
  wire \r_data_reg[2]_i_2_n_0 ;
  wire \r_data_reg[30]_i_1_n_0 ;
  wire \r_data_reg[30]_i_2_n_0 ;
  wire \r_data_reg[31]_i_1_n_0 ;
  wire \r_data_reg[31]_i_2_n_0 ;
  wire \r_data_reg[31]_i_3_n_0 ;
  wire \r_data_reg[3]_i_1_n_0 ;
  wire \r_data_reg[3]_i_2_n_0 ;
  wire \r_data_reg[4]_i_1_n_0 ;
  wire \r_data_reg[4]_i_2_n_0 ;
  wire \r_data_reg[5]_i_1_n_0 ;
  wire \r_data_reg[5]_i_2_n_0 ;
  wire \r_data_reg[6]_i_1_n_0 ;
  wire \r_data_reg[6]_i_2_n_0 ;
  wire \r_data_reg[7]_i_1_n_0 ;
  wire \r_data_reg[7]_i_2_n_0 ;
  wire \r_data_reg[8]_i_1_n_0 ;
  wire \r_data_reg[8]_i_2_n_0 ;
  wire \r_data_reg[9]_i_1_n_0 ;
  wire \r_data_reg[9]_i_2_n_0 ;
  wire r_valid_reg_i_1_n_0;
  wire r_valid_reg_reg_0;
  wire rst_n;
  wire [7:0]rx_data_latched;
  wire rx_data_new;
  wire rx_data_new_i_2_n_0;
  wire [7:0]rx_shift_reg;
  wire s_axi_aclk;
  wire [7:0]s_axi_araddr;
  wire s_axi_arvalid;
  wire [7:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire s_axi_rready;
  wire [7:0]s_axi_wdata;
  wire s_axi_wvalid;
  wire soft_rst_n;
  wire soft_rst_n_i_1_n_0;
  wire soft_rst_n_i_2_n_0;
  wire \ts_counter[0]_i_2_n_0 ;
  wire \ts_counter_reg[0]_i_1_n_0 ;
  wire \ts_counter_reg[0]_i_1_n_1 ;
  wire \ts_counter_reg[0]_i_1_n_2 ;
  wire \ts_counter_reg[0]_i_1_n_3 ;
  wire \ts_counter_reg[0]_i_1_n_4 ;
  wire \ts_counter_reg[0]_i_1_n_5 ;
  wire \ts_counter_reg[0]_i_1_n_6 ;
  wire \ts_counter_reg[0]_i_1_n_7 ;
  wire \ts_counter_reg[12]_i_1_n_0 ;
  wire \ts_counter_reg[12]_i_1_n_1 ;
  wire \ts_counter_reg[12]_i_1_n_2 ;
  wire \ts_counter_reg[12]_i_1_n_3 ;
  wire \ts_counter_reg[12]_i_1_n_4 ;
  wire \ts_counter_reg[12]_i_1_n_5 ;
  wire \ts_counter_reg[12]_i_1_n_6 ;
  wire \ts_counter_reg[12]_i_1_n_7 ;
  wire \ts_counter_reg[16]_i_1_n_0 ;
  wire \ts_counter_reg[16]_i_1_n_1 ;
  wire \ts_counter_reg[16]_i_1_n_2 ;
  wire \ts_counter_reg[16]_i_1_n_3 ;
  wire \ts_counter_reg[16]_i_1_n_4 ;
  wire \ts_counter_reg[16]_i_1_n_5 ;
  wire \ts_counter_reg[16]_i_1_n_6 ;
  wire \ts_counter_reg[16]_i_1_n_7 ;
  wire \ts_counter_reg[20]_i_1_n_0 ;
  wire \ts_counter_reg[20]_i_1_n_1 ;
  wire \ts_counter_reg[20]_i_1_n_2 ;
  wire \ts_counter_reg[20]_i_1_n_3 ;
  wire \ts_counter_reg[20]_i_1_n_4 ;
  wire \ts_counter_reg[20]_i_1_n_5 ;
  wire \ts_counter_reg[20]_i_1_n_6 ;
  wire \ts_counter_reg[20]_i_1_n_7 ;
  wire \ts_counter_reg[24]_i_1_n_0 ;
  wire \ts_counter_reg[24]_i_1_n_1 ;
  wire \ts_counter_reg[24]_i_1_n_2 ;
  wire \ts_counter_reg[24]_i_1_n_3 ;
  wire \ts_counter_reg[24]_i_1_n_4 ;
  wire \ts_counter_reg[24]_i_1_n_5 ;
  wire \ts_counter_reg[24]_i_1_n_6 ;
  wire \ts_counter_reg[24]_i_1_n_7 ;
  wire \ts_counter_reg[28]_i_1_n_0 ;
  wire \ts_counter_reg[28]_i_1_n_1 ;
  wire \ts_counter_reg[28]_i_1_n_2 ;
  wire \ts_counter_reg[28]_i_1_n_3 ;
  wire \ts_counter_reg[28]_i_1_n_4 ;
  wire \ts_counter_reg[28]_i_1_n_5 ;
  wire \ts_counter_reg[28]_i_1_n_6 ;
  wire \ts_counter_reg[28]_i_1_n_7 ;
  wire \ts_counter_reg[32]_i_1_n_0 ;
  wire \ts_counter_reg[32]_i_1_n_1 ;
  wire \ts_counter_reg[32]_i_1_n_2 ;
  wire \ts_counter_reg[32]_i_1_n_3 ;
  wire \ts_counter_reg[32]_i_1_n_4 ;
  wire \ts_counter_reg[32]_i_1_n_5 ;
  wire \ts_counter_reg[32]_i_1_n_6 ;
  wire \ts_counter_reg[32]_i_1_n_7 ;
  wire \ts_counter_reg[36]_i_1_n_0 ;
  wire \ts_counter_reg[36]_i_1_n_1 ;
  wire \ts_counter_reg[36]_i_1_n_2 ;
  wire \ts_counter_reg[36]_i_1_n_3 ;
  wire \ts_counter_reg[36]_i_1_n_4 ;
  wire \ts_counter_reg[36]_i_1_n_5 ;
  wire \ts_counter_reg[36]_i_1_n_6 ;
  wire \ts_counter_reg[36]_i_1_n_7 ;
  wire \ts_counter_reg[40]_i_1_n_0 ;
  wire \ts_counter_reg[40]_i_1_n_1 ;
  wire \ts_counter_reg[40]_i_1_n_2 ;
  wire \ts_counter_reg[40]_i_1_n_3 ;
  wire \ts_counter_reg[40]_i_1_n_4 ;
  wire \ts_counter_reg[40]_i_1_n_5 ;
  wire \ts_counter_reg[40]_i_1_n_6 ;
  wire \ts_counter_reg[40]_i_1_n_7 ;
  wire \ts_counter_reg[44]_i_1_n_0 ;
  wire \ts_counter_reg[44]_i_1_n_1 ;
  wire \ts_counter_reg[44]_i_1_n_2 ;
  wire \ts_counter_reg[44]_i_1_n_3 ;
  wire \ts_counter_reg[44]_i_1_n_4 ;
  wire \ts_counter_reg[44]_i_1_n_5 ;
  wire \ts_counter_reg[44]_i_1_n_6 ;
  wire \ts_counter_reg[44]_i_1_n_7 ;
  wire \ts_counter_reg[48]_i_1_n_0 ;
  wire \ts_counter_reg[48]_i_1_n_1 ;
  wire \ts_counter_reg[48]_i_1_n_2 ;
  wire \ts_counter_reg[48]_i_1_n_3 ;
  wire \ts_counter_reg[48]_i_1_n_4 ;
  wire \ts_counter_reg[48]_i_1_n_5 ;
  wire \ts_counter_reg[48]_i_1_n_6 ;
  wire \ts_counter_reg[48]_i_1_n_7 ;
  wire \ts_counter_reg[4]_i_1_n_0 ;
  wire \ts_counter_reg[4]_i_1_n_1 ;
  wire \ts_counter_reg[4]_i_1_n_2 ;
  wire \ts_counter_reg[4]_i_1_n_3 ;
  wire \ts_counter_reg[4]_i_1_n_4 ;
  wire \ts_counter_reg[4]_i_1_n_5 ;
  wire \ts_counter_reg[4]_i_1_n_6 ;
  wire \ts_counter_reg[4]_i_1_n_7 ;
  wire \ts_counter_reg[52]_i_1_n_0 ;
  wire \ts_counter_reg[52]_i_1_n_1 ;
  wire \ts_counter_reg[52]_i_1_n_2 ;
  wire \ts_counter_reg[52]_i_1_n_3 ;
  wire \ts_counter_reg[52]_i_1_n_4 ;
  wire \ts_counter_reg[52]_i_1_n_5 ;
  wire \ts_counter_reg[52]_i_1_n_6 ;
  wire \ts_counter_reg[52]_i_1_n_7 ;
  wire \ts_counter_reg[56]_i_1_n_0 ;
  wire \ts_counter_reg[56]_i_1_n_1 ;
  wire \ts_counter_reg[56]_i_1_n_2 ;
  wire \ts_counter_reg[56]_i_1_n_3 ;
  wire \ts_counter_reg[56]_i_1_n_4 ;
  wire \ts_counter_reg[56]_i_1_n_5 ;
  wire \ts_counter_reg[56]_i_1_n_6 ;
  wire \ts_counter_reg[56]_i_1_n_7 ;
  wire \ts_counter_reg[60]_i_1_n_1 ;
  wire \ts_counter_reg[60]_i_1_n_2 ;
  wire \ts_counter_reg[60]_i_1_n_3 ;
  wire \ts_counter_reg[60]_i_1_n_4 ;
  wire \ts_counter_reg[60]_i_1_n_5 ;
  wire \ts_counter_reg[60]_i_1_n_6 ;
  wire \ts_counter_reg[60]_i_1_n_7 ;
  wire \ts_counter_reg[8]_i_1_n_0 ;
  wire \ts_counter_reg[8]_i_1_n_1 ;
  wire \ts_counter_reg[8]_i_1_n_2 ;
  wire \ts_counter_reg[8]_i_1_n_3 ;
  wire \ts_counter_reg[8]_i_1_n_4 ;
  wire \ts_counter_reg[8]_i_1_n_5 ;
  wire \ts_counter_reg[8]_i_1_n_6 ;
  wire \ts_counter_reg[8]_i_1_n_7 ;
  wire \ts_counter_reg_n_0_[0] ;
  wire \ts_counter_reg_n_0_[10] ;
  wire \ts_counter_reg_n_0_[11] ;
  wire \ts_counter_reg_n_0_[12] ;
  wire \ts_counter_reg_n_0_[13] ;
  wire \ts_counter_reg_n_0_[14] ;
  wire \ts_counter_reg_n_0_[15] ;
  wire \ts_counter_reg_n_0_[16] ;
  wire \ts_counter_reg_n_0_[17] ;
  wire \ts_counter_reg_n_0_[18] ;
  wire \ts_counter_reg_n_0_[19] ;
  wire \ts_counter_reg_n_0_[1] ;
  wire \ts_counter_reg_n_0_[20] ;
  wire \ts_counter_reg_n_0_[21] ;
  wire \ts_counter_reg_n_0_[22] ;
  wire \ts_counter_reg_n_0_[23] ;
  wire \ts_counter_reg_n_0_[24] ;
  wire \ts_counter_reg_n_0_[25] ;
  wire \ts_counter_reg_n_0_[26] ;
  wire \ts_counter_reg_n_0_[27] ;
  wire \ts_counter_reg_n_0_[28] ;
  wire \ts_counter_reg_n_0_[29] ;
  wire \ts_counter_reg_n_0_[2] ;
  wire \ts_counter_reg_n_0_[30] ;
  wire \ts_counter_reg_n_0_[31] ;
  wire \ts_counter_reg_n_0_[3] ;
  wire \ts_counter_reg_n_0_[4] ;
  wire \ts_counter_reg_n_0_[5] ;
  wire \ts_counter_reg_n_0_[6] ;
  wire \ts_counter_reg_n_0_[7] ;
  wire \ts_counter_reg_n_0_[8] ;
  wire \ts_counter_reg_n_0_[9] ;
  wire \ts_latched_reg_n_0_[0] ;
  wire \ts_latched_reg_n_0_[10] ;
  wire \ts_latched_reg_n_0_[11] ;
  wire \ts_latched_reg_n_0_[12] ;
  wire \ts_latched_reg_n_0_[13] ;
  wire \ts_latched_reg_n_0_[14] ;
  wire \ts_latched_reg_n_0_[15] ;
  wire \ts_latched_reg_n_0_[16] ;
  wire \ts_latched_reg_n_0_[17] ;
  wire \ts_latched_reg_n_0_[18] ;
  wire \ts_latched_reg_n_0_[19] ;
  wire \ts_latched_reg_n_0_[1] ;
  wire \ts_latched_reg_n_0_[20] ;
  wire \ts_latched_reg_n_0_[21] ;
  wire \ts_latched_reg_n_0_[22] ;
  wire \ts_latched_reg_n_0_[23] ;
  wire \ts_latched_reg_n_0_[24] ;
  wire \ts_latched_reg_n_0_[25] ;
  wire \ts_latched_reg_n_0_[26] ;
  wire \ts_latched_reg_n_0_[27] ;
  wire \ts_latched_reg_n_0_[28] ;
  wire \ts_latched_reg_n_0_[29] ;
  wire \ts_latched_reg_n_0_[2] ;
  wire \ts_latched_reg_n_0_[30] ;
  wire \ts_latched_reg_n_0_[31] ;
  wire \ts_latched_reg_n_0_[3] ;
  wire \ts_latched_reg_n_0_[4] ;
  wire \ts_latched_reg_n_0_[5] ;
  wire \ts_latched_reg_n_0_[6] ;
  wire \ts_latched_reg_n_0_[7] ;
  wire \ts_latched_reg_n_0_[8] ;
  wire \ts_latched_reg_n_0_[9] ;
  wire [7:0]tx_data_reg;
  wire \tx_data_reg[7]_i_2_n_0 ;
  wire tx_en_reg_reg_n_0;
  wire u_ps2_host_n_11;
  wire u_ps2_host_n_12;
  wire u_ps2_host_n_13;
  wire u_ps2_host_n_2;
  wire [3:3]\NLW_ts_counter_reg[60]_i_1_CO_UNCONNECTED ;

  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h7444)) 
    b_valid_reg_i_1
       (.I0(s_axi_bready),
        .I1(s_axi_bvalid),
        .I2(s_axi_awvalid),
        .I3(s_axi_wvalid),
        .O(b_valid_reg_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    b_valid_reg_i_2
       (.I0(rst_n),
        .O(b_valid_reg_i_2_n_0));
  FDCE b_valid_reg_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(b_valid_reg_i_1_n_0),
        .Q(s_axi_bvalid));
  FDCE parity_err_latched_reg
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(parity_err_reg),
        .Q(parity_err_latched));
  LUT6 #(
    .INIT(64'h8888CC8C88880080)) 
    \r_data_reg[0]_i_1 
       (.I0(\r_data_reg[0]_i_2_n_0 ),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[0]),
        .I4(s_axi_araddr[1]),
        .I5(\r_data_reg[0]_i_3_n_0 ),
        .O(\r_data_reg[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[0]_i_2 
       (.I0(data5[0]),
        .I1(\ts_counter_reg_n_0_[0] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[0] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[0]),
        .O(\r_data_reg[0]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h3808)) 
    \r_data_reg[0]_i_3 
       (.I0(rx_data_new),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[4]),
        .I3(data3[0]),
        .O(\r_data_reg[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h000000000088CCC0)) 
    \r_data_reg[10]_i_1 
       (.I0(data3[10]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\ts_counter_reg_n_0_[10] ),
        .I3(s_axi_araddr[2]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[10]_i_2_n_0 ),
        .O(\r_data_reg[10]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[10]_i_2 
       (.I0(data5[10]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[10] ),
        .O(\r_data_reg[10]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[11]_i_1 
       (.I0(\r_data_reg[11]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[11] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[11]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[11]_i_2 
       (.I0(data3[11]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[11] ),
        .O(\r_data_reg[11]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000000000088CCC0)) 
    \r_data_reg[12]_i_1 
       (.I0(data3[12]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\ts_counter_reg_n_0_[12] ),
        .I3(s_axi_araddr[2]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[12]_i_2_n_0 ),
        .O(\r_data_reg[12]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[12]_i_2 
       (.I0(data5[12]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[12] ),
        .O(\r_data_reg[12]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[13]_i_1 
       (.I0(\r_data_reg[13]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[13] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[13]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[13]_i_2 
       (.I0(data3[13]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[13] ),
        .O(\r_data_reg[13]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[14]_i_1 
       (.I0(\r_data_reg[14]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[14] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[14]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[14]_i_2 
       (.I0(data3[14]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[14] ),
        .O(\r_data_reg[14]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[15]_i_1 
       (.I0(\r_data_reg[15]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[15] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[15]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[15]_i_2 
       (.I0(data3[15]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[15] ),
        .O(\r_data_reg[15]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[16]_i_1 
       (.I0(\r_data_reg[16]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[16] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[16]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[16]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[16]_i_2 
       (.I0(data3[16]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[16] ),
        .O(\r_data_reg[16]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[17]_i_1 
       (.I0(\r_data_reg[17]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[17] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[17]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[17]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[17]_i_2 
       (.I0(data3[17]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[17] ),
        .O(\r_data_reg[17]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000000000088CCC0)) 
    \r_data_reg[18]_i_1 
       (.I0(data3[18]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\ts_counter_reg_n_0_[18] ),
        .I3(s_axi_araddr[2]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[18]_i_2_n_0 ),
        .O(\r_data_reg[18]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[18]_i_2 
       (.I0(data5[18]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[18] ),
        .O(\r_data_reg[18]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[19]_i_1 
       (.I0(\r_data_reg[19]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[19] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[19]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[19]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[19]_i_2 
       (.I0(data3[19]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[19] ),
        .O(\r_data_reg[19]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h8888CC8C88880080)) 
    \r_data_reg[1]_i_1 
       (.I0(\r_data_reg[1]_i_2_n_0 ),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[0]),
        .I4(s_axi_araddr[1]),
        .I5(\r_data_reg[1]_i_3_n_0 ),
        .O(\r_data_reg[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[1]_i_2 
       (.I0(data5[1]),
        .I1(\ts_counter_reg_n_0_[1] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[1] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[1]),
        .O(\r_data_reg[1]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h3808)) 
    \r_data_reg[1]_i_3 
       (.I0(parity_err_latched),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[4]),
        .I3(data3[1]),
        .O(\r_data_reg[1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h000008080C0C0C00)) 
    \r_data_reg[20]_i_1 
       (.I0(data3[20]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\r_data_reg[20]_i_2_n_0 ),
        .I3(\ts_counter_reg_n_0_[20] ),
        .I4(s_axi_araddr[2]),
        .I5(\r_data_reg[28]_i_2_n_0 ),
        .O(\r_data_reg[20]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[20]_i_2 
       (.I0(data5[20]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[20] ),
        .O(\r_data_reg[20]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000000000088CCC0)) 
    \r_data_reg[21]_i_1 
       (.I0(data3[21]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\ts_counter_reg_n_0_[21] ),
        .I3(s_axi_araddr[2]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[21]_i_2_n_0 ),
        .O(\r_data_reg[21]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[21]_i_2 
       (.I0(data5[21]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[21] ),
        .O(\r_data_reg[21]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000000000088CCC0)) 
    \r_data_reg[22]_i_1 
       (.I0(data3[22]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\ts_counter_reg_n_0_[22] ),
        .I3(s_axi_araddr[2]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[22]_i_2_n_0 ),
        .O(\r_data_reg[22]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[22]_i_2 
       (.I0(data5[22]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[22] ),
        .O(\r_data_reg[22]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000008080C0C0C00)) 
    \r_data_reg[23]_i_1 
       (.I0(data3[23]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\r_data_reg[23]_i_2_n_0 ),
        .I3(\ts_counter_reg_n_0_[23] ),
        .I4(s_axi_araddr[2]),
        .I5(\r_data_reg[28]_i_2_n_0 ),
        .O(\r_data_reg[23]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[23]_i_2 
       (.I0(data5[23]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[23] ),
        .O(\r_data_reg[23]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[24]_i_1 
       (.I0(\r_data_reg[24]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[24] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[24]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[24]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[24]_i_2 
       (.I0(data3[24]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[24] ),
        .O(\r_data_reg[24]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000008080C0C0C00)) 
    \r_data_reg[25]_i_1 
       (.I0(data3[25]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\r_data_reg[25]_i_2_n_0 ),
        .I3(\ts_counter_reg_n_0_[25] ),
        .I4(s_axi_araddr[2]),
        .I5(\r_data_reg[28]_i_2_n_0 ),
        .O(\r_data_reg[25]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[25]_i_2 
       (.I0(data5[25]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[25] ),
        .O(\r_data_reg[25]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000000000088CCC0)) 
    \r_data_reg[26]_i_1 
       (.I0(data3[26]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\ts_counter_reg_n_0_[26] ),
        .I3(s_axi_araddr[2]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[26]_i_2_n_0 ),
        .O(\r_data_reg[26]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[26]_i_2 
       (.I0(data5[26]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[26] ),
        .O(\r_data_reg[26]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[27]_i_1 
       (.I0(\r_data_reg[27]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[27] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[27]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[27]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[27]_i_2 
       (.I0(data3[27]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[27] ),
        .O(\r_data_reg[27]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000000000088CCC0)) 
    \r_data_reg[28]_i_1 
       (.I0(data3[28]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\ts_counter_reg_n_0_[28] ),
        .I3(s_axi_araddr[2]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[28]_i_3_n_0 ),
        .O(\r_data_reg[28]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h45)) 
    \r_data_reg[28]_i_2 
       (.I0(s_axi_araddr[1]),
        .I1(s_axi_araddr[0]),
        .I2(s_axi_araddr[3]),
        .O(\r_data_reg[28]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[28]_i_3 
       (.I0(data5[28]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[28] ),
        .O(\r_data_reg[28]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[29]_i_1 
       (.I0(\r_data_reg[29]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[29] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[29]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[29]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[29]_i_2 
       (.I0(data3[29]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[29] ),
        .O(\r_data_reg[29]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[2]_i_2 
       (.I0(data5[2]),
        .I1(\ts_counter_reg_n_0_[2] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[2] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[2]),
        .O(\r_data_reg[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[30]_i_1 
       (.I0(\r_data_reg[30]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[30] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[30]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[30]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[30]_i_2 
       (.I0(data3[30]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[30] ),
        .O(\r_data_reg[30]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[31]_i_1 
       (.I0(\r_data_reg[31]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[31] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[31]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[31]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[31]_i_2 
       (.I0(data3[31]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[31] ),
        .O(\r_data_reg[31]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h00000001)) 
    \r_data_reg[31]_i_3 
       (.I0(s_axi_araddr[7]),
        .I1(s_axi_araddr[5]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[6]),
        .O(\r_data_reg[31]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h3000AAAA00000000)) 
    \r_data_reg[3]_i_1 
       (.I0(\r_data_reg[3]_i_2_n_0 ),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[4]),
        .I3(data3[3]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[3]_i_2 
       (.I0(data5[3]),
        .I1(\ts_counter_reg_n_0_[3] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[3] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[3]),
        .O(\r_data_reg[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h3000AAAA00000000)) 
    \r_data_reg[4]_i_1 
       (.I0(\r_data_reg[4]_i_2_n_0 ),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[4]),
        .I3(data3[4]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[4]_i_2 
       (.I0(data5[4]),
        .I1(\ts_counter_reg_n_0_[4] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[4] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[4]),
        .O(\r_data_reg[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h3000AAAA00000000)) 
    \r_data_reg[5]_i_1 
       (.I0(\r_data_reg[5]_i_2_n_0 ),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[4]),
        .I3(data3[5]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[5]_i_2 
       (.I0(data5[5]),
        .I1(\ts_counter_reg_n_0_[5] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[5] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[5]),
        .O(\r_data_reg[5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h3000AAAA00000000)) 
    \r_data_reg[6]_i_1 
       (.I0(\r_data_reg[6]_i_2_n_0 ),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[4]),
        .I3(data3[6]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[6]_i_2 
       (.I0(data5[6]),
        .I1(\ts_counter_reg_n_0_[6] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[6] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[6]),
        .O(\r_data_reg[6]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h3000AAAA00000000)) 
    \r_data_reg[7]_i_1 
       (.I0(\r_data_reg[7]_i_2_n_0 ),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[4]),
        .I3(data3[7]),
        .I4(\r_data_reg[28]_i_2_n_0 ),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \r_data_reg[7]_i_2 
       (.I0(data5[7]),
        .I1(\ts_counter_reg_n_0_[7] ),
        .I2(s_axi_araddr[4]),
        .I3(\ts_latched_reg_n_0_[7] ),
        .I4(s_axi_araddr[2]),
        .I5(rx_data_latched[7]),
        .O(\r_data_reg[7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAA0A808000000000)) 
    \r_data_reg[8]_i_1 
       (.I0(\r_data_reg[8]_i_2_n_0 ),
        .I1(\ts_latched_reg_n_0_[8] ),
        .I2(s_axi_araddr[2]),
        .I3(data5[8]),
        .I4(s_axi_araddr[4]),
        .I5(\r_data_reg[31]_i_3_n_0 ),
        .O(\r_data_reg[8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hCFCCEFEECFCC2022)) 
    \r_data_reg[8]_i_2 
       (.I0(data3[8]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[2]),
        .I5(\ts_counter_reg_n_0_[8] ),
        .O(\r_data_reg[8]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h000008080C0C0C00)) 
    \r_data_reg[9]_i_1 
       (.I0(data3[9]),
        .I1(\r_data_reg[31]_i_3_n_0 ),
        .I2(\r_data_reg[9]_i_2_n_0 ),
        .I3(\ts_counter_reg_n_0_[9] ),
        .I4(s_axi_araddr[2]),
        .I5(\r_data_reg[28]_i_2_n_0 ),
        .O(\r_data_reg[9]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h4373)) 
    \r_data_reg[9]_i_2 
       (.I0(data5[9]),
        .I1(s_axi_araddr[4]),
        .I2(s_axi_araddr[2]),
        .I3(\ts_latched_reg_n_0_[9] ),
        .O(\r_data_reg[9]_i_2_n_0 ));
  FDCE \r_data_reg_reg[0] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[0]_i_1_n_0 ),
        .Q(s_axi_rdata[0]));
  FDCE \r_data_reg_reg[10] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[10]_i_1_n_0 ),
        .Q(s_axi_rdata[10]));
  FDCE \r_data_reg_reg[11] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[11]_i_1_n_0 ),
        .Q(s_axi_rdata[11]));
  FDCE \r_data_reg_reg[12] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[12]_i_1_n_0 ),
        .Q(s_axi_rdata[12]));
  FDCE \r_data_reg_reg[13] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[13]_i_1_n_0 ),
        .Q(s_axi_rdata[13]));
  FDCE \r_data_reg_reg[14] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[14]_i_1_n_0 ),
        .Q(s_axi_rdata[14]));
  FDCE \r_data_reg_reg[15] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[15]_i_1_n_0 ),
        .Q(s_axi_rdata[15]));
  FDCE \r_data_reg_reg[16] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[16]_i_1_n_0 ),
        .Q(s_axi_rdata[16]));
  FDCE \r_data_reg_reg[17] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[17]_i_1_n_0 ),
        .Q(s_axi_rdata[17]));
  FDCE \r_data_reg_reg[18] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[18]_i_1_n_0 ),
        .Q(s_axi_rdata[18]));
  FDCE \r_data_reg_reg[19] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[19]_i_1_n_0 ),
        .Q(s_axi_rdata[19]));
  FDCE \r_data_reg_reg[1] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[1]_i_1_n_0 ),
        .Q(s_axi_rdata[1]));
  FDCE \r_data_reg_reg[20] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[20]_i_1_n_0 ),
        .Q(s_axi_rdata[20]));
  FDCE \r_data_reg_reg[21] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[21]_i_1_n_0 ),
        .Q(s_axi_rdata[21]));
  FDCE \r_data_reg_reg[22] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[22]_i_1_n_0 ),
        .Q(s_axi_rdata[22]));
  FDCE \r_data_reg_reg[23] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[23]_i_1_n_0 ),
        .Q(s_axi_rdata[23]));
  FDCE \r_data_reg_reg[24] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[24]_i_1_n_0 ),
        .Q(s_axi_rdata[24]));
  FDCE \r_data_reg_reg[25] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[25]_i_1_n_0 ),
        .Q(s_axi_rdata[25]));
  FDCE \r_data_reg_reg[26] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[26]_i_1_n_0 ),
        .Q(s_axi_rdata[26]));
  FDCE \r_data_reg_reg[27] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[27]_i_1_n_0 ),
        .Q(s_axi_rdata[27]));
  FDCE \r_data_reg_reg[28] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[28]_i_1_n_0 ),
        .Q(s_axi_rdata[28]));
  FDCE \r_data_reg_reg[29] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[29]_i_1_n_0 ),
        .Q(s_axi_rdata[29]));
  FDCE \r_data_reg_reg[2] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(u_ps2_host_n_11),
        .Q(s_axi_rdata[2]));
  FDCE \r_data_reg_reg[30] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[30]_i_1_n_0 ),
        .Q(s_axi_rdata[30]));
  FDCE \r_data_reg_reg[31] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[31]_i_1_n_0 ),
        .Q(s_axi_rdata[31]));
  FDCE \r_data_reg_reg[3] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[3]_i_1_n_0 ),
        .Q(s_axi_rdata[3]));
  FDCE \r_data_reg_reg[4] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[4]_i_1_n_0 ),
        .Q(s_axi_rdata[4]));
  FDCE \r_data_reg_reg[5] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[5]_i_1_n_0 ),
        .Q(s_axi_rdata[5]));
  FDCE \r_data_reg_reg[6] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[6]_i_1_n_0 ),
        .Q(s_axi_rdata[6]));
  FDCE \r_data_reg_reg[7] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[7]_i_1_n_0 ),
        .Q(s_axi_rdata[7]));
  FDCE \r_data_reg_reg[8] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[8]_i_1_n_0 ),
        .Q(s_axi_rdata[8]));
  FDCE \r_data_reg_reg[9] 
       (.C(s_axi_aclk),
        .CE(E),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\r_data_reg[9]_i_1_n_0 ),
        .Q(s_axi_rdata[9]));
  LUT3 #(
    .INIT(8'h5C)) 
    r_valid_reg_i_1
       (.I0(s_axi_rready),
        .I1(s_axi_arvalid),
        .I2(r_valid_reg_reg_0),
        .O(r_valid_reg_i_1_n_0));
  FDCE r_valid_reg_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(r_valid_reg_i_1_n_0),
        .Q(r_valid_reg_reg_0));
  FDCE \rx_data_latched_reg[0] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[0]),
        .Q(rx_data_latched[0]));
  FDCE \rx_data_latched_reg[1] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[1]),
        .Q(rx_data_latched[1]));
  FDCE \rx_data_latched_reg[2] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[2]),
        .Q(rx_data_latched[2]));
  FDCE \rx_data_latched_reg[3] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[3]),
        .Q(rx_data_latched[3]));
  FDCE \rx_data_latched_reg[4] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[4]),
        .Q(rx_data_latched[4]));
  FDCE \rx_data_latched_reg[5] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[5]),
        .Q(rx_data_latched[5]));
  FDCE \rx_data_latched_reg[6] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[6]),
        .Q(rx_data_latched[6]));
  FDCE \rx_data_latched_reg[7] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(rx_shift_reg[7]),
        .Q(rx_data_latched[7]));
  LUT5 #(
    .INIT(32'hFFEFFFFF)) 
    rx_data_new_i_2
       (.I0(s_axi_araddr[4]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(r_valid_reg_reg_0),
        .I4(s_axi_arvalid),
        .O(rx_data_new_i_2_n_0));
  FDCE rx_data_new_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(u_ps2_host_n_12),
        .Q(rx_data_new));
  LUT2 #(
    .INIT(4'h2)) 
    s_axi_arready_INST_0
       (.I0(s_axi_arvalid),
        .I1(r_valid_reg_reg_0),
        .O(E));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h08)) 
    s_axi_wready_INST_0
       (.I0(s_axi_wvalid),
        .I1(s_axi_awvalid),
        .I2(s_axi_bvalid),
        .O(s_axi_awready));
  LUT6 #(
    .INIT(64'hFFFDFFFF00010000)) 
    soft_rst_n_i_1
       (.I0(s_axi_wdata[0]),
        .I1(\tx_data_reg[7]_i_2_n_0 ),
        .I2(s_axi_awaddr[2]),
        .I3(s_axi_awaddr[4]),
        .I4(soft_rst_n_i_2_n_0),
        .I5(soft_rst_n),
        .O(soft_rst_n_i_1_n_0));
  LUT2 #(
    .INIT(4'h1)) 
    soft_rst_n_i_2
       (.I0(s_axi_awaddr[1]),
        .I1(s_axi_awaddr[5]),
        .O(soft_rst_n_i_2_n_0));
  FDPE soft_rst_n_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(soft_rst_n_i_1_n_0),
        .PRE(b_valid_reg_i_2_n_0),
        .Q(soft_rst_n));
  LUT1 #(
    .INIT(2'h1)) 
    \ts_counter[0]_i_2 
       (.I0(\ts_counter_reg_n_0_[0] ),
        .O(\ts_counter[0]_i_2_n_0 ));
  FDCE \ts_counter_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[0]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[0] ));
  CARRY4 \ts_counter_reg[0]_i_1 
       (.CI(1'b0),
        .CO({\ts_counter_reg[0]_i_1_n_0 ,\ts_counter_reg[0]_i_1_n_1 ,\ts_counter_reg[0]_i_1_n_2 ,\ts_counter_reg[0]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b1}),
        .O({\ts_counter_reg[0]_i_1_n_4 ,\ts_counter_reg[0]_i_1_n_5 ,\ts_counter_reg[0]_i_1_n_6 ,\ts_counter_reg[0]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[3] ,\ts_counter_reg_n_0_[2] ,\ts_counter_reg_n_0_[1] ,\ts_counter[0]_i_2_n_0 }));
  FDCE \ts_counter_reg[10] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[8]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[10] ));
  FDCE \ts_counter_reg[11] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[8]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[11] ));
  FDCE \ts_counter_reg[12] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[12]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[12] ));
  CARRY4 \ts_counter_reg[12]_i_1 
       (.CI(\ts_counter_reg[8]_i_1_n_0 ),
        .CO({\ts_counter_reg[12]_i_1_n_0 ,\ts_counter_reg[12]_i_1_n_1 ,\ts_counter_reg[12]_i_1_n_2 ,\ts_counter_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[12]_i_1_n_4 ,\ts_counter_reg[12]_i_1_n_5 ,\ts_counter_reg[12]_i_1_n_6 ,\ts_counter_reg[12]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[15] ,\ts_counter_reg_n_0_[14] ,\ts_counter_reg_n_0_[13] ,\ts_counter_reg_n_0_[12] }));
  FDCE \ts_counter_reg[13] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[12]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[13] ));
  FDCE \ts_counter_reg[14] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[12]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[14] ));
  FDCE \ts_counter_reg[15] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[12]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[15] ));
  FDCE \ts_counter_reg[16] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[16]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[16] ));
  CARRY4 \ts_counter_reg[16]_i_1 
       (.CI(\ts_counter_reg[12]_i_1_n_0 ),
        .CO({\ts_counter_reg[16]_i_1_n_0 ,\ts_counter_reg[16]_i_1_n_1 ,\ts_counter_reg[16]_i_1_n_2 ,\ts_counter_reg[16]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[16]_i_1_n_4 ,\ts_counter_reg[16]_i_1_n_5 ,\ts_counter_reg[16]_i_1_n_6 ,\ts_counter_reg[16]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[19] ,\ts_counter_reg_n_0_[18] ,\ts_counter_reg_n_0_[17] ,\ts_counter_reg_n_0_[16] }));
  FDCE \ts_counter_reg[17] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[16]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[17] ));
  FDCE \ts_counter_reg[18] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[16]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[18] ));
  FDCE \ts_counter_reg[19] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[16]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[19] ));
  FDCE \ts_counter_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[0]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[1] ));
  FDCE \ts_counter_reg[20] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[20]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[20] ));
  CARRY4 \ts_counter_reg[20]_i_1 
       (.CI(\ts_counter_reg[16]_i_1_n_0 ),
        .CO({\ts_counter_reg[20]_i_1_n_0 ,\ts_counter_reg[20]_i_1_n_1 ,\ts_counter_reg[20]_i_1_n_2 ,\ts_counter_reg[20]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[20]_i_1_n_4 ,\ts_counter_reg[20]_i_1_n_5 ,\ts_counter_reg[20]_i_1_n_6 ,\ts_counter_reg[20]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[23] ,\ts_counter_reg_n_0_[22] ,\ts_counter_reg_n_0_[21] ,\ts_counter_reg_n_0_[20] }));
  FDCE \ts_counter_reg[21] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[20]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[21] ));
  FDCE \ts_counter_reg[22] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[20]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[22] ));
  FDCE \ts_counter_reg[23] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[20]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[23] ));
  FDCE \ts_counter_reg[24] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[24]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[24] ));
  CARRY4 \ts_counter_reg[24]_i_1 
       (.CI(\ts_counter_reg[20]_i_1_n_0 ),
        .CO({\ts_counter_reg[24]_i_1_n_0 ,\ts_counter_reg[24]_i_1_n_1 ,\ts_counter_reg[24]_i_1_n_2 ,\ts_counter_reg[24]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[24]_i_1_n_4 ,\ts_counter_reg[24]_i_1_n_5 ,\ts_counter_reg[24]_i_1_n_6 ,\ts_counter_reg[24]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[27] ,\ts_counter_reg_n_0_[26] ,\ts_counter_reg_n_0_[25] ,\ts_counter_reg_n_0_[24] }));
  FDCE \ts_counter_reg[25] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[24]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[25] ));
  FDCE \ts_counter_reg[26] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[24]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[26] ));
  FDCE \ts_counter_reg[27] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[24]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[27] ));
  FDCE \ts_counter_reg[28] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[28]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[28] ));
  CARRY4 \ts_counter_reg[28]_i_1 
       (.CI(\ts_counter_reg[24]_i_1_n_0 ),
        .CO({\ts_counter_reg[28]_i_1_n_0 ,\ts_counter_reg[28]_i_1_n_1 ,\ts_counter_reg[28]_i_1_n_2 ,\ts_counter_reg[28]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[28]_i_1_n_4 ,\ts_counter_reg[28]_i_1_n_5 ,\ts_counter_reg[28]_i_1_n_6 ,\ts_counter_reg[28]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[31] ,\ts_counter_reg_n_0_[30] ,\ts_counter_reg_n_0_[29] ,\ts_counter_reg_n_0_[28] }));
  FDCE \ts_counter_reg[29] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[28]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[29] ));
  FDCE \ts_counter_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[0]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[2] ));
  FDCE \ts_counter_reg[30] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[28]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[30] ));
  FDCE \ts_counter_reg[31] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[28]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[31] ));
  FDCE \ts_counter_reg[32] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[32]_i_1_n_7 ),
        .Q(data5[0]));
  CARRY4 \ts_counter_reg[32]_i_1 
       (.CI(\ts_counter_reg[28]_i_1_n_0 ),
        .CO({\ts_counter_reg[32]_i_1_n_0 ,\ts_counter_reg[32]_i_1_n_1 ,\ts_counter_reg[32]_i_1_n_2 ,\ts_counter_reg[32]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[32]_i_1_n_4 ,\ts_counter_reg[32]_i_1_n_5 ,\ts_counter_reg[32]_i_1_n_6 ,\ts_counter_reg[32]_i_1_n_7 }),
        .S(data5[3:0]));
  FDCE \ts_counter_reg[33] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[32]_i_1_n_6 ),
        .Q(data5[1]));
  FDCE \ts_counter_reg[34] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[32]_i_1_n_5 ),
        .Q(data5[2]));
  FDCE \ts_counter_reg[35] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[32]_i_1_n_4 ),
        .Q(data5[3]));
  FDCE \ts_counter_reg[36] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[36]_i_1_n_7 ),
        .Q(data5[4]));
  CARRY4 \ts_counter_reg[36]_i_1 
       (.CI(\ts_counter_reg[32]_i_1_n_0 ),
        .CO({\ts_counter_reg[36]_i_1_n_0 ,\ts_counter_reg[36]_i_1_n_1 ,\ts_counter_reg[36]_i_1_n_2 ,\ts_counter_reg[36]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[36]_i_1_n_4 ,\ts_counter_reg[36]_i_1_n_5 ,\ts_counter_reg[36]_i_1_n_6 ,\ts_counter_reg[36]_i_1_n_7 }),
        .S(data5[7:4]));
  FDCE \ts_counter_reg[37] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[36]_i_1_n_6 ),
        .Q(data5[5]));
  FDCE \ts_counter_reg[38] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[36]_i_1_n_5 ),
        .Q(data5[6]));
  FDCE \ts_counter_reg[39] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[36]_i_1_n_4 ),
        .Q(data5[7]));
  FDCE \ts_counter_reg[3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[0]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[3] ));
  FDCE \ts_counter_reg[40] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[40]_i_1_n_7 ),
        .Q(data5[8]));
  CARRY4 \ts_counter_reg[40]_i_1 
       (.CI(\ts_counter_reg[36]_i_1_n_0 ),
        .CO({\ts_counter_reg[40]_i_1_n_0 ,\ts_counter_reg[40]_i_1_n_1 ,\ts_counter_reg[40]_i_1_n_2 ,\ts_counter_reg[40]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[40]_i_1_n_4 ,\ts_counter_reg[40]_i_1_n_5 ,\ts_counter_reg[40]_i_1_n_6 ,\ts_counter_reg[40]_i_1_n_7 }),
        .S(data5[11:8]));
  FDCE \ts_counter_reg[41] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[40]_i_1_n_6 ),
        .Q(data5[9]));
  FDCE \ts_counter_reg[42] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[40]_i_1_n_5 ),
        .Q(data5[10]));
  FDCE \ts_counter_reg[43] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[40]_i_1_n_4 ),
        .Q(data5[11]));
  FDCE \ts_counter_reg[44] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[44]_i_1_n_7 ),
        .Q(data5[12]));
  CARRY4 \ts_counter_reg[44]_i_1 
       (.CI(\ts_counter_reg[40]_i_1_n_0 ),
        .CO({\ts_counter_reg[44]_i_1_n_0 ,\ts_counter_reg[44]_i_1_n_1 ,\ts_counter_reg[44]_i_1_n_2 ,\ts_counter_reg[44]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[44]_i_1_n_4 ,\ts_counter_reg[44]_i_1_n_5 ,\ts_counter_reg[44]_i_1_n_6 ,\ts_counter_reg[44]_i_1_n_7 }),
        .S(data5[15:12]));
  FDCE \ts_counter_reg[45] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[44]_i_1_n_6 ),
        .Q(data5[13]));
  FDCE \ts_counter_reg[46] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[44]_i_1_n_5 ),
        .Q(data5[14]));
  FDCE \ts_counter_reg[47] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[44]_i_1_n_4 ),
        .Q(data5[15]));
  FDCE \ts_counter_reg[48] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[48]_i_1_n_7 ),
        .Q(data5[16]));
  CARRY4 \ts_counter_reg[48]_i_1 
       (.CI(\ts_counter_reg[44]_i_1_n_0 ),
        .CO({\ts_counter_reg[48]_i_1_n_0 ,\ts_counter_reg[48]_i_1_n_1 ,\ts_counter_reg[48]_i_1_n_2 ,\ts_counter_reg[48]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[48]_i_1_n_4 ,\ts_counter_reg[48]_i_1_n_5 ,\ts_counter_reg[48]_i_1_n_6 ,\ts_counter_reg[48]_i_1_n_7 }),
        .S(data5[19:16]));
  FDCE \ts_counter_reg[49] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[48]_i_1_n_6 ),
        .Q(data5[17]));
  FDCE \ts_counter_reg[4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[4]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[4] ));
  CARRY4 \ts_counter_reg[4]_i_1 
       (.CI(\ts_counter_reg[0]_i_1_n_0 ),
        .CO({\ts_counter_reg[4]_i_1_n_0 ,\ts_counter_reg[4]_i_1_n_1 ,\ts_counter_reg[4]_i_1_n_2 ,\ts_counter_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[4]_i_1_n_4 ,\ts_counter_reg[4]_i_1_n_5 ,\ts_counter_reg[4]_i_1_n_6 ,\ts_counter_reg[4]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[7] ,\ts_counter_reg_n_0_[6] ,\ts_counter_reg_n_0_[5] ,\ts_counter_reg_n_0_[4] }));
  FDCE \ts_counter_reg[50] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[48]_i_1_n_5 ),
        .Q(data5[18]));
  FDCE \ts_counter_reg[51] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[48]_i_1_n_4 ),
        .Q(data5[19]));
  FDCE \ts_counter_reg[52] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[52]_i_1_n_7 ),
        .Q(data5[20]));
  CARRY4 \ts_counter_reg[52]_i_1 
       (.CI(\ts_counter_reg[48]_i_1_n_0 ),
        .CO({\ts_counter_reg[52]_i_1_n_0 ,\ts_counter_reg[52]_i_1_n_1 ,\ts_counter_reg[52]_i_1_n_2 ,\ts_counter_reg[52]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[52]_i_1_n_4 ,\ts_counter_reg[52]_i_1_n_5 ,\ts_counter_reg[52]_i_1_n_6 ,\ts_counter_reg[52]_i_1_n_7 }),
        .S(data5[23:20]));
  FDCE \ts_counter_reg[53] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[52]_i_1_n_6 ),
        .Q(data5[21]));
  FDCE \ts_counter_reg[54] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[52]_i_1_n_5 ),
        .Q(data5[22]));
  FDCE \ts_counter_reg[55] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[52]_i_1_n_4 ),
        .Q(data5[23]));
  FDCE \ts_counter_reg[56] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[56]_i_1_n_7 ),
        .Q(data5[24]));
  CARRY4 \ts_counter_reg[56]_i_1 
       (.CI(\ts_counter_reg[52]_i_1_n_0 ),
        .CO({\ts_counter_reg[56]_i_1_n_0 ,\ts_counter_reg[56]_i_1_n_1 ,\ts_counter_reg[56]_i_1_n_2 ,\ts_counter_reg[56]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[56]_i_1_n_4 ,\ts_counter_reg[56]_i_1_n_5 ,\ts_counter_reg[56]_i_1_n_6 ,\ts_counter_reg[56]_i_1_n_7 }),
        .S(data5[27:24]));
  FDCE \ts_counter_reg[57] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[56]_i_1_n_6 ),
        .Q(data5[25]));
  FDCE \ts_counter_reg[58] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[56]_i_1_n_5 ),
        .Q(data5[26]));
  FDCE \ts_counter_reg[59] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[56]_i_1_n_4 ),
        .Q(data5[27]));
  FDCE \ts_counter_reg[5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[4]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[5] ));
  FDCE \ts_counter_reg[60] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[60]_i_1_n_7 ),
        .Q(data5[28]));
  CARRY4 \ts_counter_reg[60]_i_1 
       (.CI(\ts_counter_reg[56]_i_1_n_0 ),
        .CO({\NLW_ts_counter_reg[60]_i_1_CO_UNCONNECTED [3],\ts_counter_reg[60]_i_1_n_1 ,\ts_counter_reg[60]_i_1_n_2 ,\ts_counter_reg[60]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[60]_i_1_n_4 ,\ts_counter_reg[60]_i_1_n_5 ,\ts_counter_reg[60]_i_1_n_6 ,\ts_counter_reg[60]_i_1_n_7 }),
        .S(data5[31:28]));
  FDCE \ts_counter_reg[61] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[60]_i_1_n_6 ),
        .Q(data5[29]));
  FDCE \ts_counter_reg[62] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[60]_i_1_n_5 ),
        .Q(data5[30]));
  FDCE \ts_counter_reg[63] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[60]_i_1_n_4 ),
        .Q(data5[31]));
  FDCE \ts_counter_reg[6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[4]_i_1_n_5 ),
        .Q(\ts_counter_reg_n_0_[6] ));
  FDCE \ts_counter_reg[7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[4]_i_1_n_4 ),
        .Q(\ts_counter_reg_n_0_[7] ));
  FDCE \ts_counter_reg[8] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[8]_i_1_n_7 ),
        .Q(\ts_counter_reg_n_0_[8] ));
  CARRY4 \ts_counter_reg[8]_i_1 
       (.CI(\ts_counter_reg[4]_i_1_n_0 ),
        .CO({\ts_counter_reg[8]_i_1_n_0 ,\ts_counter_reg[8]_i_1_n_1 ,\ts_counter_reg[8]_i_1_n_2 ,\ts_counter_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\ts_counter_reg[8]_i_1_n_4 ,\ts_counter_reg[8]_i_1_n_5 ,\ts_counter_reg[8]_i_1_n_6 ,\ts_counter_reg[8]_i_1_n_7 }),
        .S({\ts_counter_reg_n_0_[11] ,\ts_counter_reg_n_0_[10] ,\ts_counter_reg_n_0_[9] ,\ts_counter_reg_n_0_[8] }));
  FDCE \ts_counter_reg[9] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg[8]_i_1_n_6 ),
        .Q(\ts_counter_reg_n_0_[9] ));
  FDCE \ts_latched_reg[0] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[0] ),
        .Q(\ts_latched_reg_n_0_[0] ));
  FDCE \ts_latched_reg[10] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[10] ),
        .Q(\ts_latched_reg_n_0_[10] ));
  FDCE \ts_latched_reg[11] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[11] ),
        .Q(\ts_latched_reg_n_0_[11] ));
  FDCE \ts_latched_reg[12] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[12] ),
        .Q(\ts_latched_reg_n_0_[12] ));
  FDCE \ts_latched_reg[13] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[13] ),
        .Q(\ts_latched_reg_n_0_[13] ));
  FDCE \ts_latched_reg[14] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[14] ),
        .Q(\ts_latched_reg_n_0_[14] ));
  FDCE \ts_latched_reg[15] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[15] ),
        .Q(\ts_latched_reg_n_0_[15] ));
  FDCE \ts_latched_reg[16] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[16] ),
        .Q(\ts_latched_reg_n_0_[16] ));
  FDCE \ts_latched_reg[17] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[17] ),
        .Q(\ts_latched_reg_n_0_[17] ));
  FDCE \ts_latched_reg[18] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[18] ),
        .Q(\ts_latched_reg_n_0_[18] ));
  FDCE \ts_latched_reg[19] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[19] ),
        .Q(\ts_latched_reg_n_0_[19] ));
  FDCE \ts_latched_reg[1] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[1] ),
        .Q(\ts_latched_reg_n_0_[1] ));
  FDCE \ts_latched_reg[20] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[20] ),
        .Q(\ts_latched_reg_n_0_[20] ));
  FDCE \ts_latched_reg[21] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[21] ),
        .Q(\ts_latched_reg_n_0_[21] ));
  FDCE \ts_latched_reg[22] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[22] ),
        .Q(\ts_latched_reg_n_0_[22] ));
  FDCE \ts_latched_reg[23] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[23] ),
        .Q(\ts_latched_reg_n_0_[23] ));
  FDCE \ts_latched_reg[24] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[24] ),
        .Q(\ts_latched_reg_n_0_[24] ));
  FDCE \ts_latched_reg[25] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[25] ),
        .Q(\ts_latched_reg_n_0_[25] ));
  FDCE \ts_latched_reg[26] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[26] ),
        .Q(\ts_latched_reg_n_0_[26] ));
  FDCE \ts_latched_reg[27] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[27] ),
        .Q(\ts_latched_reg_n_0_[27] ));
  FDCE \ts_latched_reg[28] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[28] ),
        .Q(\ts_latched_reg_n_0_[28] ));
  FDCE \ts_latched_reg[29] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[29] ),
        .Q(\ts_latched_reg_n_0_[29] ));
  FDCE \ts_latched_reg[2] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[2] ),
        .Q(\ts_latched_reg_n_0_[2] ));
  FDCE \ts_latched_reg[30] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[30] ),
        .Q(\ts_latched_reg_n_0_[30] ));
  FDCE \ts_latched_reg[31] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[31] ),
        .Q(\ts_latched_reg_n_0_[31] ));
  FDCE \ts_latched_reg[32] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[0]),
        .Q(data3[0]));
  FDCE \ts_latched_reg[33] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[1]),
        .Q(data3[1]));
  FDCE \ts_latched_reg[34] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[2]),
        .Q(data3[2]));
  FDCE \ts_latched_reg[35] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[3]),
        .Q(data3[3]));
  FDCE \ts_latched_reg[36] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[4]),
        .Q(data3[4]));
  FDCE \ts_latched_reg[37] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[5]),
        .Q(data3[5]));
  FDCE \ts_latched_reg[38] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[6]),
        .Q(data3[6]));
  FDCE \ts_latched_reg[39] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[7]),
        .Q(data3[7]));
  FDCE \ts_latched_reg[3] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[3] ),
        .Q(\ts_latched_reg_n_0_[3] ));
  FDCE \ts_latched_reg[40] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[8]),
        .Q(data3[8]));
  FDCE \ts_latched_reg[41] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[9]),
        .Q(data3[9]));
  FDCE \ts_latched_reg[42] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[10]),
        .Q(data3[10]));
  FDCE \ts_latched_reg[43] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[11]),
        .Q(data3[11]));
  FDCE \ts_latched_reg[44] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[12]),
        .Q(data3[12]));
  FDCE \ts_latched_reg[45] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[13]),
        .Q(data3[13]));
  FDCE \ts_latched_reg[46] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[14]),
        .Q(data3[14]));
  FDCE \ts_latched_reg[47] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[15]),
        .Q(data3[15]));
  FDCE \ts_latched_reg[48] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[16]),
        .Q(data3[16]));
  FDCE \ts_latched_reg[49] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[17]),
        .Q(data3[17]));
  FDCE \ts_latched_reg[4] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[4] ),
        .Q(\ts_latched_reg_n_0_[4] ));
  FDCE \ts_latched_reg[50] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[18]),
        .Q(data3[18]));
  FDCE \ts_latched_reg[51] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[19]),
        .Q(data3[19]));
  FDCE \ts_latched_reg[52] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[20]),
        .Q(data3[20]));
  FDCE \ts_latched_reg[53] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[21]),
        .Q(data3[21]));
  FDCE \ts_latched_reg[54] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[22]),
        .Q(data3[22]));
  FDCE \ts_latched_reg[55] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[23]),
        .Q(data3[23]));
  FDCE \ts_latched_reg[56] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[24]),
        .Q(data3[24]));
  FDCE \ts_latched_reg[57] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[25]),
        .Q(data3[25]));
  FDCE \ts_latched_reg[58] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[26]),
        .Q(data3[26]));
  FDCE \ts_latched_reg[59] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[27]),
        .Q(data3[27]));
  FDCE \ts_latched_reg[5] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[5] ),
        .Q(\ts_latched_reg_n_0_[5] ));
  FDCE \ts_latched_reg[60] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[28]),
        .Q(data3[28]));
  FDCE \ts_latched_reg[61] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[29]),
        .Q(data3[29]));
  FDCE \ts_latched_reg[62] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[30]),
        .Q(data3[30]));
  FDCE \ts_latched_reg[63] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(data5[31]),
        .Q(data3[31]));
  FDCE \ts_latched_reg[6] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[6] ),
        .Q(\ts_latched_reg_n_0_[6] ));
  FDCE \ts_latched_reg[7] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[7] ),
        .Q(\ts_latched_reg_n_0_[7] ));
  FDCE \ts_latched_reg[8] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[8] ),
        .Q(\ts_latched_reg_n_0_[8] ));
  FDCE \ts_latched_reg[9] 
       (.C(s_axi_aclk),
        .CE(ps2_rx_valid),
        .CLR(b_valid_reg_i_2_n_0),
        .D(\ts_counter_reg_n_0_[9] ),
        .Q(\ts_latched_reg_n_0_[9] ));
  LUT5 #(
    .INIT(32'hFFFEFFFF)) 
    \tx_data_reg[7]_i_2 
       (.I0(s_axi_awaddr[6]),
        .I1(s_axi_awaddr[3]),
        .I2(s_axi_awaddr[7]),
        .I3(s_axi_awaddr[0]),
        .I4(s_axi_awready),
        .O(\tx_data_reg[7]_i_2_n_0 ));
  FDCE \tx_data_reg_reg[0] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[0]),
        .Q(tx_data_reg[0]));
  FDCE \tx_data_reg_reg[1] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[1]),
        .Q(tx_data_reg[1]));
  FDCE \tx_data_reg_reg[2] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[2]),
        .Q(tx_data_reg[2]));
  FDCE \tx_data_reg_reg[3] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[3]),
        .Q(tx_data_reg[3]));
  FDCE \tx_data_reg_reg[4] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[4]),
        .Q(tx_data_reg[4]));
  FDCE \tx_data_reg_reg[5] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[5]),
        .Q(tx_data_reg[5]));
  FDCE \tx_data_reg_reg[6] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[6]),
        .Q(tx_data_reg[6]));
  FDCE \tx_data_reg_reg[7] 
       (.C(s_axi_aclk),
        .CE(u_ps2_host_n_2),
        .CLR(b_valid_reg_i_2_n_0),
        .D(s_axi_wdata[7]),
        .Q(tx_data_reg[7]));
  FDCE tx_en_reg_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .CLR(b_valid_reg_i_2_n_0),
        .D(u_ps2_host_n_13),
        .Q(tx_en_reg_reg_n_0));
  design_1_ps2_host_axi_0_0_ps2_host u_ps2_host
       (.D(u_ps2_host_n_11),
        .E(ps2_rx_valid),
        .Q(rx_shift_reg),
        .parity_err_reg(parity_err_reg),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .\r_data_reg_reg[2] (\r_data_reg[2]_i_2_n_0 ),
        .\r_data_reg_reg[2]_0 (data3[2]),
        .rst_n(rst_n),
        .rx_data_new(rx_data_new),
        .rx_data_new_reg(\r_data_reg[31]_i_3_n_0 ),
        .rx_data_new_reg_0(rx_data_new_i_2_n_0),
        .rx_valid_reg_reg_0(u_ps2_host_n_12),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr[4:0]),
        .s_axi_awaddr({s_axi_awaddr[5:4],s_axi_awaddr[2:1]}),
        .\s_axi_awaddr[5] (u_ps2_host_n_2),
        .soft_rst_n(soft_rst_n),
        .tx_active_reg_0(u_ps2_host_n_13),
        .tx_en_reg_reg(tx_en_reg_reg_n_0),
        .tx_en_reg_reg_0(\tx_data_reg[7]_i_2_n_0 ),
        .tx_en_reg_reg_1(soft_rst_n_i_2_n_0),
        .\tx_shift_reg_reg[7]_0 (tx_data_reg));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
