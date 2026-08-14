-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Aug 13 10:31:07 2026
-- Host        : zx-lxy running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               G:/fpga/0708/0810/xdma/xdma/xdma.srcs/sources_1/bd/design_1/ip/design_1_ps2_host_axi_0_0/design_1_ps2_host_axi_0_0_sim_netlist.vhdl
-- Design      : design_1_ps2_host_axi_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z015clg485-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_ps2_host_axi_0_0_ps2_host is
  port (
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    parity_err_reg : out STD_LOGIC;
    \s_axi_awaddr[5]\ : out STD_LOGIC_VECTOR ( 0 to 0 );
    Q : out STD_LOGIC_VECTOR ( 7 downto 0 );
    D : out STD_LOGIC_VECTOR ( 0 to 0 );
    rx_valid_reg_reg_0 : out STD_LOGIC;
    tx_active_reg_0 : out STD_LOGIC;
    ps2_clk : inout STD_LOGIC;
    ps2_data : inout STD_LOGIC;
    s_axi_aclk : in STD_LOGIC;
    tx_en_reg_reg : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    tx_en_reg_reg_0 : in STD_LOGIC;
    \tx_shift_reg_reg[7]_0\ : in STD_LOGIC_VECTOR ( 7 downto 0 );
    \r_data_reg_reg[2]\ : in STD_LOGIC;
    rx_data_new_reg : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    \r_data_reg_reg[2]_0\ : in STD_LOGIC_VECTOR ( 0 to 0 );
    rx_data_new_reg_0 : in STD_LOGIC;
    rx_data_new : in STD_LOGIC;
    tx_en_reg_reg_1 : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    soft_rst_n : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_ps2_host_axi_0_0_ps2_host : entity is "ps2_host";
end design_1_ps2_host_axi_0_0_ps2_host;

architecture STRUCTURE of design_1_ps2_host_axi_0_0_ps2_host is
  signal \^e\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \FSM_sequential_state[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[1]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[1]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[1]_i_4_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[1]_i_5_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[1]_i_6_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_4_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_5_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_6_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_7_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_8_n_0\ : STD_LOGIC;
  signal \FSM_sequential_state[2]_i_9_n_0\ : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal bit_cnt : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \bit_cnt[1]_i_1_n_0\ : STD_LOGIC;
  signal \bit_cnt[3]_i_1_n_0\ : STD_LOGIC;
  signal \bit_cnt[3]_i_3_n_0\ : STD_LOGIC;
  signal \bit_cnt[3]_i_4_n_0\ : STD_LOGIC;
  signal \bit_cnt[3]_i_5_n_0\ : STD_LOGIC;
  signal \bit_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \bit_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \bit_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \bit_cnt_reg_n_0_[3]\ : STD_LOGIC;
  signal data_en_reg_i_1_n_0 : STD_LOGIC;
  signal data_en_reg_i_2_n_0 : STD_LOGIC;
  signal data_en_reg_i_3_n_0 : STD_LOGIC;
  signal data_en_reg_i_4_n_0 : STD_LOGIC;
  signal data_en_reg_i_5_n_0 : STD_LOGIC;
  signal \^parity_err_reg\ : STD_LOGIC;
  signal parity_err_reg_i_1_n_0 : STD_LOGIC;
  signal parity_err_reg_i_2_n_0 : STD_LOGIC;
  signal parity_err_reg_i_3_n_0 : STD_LOGIC;
  signal ps2_clk_en : STD_LOGIC;
  signal ps2_clk_meta : STD_LOGIC;
  signal ps2_clk_prev : STD_LOGIC;
  signal ps2_clk_sync : STD_LOGIC;
  signal ps2_data_en : STD_LOGIC;
  signal ps2_data_meta : STD_LOGIC;
  signal ps2_data_sync : STD_LOGIC;
  signal \r_data_reg[2]_i_3_n_0\ : STD_LOGIC;
  signal \rx_shift_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal rx_valid_reg_i_1_n_0 : STD_LOGIC;
  signal \state__0\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \timeout_cnt[0]_i_2_n_0\ : STD_LOGIC;
  signal \timeout_cnt[0]_i_3_n_0\ : STD_LOGIC;
  signal \timeout_cnt[0]_i_4_n_0\ : STD_LOGIC;
  signal \timeout_cnt[0]_i_5_n_0\ : STD_LOGIC;
  signal \timeout_cnt[0]_i_6_n_0\ : STD_LOGIC;
  signal \timeout_cnt[12]_i_2_n_0\ : STD_LOGIC;
  signal \timeout_cnt[12]_i_3_n_0\ : STD_LOGIC;
  signal \timeout_cnt[12]_i_4_n_0\ : STD_LOGIC;
  signal \timeout_cnt[12]_i_5_n_0\ : STD_LOGIC;
  signal \timeout_cnt[16]_i_2_n_0\ : STD_LOGIC;
  signal \timeout_cnt[16]_i_3_n_0\ : STD_LOGIC;
  signal \timeout_cnt[16]_i_4_n_0\ : STD_LOGIC;
  signal \timeout_cnt[16]_i_5_n_0\ : STD_LOGIC;
  signal \timeout_cnt[4]_i_2_n_0\ : STD_LOGIC;
  signal \timeout_cnt[4]_i_3_n_0\ : STD_LOGIC;
  signal \timeout_cnt[4]_i_4_n_0\ : STD_LOGIC;
  signal \timeout_cnt[4]_i_5_n_0\ : STD_LOGIC;
  signal \timeout_cnt[8]_i_2_n_0\ : STD_LOGIC;
  signal \timeout_cnt[8]_i_3_n_0\ : STD_LOGIC;
  signal \timeout_cnt[8]_i_4_n_0\ : STD_LOGIC;
  signal \timeout_cnt[8]_i_5_n_0\ : STD_LOGIC;
  signal timeout_cnt_reg : STD_LOGIC_VECTOR ( 19 downto 6 );
  signal \timeout_cnt_reg[0]_i_1_n_0\ : STD_LOGIC;
  signal \timeout_cnt_reg[0]_i_1_n_1\ : STD_LOGIC;
  signal \timeout_cnt_reg[0]_i_1_n_2\ : STD_LOGIC;
  signal \timeout_cnt_reg[0]_i_1_n_3\ : STD_LOGIC;
  signal \timeout_cnt_reg[0]_i_1_n_4\ : STD_LOGIC;
  signal \timeout_cnt_reg[0]_i_1_n_5\ : STD_LOGIC;
  signal \timeout_cnt_reg[0]_i_1_n_6\ : STD_LOGIC;
  signal \timeout_cnt_reg[0]_i_1_n_7\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_0\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \timeout_cnt_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \timeout_cnt_reg[16]_i_1_n_1\ : STD_LOGIC;
  signal \timeout_cnt_reg[16]_i_1_n_2\ : STD_LOGIC;
  signal \timeout_cnt_reg[16]_i_1_n_3\ : STD_LOGIC;
  signal \timeout_cnt_reg[16]_i_1_n_4\ : STD_LOGIC;
  signal \timeout_cnt_reg[16]_i_1_n_5\ : STD_LOGIC;
  signal \timeout_cnt_reg[16]_i_1_n_6\ : STD_LOGIC;
  signal \timeout_cnt_reg[16]_i_1_n_7\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \timeout_cnt_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \timeout_cnt_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal \timeout_cnt_reg_n_0_[0]\ : STD_LOGIC;
  signal \timeout_cnt_reg_n_0_[1]\ : STD_LOGIC;
  signal \timeout_cnt_reg_n_0_[2]\ : STD_LOGIC;
  signal \timeout_cnt_reg_n_0_[3]\ : STD_LOGIC;
  signal \timeout_cnt_reg_n_0_[4]\ : STD_LOGIC;
  signal \timeout_cnt_reg_n_0_[5]\ : STD_LOGIC;
  signal tx_active_i_1_n_0 : STD_LOGIC;
  signal tx_active_i_2_n_0 : STD_LOGIC;
  signal tx_active_i_3_n_0 : STD_LOGIC;
  signal tx_shift_reg : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \tx_shift_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[0]\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[1]\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[2]\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[3]\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[4]\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[5]\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[6]\ : STD_LOGIC;
  signal \tx_shift_reg_reg_n_0_[7]\ : STD_LOGIC;
  signal \NLW_timeout_cnt_reg[16]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_sequential_state[1]_i_4\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \FSM_sequential_state[1]_i_6\ : label is "soft_lutpair0";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_sequential_state_reg[0]\ : label is "TX_DATA:010,TX_PARITY:011,TX_STOP:100,RX_DATA:110,RX_START:101,TX_START:001,IDLE:000,RX_PARITY:111";
  attribute FSM_ENCODED_STATES of \FSM_sequential_state_reg[1]\ : label is "TX_DATA:010,TX_PARITY:011,TX_STOP:100,RX_DATA:110,RX_START:101,TX_START:001,IDLE:000,RX_PARITY:111";
  attribute FSM_ENCODED_STATES of \FSM_sequential_state_reg[2]\ : label is "TX_DATA:010,TX_PARITY:011,TX_STOP:100,RX_DATA:110,RX_START:101,TX_START:001,IDLE:000,RX_PARITY:111";
  attribute SOFT_HLUTNM of \bit_cnt[0]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \bit_cnt[1]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \bit_cnt[2]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \bit_cnt[3]_i_2\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \bit_cnt[3]_i_3\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \bit_cnt[3]_i_4\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \bit_cnt[3]_i_5\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of data_en_reg_i_5 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \r_data_reg[2]_i_3\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of tx_active_i_2 : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of tx_active_i_3 : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \tx_shift_reg[1]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \tx_shift_reg[2]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \tx_shift_reg[3]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \tx_shift_reg[4]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \tx_shift_reg[5]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \tx_shift_reg[6]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \tx_shift_reg[7]_i_2\ : label is "soft_lutpair2";
begin
  E(0) <= \^e\(0);
  Q(7 downto 0) <= \^q\(7 downto 0);
  parity_err_reg <= \^parity_err_reg\;
\FSM_sequential_state[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00FF00004F000000"
    )
        port map (
      I0 => \FSM_sequential_state[1]_i_2_n_0\,
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \FSM_sequential_state[1]_i_3_n_0\,
      I4 => \FSM_sequential_state[2]_i_6_n_0\,
      I5 => \state__0\(0),
      O => \FSM_sequential_state[0]_i_1_n_0\
    );
\FSM_sequential_state[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"13FF0000CC000000"
    )
        port map (
      I0 => \state__0\(2),
      I1 => \state__0\(0),
      I2 => \FSM_sequential_state[1]_i_2_n_0\,
      I3 => \FSM_sequential_state[1]_i_3_n_0\,
      I4 => \FSM_sequential_state[2]_i_6_n_0\,
      I5 => \state__0\(1),
      O => \FSM_sequential_state[1]_i_1_n_0\
    );
\FSM_sequential_state[1]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => ps2_clk_sync,
      I1 => ps2_clk_prev,
      O => \FSM_sequential_state[1]_i_2_n_0\
    );
\FSM_sequential_state[1]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF0010"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[3]\,
      I1 => \FSM_sequential_state[1]_i_4_n_0\,
      I2 => \state__0\(1),
      I3 => \FSM_sequential_state[1]_i_2_n_0\,
      I4 => \FSM_sequential_state[1]_i_5_n_0\,
      I5 => \FSM_sequential_state[1]_i_6_n_0\,
      O => \FSM_sequential_state[1]_i_3_n_0\
    );
\FSM_sequential_state[1]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[1]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[2]\,
      O => \FSM_sequential_state[1]_i_4_n_0\
    );
\FSM_sequential_state[1]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000F0FD00000000"
    )
        port map (
      I0 => ps2_data_sync,
      I1 => \state__0\(2),
      I2 => \state__0\(0),
      I3 => \state__0\(1),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \FSM_sequential_state[1]_i_5_n_0\
    );
