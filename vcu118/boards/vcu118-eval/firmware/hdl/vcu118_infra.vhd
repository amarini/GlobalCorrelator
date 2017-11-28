-- partially inspired by https://github.com/ipbus/ipbus-firmware/blob/master/boards/kcu105/base_fw/kcu105_basex/synth/firmware/hdl/kcu105_basex_infra.vhd

library ieee;
use ieee.std_logic_1164.all;

use work.ipbus.all;

entity vcu118_infra is
    port(
        -- input clock pins
        sysclk_in_p : in std_logic; -- 300 MHz
        sysclk_in_n : in std_logic; -- 300 MHz
        sysclk125_in_p : in std_logic; -- 125 MHz
        sysclk125_in_n : in std_logic; -- 125 MHz
        -- output data clocks & reset
        clk:   out std_logic; -- algo clock (240 MHz)
        clk40: out std_logic; -- 40 MHz output clock
        -- status ok
        status_ok : out std_logic; -- should be 1 on stable running
        -- ipbus
        clk_ipb: out std_logic;
        rst_ipb: in std_logic;
        ipb_in: in ipb_rbus; 
        ipb_out: out ipb_wbus;
        -- ethernet
        clk625_p : in std_logic; --> 625 MHz clock from external device
        clk625_n : in std_logic; 
        txp : out std_logic; 
        txn : out std_logic; 
        rxp : in std_logic; 
        rxn : in std_logic; 
        phy_on   : out std_logic; -- on/off signal
        phy_resetb: out std_logic -- reset signal
    );
end vcu118_infra;

architecture rtl of vcu118_infra is
    -- for clocking part
    signal sysclk125, ipbclk, mmcm_reset, mmcm_locked: std_logic; 
    -- inputs from ethernet
    signal eth_clk125, eth_rst125, eth_locked, phy_reset_done: std_logic;
    -- control
    signal rst_eth, rst_phy: std_logic; -- request rest ethernet MAC / physical interface  
    -- ipbus to ethernet
    signal tx_data, rx_data: std_logic_vector(7 downto 0);
    signal tx_valid, tx_last, tx_error, tx_ready, rx_valid, rx_last, rx_error: std_logic;
    -- other ipbus stuff
    signal mac_addr: std_logic_vector(47 downto 0);
    signal ip_addr: std_logic_vector(31 downto 0);
    signal pkt : std_logic;
begin
    clocks : entity work.vcu118_clocks
        port map(
            sysclk_in_p => sysclk_in_p,
            sysclk_in_n => sysclk_in_n,
            sysclk125_in_p => sysclk125_in_p,
            sysclk125_in_n => sysclk125_in_n,
            sysclk125 => sysclk125,
            ipbclk => ipbclk,
            clk => clk,
            clk40 => clk40,
            mmcm_reset => mmcm_reset,
            mmcm_locked => mmcm_locked);

    mmcm_reset <= '0'; -- FIXME figure out input reset logic

    eth : entity work.vcu118_eth
        port map(
            -- system clock in
            sysclk125 => sysclk125,
            -- reset in
            rsti => rst_eth,
            rst_phy => rst_phy,
            -- status
            locked => eth_locked,
            rst_phy_done => phy_reset_done,
            -- eth clock out
            clk125_out => eth_clk125,
            rst125_out => eth_rst125,
            -- mac ports (go to ipbus)
            tx_data => tx_data, rx_data => rx_data,
            tx_valid => tx_valid, tx_last => tx_last, tx_error => tx_error, tx_ready => tx_ready, 
            rx_valid => rx_valid, rx_last => rx_last, rx_error => rx_error,
            -- eth external ports (go to top level ports)
            clk625_p => clk625_p, clk625_n => clk625_n,
            txp => txp, txn => txn,
            rxp => rxp, rxn => rxn,
            phy_on => phy_on, phy_resetb => phy_resetb);

    rst_eth <= '0'; -- FIXME figure out when to reset
    rst_phy <= '0'; -- FIXME figure out when to reset

    ipbus: entity work.ipbus_ctrl
        port map(
            mac_clk => eth_clk125,
            rst_macclk => eth_rst125,
            ipb_clk => ipbclk,
            rst_ipb => rst_ipb,
            mac_rx_data => rx_data,
            mac_rx_valid => rx_valid,
            mac_rx_last => rx_last,
            mac_rx_error => rx_error,
            mac_tx_data => tx_data,
            mac_tx_valid => tx_valid,
            mac_tx_last => tx_last,
            mac_tx_error => tx_error,
            mac_tx_ready => tx_ready,
            ipb_out => ipb_out,
            ipb_in => ipb_in,
            mac_addr => mac_addr,
            ip_addr => ip_addr,
            pkt => pkt);

    mac_addr <= X"020ddba11511";
    ip_addr <= X"c0a8c811";
    clk_ipb <= ipbclk;

    status_ok <= mmcm_locked and eth_locked and phy_reset_done;

end rtl;
