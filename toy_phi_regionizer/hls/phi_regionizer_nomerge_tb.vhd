library std;
use std.textio.all;
use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    constant NSECTORS : natural := 9;
    constant NFIBERS : natural := 2;
    constant NFIFOS : natural := 6;
    constant NREGIONS : natural := NSECTORS*NFIFOS;

    type pt_vect     is array(natural range <>) of std_logic_vector(13 downto 0);
    type etaphi_vect is array(natural range <>) of std_logic_vector(11 downto 0);
    type rest_vect   is array(natural range <>) of std_logic_vector(25 downto 0);

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start, ready, idle, done : std_logic;
    signal newevent, newevent_out : std_logic;

    signal pt_in:  pt_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(13 downto 0);
    signal pt_out: pt_vect(NREGIONS-1         downto 0); -- of std_logic_vector(13 downto 0);
    signal eta_in, phi_in:   etaphi_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(11 downto 0);
    signal eta_out, phi_out: etaphi_vect(NREGIONS-1         downto 0); -- of std_logic_vector(11 downto 0);
    signal rest_in:  rest_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(25 downto 0);
    signal rest_out: rest_vect(NREGIONS-1         downto 0); -- of std_logic_vector(25 downto 0);

    file Fi : text open read_mode is "input.txt";
    file Fo : text open write_mode is "output_vhdl_tb.txt";

    component router_nomerge is
        port (
            ap_clk : IN STD_LOGIC;
            ap_rst : IN STD_LOGIC;
            ap_start : IN STD_LOGIC;
            ap_done : OUT STD_LOGIC;
            ap_idle : OUT STD_LOGIC;
            ap_ready : OUT STD_LOGIC;
            newevent : IN STD_LOGIC;
            tracks_in_0_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_3_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_3_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_4_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_4_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_5_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_5_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_6_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_6_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_7_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_7_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_8_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_8_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_0_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_3_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_3_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_4_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_4_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_5_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_5_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_6_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_6_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_7_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_7_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_8_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_8_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_0_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_0_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_0_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_0_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_0_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_0_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_0_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_0_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_1_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_1_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_1_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_1_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_2_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_2_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_2_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_2_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_3_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_3_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_3_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_3_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_4_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_4_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_4_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_4_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_5_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_5_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_5_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_5_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_6_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_6_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_6_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_6_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_7_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_7_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_7_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_7_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_8_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_8_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_8_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_8_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_9_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_9_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_9_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_9_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_10_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_10_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_10_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_10_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_11_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_11_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_11_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_11_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_12_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_12_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_12_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_12_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_13_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_13_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_13_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_13_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_14_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_14_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_14_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_14_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_15_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_15_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_15_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_15_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_16_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_16_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_16_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_16_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_17_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_17_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_17_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_17_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_18_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_18_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_18_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_18_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_18_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_18_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_18_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_18_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_19_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_19_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_19_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_19_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_19_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_19_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_19_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_19_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_20_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_20_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_20_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_20_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_20_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_20_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_20_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_20_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_21_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_21_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_21_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_21_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_21_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_21_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_21_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_21_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_22_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_22_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_22_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_22_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_22_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_22_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_22_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_22_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_23_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_23_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_23_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_23_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_23_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_23_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_23_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_23_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_24_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_24_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_24_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_24_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_24_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_24_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_24_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_24_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_25_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_25_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_25_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_25_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_25_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_25_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_25_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_25_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_26_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_26_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_26_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_26_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_26_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_26_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_26_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_26_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_27_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_27_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_27_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_27_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_27_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_27_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_27_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_27_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_28_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_28_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_28_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_28_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_28_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_28_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_28_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_28_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_29_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_29_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_29_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_29_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_29_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_29_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_29_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_29_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_30_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_30_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_30_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_30_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_30_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_30_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_30_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_30_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_31_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_31_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_31_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_31_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_31_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_31_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_31_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_31_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_32_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_32_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_32_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_32_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_32_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_32_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_32_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_32_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_33_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_33_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_33_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_33_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_33_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_33_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_33_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_33_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_34_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_34_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_34_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_34_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_34_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_34_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_34_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_34_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_35_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_35_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_35_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_35_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_35_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_35_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_35_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_35_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_36_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_36_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_36_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_36_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_36_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_36_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_36_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_36_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_37_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_37_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_37_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_37_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_37_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_37_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_37_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_37_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_38_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_38_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_38_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_38_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_38_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_38_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_38_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_38_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_39_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_39_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_39_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_39_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_39_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_39_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_39_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_39_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_40_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_40_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_40_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_40_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_40_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_40_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_40_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_40_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_41_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_41_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_41_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_41_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_41_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_41_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_41_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_41_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_42_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_42_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_42_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_42_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_42_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_42_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_42_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_42_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_43_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_43_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_43_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_43_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_43_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_43_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_43_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_43_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_44_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_44_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_44_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_44_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_44_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_44_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_44_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_44_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_45_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_45_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_45_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_45_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_45_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_45_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_45_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_45_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_46_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_46_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_46_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_46_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_46_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_46_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_46_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_46_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_47_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_47_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_47_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_47_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_47_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_47_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_47_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_47_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_48_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_48_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_48_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_48_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_48_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_48_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_48_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_48_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_49_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_49_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_49_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_49_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_49_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_49_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_49_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_49_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_50_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_50_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_50_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_50_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_50_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_50_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_50_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_50_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_51_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_51_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_51_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_51_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_51_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_51_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_51_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_51_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_52_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_52_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_52_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_52_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_52_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_52_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_52_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_52_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_53_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_53_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_53_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_53_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_53_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_53_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_53_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_53_rest_V_ap_vld : OUT STD_LOGIC;
            newevent_out : OUT STD_LOGIC;
            newevent_out_ap_vld : OUT STD_LOGIC );
    end component;