\FSM_sequential_state[1]_i_6\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00010000"
    )
        port map (
      I0 => \state__0\(0),
      I1 => \state__0\(2),
      I2 => \state__0\(1),
      I3 => ps2_clk_en,
      I4 => tx_en_reg_reg,
      O => \FSM_sequential_state[1]_i_6_n_0\
    );
\FSM_sequential_state[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"57005400"
    )
        port map (
      I0 => \FSM_sequential_state[2]_i_3_n_0\,
      I1 => \FSM_sequential_state[2]_i_4_n_0\,
      I2 => \FSM_sequential_state[2]_i_5_n_0\,
      I3 => \FSM_sequential_state[2]_i_6_n_0\,
      I4 => \state__0\(2),
      O => \FSM_sequential_state[2]_i_1_n_0\
    );
\FSM_sequential_state[2]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => rst_n,
      I1 => soft_rst_n,
      O => \FSM_sequential_state[2]_i_2_n_0\
    );
\FSM_sequential_state[2]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF5555AEAA5555AE"
    )
        port map (
      I0 => \state__0\(0),
      I1 => tx_en_reg_reg,
      I2 => ps2_clk_en,
      I3 => \state__0\(1),
      I4 => \state__0\(2),
      I5 => \FSM_sequential_state[1]_i_2_n_0\,
      O => \FSM_sequential_state[2]_i_3_n_0\
    );
\FSM_sequential_state[2]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3303330A3303330B"
    )
        port map (
      I0 => \bit_cnt[3]_i_4_n_0\,
      I1 => \FSM_sequential_state[1]_i_2_n_0\,
      I2 => \state__0\(1),
      I3 => \state__0\(0),
      I4 => \state__0\(2),
      I5 => ps2_data_sync,
      O => \FSM_sequential_state[2]_i_4_n_0\
    );
\FSM_sequential_state[2]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000040000000"
    )
        port map (
      I0 => \FSM_sequential_state[1]_i_2_n_0\,
      I1 => \state__0\(1),
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \bit_cnt_reg_n_0_[0]\,
      I4 => \bit_cnt_reg_n_0_[2]\,
      I5 => \bit_cnt_reg_n_0_[3]\,
      O => \FSM_sequential_state[2]_i_5_n_0\
    );
\FSM_sequential_state[2]_i_6\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF15155515"
    )
        port map (
      I0 => \FSM_sequential_state[2]_i_7_n_0\,
      I1 => timeout_cnt_reg(16),
      I2 => timeout_cnt_reg(17),
      I3 => \FSM_sequential_state[2]_i_8_n_0\,
      I4 => \FSM_sequential_state[2]_i_9_n_0\,
      I5 => \bit_cnt[3]_i_3_n_0\,
      O => \FSM_sequential_state[2]_i_6_n_0\
    );
\FSM_sequential_state[2]_i_7\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => timeout_cnt_reg(19),
      I1 => timeout_cnt_reg(18),
      O => \FSM_sequential_state[2]_i_7_n_0\
    );
\FSM_sequential_state[2]_i_8\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"777777777F7F7FFF"
    )
        port map (
      I0 => timeout_cnt_reg(10),
      I1 => timeout_cnt_reg(11),
      I2 => timeout_cnt_reg(8),
      I3 => timeout_cnt_reg(7),
      I4 => timeout_cnt_reg(6),
      I5 => timeout_cnt_reg(9),
      O => \FSM_sequential_state[2]_i_8_n_0\
    );
\FSM_sequential_state[2]_i_9\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => timeout_cnt_reg(12),
      I1 => timeout_cnt_reg(13),
      I2 => timeout_cnt_reg(14),
      I3 => timeout_cnt_reg(15),
      O => \FSM_sequential_state[2]_i_9_n_0\
    );
\FSM_sequential_state_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \FSM_sequential_state[0]_i_1_n_0\,
      Q => \state__0\(0)
    );
\FSM_sequential_state_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \FSM_sequential_state[1]_i_1_n_0\,
      Q => \state__0\(1)
    );
\FSM_sequential_state_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \FSM_sequential_state[2]_i_1_n_0\,
      Q => \state__0\(2)
    );
\bit_cnt[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"3A"
    )
        port map (
      I0 => \state__0\(2),
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \state__0\(1),
      O => bit_cnt(0)
    );
\bit_cnt[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"60"
    )
        port map (
      I0 => \bit_cnt_reg_n_0_[1]\,
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \state__0\(1),
      O => \bit_cnt[1]_i_1_n_0\
    );
\bit_cnt[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2A80"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \bit_cnt_reg_n_0_[0]\,
      I2 => \bit_cnt_reg_n_0_[1]\,
      I3 => \bit_cnt_reg_n_0_[2]\,
      O => bit_cnt(2)
    );
\bit_cnt[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000008AAAAAAAA"
    )
        port map (
      I0 => \FSM_sequential_state[2]_i_6_n_0\,
      I1 => \bit_cnt[3]_i_3_n_0\,
      I2 => ps2_data_sync,
      I3 => \FSM_sequential_state[1]_i_2_n_0\,
      I4 => \bit_cnt[3]_i_4_n_0\,
      I5 => \bit_cnt[3]_i_5_n_0\,
      O => \bit_cnt[3]_i_1_n_0\
    );
\bit_cnt[3]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"2AAA8000"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \bit_cnt_reg_n_0_[1]\,
      I2 => \bit_cnt_reg_n_0_[0]\,
      I3 => \bit_cnt_reg_n_0_[2]\,
      I4 => \bit_cnt_reg_n_0_[3]\,
      O => bit_cnt(3)
    );
\bit_cnt[3]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => \state__0\(1),
      I1 => \state__0\(2),
      I2 => \state__0\(0),
      O => \bit_cnt[3]_i_3_n_0\
    );
\bit_cnt[3]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => tx_en_reg_reg,
      I1 => ps2_clk_en,
      O => \bit_cnt[3]_i_4_n_0\
    );
\bit_cnt[3]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FDDF"
    )
        port map (
      I0 => ps2_clk_prev,
      I1 => ps2_clk_sync,
      I2 => \state__0\(1),
      I3 => \state__0\(0),
      O => \bit_cnt[3]_i_5_n_0\
    );
\bit_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \bit_cnt[3]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => bit_cnt(0),
      Q => \bit_cnt_reg_n_0_[0]\
    );
\bit_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \bit_cnt[3]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \bit_cnt[1]_i_1_n_0\,
      Q => \bit_cnt_reg_n_0_[1]\
    );
\bit_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \bit_cnt[3]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => bit_cnt(2),
      Q => \bit_cnt_reg_n_0_[2]\
    );
\bit_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \bit_cnt[3]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => bit_cnt(3),
      Q => \bit_cnt_reg_n_0_[3]\
    );
data_en_reg_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"C404"
    )
        port map (
      I0 => data_en_reg_i_2_n_0,
      I1 => \FSM_sequential_state[2]_i_6_n_0\,
      I2 => data_en_reg_i_3_n_0,
      I3 => ps2_data_en,
      O => data_en_reg_i_1_n_0
    );
data_en_reg_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"66000F0066FF0FFF"
    )
        port map (
      I0 => data_en_reg_i_4_n_0,
      I1 => data_en_reg_i_5_n_0,
      I2 => \tx_shift_reg_reg_n_0_[0]\,
      I3 => \state__0\(1),
      I4 => \state__0\(0),
      I5 => tx_active_i_3_n_0,
      O => data_en_reg_i_2_n_0
    );
data_en_reg_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFF0DFF00F00D"
    )
        port map (
      I0 => tx_en_reg_reg,
      I1 => ps2_clk_en,
      I2 => \state__0\(0),
      I3 => \state__0\(2),
      I4 => \state__0\(1),
      I5 => \FSM_sequential_state[1]_i_2_n_0\,
      O => data_en_reg_i_3_n_0
    );
data_en_reg_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6996"
    )
        port map (
      I0 => \tx_shift_reg_reg[7]_0\(3),
      I1 => \tx_shift_reg_reg[7]_0\(2),
      I2 => \tx_shift_reg_reg[7]_0\(1),
      I3 => \tx_shift_reg_reg[7]_0\(0),
      O => data_en_reg_i_4_n_0
    );
data_en_reg_i_5: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6996"
    )
        port map (
      I0 => \tx_shift_reg_reg[7]_0\(7),
      I1 => \tx_shift_reg_reg[7]_0\(6),
      I2 => \tx_shift_reg_reg[7]_0\(5),
      I3 => \tx_shift_reg_reg[7]_0\(4),
      O => data_en_reg_i_5_n_0
    );
data_en_reg_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => data_en_reg_i_1_n_0,
      Q => ps2_data_en
    );
parity_err_reg_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"BFFFFFFF80000000"
    )
        port map (
      I0 => parity_err_reg_i_2_n_0,
      I1 => \FSM_sequential_state[2]_i_6_n_0\,
      I2 => tx_active_i_3_n_0,
      I3 => \state__0\(0),
      I4 => \state__0\(1),
      I5 => \^parity_err_reg\,
      O => parity_err_reg_i_1_n_0
    );
parity_err_reg_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9669699669969669"
    )
        port map (
      I0 => ps2_data_sync,
      I1 => parity_err_reg_i_3_n_0,
      I2 => \^q\(1),
      I3 => \^q\(0),
      I4 => \^q\(3),
      I5 => \^q\(2),
      O => parity_err_reg_i_2_n_0
    );
parity_err_reg_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6996"
    )
        port map (
      I0 => \^q\(5),
      I1 => \^q\(4),
      I2 => \^q\(7),
      I3 => \^q\(6),
      O => parity_err_reg_i_3_n_0
    );
parity_err_reg_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => parity_err_reg_i_1_n_0,
      Q => \^parity_err_reg\
    );
ps2_clk_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFF888F888F888"
    )
        port map (
      I0 => '0',
      I1 => ps2_clk_en,
      I2 => '0',
      I3 => '0',
      I4 => '0',
      I5 => '0',
      O => ps2_clk
    );
ps2_clk_meta_reg: unisim.vcomponents.FDPE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => ps2_clk,
      PRE => \FSM_sequential_state[2]_i_2_n_0\,
      Q => ps2_clk_meta
    );
ps2_clk_prev_reg: unisim.vcomponents.FDPE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => ps2_clk_sync,
      PRE => \FSM_sequential_state[2]_i_2_n_0\,
      Q => ps2_clk_prev
    );
ps2_clk_sync_reg: unisim.vcomponents.FDPE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => ps2_clk_meta,
      PRE => \FSM_sequential_state[2]_i_2_n_0\,
      Q => ps2_clk_sync
    );
ps2_data_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFF888F888F888"
    )
        port map (
      I0 => '0',
      I1 => ps2_data_en,
      I2 => '0',
      I3 => '0',
      I4 => '0',
      I5 => '0',
      O => ps2_data
    );
ps2_data_meta_reg: unisim.vcomponents.FDPE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => ps2_data,
      PRE => \FSM_sequential_state[2]_i_2_n_0\,
      Q => ps2_data_meta
    );
ps2_data_sync_reg: unisim.vcomponents.FDPE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => ps2_data_meta,
      PRE => \FSM_sequential_state[2]_i_2_n_0\,
      Q => ps2_data_sync
    );
\r_data_reg[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8888CC8C88880080"
    )
        port map (
      I0 => \r_data_reg_reg[2]\,
      I1 => rx_data_new_reg,
      I2 => s_axi_araddr(3),
      I3 => s_axi_araddr(0),
      I4 => s_axi_araddr(1),
      I5 => \r_data_reg[2]_i_3_n_0\,
      O => D(0)
    );
\r_data_reg[2]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0838"
    )
        port map (
      I0 => \r_data_reg_reg[2]_0\(0),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => ps2_clk_en,
      O => \r_data_reg[2]_i_3_n_0\
    );
rx_data_new_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"EFAA"
    )
        port map (
      I0 => \^e\(0),
      I1 => rx_data_new_reg_0,
      I2 => rx_data_new_reg,
      I3 => rx_data_new,
      O => rx_valid_reg_reg_0
    );
