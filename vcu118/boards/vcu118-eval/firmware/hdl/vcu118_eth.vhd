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
use ieee.numeric_std.all;

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
        -- input free-running clock
        sysclk125: in std_logic;
        -- connection control and status (to logic)
        rst: in std_logic;     -- request reset of ethernet system
        rst_clients: out std_logic; -- request reset of output
        locked: out std_logic; -- locked to ethernet clock
        debug_leds: out std_logic_vector(7 downto 0);
        dip_sw : in std_logic_vector(3 downto 0);
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
            an_adv_config_vector_0 : in STD_LOGIC_VECTOR( 15 downto 0 );
            an_restart_config_0 : in STD_LOGIC;
            an_interrupt_0 : out STD_LOGIC;
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

    --- clocks
    signal clk125, clk2mhz: std_logic;
    --- slow clocks and edges
    signal slowclk, slowclk_d, slowedge: std_logic := '0'; -- slow generated clocks
    --- resets
    signal rst_chain : std_logic_vector(4 downto 0) := (others => '1');
    signal sysrst: std_logic; -- in to logic
    signal rst125: std_logic; -- out from SGMII
    signal glb_rstn, tx_axi_rstn, rx_axi_rstn: std_logic; -- in to MAC
    signal tx_reset_out, rx_reset_out: std_logic; -- out from MAC
    --- locked
    signal rx_locked, tx_locked: std_logic;

    -- data
    signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
    signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;

    -- mac stats
    --signal rx_statistics_vector : std_logic_vector(27 downto 0);
    --signal rx_statistics_valid : std_logic;

    -- sgmii controls and status
    signal an_restart, an_restart_d : std_logic := '0';
    signal sgmii_status_vector : std_logic_vector(15 downto 0);

    -- mdio controls and status
    signal mdio_done, mdio_done_d, mdio_clkdone, mdio_poll_done : std_logic := '0';
    signal mdio_status_reg1, mdio_status_reg2, mdio_status_reg3, mdio_status_reg4, mdio_status_reg5 : std_logic_vector(15 downto 0);

begin

phy_on <= '1';

clkdiv: entity work.ipbus_clock_div
    port map( clk => sysclk125, d7 => clk2mhz, d28 => slowclk ); 
    phy_mdc <= clk2mhz;

make_slowedge: process(sysclk125)
    begin
        if rising_edge(sysclk125) then -- ff's with CE
            slowclk_d <= slowclk;
        end if;
    end process;
    slowedge <= '1' when (slowclk = '1' and slowclk_d /= '1') else '0';

rst_req: process(sysclk125,rst) -- async-presettables ff's with CE
    begin
        if rst = '1' then
            rst_chain <= (others => '1');
        elsif rising_edge(sysclk125) then
            if slowedge = '1' then
               rst_chain <= "0" & rst_chain(4 downto 1);
            end if;
        end if;
    end process;
    sysrst  <= rst_chain(0);
    glb_rstn <= not sysrst;
    tx_axi_rstn <= not rst125;
    rx_axi_rstn <= not rst125;
    phy_resetb <= not rst_chain(3);
    rst_clients <= tx_reset_out or rx_reset_out;

    mac: temac_gbe_v9_0
        port map(
            gtx_clk => clk125,
            glbl_rstn => glb_rstn,
            rx_axi_rstn => rx_axi_rstn,
            tx_axi_rstn => tx_axi_rstn,
            rx_statistics_vector => open,
            rx_statistics_valid => open,
            rx_mac_aclk => open,
            rx_reset => rx_reset_out,
            rx_axis_mac_tdata => rx_data,
            rx_axis_mac_tvalid => rx_valid, 
            rx_axis_mac_tlast => rx_last,
            rx_axis_mac_tuser => rx_error,
            tx_ifg_delay => X"00",
            tx_statistics_vector => open,
            tx_statistics_valid => open,
            tx_mac_aclk => open,
            tx_reset => tx_reset_out,
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
            signal_detect_0 => mdio_clkdone, 
            an_adv_config_vector_0 => b"1101_1000_0000_0001", -- probably useless
            an_restart_config_0 => an_restart, --important
            an_interrupt_0 => open, --useless
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
            status_vector_0 => sgmii_status_vector, 
            configuration_vector_0 => (4 => '1', 3 => not(mdio_clkdone), others => '0'),
            clk125_out => clk125,
            rst_125_out => rst125, 
            rx_locked => rx_locked,
            tx_locked => tx_locked,
            -- al this below is dummy but needed
            riu_rddata_3 => X"0000",
            riu_valid_3 => '0',
            riu_prsnt_3 => '0',
            riu_rddata_2 => X"0000",
            riu_valid_2 => '0',
            riu_prsnt_2 => '0',
            riu_rddata_1 => X"0000",
            riu_valid_1 => '0',
            riu_prsnt_1 => '0',
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
            -- input reset
            reset => not (mdio_clkdone)
        );
    ethclk125 <= clk125;
    locked <= rx_locked and tx_locked;

