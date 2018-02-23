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
            mdio_i : in STD_LOGIC;
            mdio_o : out STD_LOGIC;
            mdio_t : out STD_LOGIC;
            mdc : out STD_LOGIC;
            s_axi_aclk : in STD_LOGIC;
            s_axi_resetn : in STD_LOGIC;
            s_axi_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
            s_axi_awvalid : in STD_LOGIC;
            s_axi_awready : out STD_LOGIC;
            s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            s_axi_wvalid : in STD_LOGIC;
            s_axi_wready : out STD_LOGIC;
            s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            s_axi_bvalid : out STD_LOGIC;
            s_axi_bready : in STD_LOGIC;
            s_axi_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
            s_axi_arvalid : in STD_LOGIC;
            s_axi_arready : out STD_LOGIC;
            s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            s_axi_rvalid : out STD_LOGIC;
            s_axi_rready : in STD_LOGIC;
            mac_irq : out STD_LOGIC
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
            an_interrupt_0 : out STD_LOGIC;
            an_adv_config_vector_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
            an_adv_config_val_0 : in STD_LOGIC;
            an_restart_config_0 : in STD_LOGIC;
            status_vector_0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
            ext_mdc_0 : out STD_LOGIC;
            ext_mdio_i_0 : in STD_LOGIC;
            ext_mdio_o_0 : out STD_LOGIC;
            ext_mdio_t_0 : out STD_LOGIC;
            mdio_t_in_0 : in STD_LOGIC;
            mdc_0 : in STD_LOGIC;
            mdio_i_0 : in STD_LOGIC;
            mdio_o_0 : out STD_LOGIC;
            mdio_t_0 : out STD_LOGIC;
            phyaddr_0 : in STD_LOGIC_VECTOR ( 4 downto 0 );
            configuration_vector_0 : in STD_LOGIC_VECTOR ( 4 downto 0 );
            configuration_valid_0 : in STD_LOGIC;
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
    signal mac_mdio_i, mac_mdio_t, mac_mdio_o, mac_mdc : std_logic;
    signal phy_mdio_i, phy_mdio_t, phy_mdio_o : std_logic;
    signal beat_sysclk125, beat_clk125 : std_logic;
    signal an_done, rx_valid_i : std_logic;
    signal for_leds : std_logic_vector(7 downto 2) := (others => '0');
    signal toggle_leds: std_logic := '0';
    signal rst_b1_c125_m, rst_b1_c125, rst_b2_c125_m, rst_b2_c125, rst_b2_c125_d : std_logic := '0';

    signal axi_addr : std_logic_vector(11 downto 0);
    signal axi_wdata, axi_rdata : std_logic_vector(31 downto 0) := (others => '0');
    signal axi_wresp, axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
    signal axi_awvalid, axi_awready : std_logic := '0';
    signal axi_wvalid, axi_wready : std_logic := '0';
    signal axi_arvalid, axi_arready : std_logic := '0';
    signal axi_wresp_valid, axi_rvalid : std_logic := '0';

    signal beat_sysclk125_del, slowedge: std_logic := '0';  -- very slow clock (~Hz), for waiting until device is read
    signal rst_chain : std_logic_vector(4 downto 0) := (others => '1'); -- delay chain 

    signal axi_prog_done : std_logic := '0';
    type   axi_prog_state_t is ( DoInit, WaitMDIOReady, MDIOAddReady, MDIODataReady, MDIOWriteDone, ProgDone );
    signal axi_prog_state : axi_prog_state_t := DoInit;

    constant VCU118_PHYADD : std_logic_vector(4 downto 0) := b"00011";
    constant AXI_PROG_LENGTH : integer := 4;
    signal axi_prog_index : integer range 0 to AXI_PROG_LENGTH := 0;
    signal axi_prog_wait : std_logic := '0';
    type   axi_prog_reg_t is array(0 to AXI_PROG_LENGTH-1) of std_logic_vector(4 downto 0);
    type   axi_prog_val_t is array(0 to AXI_PROG_LENGTH-1) of std_logic_vector(15 downto 0);
    signal axi_prog_reg : axi_prog_reg_t := ( "01101", "01110", "01101", "01110" );
    signal axi_prog_val : axi_prog_val_t := ( x"001F", x"00D3", x"401F", x"4000" );

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
            mdio_i => mac_mdio_i,
            mdio_o => mac_mdio_o,
            mdio_t => mac_mdio_t,
            mdc => mac_mdc,
            s_axi_aclk => sysclk125,
            s_axi_resetn => rst_phy,
            s_axi_awaddr => axi_addr, --: in STD_LOGIC_VECTOR ( 11 downto 0 ), -- write addr
            s_axi_awvalid => axi_awvalid, --: in STD_LOGIC,                                  -- write addr valid
            s_axi_awready => axi_awready, --: out STD_LOGIC,                                -- write addr ready
            s_axi_wdata => axi_wdata, --: in STD_LOGIC_VECTOR ( 31 downto 0 );     -- write data
            s_axi_wvalid => axi_wvalid, --: in STD_LOGIC,                                   -- valid
            s_axi_wready => axi_wready, --: out STD_LOGIC,                                 -- ready
            s_axi_bresp => axi_wresp, --: out STD_LOGIC_VECTOR ( 1 downto 0 ),            -- response
            s_axi_bvalid => axi_wresp_valid, --: out STD_LOGIC,                                 -- valid
            s_axi_bready => '1', --: in STD_LOGIC,                                -- ready
            s_axi_araddr => axi_addr, --: in STD_LOGIC_VECTOR ( 11 downto 0 ),   -- read addr
            s_axi_arvalid => axi_arvalid, -- : in STD_LOGIC,                                   -- valid
            s_axi_arready => axi_arready, --: out STD_LOGIC,                                  -- ready
            s_axi_rdata => axi_rdata, --: out STD_LOGIC_VECTOR ( 31 downto 0 ),             -- data
            s_axi_rresp => axi_rresp, --: out STD_LOGIC_VECTOR ( 1 downto 0 ),              -- response
            s_axi_rvalid => axi_rvalid, --: out STD_LOGIC,                                   -- valid
            s_axi_rready => '1', --: in STD_LOGIC,                                     -- ready
            mac_irq => open  --: out STD_LOGIC

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
            an_interrupt_0 => an_done, --useless, it doesn't come from the phy
            an_adv_config_vector_0 => (0 => '1', 10=>'0', 11=>'1', 12=>'1', 14=>'1', 15=>'1', others=>'0'),
                                      -- 0:SGMII: 10-11: 1000Mbps  12: Full Duplex  14: ACK  15: Link up 
                                      -- probably useless as it does not reach the PHY
            an_adv_config_val_0 => '1',
            an_restart_config_0 => '0', --useless, it doesn't reach: the phy
            status_vector_0 => status_vector, --open, --useless, it doesn't come from the phy

            ext_mdc_0 => phy_mdc,
            ext_mdio_i_0 => phy_mdio_i,
            ext_mdio_o_0 => phy_mdio_o,
            ext_mdio_t_0 => phy_mdio_t,
            mdio_t_in_0 => mac_mdio_t,
            mdc_0 => mac_mdc,
            mdio_i_0 => mac_mdio_o,
            mdio_o_0 => mac_mdio_i,
            mdio_t_0 => open,
            phyaddr_0 => b"01000", -- must not be 00011 (VCU PHY)
            configuration_vector_0 => b"00000", -- useless, it doesn't reach the PHY
            configuration_valid_0 => '0',
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
            reset => '0' -- otherwise we reset the PLLs and they will never lock!
        );


    locked_i <= tx_locked and rx_locked;
    locked <= locked_i;

    mdio_3st: IOBUF
        port map( T => phy_mdio_t, I => phy_mdio_o, O => phy_mdio_i, IO => phy_mdio );

    phy_on <= '1';
    phy_resetb <= not rst_phy;

    -- synchronize reset buttons to clk125
    capture_reset1: process(sysclk125,reset_b1)
        begin
            if reset_b1 = '1' then
                rst_b1_c125_m <= '1'; 
                rst_b1_c125 <= '1'; 
            elsif rising_edge(sysclk125) then
                rst_b1_c125_m <= '0';
                rst_b1_c125 <= rst_b1_c125_m;
            end if;
        end process;

    toggle_led: process(sysclk125)
        begin
            if rising_edge(sysclk125) then
                toggle_leds <= dip_sw(0);
            end if;
        end process;

    debug_leds(0) <= locked_i and beat_clk125;
    debug_leds(1) <= beat_sysclk125;
    debug_leds(7 downto 2) <= for_leds(7 downto 2);

    capture_leds: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            if rst_b1_c125 = '1' then
                for_leds <= (others => '0');
            else
                if dip_sw(3) = '0' then
                    if dip_sw(1) = '0' then
                        if dip_sw(0) = '0' then
                            for_leds(2) <= an_done;
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
                else
                    if dip_sw(1) = '0' then
                        for_leds(2) <= axi_prog_done;
                        for_leds(3) <= axi_prog_wait;
                        if axi_prog_index > 0 then
                            for_leds(4) <= '1';
                        else
                            for_leds(4) <= '0';
                        end if;
                        case axi_prog_state is
                            when DoInit => for_leds(7 downto 5) <= "000";
                            when WaitMDIOReady => for_leds(7 downto 5) <= "001";
                            when MDIOAddReady  => for_leds(7 downto 5) <= "010";
                            when MDIODataReady => for_leds(7 downto 5) <= "011";
                            when MDIOWriteDone => for_leds(7 downto 5) <= "101";
                            when ProgDone => for_leds(7 downto 5) <= "111";
                        end case;
                    else
                        --for_leds(2) <= axi_prog_done;
                        --for_leds(7 downto 3) <= rst_chain(4 downto 0);
                        if dip_sw(0) = '0' then
                            for_leds(2) <= axi_awvalid;
                            for_leds(3) <= axi_awready;
                            for_leds(4) <= axi_wvalid;
                            for_leds(5) <= axi_wready;
                            for_leds(6) <= axi_wresp_valid;
                            for_leds(7) <= not (axi_wresp(0) or axi_wresp(1));
                        else
                            for_leds(2) <= axi_arvalid;
                            for_leds(3) <= axi_arready;
                            for_leds(4) <= '0';
                            for_leds(5) <= '0';
                            for_leds(6) <= axi_rvalid;
                            for_leds(7) <= not (axi_rresp(0) or axi_rresp(1));
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    heart_sysclk125: entity work.ipbus_clock_div
            port map( clk => sysclk125, d28 => beat_sysclk125 );
    heart_clk125: entity work.ipbus_clock_div
            port map( clk => clk125, d28 => beat_clk125 );


    make_slowedge: process(sysclk125)
        begin
            if rising_edge(sysclk125) then 
                beat_sysclk125_del <= beat_sysclk125;
            end if;
        end process;
        slowedge <= '1' when (beat_sysclk125 = '1' and beat_sysclk125_del /= '1') else '0';

    long_wait: process(sysclk125,rst_phy)
        begin
            if rst_phy = '1' then
                rst_chain <= (others => '1');
            elsif rising_edge(sysclk125) then
                if slowedge = '1' then
                   rst_chain(4 downto 0) <= '0' & rst_chain(4 downto 1);
                end if;
            end if;
        end process;

    axi_prog: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            if rst_chain(0) = '0' then
                case axi_prog_state is
                    when DoInit =>
                        if axi_prog_wait = '0' then
                            axi_addr <= x"500";
                            axi_awvalid <= '1';
                            axi_arvalid <= '0';
                            axi_wdata <= x"0000005F";
                            axi_wvalid <= '1';
                            axi_prog_wait <= '1';
                        else
                            if axi_awready = '1' then axi_awvalid <= '0'; end if;
                            if axi_wready  = '1' then axi_wvalid  <= '0'; end if;
                            if axi_wresp_valid = '1' then
                                if axi_wresp = b"00" then
                                    axi_prog_state <= WaitMDIOReady;
                                end if;
                                axi_prog_wait <= '0';
                            end if;
                        end if;
                    when WaitMDIOReady =>
                        if axi_prog_wait = '0' then
                            axi_addr <= x"504";
                            axi_awvalid <= '0';
                            axi_arvalid <= '1';
                            axi_wvalid <= '0';
                            axi_prog_wait <= '1';
                        else
                            if axi_arready = '1' then axi_arvalid <= '0'; end if;
                            if axi_rvalid = '1' then
                                if axi_wresp = b"00" and axi_rdata(7) = '1' then
                                    axi_prog_state <= MDIOAddReady;
                                end if;
                                axi_prog_wait <= '0';
                            end if;
                        end if;
                    when MDIOAddReady =>
                        if axi_prog_wait = '1' then
                            axi_addr <= x"504";
                            axi_awvalid <= '1';
                            axi_arvalid <= '0';
                            axi_wdata <= b"000" & VCU118_PHYADD & b"000" & axi_prog_reg(axi_prog_index) & b"01_00_1_000_0_000_0000";
                            axi_wvalid <= '1';
                            axi_prog_wait <= '1';
                        else
                            if axi_awready = '1' then axi_awvalid <= '0'; end if;
                            if axi_wready  = '1' then axi_wvalid  <= '0'; end if;
                            if axi_wresp_valid = '1' then
                                if axi_wresp = b"00" then
                                    axi_prog_state <= MDIODataReady;
                                end if;
                                axi_prog_wait <= '0';
                            end if;
                        end if;
                    when MDIODataReady =>
                        if axi_prog_wait = '1' then
                            axi_addr <= x"508";
                            axi_awvalid <= '1';
                            axi_arvalid <= '0';
                            axi_wdata <= x"0000" & axi_prog_val(axi_prog_index);
                            axi_wvalid <= '1';
                            axi_prog_wait <= '1';
                        else
                            if axi_awready = '1' then axi_awvalid <= '0'; end if;
                            if axi_wready  = '1' then axi_wvalid  <= '0'; end if;
                            if axi_wresp_valid = '1' then
                                if axi_wresp = b"00" then
                                    axi_prog_state <= MDIOWriteDone;
                                end if;
                                axi_prog_wait <= '0';
                            end if;
                        end if;
                    when MDIOWriteDone =>
                        if axi_prog_index = AXI_PROG_LENGTH-1 then
                            axi_prog_state <= ProgDone;
                        else
                            axi_prog_index <= axi_prog_index + 1;
                            axi_prog_state <= WaitMDIOReady;
                        end if;
                    when ProgDone =>
                        axi_prog_done <= '1';
                end case;
           else
                axi_prog_state <= DoInit;
                axi_prog_wait <= '0';
                axi_prog_index <= 0;
                axi_prog_done <= '0';
            end if;
        end if;
    end process;


end rtl;