\rx_shift_reg[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000008000800000"
    )
        port map (
      I0 => \FSM_sequential_state[2]_i_6_n_0\,
      I1 => \state__0\(2),
      I2 => ps2_clk_prev,
      I3 => ps2_clk_sync,
      I4 => \state__0\(1),
      I5 => \state__0\(0),
      O => \rx_shift_reg[7]_i_1_n_0\
    );
\rx_shift_reg_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \^q\(1),
      Q => \^q\(0)
    );
\rx_shift_reg_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \^q\(2),
      Q => \^q\(1)
    );
\rx_shift_reg_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \^q\(3),
      Q => \^q\(2)
    );
\rx_shift_reg_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \^q\(4),
      Q => \^q\(3)
    );
\rx_shift_reg_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \^q\(5),
      Q => \^q\(4)
    );
\rx_shift_reg_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \^q\(6),
      Q => \^q\(5)
    );
\rx_shift_reg_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \^q\(7),
      Q => \^q\(6)
    );
\rx_shift_reg_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \rx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => ps2_data_sync,
      Q => \^q\(7)
    );
rx_valid_reg_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0080000000000000"
    )
        port map (
      I0 => \FSM_sequential_state[2]_i_6_n_0\,
      I1 => \state__0\(2),
      I2 => ps2_clk_prev,
      I3 => ps2_clk_sync,
      I4 => \state__0\(0),
      I5 => \state__0\(1),
      O => rx_valid_reg_i_1_n_0
    );
rx_valid_reg_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => rx_valid_reg_i_1_n_0,
      Q => \^e\(0)
    );
\timeout_cnt[0]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"DDDDDDD0"
    )
        port map (
      I0 => ps2_clk_prev,
      I1 => ps2_clk_sync,
      I2 => \state__0\(0),
      I3 => \state__0\(2),
      I4 => \state__0\(1),
      O => \timeout_cnt[0]_i_2_n_0\
    );
\timeout_cnt[0]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => \timeout_cnt_reg_n_0_[3]\,
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[0]_i_3_n_0\
    );
\timeout_cnt[0]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => \timeout_cnt_reg_n_0_[2]\,
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[0]_i_4_n_0\
    );
\timeout_cnt[0]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => \timeout_cnt_reg_n_0_[1]\,
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[0]_i_5_n_0\
    );
\timeout_cnt[0]_i_6\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5554000055545554"
    )
        port map (
      I0 => \timeout_cnt_reg_n_0_[0]\,
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[0]_i_6_n_0\
    );
\timeout_cnt[12]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(15),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[12]_i_2_n_0\
    );
\timeout_cnt[12]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(14),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[12]_i_3_n_0\
    );
\timeout_cnt[12]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(13),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[12]_i_4_n_0\
    );
\timeout_cnt[12]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(12),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[12]_i_5_n_0\
    );
\timeout_cnt[16]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(19),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[16]_i_2_n_0\
    );
\timeout_cnt[16]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(18),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[16]_i_3_n_0\
    );
\timeout_cnt[16]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(17),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[16]_i_4_n_0\
    );
\timeout_cnt[16]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(16),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[16]_i_5_n_0\
    );
\timeout_cnt[4]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(7),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[4]_i_2_n_0\
    );
\timeout_cnt[4]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(6),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[4]_i_3_n_0\
    );
\timeout_cnt[4]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => \timeout_cnt_reg_n_0_[5]\,
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[4]_i_4_n_0\
    );
\timeout_cnt[4]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => \timeout_cnt_reg_n_0_[4]\,
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[4]_i_5_n_0\
    );
\timeout_cnt[8]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(11),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[8]_i_2_n_0\
    );
\timeout_cnt[8]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(10),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[8]_i_3_n_0\
    );
\timeout_cnt[8]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(9),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[8]_i_4_n_0\
    );
\timeout_cnt[8]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA80000AAA8AAA8"
    )
        port map (
      I0 => timeout_cnt_reg(8),
      I1 => \state__0\(1),
      I2 => \state__0\(2),
      I3 => \state__0\(0),
      I4 => ps2_clk_sync,
      I5 => ps2_clk_prev,
      O => \timeout_cnt[8]_i_5_n_0\
    );
\timeout_cnt_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[0]_i_1_n_7\,
      Q => \timeout_cnt_reg_n_0_[0]\
    );
\timeout_cnt_reg[0]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \timeout_cnt_reg[0]_i_1_n_0\,
      CO(2) => \timeout_cnt_reg[0]_i_1_n_1\,
      CO(1) => \timeout_cnt_reg[0]_i_1_n_2\,
      CO(0) => \timeout_cnt_reg[0]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 1) => B"000",
      DI(0) => \timeout_cnt[0]_i_2_n_0\,
      O(3) => \timeout_cnt_reg[0]_i_1_n_4\,
      O(2) => \timeout_cnt_reg[0]_i_1_n_5\,
      O(1) => \timeout_cnt_reg[0]_i_1_n_6\,
      O(0) => \timeout_cnt_reg[0]_i_1_n_7\,
      S(3) => \timeout_cnt[0]_i_3_n_0\,
      S(2) => \timeout_cnt[0]_i_4_n_0\,
      S(1) => \timeout_cnt[0]_i_5_n_0\,
      S(0) => \timeout_cnt[0]_i_6_n_0\
    );
\timeout_cnt_reg[10]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[8]_i_1_n_5\,
      Q => timeout_cnt_reg(10)
    );
\timeout_cnt_reg[11]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[8]_i_1_n_4\,
      Q => timeout_cnt_reg(11)
    );
\timeout_cnt_reg[12]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[12]_i_1_n_7\,
      Q => timeout_cnt_reg(12)
    );
\timeout_cnt_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \timeout_cnt_reg[8]_i_1_n_0\,
      CO(3) => \timeout_cnt_reg[12]_i_1_n_0\,
      CO(2) => \timeout_cnt_reg[12]_i_1_n_1\,
      CO(1) => \timeout_cnt_reg[12]_i_1_n_2\,
      CO(0) => \timeout_cnt_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \timeout_cnt_reg[12]_i_1_n_4\,
      O(2) => \timeout_cnt_reg[12]_i_1_n_5\,
      O(1) => \timeout_cnt_reg[12]_i_1_n_6\,
      O(0) => \timeout_cnt_reg[12]_i_1_n_7\,
      S(3) => \timeout_cnt[12]_i_2_n_0\,
      S(2) => \timeout_cnt[12]_i_3_n_0\,
      S(1) => \timeout_cnt[12]_i_4_n_0\,
      S(0) => \timeout_cnt[12]_i_5_n_0\
    );
\timeout_cnt_reg[13]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[12]_i_1_n_6\,
      Q => timeout_cnt_reg(13)
    );
\timeout_cnt_reg[14]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[12]_i_1_n_5\,
      Q => timeout_cnt_reg(14)
    );
\timeout_cnt_reg[15]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[12]_i_1_n_4\,
      Q => timeout_cnt_reg(15)
    );
\timeout_cnt_reg[16]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[16]_i_1_n_7\,
      Q => timeout_cnt_reg(16)
    );
\timeout_cnt_reg[16]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \timeout_cnt_reg[12]_i_1_n_0\,
      CO(3) => \NLW_timeout_cnt_reg[16]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \timeout_cnt_reg[16]_i_1_n_1\,
      CO(1) => \timeout_cnt_reg[16]_i_1_n_2\,
      CO(0) => \timeout_cnt_reg[16]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \timeout_cnt_reg[16]_i_1_n_4\,
      O(2) => \timeout_cnt_reg[16]_i_1_n_5\,
      O(1) => \timeout_cnt_reg[16]_i_1_n_6\,
      O(0) => \timeout_cnt_reg[16]_i_1_n_7\,
      S(3) => \timeout_cnt[16]_i_2_n_0\,
      S(2) => \timeout_cnt[16]_i_3_n_0\,
      S(1) => \timeout_cnt[16]_i_4_n_0\,
      S(0) => \timeout_cnt[16]_i_5_n_0\
    );
\timeout_cnt_reg[17]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[16]_i_1_n_6\,
      Q => timeout_cnt_reg(17)
    );
\timeout_cnt_reg[18]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[16]_i_1_n_5\,
      Q => timeout_cnt_reg(18)
    );
\timeout_cnt_reg[19]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[16]_i_1_n_4\,
      Q => timeout_cnt_reg(19)
    );
\timeout_cnt_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[0]_i_1_n_6\,
      Q => \timeout_cnt_reg_n_0_[1]\
    );
\timeout_cnt_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[0]_i_1_n_5\,
      Q => \timeout_cnt_reg_n_0_[2]\
    );
\timeout_cnt_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[0]_i_1_n_4\,
      Q => \timeout_cnt_reg_n_0_[3]\
    );
\timeout_cnt_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[4]_i_1_n_7\,
      Q => \timeout_cnt_reg_n_0_[4]\
    );
\timeout_cnt_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \timeout_cnt_reg[0]_i_1_n_0\,
      CO(3) => \timeout_cnt_reg[4]_i_1_n_0\,
      CO(2) => \timeout_cnt_reg[4]_i_1_n_1\,
      CO(1) => \timeout_cnt_reg[4]_i_1_n_2\,
      CO(0) => \timeout_cnt_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \timeout_cnt_reg[4]_i_1_n_4\,
      O(2) => \timeout_cnt_reg[4]_i_1_n_5\,
      O(1) => \timeout_cnt_reg[4]_i_1_n_6\,
      O(0) => \timeout_cnt_reg[4]_i_1_n_7\,
      S(3) => \timeout_cnt[4]_i_2_n_0\,
      S(2) => \timeout_cnt[4]_i_3_n_0\,
      S(1) => \timeout_cnt[4]_i_4_n_0\,
      S(0) => \timeout_cnt[4]_i_5_n_0\
    );
\timeout_cnt_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[4]_i_1_n_6\,
      Q => \timeout_cnt_reg_n_0_[5]\
    );
\timeout_cnt_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[4]_i_1_n_5\,
      Q => timeout_cnt_reg(6)
    );
\timeout_cnt_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[4]_i_1_n_4\,
      Q => timeout_cnt_reg(7)
    );
\timeout_cnt_reg[8]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[8]_i_1_n_7\,
      Q => timeout_cnt_reg(8)
    );
\timeout_cnt_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \timeout_cnt_reg[4]_i_1_n_0\,
      CO(3) => \timeout_cnt_reg[8]_i_1_n_0\,
      CO(2) => \timeout_cnt_reg[8]_i_1_n_1\,
      CO(1) => \timeout_cnt_reg[8]_i_1_n_2\,
      CO(0) => \timeout_cnt_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \timeout_cnt_reg[8]_i_1_n_4\,
      O(2) => \timeout_cnt_reg[8]_i_1_n_5\,
      O(1) => \timeout_cnt_reg[8]_i_1_n_6\,
      O(0) => \timeout_cnt_reg[8]_i_1_n_7\,
      S(3) => \timeout_cnt[8]_i_2_n_0\,
      S(2) => \timeout_cnt[8]_i_3_n_0\,
      S(1) => \timeout_cnt[8]_i_4_n_0\,
      S(0) => \timeout_cnt[8]_i_5_n_0\
    );
\timeout_cnt_reg[9]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => \timeout_cnt_reg[8]_i_1_n_6\,
      Q => timeout_cnt_reg(9)
    );
tx_active_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFF7000000050000"
    )
        port map (
      I0 => tx_active_i_2_n_0,
      I1 => tx_active_i_3_n_0,
      I2 => \state__0\(0),
      I3 => \state__0\(1),
      I4 => \FSM_sequential_state[2]_i_6_n_0\,
      I5 => ps2_clk_en,
      O => tx_active_i_1_n_0
    );
tx_active_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"EF"
    )
        port map (
      I0 => \state__0\(2),
      I1 => ps2_clk_en,
      I2 => tx_en_reg_reg,
      O => tx_active_i_2_n_0
    );
