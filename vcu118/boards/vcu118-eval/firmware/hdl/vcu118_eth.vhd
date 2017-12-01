-- based on https://github.com/ipbus/ipbus-firmware/blob/master/components/ipbus_eth/firmware/hdl/eth_us_1000basex.vhd
-- taken at commit e9d7ddbb8ab196fe0974213bd1feb30514619123

---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- Contains the instantiation of the Xilinx MAC & 1000baseX pcs/pma & GTP transceiver cores
--
-- Do not change signal names in here without corresponding alteration to the timing contraints file
--
-- Dave Newbold, October 2016

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity vcu118_eth is
    port(
        -- clock and data i/o (connected to external device)
        clk625_p : in std_logic; --> 625 MHz clock
        clk625_n : in std_logic; 
        txp : out std_logic; 
        txn : out std_logic; 
        rxp : in std_logic; 
        rxn : in std_logic; 
        -- output reset and power signals (to the external device)
        phy_on   : out std_logic; -- on/off signal
        phy_resetb: out std_logic; -- reset signal (inverted)
        -- 125 MHz clocks
        ethclk125: out std_logic; -- 125 MHz from ethernet
        ethrst125: out std_logic; -- 125 MHz from ethernet
        -- connection control and status (to logic)
        rst: in std_logic;    -- request reset of ethernet MAC
        locked: out std_logic; -- locked to ethernet clock
        rst_phy: in std_logic;    -- request rest of external ethernet device
        -- data in and out (connected to ipbus)
        tx_data: in std_logic_vector(7 downto 0);
        tx_valid: in std_logic;
        tx_last: in std_logic;
        tx_error: in std_logic;
        tx_ready: out std_logic;
        rx_data: out std_logic_vector(7 downto 0);
        rx_valid: out std_logic;
        rx_last: out std_logic;
        rx_error: out std_logic
    );

end vcu118_eth;