begin
    clk  <= not clk after 1.25 ns;
    
    uut : router_nomerge
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => start,
                 ap_ready => ready,
                 ap_idle =>  idle,
                 ap_done => done,
                 tracks_in_0_0_pt_V => pt_in( 0),
                 tracks_in_0_1_pt_V => pt_in( 1),
                 tracks_in_1_0_pt_V => pt_in( 2),
                 tracks_in_1_1_pt_V => pt_in( 3), 
                 tracks_in_2_0_pt_V => pt_in( 4),
                 tracks_in_2_1_pt_V => pt_in( 5),
                 tracks_in_3_0_pt_V => pt_in( 6),
                 tracks_in_3_1_pt_V => pt_in( 7),
                 tracks_in_4_0_pt_V => pt_in( 8),
                 tracks_in_4_1_pt_V => pt_in( 9), 
                 tracks_in_5_0_pt_V => pt_in(10),
                 tracks_in_5_1_pt_V => pt_in(11),
                 tracks_in_6_0_pt_V => pt_in(12),
                 tracks_in_6_1_pt_V => pt_in(13),
                 tracks_in_7_0_pt_V => pt_in(14),
                 tracks_in_7_1_pt_V => pt_in(15), 
                 tracks_in_8_0_pt_V => pt_in(16),
                 tracks_in_8_1_pt_V => pt_in(17),
                 tracks_in_0_0_eta_V => eta_in( 0),
                 tracks_in_0_1_eta_V => eta_in( 1),
                 tracks_in_1_0_eta_V => eta_in( 2),
                 tracks_in_1_1_eta_V => eta_in( 3), 
                 tracks_in_2_0_eta_V => eta_in( 4),
                 tracks_in_2_1_eta_V => eta_in( 5),
                 tracks_in_3_0_eta_V => eta_in( 6),
                 tracks_in_3_1_eta_V => eta_in( 7),
                 tracks_in_4_0_eta_V => eta_in( 8),
                 tracks_in_4_1_eta_V => eta_in( 9), 
                 tracks_in_5_0_eta_V => eta_in(10),
                 tracks_in_5_1_eta_V => eta_in(11),
                 tracks_in_6_0_eta_V => eta_in(12),
                 tracks_in_6_1_eta_V => eta_in(13),
                 tracks_in_7_0_eta_V => eta_in(14),
                 tracks_in_7_1_eta_V => eta_in(15), 
                 tracks_in_8_0_eta_V => eta_in(16),
                 tracks_in_8_1_eta_V => eta_in(17),
                 tracks_in_0_0_phi_V => phi_in( 0),
                 tracks_in_0_1_phi_V => phi_in( 1),
                 tracks_in_1_0_phi_V => phi_in( 2),
                 tracks_in_1_1_phi_V => phi_in( 3), 
                 tracks_in_2_0_phi_V => phi_in( 4),
                 tracks_in_2_1_phi_V => phi_in( 5),
                 tracks_in_3_0_phi_V => phi_in( 6),
                 tracks_in_3_1_phi_V => phi_in( 7),
                 tracks_in_4_0_phi_V => phi_in( 8),
                 tracks_in_4_1_phi_V => phi_in( 9), 
                 tracks_in_5_0_phi_V => phi_in(10),
                 tracks_in_5_1_phi_V => phi_in(11),
                 tracks_in_6_0_phi_V => phi_in(12),
                 tracks_in_6_1_phi_V => phi_in(13),
                 tracks_in_7_0_phi_V => phi_in(14),
                 tracks_in_7_1_phi_V => phi_in(15), 
                 tracks_in_8_0_phi_V => phi_in(16),
                 tracks_in_8_1_phi_V => phi_in(17),
                 tracks_in_0_0_rest_V => rest_in( 0),
                 tracks_in_0_1_rest_V => rest_in( 1),
                 tracks_in_1_0_rest_V => rest_in( 2),
                 tracks_in_1_1_rest_V => rest_in( 3), 
                 tracks_in_2_0_rest_V => rest_in( 4),
                 tracks_in_2_1_rest_V => rest_in( 5),
                 tracks_in_3_0_rest_V => rest_in( 6),
                 tracks_in_3_1_rest_V => rest_in( 7),
                 tracks_in_4_0_rest_V => rest_in( 8),
                 tracks_in_4_1_rest_V => rest_in( 9), 
                 tracks_in_5_0_rest_V => rest_in(10),
                 tracks_in_5_1_rest_V => rest_in(11),
                 tracks_in_6_0_rest_V => rest_in(12),
                 tracks_in_6_1_rest_V => rest_in(13),
                 tracks_in_7_0_rest_V => rest_in(14),
                 tracks_in_7_1_rest_V => rest_in(15), 
                 tracks_in_8_0_rest_V => rest_in(16),
                 tracks_in_8_1_rest_V => rest_in(17),
                 tracks_out_0_pt_V => pt_out(0),
                 tracks_out_0_eta_V => eta_out(0),
                 tracks_out_0_phi_V => phi_out(0),
                 tracks_out_0_rest_V => rest_out(0),
                 tracks_out_1_pt_V => pt_out(1),
                 tracks_out_1_eta_V => eta_out(1),
                 tracks_out_1_phi_V => phi_out(1),
                 tracks_out_1_rest_V => rest_out(1),
                 tracks_out_2_pt_V => pt_out(2),
                 tracks_out_2_eta_V => eta_out(2),
                 tracks_out_2_phi_V => phi_out(2),
                 tracks_out_2_rest_V => rest_out(2),
                 tracks_out_3_pt_V => pt_out(3),
                 tracks_out_3_eta_V => eta_out(3),
                 tracks_out_3_phi_V => phi_out(3),
                 tracks_out_3_rest_V => rest_out(3),
                 tracks_out_4_pt_V => pt_out(4),
                 tracks_out_4_eta_V => eta_out(4),
                 tracks_out_4_phi_V => phi_out(4),
                 tracks_out_4_rest_V => rest_out(4),
                 tracks_out_5_pt_V => pt_out(5),
                 tracks_out_5_eta_V => eta_out(5),
                 tracks_out_5_phi_V => phi_out(5),
                 tracks_out_5_rest_V => rest_out(5),
                 tracks_out_6_pt_V => pt_out(6),
                 tracks_out_6_eta_V => eta_out(6),
                 tracks_out_6_phi_V => phi_out(6),
                 tracks_out_6_rest_V => rest_out(6),
                 tracks_out_7_pt_V => pt_out(7),
                 tracks_out_7_eta_V => eta_out(7),
                 tracks_out_7_phi_V => phi_out(7),
                 tracks_out_7_rest_V => rest_out(7),
                 tracks_out_8_pt_V => pt_out(8),
                 tracks_out_8_eta_V => eta_out(8),
                 tracks_out_8_phi_V => phi_out(8),
                 tracks_out_8_rest_V => rest_out(8),
                 tracks_out_9_pt_V => pt_out(9),
                 tracks_out_9_eta_V => eta_out(9),
                 tracks_out_9_phi_V => phi_out(9),
                 tracks_out_9_rest_V => rest_out(9),
                 tracks_out_10_pt_V => pt_out(10),
                 tracks_out_10_eta_V => eta_out(10),
                 tracks_out_10_phi_V => phi_out(10),
                 tracks_out_10_rest_V => rest_out(10),
                 tracks_out_11_pt_V => pt_out(11),
                 tracks_out_11_eta_V => eta_out(11),
                 tracks_out_11_phi_V => phi_out(11),
                 tracks_out_11_rest_V => rest_out(11),
                 tracks_out_12_pt_V => pt_out(12),
                 tracks_out_12_eta_V => eta_out(12),
                 tracks_out_12_phi_V => phi_out(12),
                 tracks_out_12_rest_V => rest_out(12),
                 tracks_out_13_pt_V => pt_out(13),
                 tracks_out_13_eta_V => eta_out(13),
                 tracks_out_13_phi_V => phi_out(13),
                 tracks_out_13_rest_V => rest_out(13),
                 tracks_out_14_pt_V => pt_out(14),
                 tracks_out_14_eta_V => eta_out(14),
                 tracks_out_14_phi_V => phi_out(14),
                 tracks_out_14_rest_V => rest_out(14),
                 tracks_out_15_pt_V => pt_out(15),
                 tracks_out_15_eta_V => eta_out(15),
                 tracks_out_15_phi_V => phi_out(15),
                 tracks_out_15_rest_V => rest_out(15),
                 tracks_out_16_pt_V => pt_out(16),
                 tracks_out_16_eta_V => eta_out(16),
                 tracks_out_16_phi_V => phi_out(16),
                 tracks_out_16_rest_V => rest_out(16),
                 tracks_out_17_pt_V => pt_out(17),
                 tracks_out_17_eta_V => eta_out(17),
                 tracks_out_17_phi_V => phi_out(17),
                 tracks_out_17_rest_V => rest_out(17),
                 tracks_out_18_pt_V => pt_out(18),
                 tracks_out_18_eta_V => eta_out(18),
                 tracks_out_18_phi_V => phi_out(18),
                 tracks_out_18_rest_V => rest_out(18),
                 tracks_out_19_pt_V => pt_out(19),
                 tracks_out_19_eta_V => eta_out(19),
                 tracks_out_19_phi_V => phi_out(19),
                 tracks_out_19_rest_V => rest_out(19),
                 tracks_out_20_pt_V => pt_out(20),
                 tracks_out_20_eta_V => eta_out(20),
                 tracks_out_20_phi_V => phi_out(20),
                 tracks_out_20_rest_V => rest_out(20),
                 tracks_out_21_pt_V => pt_out(21),
                 tracks_out_21_eta_V => eta_out(21),
                 tracks_out_21_phi_V => phi_out(21),
                 tracks_out_21_rest_V => rest_out(21),
                 tracks_out_22_pt_V => pt_out(22),
                 tracks_out_22_eta_V => eta_out(22),
                 tracks_out_22_phi_V => phi_out(22),
                 tracks_out_22_rest_V => rest_out(22),
                 tracks_out_23_pt_V => pt_out(23),
                 tracks_out_23_eta_V => eta_out(23),
                 tracks_out_23_phi_V => phi_out(23),
                 tracks_out_23_rest_V => rest_out(23),
                 tracks_out_24_pt_V => pt_out(24),
                 tracks_out_24_eta_V => eta_out(24),
                 tracks_out_24_phi_V => phi_out(24),
                 tracks_out_24_rest_V => rest_out(24),
                 tracks_out_25_pt_V => pt_out(25),
                 tracks_out_25_eta_V => eta_out(25),
                 tracks_out_25_phi_V => phi_out(25),
                 tracks_out_25_rest_V => rest_out(25),
                 tracks_out_26_pt_V => pt_out(26),
                 tracks_out_26_eta_V => eta_out(26),
                 tracks_out_26_phi_V => phi_out(26),
                 tracks_out_26_rest_V => rest_out(26),
                 tracks_out_27_pt_V => pt_out(27),
                 tracks_out_27_eta_V => eta_out(27),
                 tracks_out_27_phi_V => phi_out(27),
                 tracks_out_27_rest_V => rest_out(27),
                 tracks_out_28_pt_V => pt_out(28),
                 tracks_out_28_eta_V => eta_out(28),
                 tracks_out_28_phi_V => phi_out(28),
                 tracks_out_28_rest_V => rest_out(28),
                 tracks_out_29_pt_V => pt_out(29),
                 tracks_out_29_eta_V => eta_out(29),
                 tracks_out_29_phi_V => phi_out(29),
                 tracks_out_29_rest_V => rest_out(29),
                 tracks_out_30_pt_V => pt_out(30),
                 tracks_out_30_eta_V => eta_out(30),
                 tracks_out_30_phi_V => phi_out(30),
                 tracks_out_30_rest_V => rest_out(30),
                 tracks_out_31_pt_V => pt_out(31),
                 tracks_out_31_eta_V => eta_out(31),
                 tracks_out_31_phi_V => phi_out(31),
                 tracks_out_31_rest_V => rest_out(31),
                 tracks_out_32_pt_V => pt_out(32),
                 tracks_out_32_eta_V => eta_out(32),
                 tracks_out_32_phi_V => phi_out(32),
                 tracks_out_32_rest_V => rest_out(32),
                 tracks_out_33_pt_V => pt_out(33),
                 tracks_out_33_eta_V => eta_out(33),
                 tracks_out_33_phi_V => phi_out(33),
                 tracks_out_33_rest_V => rest_out(33),
                 tracks_out_34_pt_V => pt_out(34),
                 tracks_out_34_eta_V => eta_out(34),
                 tracks_out_34_phi_V => phi_out(34),
                 tracks_out_34_rest_V => rest_out(34),
                 tracks_out_35_pt_V => pt_out(35),
                 tracks_out_35_eta_V => eta_out(35),
                 tracks_out_35_phi_V => phi_out(35),
                 tracks_out_35_rest_V => rest_out(35),
                 tracks_out_36_pt_V => pt_out(36),
                 tracks_out_36_eta_V => eta_out(36),
                 tracks_out_36_phi_V => phi_out(36),
                 tracks_out_36_rest_V => rest_out(36),
                 tracks_out_37_pt_V => pt_out(37),
                 tracks_out_37_eta_V => eta_out(37),
                 tracks_out_37_phi_V => phi_out(37),
                 tracks_out_37_rest_V => rest_out(37),
                 tracks_out_38_pt_V => pt_out(38),
                 tracks_out_38_eta_V => eta_out(38),
                 tracks_out_38_phi_V => phi_out(38),
                 tracks_out_38_rest_V => rest_out(38),
                 tracks_out_39_pt_V => pt_out(39),
                 tracks_out_39_eta_V => eta_out(39),
                 tracks_out_39_phi_V => phi_out(39),
                 tracks_out_39_rest_V => rest_out(39),
                 tracks_out_40_pt_V => pt_out(40),
                 tracks_out_40_eta_V => eta_out(40),
                 tracks_out_40_phi_V => phi_out(40),
                 tracks_out_40_rest_V => rest_out(40),
                 tracks_out_41_pt_V => pt_out(41),
                 tracks_out_41_eta_V => eta_out(41),
                 tracks_out_41_phi_V => phi_out(41),
                 tracks_out_41_rest_V => rest_out(41),
                 tracks_out_42_pt_V => pt_out(42),
                 tracks_out_42_eta_V => eta_out(42),
                 tracks_out_42_phi_V => phi_out(42),
                 tracks_out_42_rest_V => rest_out(42),
                 tracks_out_43_pt_V => pt_out(43),
                 tracks_out_43_eta_V => eta_out(43),
                 tracks_out_43_phi_V => phi_out(43),
                 tracks_out_43_rest_V => rest_out(43),
                 tracks_out_44_pt_V => pt_out(44),
                 tracks_out_44_eta_V => eta_out(44),
                 tracks_out_44_phi_V => phi_out(44),
                 tracks_out_44_rest_V => rest_out(44),
                 tracks_out_45_pt_V => pt_out(45),
                 tracks_out_45_eta_V => eta_out(45),
                 tracks_out_45_phi_V => phi_out(45),
                 tracks_out_45_rest_V => rest_out(45),
                 tracks_out_46_pt_V => pt_out(46),
                 tracks_out_46_eta_V => eta_out(46),
                 tracks_out_46_phi_V => phi_out(46),
                 tracks_out_46_rest_V => rest_out(46),
                 tracks_out_47_pt_V => pt_out(47),
                 tracks_out_47_eta_V => eta_out(47),
                 tracks_out_47_phi_V => phi_out(47),
                 tracks_out_47_rest_V => rest_out(47),
                 tracks_out_48_pt_V => pt_out(48),
                 tracks_out_48_eta_V => eta_out(48),
                 tracks_out_48_phi_V => phi_out(48),
                 tracks_out_48_rest_V => rest_out(48),
                 tracks_out_49_pt_V => pt_out(49),
                 tracks_out_49_eta_V => eta_out(49),
                 tracks_out_49_phi_V => phi_out(49),
                 tracks_out_49_rest_V => rest_out(49),
                 tracks_out_50_pt_V => pt_out(50),
                 tracks_out_50_eta_V => eta_out(50),
                 tracks_out_50_phi_V => phi_out(50),
                 tracks_out_50_rest_V => rest_out(50),
                 tracks_out_51_pt_V => pt_out(51),
                 tracks_out_51_eta_V => eta_out(51),
                 tracks_out_51_phi_V => phi_out(51),
                 tracks_out_51_rest_V => rest_out(51),
                 tracks_out_52_pt_V => pt_out(52),
                 tracks_out_52_eta_V => eta_out(52),
                 tracks_out_52_phi_V => phi_out(52),
                 tracks_out_52_rest_V => rest_out(52),
                 tracks_out_53_pt_V => pt_out(53),
                 tracks_out_53_eta_V => eta_out(53),
                 tracks_out_53_phi_V => phi_out(53),
                 tracks_out_53_rest_V => rest_out(53),
                 newevent => newevent,
                 newevent_out => newevent_out
             );
   

    runit : process 
        variable remainingEvents : integer := 5;
        variable frame : integer := 0;
        variable Li, Lo : line;
        variable itest, iobj : integer;
    begin
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        start <= '0';
        wait until rising_edge(clk);
        while remainingEvents > 0 loop
            if not endfile(Fi) then
                readline(Fi, Li);
                read(Li, itest);
                read(Li, iobj); if (iobj > 0) then newevent <= '1'; else newevent <= '0'; end if;
                for i in 0 to NSECTORS*NFIBERS-1  loop
                    read(Li, iobj); pt_in(i)   <= std_logic_vector(to_unsigned(iobj, 14));
                    read(Li, iobj); eta_in(i)  <= std_logic_vector(to_signed(  iobj, 12));
                    read(Li, iobj); phi_in(i)  <= std_logic_vector(to_signed(  iobj, 12));
                    read(Li, iobj); rest_in(i) <= std_logic_vector(to_unsigned(iobj, 26));
                end loop;
                start <= '1';
             else
                remainingEvents := remainingEvents - 1;
                newevent <= '0';
                pt_in <= (others => (others => '0'));
                eta_in <= (others => (others => '0'));
                phi_in <= (others => (others => '0'));
                rest_in <= (others => (others => '0'));
                start <= '1';
            end if;
           -- ready to dispatch ---
            wait until rising_edge(clk);
            -- write out the output --
            write(Lo, frame, field=>5);  
            write(Lo, string'(" 1 ")); 
            write(Lo, newevent_out); 
            write(Lo, string'(" ")); 
            for i in 0 to NREGIONS-1 loop 
                write(Lo, to_integer(unsigned(pt_out(i))),   field => 6); 
                write(Lo, to_integer(signed(eta_out(i))),    field => 6); 
                write(Lo, to_integer(signed(phi_out(i))),    field => 6); 
                write(Lo, to_integer(unsigned(rest_out(i))), field => 6); 
            end loop;
            write(Lo, string'(" |  ready ")); 
            write(Lo, ready); 
            write(Lo, string'("   idle ")); 
            write(Lo, idle); 
            write(Lo, string'("  done ")); 
            write(Lo, done); 
            writeline(Fo, Lo);
            frame := frame + 1;
        end loop;
        wait for 50 ns;
        finish(0);
    end process;

    
end Behavioral;