tx_active_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => \state__0\(2),
      I1 => ps2_clk_prev,
      I2 => ps2_clk_sync,
      O => tx_active_i_3_n_0
    );
tx_active_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_active_i_1_n_0,
      Q => ps2_clk_en
    );
\tx_data_reg[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000001000000"
    )
        port map (
      I0 => \bit_cnt[3]_i_4_n_0\,
      I1 => s_axi_awaddr(3),
      I2 => s_axi_awaddr(0),
      I3 => s_axi_awaddr(2),
      I4 => s_axi_awaddr(1),
      I5 => tx_en_reg_reg_0,
      O => \s_axi_awaddr[5]\(0)
    );
tx_en_reg_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"88888888B8888888"
    )
        port map (
      I0 => ps2_clk_en,
      I1 => tx_en_reg_reg,
      I2 => tx_en_reg_reg_1,
      I3 => s_axi_awaddr(2),
      I4 => s_axi_awaddr(1),
      I5 => tx_en_reg_reg_0,
      O => tx_active_reg_0
    );
\tx_shift_reg[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \tx_shift_reg_reg_n_0_[1]\,
      I1 => \state__0\(1),
      I2 => \tx_shift_reg_reg[7]_0\(0),
      O => tx_shift_reg(0)
    );
\tx_shift_reg[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \tx_shift_reg_reg_n_0_[2]\,
      I1 => \state__0\(1),
      I2 => \tx_shift_reg_reg[7]_0\(1),
      O => tx_shift_reg(1)
    );
\tx_shift_reg[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \tx_shift_reg_reg_n_0_[3]\,
      I1 => \state__0\(1),
      I2 => \tx_shift_reg_reg[7]_0\(2),
      O => tx_shift_reg(2)
    );
\tx_shift_reg[3]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \tx_shift_reg_reg_n_0_[4]\,
      I1 => \state__0\(1),
      I2 => \tx_shift_reg_reg[7]_0\(3),
      O => tx_shift_reg(3)
    );
\tx_shift_reg[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \tx_shift_reg_reg_n_0_[5]\,
      I1 => \state__0\(1),
      I2 => \tx_shift_reg_reg[7]_0\(4),
      O => tx_shift_reg(4)
    );
\tx_shift_reg[5]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \tx_shift_reg_reg_n_0_[6]\,
      I1 => \state__0\(1),
      I2 => \tx_shift_reg_reg[7]_0\(5),
      O => tx_shift_reg(5)
    );
\tx_shift_reg[6]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \tx_shift_reg_reg_n_0_[7]\,
      I1 => \state__0\(1),
      I2 => \tx_shift_reg_reg[7]_0\(6),
      O => tx_shift_reg(6)
    );
\tx_shift_reg[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0002000002020200"
    )
        port map (
      I0 => \FSM_sequential_state[2]_i_6_n_0\,
      I1 => \state__0\(0),
      I2 => \state__0\(2),
      I3 => \state__0\(1),
      I4 => \bit_cnt[3]_i_4_n_0\,
      I5 => \FSM_sequential_state[1]_i_2_n_0\,
      O => \tx_shift_reg[7]_i_1_n_0\
    );
\tx_shift_reg[7]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \tx_shift_reg_reg[7]_0\(7),
      I1 => \state__0\(1),
      O => tx_shift_reg(7)
    );
\tx_shift_reg_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(0),
      Q => \tx_shift_reg_reg_n_0_[0]\
    );
\tx_shift_reg_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(1),
      Q => \tx_shift_reg_reg_n_0_[1]\
    );
\tx_shift_reg_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(2),
      Q => \tx_shift_reg_reg_n_0_[2]\
    );
\tx_shift_reg_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(3),
      Q => \tx_shift_reg_reg_n_0_[3]\
    );
\tx_shift_reg_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(4),
      Q => \tx_shift_reg_reg_n_0_[4]\
    );
\tx_shift_reg_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(5),
      Q => \tx_shift_reg_reg_n_0_[5]\
    );
\tx_shift_reg_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(6),
      Q => \tx_shift_reg_reg_n_0_[6]\
    );
\tx_shift_reg_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \tx_shift_reg[7]_i_1_n_0\,
      CLR => \FSM_sequential_state[2]_i_2_n_0\,
      D => tx_shift_reg(7),
      Q => \tx_shift_reg_reg_n_0_[7]\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_ps2_host_axi_0_0_ps2_host_axi is
  port (
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_awready : out STD_LOGIC;
    s_axi_bvalid : out STD_LOGIC;
    r_valid_reg_reg_0 : out STD_LOGIC;
    ps2_clk : inout STD_LOGIC;
    ps2_data : inout STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_aclk : in STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_awvalid : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_rready : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_ps2_host_axi_0_0_ps2_host_axi : entity is "ps2_host_axi";
end design_1_ps2_host_axi_0_0_ps2_host_axi;

architecture STRUCTURE of design_1_ps2_host_axi_0_0_ps2_host_axi is
  signal \^e\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal b_valid_reg_i_1_n_0 : STD_LOGIC;
  signal b_valid_reg_i_2_n_0 : STD_LOGIC;
  signal data3 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal data5 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal parity_err_latched : STD_LOGIC;
  signal parity_err_reg : STD_LOGIC;
  signal ps2_rx_valid : STD_LOGIC;
  signal \r_data_reg[0]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[0]_i_3_n_0\ : STD_LOGIC;
  signal \r_data_reg[10]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[10]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[11]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[11]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[12]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[12]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[13]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[13]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[14]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[14]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[15]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[15]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[16]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[16]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[17]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[17]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[18]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[18]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[19]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[19]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[1]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[1]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[1]_i_3_n_0\ : STD_LOGIC;
  signal \r_data_reg[20]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[20]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[21]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[21]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[22]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[22]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[23]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[23]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[24]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[24]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[25]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[25]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[26]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[26]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[27]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[27]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[28]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[28]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[28]_i_3_n_0\ : STD_LOGIC;
  signal \r_data_reg[29]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[29]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[2]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[30]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[30]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[31]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[31]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[31]_i_3_n_0\ : STD_LOGIC;
  signal \r_data_reg[3]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[3]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[4]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[5]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[5]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[6]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[6]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[7]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[8]_i_2_n_0\ : STD_LOGIC;
  signal \r_data_reg[9]_i_1_n_0\ : STD_LOGIC;
  signal \r_data_reg[9]_i_2_n_0\ : STD_LOGIC;
  signal r_valid_reg_i_1_n_0 : STD_LOGIC;
  signal \^r_valid_reg_reg_0\ : STD_LOGIC;
  signal rx_data_latched : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal rx_data_new : STD_LOGIC;
  signal rx_data_new_i_2_n_0 : STD_LOGIC;
  signal rx_shift_reg : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \^s_axi_awready\ : STD_LOGIC;
  signal \^s_axi_bvalid\ : STD_LOGIC;
  signal soft_rst_n : STD_LOGIC;
  signal soft_rst_n_i_1_n_0 : STD_LOGIC;
  signal soft_rst_n_i_2_n_0 : STD_LOGIC;
  signal \ts_counter[0]_i_2_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[0]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[16]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[20]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[24]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[28]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[32]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[36]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[40]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[44]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[48]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[52]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[56]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[60]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[60]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[60]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[60]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[60]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[60]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[60]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \ts_counter_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[0]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[10]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[11]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[12]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[13]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[14]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[15]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[16]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[17]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[18]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[19]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[1]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[20]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[21]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[22]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[23]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[24]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[25]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[26]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[27]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[28]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[29]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[2]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[30]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[31]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[3]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[4]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[5]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[6]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[7]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[8]\ : STD_LOGIC;
  signal \ts_counter_reg_n_0_[9]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[0]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[10]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[11]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[12]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[13]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[14]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[15]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[16]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[17]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[18]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[19]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[1]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[20]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[21]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[22]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[23]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[24]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[25]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[26]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[27]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[28]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[29]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[2]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[30]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[31]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[3]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[4]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[5]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[6]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[7]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[8]\ : STD_LOGIC;
  signal \ts_latched_reg_n_0_[9]\ : STD_LOGIC;
  signal tx_data_reg : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \tx_data_reg[7]_i_2_n_0\ : STD_LOGIC;
  signal tx_en_reg_reg_n_0 : STD_LOGIC;
  signal u_ps2_host_n_11 : STD_LOGIC;
  signal u_ps2_host_n_12 : STD_LOGIC;
  signal u_ps2_host_n_13 : STD_LOGIC;
  signal u_ps2_host_n_2 : STD_LOGIC;
  signal \NLW_ts_counter_reg[60]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of b_valid_reg_i_1 : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of s_axi_wready_INST_0 : label is "soft_lutpair10";
begin
  E(0) <= \^e\(0);
  r_valid_reg_reg_0 <= \^r_valid_reg_reg_0\;
  s_axi_awready <= \^s_axi_awready\;
  s_axi_bvalid <= \^s_axi_bvalid\;
b_valid_reg_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7444"
    )
        port map (
      I0 => s_axi_bready,
      I1 => \^s_axi_bvalid\,
      I2 => s_axi_awvalid,
      I3 => s_axi_wvalid,
      O => b_valid_reg_i_1_n_0
    );
b_valid_reg_i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => rst_n,
      O => b_valid_reg_i_2_n_0
    );
b_valid_reg_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => b_valid_reg_i_1_n_0,
      Q => \^s_axi_bvalid\
    );
parity_err_latched_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => parity_err_reg,
      Q => parity_err_latched
    );
\r_data_reg[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8888CC8C88880080"
    )
        port map (
      I0 => \r_data_reg[0]_i_2_n_0\,
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => s_axi_araddr(3),
      I3 => s_axi_araddr(0),
      I4 => s_axi_araddr(1),
      I5 => \r_data_reg[0]_i_3_n_0\,
      O => \r_data_reg[0]_i_1_n_0\
    );
\r_data_reg[0]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(0),
      I1 => \ts_counter_reg_n_0_[0]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[0]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(0),
      O => \r_data_reg[0]_i_2_n_0\
    );
\r_data_reg[0]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"3808"
    )
        port map (
      I0 => rx_data_new,
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(4),
      I3 => data3(0),
      O => \r_data_reg[0]_i_3_n_0\
    );
\r_data_reg[10]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000088CCC0"
    )
        port map (
      I0 => data3(10),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \ts_counter_reg_n_0_[10]\,
      I3 => s_axi_araddr(2),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[10]_i_2_n_0\,
      O => \r_data_reg[10]_i_1_n_0\
    );
\r_data_reg[10]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(10),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[10]\,
      O => \r_data_reg[10]_i_2_n_0\
    );
\r_data_reg[11]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[11]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[11]\,
      I2 => s_axi_araddr(2),
      I3 => data5(11),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[11]_i_1_n_0\
    );
\r_data_reg[11]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(11),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[11]\,
      O => \r_data_reg[11]_i_2_n_0\
    );
\r_data_reg[12]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000088CCC0"
    )
        port map (
      I0 => data3(12),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \ts_counter_reg_n_0_[12]\,
      I3 => s_axi_araddr(2),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[12]_i_2_n_0\,
      O => \r_data_reg[12]_i_1_n_0\
    );
\r_data_reg[12]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(12),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[12]\,
      O => \r_data_reg[12]_i_2_n_0\
    );
\r_data_reg[13]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[13]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[13]\,
      I2 => s_axi_araddr(2),
      I3 => data5(13),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[13]_i_1_n_0\
    );
\r_data_reg[13]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(13),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[13]\,
      O => \r_data_reg[13]_i_2_n_0\
    );
\r_data_reg[14]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[14]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[14]\,
      I2 => s_axi_araddr(2),
      I3 => data5(14),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[14]_i_1_n_0\
    );
\r_data_reg[14]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(14),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[14]\,
      O => \r_data_reg[14]_i_2_n_0\
    );
\r_data_reg[15]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[15]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[15]\,
      I2 => s_axi_araddr(2),
      I3 => data5(15),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[15]_i_1_n_0\
    );
