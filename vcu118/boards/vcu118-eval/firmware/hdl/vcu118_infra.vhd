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
        rst:   out std_logic; -- algo reset (on algo clock)
        rst40: out std_logic; -- algo reset (on clk40)
        -- input big reset button
        reset_button: in std_logic; -- in case of panic, press this button
        -- status ok
        status_ok : out std_logic; -- should be 1 on stable running
        -- ipbus
        clk_ipb: out std_logic;
        rst_ipb: out std_logic;
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
    -- ===== clock, rest and status signals ===== ---
    -- for clocking part (the ones without the _i don't go out of this module)
    signal clk_i, clk40_i, clk_ipb_i, sysclk125, mmcm_locked: std_logic; 
    -- inputs from reset logic
    signal rst_ipb_i, rst_ipb_ctrl, rst_eth, rst_phy, rst_eth_clients: std_logic;
    -- inputs from ethernet
    signal ethclk125, ethrst125, eth_locked: std_logic;
    -- generated here
    signal rst_ipbus_macpart: std_logic;

    -- ===== data lines ===== ---
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
            ipbclk => clk_ipb_i,
            clk => clk_i,
            clk40 => clk40_i,
            mmcm_reset => '0', -- for the moment, assume we don't need to reset this
            mmcm_locked => mmcm_locked);
    clk <= clk_i;
    clk40 <= clk40_i;

    resets : entity work.vcu118_resets
        port map(
            sysclk125 => sysclk125, -- system clock (125 MHz)
            ethclk125 => ethclk125, -- ethernet clock (125 MHz)
            ipbclk    => clk_ipb_i, -- ipbus clock (30 MHz)
            clk       => clk_i, -- algo clock (240 MHz)
            clk40     => clk40_i, -- 40 MHz clock
            --
            mmcm_locked => mmcm_locked,
            eth_locked => eth_locked,
            request_hard_rst_ext => reset_button,
            request_hard_rst_ipb => '0', -- FIXME read from IPbus register
            request_soft_rst_ipb => '0', -- FIXME read from IPbus register
            --
            rst => rst,
            rst40 => rst40,
            rst_ipb => rst_ipb_i,
            rst_ipb_ctrl => rst_ipb_ctrl,
            rst_phy => rst_phy,
            rst_eth => rst_eth,
            rst_eth_clients => rst_eth_clients,
            -- this is on when all resets are complete
            status_ok => status_ok);
    rst_ipb <= rst_ipb_i;

    eth : entity work.vcu118_eth
        port map(
            -- reset in
            rst => rst_eth,
            rst_phy => rst_phy,
            -- status
            locked => eth_locked,
            -- eth clock out
            ethclk125 => ethclk125,
            ethrst125 => ethrst125,
            -- mac ports (go to ipbus)
            tx_data => tx_data, rx_data => rx_data,
            tx_valid => tx_valid, tx_last => tx_last, tx_error => tx_error, tx_ready => tx_ready, 
            rx_valid => rx_valid, rx_last => rx_last, rx_error => rx_error,
            -- eth external ports (go to top level ports)
            clk625_p => clk625_p, clk625_n => clk625_n,
            txp => txp, txn => txn,
            rxp => rxp, rxn => rxn,
            phy_on => phy_on, phy_resetb => phy_resetb);

    rst_ipbus_macpart <= ethrst125 or rst_eth_clients;

    ipbus: entity work.ipbus_ctrl
        port map(
            mac_clk => ethclk125,
            rst_macclk => rst_ipbus_macpart,
            ipb_clk => clk_ipb_i,
            rst_ipb => rst_ipb_ctrl,
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
    clk_ipb <= clk_ipb_i;

end rtl;
