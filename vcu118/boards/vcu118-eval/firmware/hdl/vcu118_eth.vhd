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
        phy_mdio: inout std_logic; -- control line to program the PHY chip
        phy_mdc : out std_logic;   -- clock line (must be < 2.5 MHz)
        -- 125 MHz clocks
        ethclk125: out std_logic; -- 125 MHz from ethernet
        ethrst125: out std_logic; -- 125 MHz from ethernet
        -- input free-running clock
        sysclk125: in std_logic;
        -- connection control and status (to logic)
        rst: in std_logic;     -- request reset of ethernet MAC
        locked: out std_logic; -- locked to ethernet clock
        rst_phy: in std_logic; -- request reset of external ethernet device
        debug_leds: out std_logic_vector(7 downto 0);
        reset_b1: in std_logic; -- in case of worry, press this button
        reset_b2: in std_logic; -- in case of uneasiness, press this button
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
            --an_adv_config_vector_0 : in STD_LOGIC_VECTOR( 15 downto 0 );
            --an_restart_config_0 : in STD_LOGIC;
            --an_interrupt_0 : out STD_LOGIC;
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
            tx_dly_rdy_1 : in STD_LOGIC;
            rx_dly_rdy_1 : in STD_LOGIC;
            rx_vtc_rdy_1 : in STD_LOGIC;
            tx_vtc_rdy_1 : in STD_LOGIC;
            tx_dly_rdy_2 : in STD_LOGIC;
            rx_dly_rdy_2 : in STD_LOGIC;
            rx_vtc_rdy_2 : in STD_LOGIC;
            tx_vtc_rdy_2 : in STD_LOGIC;
            tx_dly_rdy_3 : in STD_LOGIC;
            rx_dly_rdy_3 : in STD_LOGIC;
            rx_vtc_rdy_3 : in STD_LOGIC;
            tx_vtc_rdy_3 : in STD_LOGIC;
            tx_pll_clk_out : out STD_LOGIC;
            rx_pll_clk_out : out STD_LOGIC;
            tx_rdclk_out : out STD_LOGIC;
            reset : in STD_LOGIC
        );
    END COMPONENT;

    signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
    signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;
    signal gmii_rx_clk: std_logic;
    signal clk125, rst125, rx_locked, tx_locked, locked_i, rstn: std_logic;
    signal rx_statistics_vector : std_logic_vector(27 downto 0);
    signal rx_statistics_valid : std_logic;
    signal status_vector : std_logic_vector(15 downto 0);
    signal mdio_done : std_logic;
    signal beat_sysclk125, beat_clk125 : std_logic;
    signal rx_valid_i : std_logic;
    signal for_leds : std_logic_vector(7 downto 2) := (others => '0');
    signal toggle_leds: std_logic := '0';
    signal rst_b1_c125_m, rst_b1_c125, rst_b2_c125_m, rst_b2_c125, rst_b2_c125_d : std_logic := '0';
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
            rx_statistics_vector => rx_statistics_vector,
            rx_statistics_valid => rx_statistics_valid,
            rx_mac_aclk => open,
            rx_reset => open,
            rx_axis_mac_tdata => rx_data,
            rx_axis_mac_tvalid => rx_valid_i,
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
    rx_valid <= rx_valid_i;

    sgmii: sgmii_adapter_lvds_0
        port map ( 
            refclk625_p => clk625_p,
            refclk625_n => clk625_n,
            txp_0 => txp,
            txn_0 => txn,
            rxp_0 => rxp,
            rxn_0 => rxn,
            signal_detect_0 => '1', --?
            --an_adv_config_vector_0 => (0 => '1', 10=>'0', 11=>'1', 12=>'1', 14=>'1', 15=>'1', others=>'0'),
            --                          -- 0:SGMII: 10-11: 1000Mbps  12: Full Duplex  14: ACK  15: Link up 
            --                          -- probably useless as it does not reach the PHY
            --an_restart_config_0 => '0', --useless, it doesn't reach: the phy
            --an_interrupt_0 => done, --useless, it doesn't come from the phy
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
            status_vector_0 => status_vector, --open, --useless, it doesn't come from the phy
            configuration_vector_0 => b"00000", -- useless, it doesn't reach the PHY
            clk125_out => clk125,
            --clk312_out => clk312,
            rst_125_out => rst125, 
            --tx_logic_reset => 
            --rx_logic_reset => 
            rx_locked => rx_locked,
            tx_locked => tx_locked,
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
            tx_dly_rdy_1 => '1',
            rx_dly_rdy_1 => '1',
            rx_vtc_rdy_1 => '1',
            tx_vtc_rdy_1 => '1',
            tx_dly_rdy_2 => '1',
            rx_dly_rdy_2 => '1',
            rx_vtc_rdy_2 => '1',
            tx_vtc_rdy_2 => '1',
            tx_dly_rdy_3 => '1',
            rx_dly_rdy_3 => '1',
            rx_vtc_rdy_3 => '1',
            tx_vtc_rdy_3 => '1',
            --tx_pll_clk_out => 
            --rx_pll_clk_out => 
            --tx_rdclk_out => 
            reset => not mdio_done -- otherwise we reset the PLLs and they will never lock!
        );


    locked_i <= tx_locked and rx_locked and mdio_done;
    locked <= locked_i;

    mdio_mdc: entity work.vcu118_eth_mdio
        port map ( 
            sysclk125 => sysclk125,
            rst_phy => rst_phy,
            done => mdio_done,
            phy_mdio => phy_mdio,
            phy_mdc => phy_mdc);
                
    phy_on <= '1';
    phy_resetb <= not rst_phy;

    -- synchronize reset buttons to clk125
    capture_reset1: process(clk125,reset_b1)
        begin
            if reset_b1 = '1' then
                rst_b1_c125_m <= '1'; 
                rst_b1_c125 <= '1'; 
            elsif rising_edge(clk125) then
                rst_b1_c125_m <= '0';
                rst_b1_c125 <= rst_b1_c125_m;
            end if;
        end process;

    toggle_led: process(sysclk125)
        begin
            if rising_edge(sysclk125) then
                rst_b2_c125_d <= reset_b2;
                if reset_b2 = '1' and rst_b2_c125_d = '0' then
                    toggle_leds <= not toggle_leds;
                end if;
            end if;
        end process;

    debug_leds(0) <= locked_i and beat_clk125;
    debug_leds(1) <= mdio_done;
    debug_leds(2) <= toggle_leds;
    debug_leds(7 downto 2) <= for_leds(7 downto 2);

    capture_leds: process(clk125)
    begin
        if rising_edge(clk125) then
            if rst_b1_c125 = '1' then
                for_leds <= (others => '0');
            else
                if toggle_leds = '0' then
                    if rst125 = '1'     then for_leds(3) <= '1'; end if;
                    if gmii_rx_dv = '1' then for_leds(4) <= '1'; end if;
                    if gmii_rx_er = '1' then for_leds(5) <= '1'; end if;
                    if status_vector(0) = '1' then for_leds(6) <= '1'; end if;
                    if status_vector(1) = '1' then for_leds(7) <= '1'; end if;
                else
                    if status_vector(2) = '1' then for_leds(3) <= '1'; end if;
                    if status_vector(3) = '1' then for_leds(4) <= '1'; end if;
                    if status_vector(4) = '1' then for_leds(5) <= '1'; end if;
                    if status_vector(5) = '1' then for_leds(6) <= '1'; end if;
                    if status_vector(6) = '1' then for_leds(7) <= '1'; end if;
                end if;
            end if;
        end if;
    end process;

    heart_sysclk125: entity work.ipbus_clock_div
            port map( clk => sysclk125, d28 => beat_sysclk125 );
    heart_clk125: entity work.ipbus_clock_div
            port map( clk => clk125, d28 => beat_clk125 );



end rtl;