\r_data_reg[15]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(15),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[15]\,
      O => \r_data_reg[15]_i_2_n_0\
    );
\r_data_reg[16]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[16]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[16]\,
      I2 => s_axi_araddr(2),
      I3 => data5(16),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[16]_i_1_n_0\
    );
\r_data_reg[16]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(16),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[16]\,
      O => \r_data_reg[16]_i_2_n_0\
    );
\r_data_reg[17]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[17]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[17]\,
      I2 => s_axi_araddr(2),
      I3 => data5(17),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[17]_i_1_n_0\
    );
\r_data_reg[17]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(17),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[17]\,
      O => \r_data_reg[17]_i_2_n_0\
    );
\r_data_reg[18]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000088CCC0"
    )
        port map (
      I0 => data3(18),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \ts_counter_reg_n_0_[18]\,
      I3 => s_axi_araddr(2),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[18]_i_2_n_0\,
      O => \r_data_reg[18]_i_1_n_0\
    );
\r_data_reg[18]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(18),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[18]\,
      O => \r_data_reg[18]_i_2_n_0\
    );
\r_data_reg[19]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[19]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[19]\,
      I2 => s_axi_araddr(2),
      I3 => data5(19),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[19]_i_1_n_0\
    );
\r_data_reg[19]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(19),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[19]\,
      O => \r_data_reg[19]_i_2_n_0\
    );
\r_data_reg[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8888CC8C88880080"
    )
        port map (
      I0 => \r_data_reg[1]_i_2_n_0\,
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => s_axi_araddr(3),
      I3 => s_axi_araddr(0),
      I4 => s_axi_araddr(1),
      I5 => \r_data_reg[1]_i_3_n_0\,
      O => \r_data_reg[1]_i_1_n_0\
    );
\r_data_reg[1]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(1),
      I1 => \ts_counter_reg_n_0_[1]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[1]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(1),
      O => \r_data_reg[1]_i_2_n_0\
    );
\r_data_reg[1]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"3808"
    )
        port map (
      I0 => parity_err_latched,
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(4),
      I3 => data3(1),
      O => \r_data_reg[1]_i_3_n_0\
    );
\r_data_reg[20]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000008080C0C0C00"
    )
        port map (
      I0 => data3(20),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \r_data_reg[20]_i_2_n_0\,
      I3 => \ts_counter_reg_n_0_[20]\,
      I4 => s_axi_araddr(2),
      I5 => \r_data_reg[28]_i_2_n_0\,
      O => \r_data_reg[20]_i_1_n_0\
    );
\r_data_reg[20]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(20),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[20]\,
      O => \r_data_reg[20]_i_2_n_0\
    );
\r_data_reg[21]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000088CCC0"
    )
        port map (
      I0 => data3(21),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \ts_counter_reg_n_0_[21]\,
      I3 => s_axi_araddr(2),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[21]_i_2_n_0\,
      O => \r_data_reg[21]_i_1_n_0\
    );
\r_data_reg[21]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(21),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[21]\,
      O => \r_data_reg[21]_i_2_n_0\
    );
\r_data_reg[22]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000088CCC0"
    )
        port map (
      I0 => data3(22),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \ts_counter_reg_n_0_[22]\,
      I3 => s_axi_araddr(2),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[22]_i_2_n_0\,
      O => \r_data_reg[22]_i_1_n_0\
    );
\r_data_reg[22]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(22),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[22]\,
      O => \r_data_reg[22]_i_2_n_0\
    );
\r_data_reg[23]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000008080C0C0C00"
    )
        port map (
      I0 => data3(23),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \r_data_reg[23]_i_2_n_0\,
      I3 => \ts_counter_reg_n_0_[23]\,
      I4 => s_axi_araddr(2),
      I5 => \r_data_reg[28]_i_2_n_0\,
      O => \r_data_reg[23]_i_1_n_0\
    );
\r_data_reg[23]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(23),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[23]\,
      O => \r_data_reg[23]_i_2_n_0\
    );
\r_data_reg[24]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[24]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[24]\,
      I2 => s_axi_araddr(2),
      I3 => data5(24),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[24]_i_1_n_0\
    );
\r_data_reg[24]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(24),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[24]\,
      O => \r_data_reg[24]_i_2_n_0\
    );
\r_data_reg[25]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000008080C0C0C00"
    )
        port map (
      I0 => data3(25),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \r_data_reg[25]_i_2_n_0\,
      I3 => \ts_counter_reg_n_0_[25]\,
      I4 => s_axi_araddr(2),
      I5 => \r_data_reg[28]_i_2_n_0\,
      O => \r_data_reg[25]_i_1_n_0\
    );
\r_data_reg[25]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(25),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[25]\,
      O => \r_data_reg[25]_i_2_n_0\
    );
\r_data_reg[26]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000088CCC0"
    )
        port map (
      I0 => data3(26),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \ts_counter_reg_n_0_[26]\,
      I3 => s_axi_araddr(2),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[26]_i_2_n_0\,
      O => \r_data_reg[26]_i_1_n_0\
    );
\r_data_reg[26]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(26),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[26]\,
      O => \r_data_reg[26]_i_2_n_0\
    );
\r_data_reg[27]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[27]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[27]\,
      I2 => s_axi_araddr(2),
      I3 => data5(27),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[27]_i_1_n_0\
    );
\r_data_reg[27]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(27),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[27]\,
      O => \r_data_reg[27]_i_2_n_0\
    );
\r_data_reg[28]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000088CCC0"
    )
        port map (
      I0 => data3(28),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \ts_counter_reg_n_0_[28]\,
      I3 => s_axi_araddr(2),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[28]_i_3_n_0\,
      O => \r_data_reg[28]_i_1_n_0\
    );
\r_data_reg[28]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"45"
    )
        port map (
      I0 => s_axi_araddr(1),
      I1 => s_axi_araddr(0),
      I2 => s_axi_araddr(3),
      O => \r_data_reg[28]_i_2_n_0\
    );
\r_data_reg[28]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(28),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[28]\,
      O => \r_data_reg[28]_i_3_n_0\
    );
\r_data_reg[29]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[29]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[29]\,
      I2 => s_axi_araddr(2),
      I3 => data5(29),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[29]_i_1_n_0\
    );
\r_data_reg[29]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(29),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[29]\,
      O => \r_data_reg[29]_i_2_n_0\
    );
\r_data_reg[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(2),
      I1 => \ts_counter_reg_n_0_[2]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[2]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(2),
      O => \r_data_reg[2]_i_2_n_0\
    );
\r_data_reg[30]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[30]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[30]\,
      I2 => s_axi_araddr(2),
      I3 => data5(30),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[30]_i_1_n_0\
    );
\r_data_reg[30]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(30),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[30]\,
      O => \r_data_reg[30]_i_2_n_0\
    );
\r_data_reg[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[31]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[31]\,
      I2 => s_axi_araddr(2),
      I3 => data5(31),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[31]_i_1_n_0\
    );
\r_data_reg[31]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(31),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[31]\,
      O => \r_data_reg[31]_i_2_n_0\
    );
\r_data_reg[31]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000001"
    )
        port map (
      I0 => s_axi_araddr(7),
      I1 => s_axi_araddr(5),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(1),
      I4 => s_axi_araddr(6),
      O => \r_data_reg[31]_i_3_n_0\
    );
\r_data_reg[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3000AAAA00000000"
    )
        port map (
      I0 => \r_data_reg[3]_i_2_n_0\,
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(4),
      I3 => data3(3),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[3]_i_1_n_0\
    );
\r_data_reg[3]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(3),
      I1 => \ts_counter_reg_n_0_[3]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[3]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(3),
      O => \r_data_reg[3]_i_2_n_0\
    );
\r_data_reg[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3000AAAA00000000"
    )
        port map (
      I0 => \r_data_reg[4]_i_2_n_0\,
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(4),
      I3 => data3(4),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[4]_i_1_n_0\
    );
\r_data_reg[4]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(4),
      I1 => \ts_counter_reg_n_0_[4]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[4]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(4),
      O => \r_data_reg[4]_i_2_n_0\
    );
\r_data_reg[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3000AAAA00000000"
    )
        port map (
      I0 => \r_data_reg[5]_i_2_n_0\,
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(4),
      I3 => data3(5),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[5]_i_1_n_0\
    );
\r_data_reg[5]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(5),
      I1 => \ts_counter_reg_n_0_[5]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[5]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(5),
      O => \r_data_reg[5]_i_2_n_0\
    );
\r_data_reg[6]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3000AAAA00000000"
    )
        port map (
      I0 => \r_data_reg[6]_i_2_n_0\,
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(4),
      I3 => data3(6),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[6]_i_1_n_0\
    );
\r_data_reg[6]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(6),
      I1 => \ts_counter_reg_n_0_[6]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[6]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(6),
      O => \r_data_reg[6]_i_2_n_0\
    );
\r_data_reg[7]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3000AAAA00000000"
    )
        port map (
      I0 => \r_data_reg[7]_i_2_n_0\,
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(4),
      I3 => data3(7),
      I4 => \r_data_reg[28]_i_2_n_0\,
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[7]_i_1_n_0\
    );
\r_data_reg[7]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => data5(7),
      I1 => \ts_counter_reg_n_0_[7]\,
      I2 => s_axi_araddr(4),
      I3 => \ts_latched_reg_n_0_[7]\,
      I4 => s_axi_araddr(2),
      I5 => rx_data_latched(7),
      O => \r_data_reg[7]_i_2_n_0\
    );
\r_data_reg[8]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AA0A808000000000"
    )
        port map (
      I0 => \r_data_reg[8]_i_2_n_0\,
      I1 => \ts_latched_reg_n_0_[8]\,
      I2 => s_axi_araddr(2),
      I3 => data5(8),
      I4 => s_axi_araddr(4),
      I5 => \r_data_reg[31]_i_3_n_0\,
      O => \r_data_reg[8]_i_1_n_0\
    );
\r_data_reg[8]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CFCCEFEECFCC2022"
    )
        port map (
      I0 => data3(8),
      I1 => s_axi_araddr(1),
      I2 => s_axi_araddr(0),
      I3 => s_axi_araddr(3),
      I4 => s_axi_araddr(2),
      I5 => \ts_counter_reg_n_0_[8]\,
      O => \r_data_reg[8]_i_2_n_0\
    );
\r_data_reg[9]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000008080C0C0C00"
    )
        port map (
      I0 => data3(9),
      I1 => \r_data_reg[31]_i_3_n_0\,
      I2 => \r_data_reg[9]_i_2_n_0\,
      I3 => \ts_counter_reg_n_0_[9]\,
      I4 => s_axi_araddr(2),
      I5 => \r_data_reg[28]_i_2_n_0\,
      O => \r_data_reg[9]_i_1_n_0\
    );
\r_data_reg[9]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4373"
    )
        port map (
      I0 => data5(9),
      I1 => s_axi_araddr(4),
      I2 => s_axi_araddr(2),
      I3 => \ts_latched_reg_n_0_[9]\,
      O => \r_data_reg[9]_i_2_n_0\
    );
\r_data_reg_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[0]_i_1_n_0\,
      Q => s_axi_rdata(0)
    );
\r_data_reg_reg[10]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[10]_i_1_n_0\,
      Q => s_axi_rdata(10)
    );
\r_data_reg_reg[11]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[11]_i_1_n_0\,
      Q => s_axi_rdata(11)
    );
\r_data_reg_reg[12]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[12]_i_1_n_0\,
      Q => s_axi_rdata(12)
    );
\r_data_reg_reg[13]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[13]_i_1_n_0\,
      Q => s_axi_rdata(13)
    );
\r_data_reg_reg[14]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[14]_i_1_n_0\,
      Q => s_axi_rdata(14)
    );
\r_data_reg_reg[15]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[15]_i_1_n_0\,
      Q => s_axi_rdata(15)
    );
\r_data_reg_reg[16]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[16]_i_1_n_0\,
      Q => s_axi_rdata(16)
    );