mdio_mdc: entity work.vcu118_eth_mdio
    port map ( 
        sysclk125 => sysclk125,
        mdc => clk2mhz,
        rst => sysrst,
        done => mdio_done,
        clkdone => mdio_clkdone,
        poll_enable => '1',
        poll_clk => slowclk,
        poll_done => mdio_poll_done,
        status_reg1 => mdio_status_reg1,
        status_reg2 => mdio_status_reg2,
        status_reg3 => mdio_status_reg3,
        status_reg4 => mdio_status_reg4,
        status_reg5 => mdio_status_reg5,
        phy_mdio => phy_mdio);
                
auto_reneg: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            mdio_done_d <= mdio_done;
            if mdio_done_d = '0' and mdio_done = '1' then
                an_restart <= '1';    
                an_restart_d <= '1';    
            else
                an_restart <= an_restart_d;
                an_restart_d <= '0';
            end if;
        end if;
    end process;

set_leds: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            case dip_sw(2 downto 0) is 
               when "000" =>
                    debug_leds(0) <= slowclk;
                    debug_leds(1) <= mdio_done;
                    debug_leds(2) <= rx_locked and rx_locked;
                    debug_leds(3) <= not (tx_reset_out or rx_reset_out);
                    debug_leds(4) <= sgmii_status_vector(0) and sgmii_status_vector(1) and sgmii_status_vector(7);
                    debug_leds(5) <= sgmii_status_vector(3);
                    debug_leds(6) <= sgmii_status_vector(10);
                    debug_leds(7) <= sgmii_status_vector(11);
               when "001" => 
                    debug_leds(0) <= mdio_clkdone;
                    debug_leds(1) <= mdio_done;
                    debug_leds(2) <= rx_locked and rx_locked;
                    debug_leds(3) <= rst125;
                    debug_leds(4) <= not (tx_reset_out or rx_reset_out);
                    debug_leds(5) <= sgmii_status_vector(0) and sgmii_status_vector(1) and sgmii_status_vector(7);
                    debug_leds(6) <= sgmii_status_vector(3);
                    debug_leds(7) <= an_restart;
               when "010" => debug_leds(7 downto 0) <= (others => '0');
               when "011" => debug_leds(7 downto 0) <= (others => '0');
               when "100" =>
                    debug_leds(0) <= slowclk;
                    debug_leds(1) <= mdio_poll_done;
                    debug_leds(2) <= mdio_status_reg1(5);
                    debug_leds(3) <= mdio_status_reg1(4);
                    debug_leds(4) <= mdio_status_reg1(3);
                    debug_leds(5) <= mdio_status_reg1(2);
                    debug_leds(6) <= mdio_status_reg1(1);
                    debug_leds(7) <= mdio_status_reg1(0);
               when "101" =>
                    debug_leds(0) <= slowclk;
                    debug_leds(1) <= mdio_poll_done;
                    debug_leds(2) <= mdio_status_reg2(13);
                    debug_leds(3) <= mdio_status_reg2(12);
                    debug_leds(4) <= mdio_status_reg2(11);
                    debug_leds(5) <= mdio_status_reg2(10);
                    debug_leds(6) <= mdio_status_reg2(1);
                    debug_leds(7) <= mdio_status_reg2(0);
               when "110" =>
                    debug_leds(0) <= slowclk;
                    debug_leds(1) <= mdio_poll_done;
                    debug_leds(2) <= mdio_status_reg3(14);
                    debug_leds(3) <= mdio_status_reg3(13);
                    debug_leds(4) <= mdio_status_reg3(11);
                    debug_leds(5) <= mdio_status_reg3(10);
                    debug_leds(6) <= mdio_status_reg3(9);
                    debug_leds(7) <= mdio_status_reg3(8);
               when "111" =>
                    debug_leds(0) <= slowclk;
                    debug_leds(1) <= mdio_poll_done;
                    debug_leds(2) <= mdio_status_reg4(15);
                    debug_leds(3) <= mdio_status_reg4(14);
                    debug_leds(4) <= mdio_status_reg4(13);
                    debug_leds(5) <= mdio_status_reg4(12);
                    debug_leds(6) <= mdio_status_reg4(11);
                    debug_leds(7) <= mdio_status_reg4(10);
            end case;
        end if;
    end process;

end rtl;