architecture rtl of vcu118_eth is
    --- this is the MAC ---
    COMPONENT temac_gbe_v9_0
        PORT (
            gtx_clk : IN STD_LOGIC;
            glbl_rstn : IN STD_LOGIC;
            rx_axi_rstn : IN STD_LOGIC;
            tx_axi_rstn : IN STD_LOGIC;
            rx_statistics_vector : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
            rx_statistics_valid : OUT STD_LOGIC;
            rx_mac_aclk : OUT STD_LOGIC;
            rx_reset : OUT STD_LOGIC;
            rx_axis_mac_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            rx_axis_mac_tvalid : OUT STD_LOGIC;
            rx_axis_mac_tlast : OUT STD_LOGIC;
            rx_axis_mac_tuser : OUT STD_LOGIC;
            tx_ifg_delay : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            tx_statistics_vector : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            tx_statistics_valid : OUT STD_LOGIC;
            tx_mac_aclk : OUT STD_LOGIC;
            tx_reset : OUT STD_LOGIC;
            tx_axis_mac_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            tx_axis_mac_tvalid : IN STD_LOGIC;
            tx_axis_mac_tlast : IN STD_LOGIC;
            tx_axis_mac_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            tx_axis_mac_tready : OUT STD_LOGIC;
            pause_req : IN STD_LOGIC;
            pause_val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            speedis100 : OUT STD_LOGIC;
            speedis10100 : OUT STD_LOGIC;
            gmii_txd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            gmii_tx_en : OUT STD_LOGIC;
            gmii_tx_er : OUT STD_LOGIC;
            gmii_rxd : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            gmii_rx_dv : IN STD_LOGIC;
            gmii_rx_er : IN STD_LOGIC;
            rx_configuration_vector : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
            tx_configuration_vector : IN STD_LOGIC_VECTOR(79 DOWNTO 0)
        );
    END COMPONENT;

    -- this is the SGMII adapter + transceiver using LVDS SelectIO ---
    COMPONENT sgmii_adapter_lvds_0
        PORT ( 
            txp_0 : out STD_LOGIC;
            txn_0 : out STD_LOGIC;
            rxp_0 : in STD_LOGIC;
            rxn_0 : in STD_LOGIC;
            signal_detect_0 : in STD_LOGIC;
            gmii_txd_0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
            gmii_tx_en_0 : in STD_LOGIC;
            gmii_tx_er_0 : in STD_LOGIC;
            gmii_rxd_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
            gmii_rx_dv_0 : out STD_LOGIC;
            gmii_rx_er_0 : out STD_LOGIC;
            gmii_isolate_0 : out STD_LOGIC;
            sgmii_clk_r_0 : out STD_LOGIC;
            sgmii_clk_f_0 : out STD_LOGIC;
            sgmii_clk_en_0 : out STD_LOGIC;
            speed_is_10_100_0 : in STD_LOGIC;
            speed_is_100_0 : in STD_LOGIC;
            status_vector_0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
            configuration_vector_0 : in STD_LOGIC_VECTOR ( 4 downto 0 );
            refclk625_p : in STD_LOGIC;
            refclk625_n : in STD_LOGIC;
            clk125_out : out STD_LOGIC;
            clk312_out : out STD_LOGIC;
            rst_125_out : out STD_LOGIC;
            tx_logic_reset : out STD_LOGIC;
            rx_logic_reset : out STD_LOGIC;
            rx_locked : out STD_LOGIC;
            tx_locked : out STD_LOGIC;
            tx_pll_clkout_phy_en : out STD_LOGIC;
            rx_pll_clkout_phy_en : out STD_LOGIC;
            tx_bsc_rst_out : out STD_LOGIC;
            rx_bsc_rst_out : out STD_LOGIC;
            tx_bs_rst_out : out STD_LOGIC;
            rx_bs_rst_out : out STD_LOGIC;
            tx_rst_dly_out : out STD_LOGIC;
            rx_rst_dly_out : out STD_LOGIC;
            tx_bsc_en_vtc_out : out STD_LOGIC;
            rx_bsc_en_vtc_out : out STD_LOGIC;
            tx_bs_en_vtc_out : out STD_LOGIC;
            rx_bs_en_vtc_out : out STD_LOGIC;
            riu_clk_out : out STD_LOGIC;
            riu_addr_out : out STD_LOGIC_VECTOR ( 5 downto 0 );
            riu_wr_data_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
            riu_wr_en_out : out STD_LOGIC;
            riu_nibble_sel_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
            riu_rddata_3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
            riu_valid_3 : in STD_LOGIC;
            riu_prsnt_3 : in STD_LOGIC;
            riu_rddata_2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
            riu_valid_2 : in STD_LOGIC;
            riu_prsnt_2 : in STD_LOGIC;
            riu_rddata_1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
            riu_valid_1 : in STD_LOGIC;
            riu_prsnt_1 : in STD_LOGIC;
            rx_btval_3 : out STD_LOGIC_VECTOR ( 8 downto 0 );
            rx_btval_2 : out STD_LOGIC_VECTOR ( 8 downto 0 );
            rx_btval_1 : out STD_LOGIC_VECTOR ( 8 downto 0 );
            clk_rst_debug_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
            tx_pll_clk_out : out STD_LOGIC;
            rx_pll_clk_out : out STD_LOGIC;
            tx_rdclk_out : out STD_LOGIC;
            tx_dly_rdy : out STD_LOGIC;
            tx_vtc_rdy : out STD_LOGIC;
            rx_dly_rdy : out STD_LOGIC;
            rx_vtc_rdy : out STD_LOGIC;
            reset : in STD_LOGIC
        );
    END COMPONENT;

    signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
    signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;
    signal gmii_rx_clk: std_logic;
    signal clk125, rst125, rx_locked, tx_locked, locked_i, rstn: std_logic;