\r_data_reg_reg[17]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[17]_i_1_n_0\,
      Q => s_axi_rdata(17)
    );
\r_data_reg_reg[18]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[18]_i_1_n_0\,
      Q => s_axi_rdata(18)
    );
\r_data_reg_reg[19]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[19]_i_1_n_0\,
      Q => s_axi_rdata(19)
    );
\r_data_reg_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[1]_i_1_n_0\,
      Q => s_axi_rdata(1)
    );
\r_data_reg_reg[20]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[20]_i_1_n_0\,
      Q => s_axi_rdata(20)
    );
\r_data_reg_reg[21]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[21]_i_1_n_0\,
      Q => s_axi_rdata(21)
    );
\r_data_reg_reg[22]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[22]_i_1_n_0\,
      Q => s_axi_rdata(22)
    );
\r_data_reg_reg[23]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[23]_i_1_n_0\,
      Q => s_axi_rdata(23)
    );
\r_data_reg_reg[24]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[24]_i_1_n_0\,
      Q => s_axi_rdata(24)
    );
\r_data_reg_reg[25]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[25]_i_1_n_0\,
      Q => s_axi_rdata(25)
    );
\r_data_reg_reg[26]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[26]_i_1_n_0\,
      Q => s_axi_rdata(26)
    );
\r_data_reg_reg[27]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[27]_i_1_n_0\,
      Q => s_axi_rdata(27)
    );
\r_data_reg_reg[28]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[28]_i_1_n_0\,
      Q => s_axi_rdata(28)
    );
\r_data_reg_reg[29]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[29]_i_1_n_0\,
      Q => s_axi_rdata(29)
    );
\r_data_reg_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => u_ps2_host_n_11,
      Q => s_axi_rdata(2)
    );
\r_data_reg_reg[30]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[30]_i_1_n_0\,
      Q => s_axi_rdata(30)
    );
\r_data_reg_reg[31]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[31]_i_1_n_0\,
      Q => s_axi_rdata(31)
    );
\r_data_reg_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[3]_i_1_n_0\,
      Q => s_axi_rdata(3)
    );
\r_data_reg_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[4]_i_1_n_0\,
      Q => s_axi_rdata(4)
    );
\r_data_reg_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[5]_i_1_n_0\,
      Q => s_axi_rdata(5)
    );
\r_data_reg_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[6]_i_1_n_0\,
      Q => s_axi_rdata(6)
    );
\r_data_reg_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[7]_i_1_n_0\,
      Q => s_axi_rdata(7)
    );
\r_data_reg_reg[8]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[8]_i_1_n_0\,
      Q => s_axi_rdata(8)
    );
\r_data_reg_reg[9]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => \^e\(0),
      CLR => b_valid_reg_i_2_n_0,
      D => \r_data_reg[9]_i_1_n_0\,
      Q => s_axi_rdata(9)
    );
r_valid_reg_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"5C"
    )
        port map (
      I0 => s_axi_rready,
      I1 => s_axi_arvalid,
      I2 => \^r_valid_reg_reg_0\,
      O => r_valid_reg_i_1_n_0
    );
r_valid_reg_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => r_valid_reg_i_1_n_0,
      Q => \^r_valid_reg_reg_0\
    );
\rx_data_latched_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(0),
      Q => rx_data_latched(0)
    );
\rx_data_latched_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(1),
      Q => rx_data_latched(1)
    );
\rx_data_latched_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(2),
      Q => rx_data_latched(2)
    );
\rx_data_latched_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(3),
      Q => rx_data_latched(3)
    );
\rx_data_latched_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(4),
      Q => rx_data_latched(4)
    );
\rx_data_latched_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(5),
      Q => rx_data_latched(5)
    );
\rx_data_latched_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(6),
      Q => rx_data_latched(6)
    );
\rx_data_latched_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => rx_shift_reg(7),
      Q => rx_data_latched(7)
    );
rx_data_new_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFEFFFFF"
    )
        port map (
      I0 => s_axi_araddr(4),
      I1 => s_axi_araddr(2),
      I2 => s_axi_araddr(3),
      I3 => \^r_valid_reg_reg_0\,
      I4 => s_axi_arvalid,
      O => rx_data_new_i_2_n_0
    );
rx_data_new_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => u_ps2_host_n_12,
      Q => rx_data_new
    );
s_axi_arready_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => s_axi_arvalid,
      I1 => \^r_valid_reg_reg_0\,
      O => \^e\(0)
    );
s_axi_wready_INST_0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => s_axi_wvalid,
      I1 => s_axi_awvalid,
      I2 => \^s_axi_bvalid\,
      O => \^s_axi_awready\
    );
soft_rst_n_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFDFFFF00010000"
    )
        port map (
      I0 => s_axi_wdata(0),
      I1 => \tx_data_reg[7]_i_2_n_0\,
      I2 => s_axi_awaddr(2),
      I3 => s_axi_awaddr(4),
      I4 => soft_rst_n_i_2_n_0,
      I5 => soft_rst_n,
      O => soft_rst_n_i_1_n_0
    );
soft_rst_n_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => s_axi_awaddr(1),
      I1 => s_axi_awaddr(5),
      O => soft_rst_n_i_2_n_0
    );
soft_rst_n_reg: unisim.vcomponents.FDPE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => soft_rst_n_i_1_n_0,
      PRE => b_valid_reg_i_2_n_0,
      Q => soft_rst_n
    );
\ts_counter[0]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \ts_counter_reg_n_0_[0]\,
      O => \ts_counter[0]_i_2_n_0\
    );
\ts_counter_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[0]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[0]\
    );
\ts_counter_reg[0]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \ts_counter_reg[0]_i_1_n_0\,
      CO(2) => \ts_counter_reg[0]_i_1_n_1\,
      CO(1) => \ts_counter_reg[0]_i_1_n_2\,
      CO(0) => \ts_counter_reg[0]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \ts_counter_reg[0]_i_1_n_4\,
      O(2) => \ts_counter_reg[0]_i_1_n_5\,
      O(1) => \ts_counter_reg[0]_i_1_n_6\,
      O(0) => \ts_counter_reg[0]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[3]\,
      S(2) => \ts_counter_reg_n_0_[2]\,
      S(1) => \ts_counter_reg_n_0_[1]\,
      S(0) => \ts_counter[0]_i_2_n_0\
    );
\ts_counter_reg[10]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[8]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[10]\
    );
\ts_counter_reg[11]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[8]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[11]\
    );
\ts_counter_reg[12]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[12]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[12]\
    );
\ts_counter_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[8]_i_1_n_0\,
      CO(3) => \ts_counter_reg[12]_i_1_n_0\,
      CO(2) => \ts_counter_reg[12]_i_1_n_1\,
      CO(1) => \ts_counter_reg[12]_i_1_n_2\,
      CO(0) => \ts_counter_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[12]_i_1_n_4\,
      O(2) => \ts_counter_reg[12]_i_1_n_5\,
      O(1) => \ts_counter_reg[12]_i_1_n_6\,
      O(0) => \ts_counter_reg[12]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[15]\,
      S(2) => \ts_counter_reg_n_0_[14]\,
      S(1) => \ts_counter_reg_n_0_[13]\,
      S(0) => \ts_counter_reg_n_0_[12]\
    );
\ts_counter_reg[13]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[12]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[13]\
    );
\ts_counter_reg[14]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[12]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[14]\
    );
\ts_counter_reg[15]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[12]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[15]\
    );
\ts_counter_reg[16]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[16]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[16]\
    );
\ts_counter_reg[16]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[12]_i_1_n_0\,
      CO(3) => \ts_counter_reg[16]_i_1_n_0\,
      CO(2) => \ts_counter_reg[16]_i_1_n_1\,
      CO(1) => \ts_counter_reg[16]_i_1_n_2\,
      CO(0) => \ts_counter_reg[16]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[16]_i_1_n_4\,
      O(2) => \ts_counter_reg[16]_i_1_n_5\,
      O(1) => \ts_counter_reg[16]_i_1_n_6\,
      O(0) => \ts_counter_reg[16]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[19]\,
      S(2) => \ts_counter_reg_n_0_[18]\,
      S(1) => \ts_counter_reg_n_0_[17]\,
      S(0) => \ts_counter_reg_n_0_[16]\
    );
\ts_counter_reg[17]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[16]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[17]\
    );
\ts_counter_reg[18]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[16]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[18]\
    );
\ts_counter_reg[19]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[16]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[19]\
    );
\ts_counter_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[0]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[1]\
    );
\ts_counter_reg[20]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[20]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[20]\
    );
\ts_counter_reg[20]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[16]_i_1_n_0\,
      CO(3) => \ts_counter_reg[20]_i_1_n_0\,
      CO(2) => \ts_counter_reg[20]_i_1_n_1\,
      CO(1) => \ts_counter_reg[20]_i_1_n_2\,
      CO(0) => \ts_counter_reg[20]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[20]_i_1_n_4\,
      O(2) => \ts_counter_reg[20]_i_1_n_5\,
      O(1) => \ts_counter_reg[20]_i_1_n_6\,
      O(0) => \ts_counter_reg[20]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[23]\,
      S(2) => \ts_counter_reg_n_0_[22]\,
      S(1) => \ts_counter_reg_n_0_[21]\,
      S(0) => \ts_counter_reg_n_0_[20]\
    );
\ts_counter_reg[21]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[20]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[21]\
    );
\ts_counter_reg[22]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[20]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[22]\
    );
\ts_counter_reg[23]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[20]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[23]\
    );
\ts_counter_reg[24]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[24]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[24]\
    );
\ts_counter_reg[24]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[20]_i_1_n_0\,
      CO(3) => \ts_counter_reg[24]_i_1_n_0\,
      CO(2) => \ts_counter_reg[24]_i_1_n_1\,
      CO(1) => \ts_counter_reg[24]_i_1_n_2\,
      CO(0) => \ts_counter_reg[24]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[24]_i_1_n_4\,
      O(2) => \ts_counter_reg[24]_i_1_n_5\,
      O(1) => \ts_counter_reg[24]_i_1_n_6\,
      O(0) => \ts_counter_reg[24]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[27]\,
      S(2) => \ts_counter_reg_n_0_[26]\,
      S(1) => \ts_counter_reg_n_0_[25]\,
      S(0) => \ts_counter_reg_n_0_[24]\
    );
\ts_counter_reg[25]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[24]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[25]\
    );
\ts_counter_reg[26]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[24]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[26]\
    );
\ts_counter_reg[27]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[24]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[27]\
    );
\ts_counter_reg[28]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[28]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[28]\
    );
\ts_counter_reg[28]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[24]_i_1_n_0\,
      CO(3) => \ts_counter_reg[28]_i_1_n_0\,
      CO(2) => \ts_counter_reg[28]_i_1_n_1\,
      CO(1) => \ts_counter_reg[28]_i_1_n_2\,
      CO(0) => \ts_counter_reg[28]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[28]_i_1_n_4\,
      O(2) => \ts_counter_reg[28]_i_1_n_5\,
      O(1) => \ts_counter_reg[28]_i_1_n_6\,
      O(0) => \ts_counter_reg[28]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[31]\,
      S(2) => \ts_counter_reg_n_0_[30]\,
      S(1) => \ts_counter_reg_n_0_[29]\,
      S(0) => \ts_counter_reg_n_0_[28]\
    );
\ts_counter_reg[29]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[28]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[29]\
    );
\ts_counter_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[0]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[2]\
    );
\ts_counter_reg[30]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[28]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[30]\
    );
\ts_counter_reg[31]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[28]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[31]\
    );
\ts_counter_reg[32]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[32]_i_1_n_7\,
      Q => data5(0)
    );
\ts_counter_reg[32]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[28]_i_1_n_0\,
      CO(3) => \ts_counter_reg[32]_i_1_n_0\,
      CO(2) => \ts_counter_reg[32]_i_1_n_1\,
      CO(1) => \ts_counter_reg[32]_i_1_n_2\,
      CO(0) => \ts_counter_reg[32]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[32]_i_1_n_4\,
      O(2) => \ts_counter_reg[32]_i_1_n_5\,
      O(1) => \ts_counter_reg[32]_i_1_n_6\,
      O(0) => \ts_counter_reg[32]_i_1_n_7\,
      S(3 downto 0) => data5(3 downto 0)
    );
\ts_counter_reg[33]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[32]_i_1_n_6\,
      Q => data5(1)
    );
\ts_counter_reg[34]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[32]_i_1_n_5\,
      Q => data5(2)
    );
\ts_counter_reg[35]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[32]_i_1_n_4\,
      Q => data5(3)
    );
\ts_counter_reg[36]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[36]_i_1_n_7\,
      Q => data5(4)
    );
\ts_counter_reg[36]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[32]_i_1_n_0\,
      CO(3) => \ts_counter_reg[36]_i_1_n_0\,
      CO(2) => \ts_counter_reg[36]_i_1_n_1\,
      CO(1) => \ts_counter_reg[36]_i_1_n_2\,
      CO(0) => \ts_counter_reg[36]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[36]_i_1_n_4\,
      O(2) => \ts_counter_reg[36]_i_1_n_5\,
      O(1) => \ts_counter_reg[36]_i_1_n_6\,
      O(0) => \ts_counter_reg[36]_i_1_n_7\,
      S(3 downto 0) => data5(7 downto 4)
    );
\ts_counter_reg[37]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[36]_i_1_n_6\,
      Q => data5(5)
    );
\ts_counter_reg[38]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[36]_i_1_n_5\,
      Q => data5(6)
    );
\ts_counter_reg[39]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[36]_i_1_n_4\,
      Q => data5(7)
    );
\ts_counter_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[0]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[3]\
    );
\ts_counter_reg[40]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[40]_i_1_n_7\,
      Q => data5(8)
    );
\ts_counter_reg[40]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[36]_i_1_n_0\,
      CO(3) => \ts_counter_reg[40]_i_1_n_0\,
      CO(2) => \ts_counter_reg[40]_i_1_n_1\,
      CO(1) => \ts_counter_reg[40]_i_1_n_2\,
      CO(0) => \ts_counter_reg[40]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[40]_i_1_n_4\,
      O(2) => \ts_counter_reg[40]_i_1_n_5\,
      O(1) => \ts_counter_reg[40]_i_1_n_6\,
      O(0) => \ts_counter_reg[40]_i_1_n_7\,
      S(3 downto 0) => data5(11 downto 8)
    );
\ts_counter_reg[41]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[40]_i_1_n_6\,
      Q => data5(9)
    );
\ts_counter_reg[42]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[40]_i_1_n_5\,
      Q => data5(10)
    );
\ts_counter_reg[43]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[40]_i_1_n_4\,
      Q => data5(11)
    );
\ts_counter_reg[44]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[44]_i_1_n_7\,
      Q => data5(12)
    );
\ts_counter_reg[44]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[40]_i_1_n_0\,
      CO(3) => \ts_counter_reg[44]_i_1_n_0\,
      CO(2) => \ts_counter_reg[44]_i_1_n_1\,
      CO(1) => \ts_counter_reg[44]_i_1_n_2\,
      CO(0) => \ts_counter_reg[44]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[44]_i_1_n_4\,
      O(2) => \ts_counter_reg[44]_i_1_n_5\,
      O(1) => \ts_counter_reg[44]_i_1_n_6\,
      O(0) => \ts_counter_reg[44]_i_1_n_7\,
      S(3 downto 0) => data5(15 downto 12)
    );
\ts_counter_reg[45]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[44]_i_1_n_6\,
      Q => data5(13)
    );
\ts_counter_reg[46]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[44]_i_1_n_5\,
      Q => data5(14)
    );
\ts_counter_reg[47]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[44]_i_1_n_4\,
      Q => data5(15)
    );
\ts_counter_reg[48]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[48]_i_1_n_7\,
      Q => data5(16)
    );
\ts_counter_reg[48]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[44]_i_1_n_0\,
      CO(3) => \ts_counter_reg[48]_i_1_n_0\,
      CO(2) => \ts_counter_reg[48]_i_1_n_1\,
      CO(1) => \ts_counter_reg[48]_i_1_n_2\,
      CO(0) => \ts_counter_reg[48]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[48]_i_1_n_4\,
      O(2) => \ts_counter_reg[48]_i_1_n_5\,
      O(1) => \ts_counter_reg[48]_i_1_n_6\,
      O(0) => \ts_counter_reg[48]_i_1_n_7\,
      S(3 downto 0) => data5(19 downto 16)
    );
\ts_counter_reg[49]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[48]_i_1_n_6\,
      Q => data5(17)
    );
\ts_counter_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[4]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[4]\
    );
\ts_counter_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[0]_i_1_n_0\,
      CO(3) => \ts_counter_reg[4]_i_1_n_0\,
      CO(2) => \ts_counter_reg[4]_i_1_n_1\,
      CO(1) => \ts_counter_reg[4]_i_1_n_2\,
      CO(0) => \ts_counter_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[4]_i_1_n_4\,
      O(2) => \ts_counter_reg[4]_i_1_n_5\,
      O(1) => \ts_counter_reg[4]_i_1_n_6\,
      O(0) => \ts_counter_reg[4]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[7]\,
      S(2) => \ts_counter_reg_n_0_[6]\,
      S(1) => \ts_counter_reg_n_0_[5]\,
      S(0) => \ts_counter_reg_n_0_[4]\
    );
\ts_counter_reg[50]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[48]_i_1_n_5\,
      Q => data5(18)
    );
\ts_counter_reg[51]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[48]_i_1_n_4\,
      Q => data5(19)
    );
\ts_counter_reg[52]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[52]_i_1_n_7\,
      Q => data5(20)
    );
\ts_counter_reg[52]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[48]_i_1_n_0\,
      CO(3) => \ts_counter_reg[52]_i_1_n_0\,
      CO(2) => \ts_counter_reg[52]_i_1_n_1\,
      CO(1) => \ts_counter_reg[52]_i_1_n_2\,
      CO(0) => \ts_counter_reg[52]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[52]_i_1_n_4\,
      O(2) => \ts_counter_reg[52]_i_1_n_5\,
      O(1) => \ts_counter_reg[52]_i_1_n_6\,
      O(0) => \ts_counter_reg[52]_i_1_n_7\,
      S(3 downto 0) => data5(23 downto 20)
    );
\ts_counter_reg[53]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[52]_i_1_n_6\,
      Q => data5(21)
    );
\ts_counter_reg[54]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[52]_i_1_n_5\,
      Q => data5(22)
    );
\ts_counter_reg[55]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[52]_i_1_n_4\,
      Q => data5(23)
    );
\ts_counter_reg[56]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[56]_i_1_n_7\,
      Q => data5(24)
    );
\ts_counter_reg[56]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[52]_i_1_n_0\,
      CO(3) => \ts_counter_reg[56]_i_1_n_0\,
      CO(2) => \ts_counter_reg[56]_i_1_n_1\,
      CO(1) => \ts_counter_reg[56]_i_1_n_2\,
      CO(0) => \ts_counter_reg[56]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[56]_i_1_n_4\,
      O(2) => \ts_counter_reg[56]_i_1_n_5\,
      O(1) => \ts_counter_reg[56]_i_1_n_6\,
      O(0) => \ts_counter_reg[56]_i_1_n_7\,
      S(3 downto 0) => data5(27 downto 24)
    );
\ts_counter_reg[57]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[56]_i_1_n_6\,
      Q => data5(25)
    );
\ts_counter_reg[58]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[56]_i_1_n_5\,
      Q => data5(26)
    );
\ts_counter_reg[59]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[56]_i_1_n_4\,
      Q => data5(27)
    );
\ts_counter_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[4]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[5]\
    );
\ts_counter_reg[60]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[60]_i_1_n_7\,
      Q => data5(28)
    );
\ts_counter_reg[60]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[56]_i_1_n_0\,
      CO(3) => \NLW_ts_counter_reg[60]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \ts_counter_reg[60]_i_1_n_1\,
      CO(1) => \ts_counter_reg[60]_i_1_n_2\,
      CO(0) => \ts_counter_reg[60]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[60]_i_1_n_4\,
      O(2) => \ts_counter_reg[60]_i_1_n_5\,
      O(1) => \ts_counter_reg[60]_i_1_n_6\,
      O(0) => \ts_counter_reg[60]_i_1_n_7\,
      S(3 downto 0) => data5(31 downto 28)
    );
\ts_counter_reg[61]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[60]_i_1_n_6\,
      Q => data5(29)
    );
\ts_counter_reg[62]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[60]_i_1_n_5\,
      Q => data5(30)
    );
\ts_counter_reg[63]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[60]_i_1_n_4\,
      Q => data5(31)
    );
\ts_counter_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[4]_i_1_n_5\,
      Q => \ts_counter_reg_n_0_[6]\
    );
\ts_counter_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[4]_i_1_n_4\,
      Q => \ts_counter_reg_n_0_[7]\
    );
\ts_counter_reg[8]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[8]_i_1_n_7\,
      Q => \ts_counter_reg_n_0_[8]\
    );
\ts_counter_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \ts_counter_reg[4]_i_1_n_0\,
      CO(3) => \ts_counter_reg[8]_i_1_n_0\,
      CO(2) => \ts_counter_reg[8]_i_1_n_1\,
      CO(1) => \ts_counter_reg[8]_i_1_n_2\,
      CO(0) => \ts_counter_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \ts_counter_reg[8]_i_1_n_4\,
      O(2) => \ts_counter_reg[8]_i_1_n_5\,
      O(1) => \ts_counter_reg[8]_i_1_n_6\,
      O(0) => \ts_counter_reg[8]_i_1_n_7\,
      S(3) => \ts_counter_reg_n_0_[11]\,
      S(2) => \ts_counter_reg_n_0_[10]\,
      S(1) => \ts_counter_reg_n_0_[9]\,
      S(0) => \ts_counter_reg_n_0_[8]\
    );
\ts_counter_reg[9]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg[8]_i_1_n_6\,
      Q => \ts_counter_reg_n_0_[9]\
    );
\ts_latched_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[0]\,
      Q => \ts_latched_reg_n_0_[0]\
    );
\ts_latched_reg[10]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[10]\,
      Q => \ts_latched_reg_n_0_[10]\
    );
\ts_latched_reg[11]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[11]\,
      Q => \ts_latched_reg_n_0_[11]\
    );
\ts_latched_reg[12]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[12]\,
      Q => \ts_latched_reg_n_0_[12]\
    );
\ts_latched_reg[13]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[13]\,
      Q => \ts_latched_reg_n_0_[13]\
    );
\ts_latched_reg[14]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[14]\,
      Q => \ts_latched_reg_n_0_[14]\
    );
\ts_latched_reg[15]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[15]\,
      Q => \ts_latched_reg_n_0_[15]\
    );
\ts_latched_reg[16]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[16]\,
      Q => \ts_latched_reg_n_0_[16]\
    );
\ts_latched_reg[17]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[17]\,
      Q => \ts_latched_reg_n_0_[17]\
    );
\ts_latched_reg[18]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[18]\,
      Q => \ts_latched_reg_n_0_[18]\
    );
\ts_latched_reg[19]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[19]\,
      Q => \ts_latched_reg_n_0_[19]\
    );
\ts_latched_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[1]\,
      Q => \ts_latched_reg_n_0_[1]\
    );
\ts_latched_reg[20]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[20]\,
      Q => \ts_latched_reg_n_0_[20]\
    );
\ts_latched_reg[21]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[21]\,
      Q => \ts_latched_reg_n_0_[21]\
    );
\ts_latched_reg[22]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[22]\,
      Q => \ts_latched_reg_n_0_[22]\
    );
\ts_latched_reg[23]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[23]\,
      Q => \ts_latched_reg_n_0_[23]\
    );