begin

    ethclk125 <= clk125;
    ethrst125 <= rst125;
    
    rstn <= not (rst or rst125 or not locked_i);

    mac: temac_gbe_v9_0
        port map(
            gtx_clk => clk125,
            glbl_rstn => rstn,
            rx_axi_rstn => '1',
            tx_axi_rstn => '1',
            rx_statistics_vector => open,
            rx_statistics_valid => open,
            rx_mac_aclk => open,
            rx_reset => open,
            rx_axis_mac_tdata => rx_data,
            rx_axis_mac_tvalid => rx_valid,
            rx_axis_mac_tlast => rx_last,
            rx_axis_mac_tuser => rx_error,
            tx_ifg_delay => X"00",
            tx_statistics_vector => open,
            tx_statistics_valid => open,
            tx_mac_aclk => open,
            tx_reset => open,
            tx_axis_mac_tdata => tx_data,
            tx_axis_mac_tvalid => tx_valid,
            tx_axis_mac_tlast => tx_last,
            tx_axis_mac_tuser(0) => tx_error,
            tx_axis_mac_tready => tx_ready,
            pause_req => '0',
            pause_val => X"0000",
            gmii_txd => gmii_txd,
            gmii_tx_en => gmii_tx_en,
            gmii_tx_er => gmii_tx_er,
            gmii_rxd => gmii_rxd,
            gmii_rx_dv => gmii_rx_dv,
            gmii_rx_er => gmii_rx_er,
            rx_configuration_vector => X"0000_0000_0000_0000_0812",
            tx_configuration_vector => X"0000_0000_0000_0000_0012"
        );

    sgmii: sgmii_adapter_lvds_0
        port map ( 
            refclk625_p => clk625_p,
            refclk625_n => clk625_n,
            txp_0 => txp,
            txn_0 => txn,
            rxp_0 => rxp,
            rxn_0 => rxn,
            signal_detect_0 => '1', --?
            gmii_txd_0 => gmii_txd,
            gmii_tx_en_0 => gmii_tx_en,
            gmii_tx_er_0 => gmii_tx_er,
            gmii_rxd_0 => gmii_rxd,
            gmii_rx_dv_0 => gmii_rx_dv,
            gmii_rx_er_0 => gmii_rx_er,
            gmii_isolate_0 => open,
            sgmii_clk_r_0 => open, --??
            sgmii_clk_f_0 => open, --??
            sgmii_clk_en_0 => open, --??
            speed_is_10_100_0 => '0',
            speed_is_100_0 => '0',
            status_vector_0 => open,
            configuration_vector_0 => "00000",
            clk125_out => clk125,
            --clk312_out => clk312,
            rst_125_out => rst125, 
            --tx_logic_reset => 
            --rx_logic_reset => 
            rx_locked => rx_locked,
            tx_locked => tx_locked,
            --tx_pll_clkout_phy_en => 
            --rx_pll_clkout_phy_en => 
            --tx_bsc_rst_out => 
            --rx_bsc_rst_out => 
            --tx_bs_rst_out => 
            --rx_bs_rst_out => 
            --tx_rst_dly_out => 
            --rx_rst_dly_out => 
            --tx_bsc_en_vtc_out => 
            --rx_bsc_en_vtc_out => 
            --tx_bs_en_vtc_out => 
            --rx_bs_en_vtc_out => 
            --riu_clk_out => 
            --riu_addr_out => 
            --riu_wr_data_out => 
            --riu_wr_en_out => 
            --riu_nibble_sel_out => 
            riu_rddata_3 => X"0000",
            riu_valid_3 => '0',
            riu_prsnt_3 => '0',
            riu_rddata_2 => X"0000",
            riu_valid_2 => '0',
            riu_prsnt_2 => '0',
            riu_rddata_1 => X"0000",
            riu_valid_1 => '0',
            riu_prsnt_1 => '0',
            --rx_btval_3 => 
            --rx_btval_2 => 
            --rx_btval_1 => 
            --clk_rst_debug_out => 
            --tx_pll_clk_out => 
            --rx_pll_clk_out => 
            --tx_rdclk_out => 
            --tx_dly_rdy => 
            --tx_vtc_rdy => 
            --rx_dly_rdy => 
            --rx_vtc_rdy => 
            reset => rst
        );


    locked_i <= tx_locked and rx_locked;
    locked <= locked_i;

    phy_on <= '1';
    phy_resetb <= not rst_phy;

end rtl;