\ts_latched_reg[24]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[24]\,
      Q => \ts_latched_reg_n_0_[24]\
    );
\ts_latched_reg[25]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[25]\,
      Q => \ts_latched_reg_n_0_[25]\
    );
\ts_latched_reg[26]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[26]\,
      Q => \ts_latched_reg_n_0_[26]\
    );
\ts_latched_reg[27]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[27]\,
      Q => \ts_latched_reg_n_0_[27]\
    );
\ts_latched_reg[28]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[28]\,
      Q => \ts_latched_reg_n_0_[28]\
    );
\ts_latched_reg[29]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[29]\,
      Q => \ts_latched_reg_n_0_[29]\
    );
\ts_latched_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[2]\,
      Q => \ts_latched_reg_n_0_[2]\
    );
\ts_latched_reg[30]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[30]\,
      Q => \ts_latched_reg_n_0_[30]\
    );
\ts_latched_reg[31]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[31]\,
      Q => \ts_latched_reg_n_0_[31]\
    );
\ts_latched_reg[32]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(0),
      Q => data3(0)
    );
\ts_latched_reg[33]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(1),
      Q => data3(1)
    );
\ts_latched_reg[34]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(2),
      Q => data3(2)
    );
\ts_latched_reg[35]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(3),
      Q => data3(3)
    );
\ts_latched_reg[36]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(4),
      Q => data3(4)
    );
\ts_latched_reg[37]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(5),
      Q => data3(5)
    );
\ts_latched_reg[38]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(6),
      Q => data3(6)
    );
\ts_latched_reg[39]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(7),
      Q => data3(7)
    );
\ts_latched_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[3]\,
      Q => \ts_latched_reg_n_0_[3]\
    );
\ts_latched_reg[40]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(8),
      Q => data3(8)
    );
\ts_latched_reg[41]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(9),
      Q => data3(9)
    );
\ts_latched_reg[42]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(10),
      Q => data3(10)
    );
\ts_latched_reg[43]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(11),
      Q => data3(11)
    );
\ts_latched_reg[44]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(12),
      Q => data3(12)
    );
\ts_latched_reg[45]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(13),
      Q => data3(13)
    );
\ts_latched_reg[46]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(14),
      Q => data3(14)
    );
\ts_latched_reg[47]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(15),
      Q => data3(15)
    );
\ts_latched_reg[48]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(16),
      Q => data3(16)
    );
\ts_latched_reg[49]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(17),
      Q => data3(17)
    );
\ts_latched_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[4]\,
      Q => \ts_latched_reg_n_0_[4]\
    );
\ts_latched_reg[50]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(18),
      Q => data3(18)
    );
\ts_latched_reg[51]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(19),
      Q => data3(19)
    );
\ts_latched_reg[52]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(20),
      Q => data3(20)
    );
\ts_latched_reg[53]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(21),
      Q => data3(21)
    );
\ts_latched_reg[54]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(22),
      Q => data3(22)
    );
\ts_latched_reg[55]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(23),
      Q => data3(23)
    );
\ts_latched_reg[56]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(24),
      Q => data3(24)
    );
\ts_latched_reg[57]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(25),
      Q => data3(25)
    );
\ts_latched_reg[58]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(26),
      Q => data3(26)
    );
\ts_latched_reg[59]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(27),
      Q => data3(27)
    );
\ts_latched_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[5]\,
      Q => \ts_latched_reg_n_0_[5]\
    );
\ts_latched_reg[60]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(28),
      Q => data3(28)
    );
\ts_latched_reg[61]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(29),
      Q => data3(29)
    );
\ts_latched_reg[62]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(30),
      Q => data3(30)
    );
\ts_latched_reg[63]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => data5(31),
      Q => data3(31)
    );
\ts_latched_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[6]\,
      Q => \ts_latched_reg_n_0_[6]\
    );
\ts_latched_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[7]\,
      Q => \ts_latched_reg_n_0_[7]\
    );
\ts_latched_reg[8]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[8]\,
      Q => \ts_latched_reg_n_0_[8]\
    );
\ts_latched_reg[9]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => ps2_rx_valid,
      CLR => b_valid_reg_i_2_n_0,
      D => \ts_counter_reg_n_0_[9]\,
      Q => \ts_latched_reg_n_0_[9]\
    );
\tx_data_reg[7]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFEFFFF"
    )
        port map (
      I0 => s_axi_awaddr(6),
      I1 => s_axi_awaddr(3),
      I2 => s_axi_awaddr(7),
      I3 => s_axi_awaddr(0),
      I4 => \^s_axi_awready\,
      O => \tx_data_reg[7]_i_2_n_0\
    );
\tx_data_reg_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(0),
      Q => tx_data_reg(0)
    );
\tx_data_reg_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(1),
      Q => tx_data_reg(1)
    );
\tx_data_reg_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(2),
      Q => tx_data_reg(2)
    );
\tx_data_reg_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(3),
      Q => tx_data_reg(3)
    );
\tx_data_reg_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(4),
      Q => tx_data_reg(4)
    );
\tx_data_reg_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(5),
      Q => tx_data_reg(5)
    );
\tx_data_reg_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(6),
      Q => tx_data_reg(6)
    );
\tx_data_reg_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => u_ps2_host_n_2,
      CLR => b_valid_reg_i_2_n_0,
      D => s_axi_wdata(7),
      Q => tx_data_reg(7)
    );
tx_en_reg_reg: unisim.vcomponents.FDCE
     port map (
      C => s_axi_aclk,
      CE => '1',
      CLR => b_valid_reg_i_2_n_0,
      D => u_ps2_host_n_13,
      Q => tx_en_reg_reg_n_0
    );
u_ps2_host: entity work.design_1_ps2_host_axi_0_0_ps2_host
     port map (
      D(0) => u_ps2_host_n_11,
      E(0) => ps2_rx_valid,
      Q(7 downto 0) => rx_shift_reg(7 downto 0),
      parity_err_reg => parity_err_reg,
      ps2_clk => ps2_clk,
      ps2_data => ps2_data,
      \r_data_reg_reg[2]\ => \r_data_reg[2]_i_2_n_0\,
      \r_data_reg_reg[2]_0\(0) => data3(2),
      rst_n => rst_n,
      rx_data_new => rx_data_new,
      rx_data_new_reg => \r_data_reg[31]_i_3_n_0\,
      rx_data_new_reg_0 => rx_data_new_i_2_n_0,
      rx_valid_reg_reg_0 => u_ps2_host_n_12,
      s_axi_aclk => s_axi_aclk,
      s_axi_araddr(4 downto 0) => s_axi_araddr(4 downto 0),
      s_axi_awaddr(3 downto 2) => s_axi_awaddr(5 downto 4),
      s_axi_awaddr(1 downto 0) => s_axi_awaddr(2 downto 1),
      \s_axi_awaddr[5]\(0) => u_ps2_host_n_2,
      soft_rst_n => soft_rst_n,
      tx_active_reg_0 => u_ps2_host_n_13,
      tx_en_reg_reg => tx_en_reg_reg_n_0,
      tx_en_reg_reg_0 => \tx_data_reg[7]_i_2_n_0\,
      tx_en_reg_reg_1 => soft_rst_n_i_2_n_0,
      \tx_shift_reg_reg[7]_0\(7 downto 0) => tx_data_reg(7 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_ps2_host_axi_0_0 is
  port (
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    ps2_clk : inout STD_LOGIC;
    ps2_data : inout STD_LOGIC;
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_rready : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of design_1_ps2_host_axi_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of design_1_ps2_host_axi_0_0 : entity is "design_1_ps2_host_axi_0_0,ps2_host_axi,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of design_1_ps2_host_axi_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of design_1_ps2_host_axi_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of design_1_ps2_host_axi_0_0 : entity is "ps2_host_axi,Vivado 2018.3";
end design_1_ps2_host_axi_0_0;

architecture STRUCTURE of design_1_ps2_host_axi_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \^s_axi_awready\ : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF s_axi, FREQ_HZ 62500000, PHASE 0.000, CLK_DOMAIN design_1_xdma_0_0_axi_aclk, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of ps2_clk : signal is "xilinx.com:signal:clock:1.0 ps2_clk CLK";
  attribute X_INTERFACE_PARAMETER of ps2_clk : signal is "XIL_INTERFACENAME ps2_clk, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of rst_n : signal is "xilinx.com:signal:reset:1.0 rst_n RST";
  attribute X_INTERFACE_PARAMETER of rst_n : signal is "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axi_aclk : signal is "xilinx.com:signal:clock:1.0 s_axi_aclk CLK";
  attribute X_INTERFACE_PARAMETER of s_axi_aclk : signal is "XIL_INTERFACENAME s_axi_aclk, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 62500000, PHASE 0.000, CLK_DOMAIN design_1_xdma_0_0_axi_aclk, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axi_aresetn : signal is "xilinx.com:signal:reset:1.0 s_axi_aresetn RST";
  attribute X_INTERFACE_PARAMETER of s_axi_aresetn : signal is "XIL_INTERFACENAME s_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axi_arready : signal is "xilinx.com:interface:aximm:1.0 s_axi ARREADY";
  attribute X_INTERFACE_INFO of s_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi ARVALID";
  attribute X_INTERFACE_INFO of s_axi_awready : signal is "xilinx.com:interface:aximm:1.0 s_axi AWREADY";
  attribute X_INTERFACE_INFO of s_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi AWVALID";
  attribute X_INTERFACE_INFO of s_axi_bready : signal is "xilinx.com:interface:aximm:1.0 s_axi BREADY";
  attribute X_INTERFACE_INFO of s_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi BVALID";
  attribute X_INTERFACE_INFO of s_axi_rready : signal is "xilinx.com:interface:aximm:1.0 s_axi RREADY";
  attribute X_INTERFACE_PARAMETER of s_axi_rready : signal is "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 62500000, ID_WIDTH 0, ADDR_WIDTH 8, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN design_1_xdma_0_0_axi_aclk, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi RVALID";
  attribute X_INTERFACE_INFO of s_axi_wready : signal is "xilinx.com:interface:aximm:1.0 s_axi WREADY";
  attribute X_INTERFACE_INFO of s_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi WVALID";
  attribute X_INTERFACE_INFO of s_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 s_axi ARADDR";
  attribute X_INTERFACE_INFO of s_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 s_axi AWADDR";
  attribute X_INTERFACE_INFO of s_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 s_axi BRESP";
  attribute X_INTERFACE_INFO of s_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 s_axi RDATA";
  attribute X_INTERFACE_INFO of s_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 s_axi RRESP";
  attribute X_INTERFACE_INFO of s_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 s_axi WDATA";
  attribute X_INTERFACE_INFO of s_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 s_axi WSTRB";
begin
  s_axi_awready <= \^s_axi_awready\;
  s_axi_bresp(1) <= \<const0>\;
  s_axi_bresp(0) <= \<const0>\;
  s_axi_rresp(1) <= \<const0>\;
  s_axi_rresp(0) <= \<const0>\;
  s_axi_wready <= \^s_axi_awready\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.design_1_ps2_host_axi_0_0_ps2_host_axi
     port map (
      E(0) => s_axi_arready,
      ps2_clk => ps2_clk,
      ps2_data => ps2_data,
      r_valid_reg_reg_0 => s_axi_rvalid,
      rst_n => rst_n,
      s_axi_aclk => s_axi_aclk,
      s_axi_araddr(7 downto 0) => s_axi_araddr(7 downto 0),
      s_axi_arvalid => s_axi_arvalid,
      s_axi_awaddr(7 downto 0) => s_axi_awaddr(7 downto 0),
      s_axi_awready => \^s_axi_awready\,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_bready => s_axi_bready,
      s_axi_bvalid => s_axi_bvalid,
      s_axi_rdata(31 downto 0) => s_axi_rdata(31 downto 0),
      s_axi_rready => s_axi_rready,
      s_axi_wdata(7 downto 0) => s_axi_wdata(7 downto 0),
      s_axi_wvalid => s_axi_wvalid
    );
end STRUCTURE;
