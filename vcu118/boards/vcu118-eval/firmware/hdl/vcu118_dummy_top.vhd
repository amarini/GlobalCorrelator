library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity top is
 port (
    -- board clocks
    sysclk125_in_p : in std_logic; -- 125 MHz
    sysclk125_in_n : in std_logic; -- 125 MHz
    -- ethernet
    clk625_p : in std_logic; --> 625 MHz clock from external device
    clk625_n : in std_logic; 
    txp : out std_logic := '0'; 
    txn : out std_logic := '0'; 
    rxp : in std_logic; 
    rxn : in std_logic; 
    phy_on   : out std_logic; -- on/off signal
    phy_resetb: out std_logic; -- reset signal
    phy_mdio: inout std_logic := '0'; 
    phy_mdc : out std_logic := '0'; 
    -- push button & leds
    rst_in  : in std_logic; -- external reset button
    rst_in1 : in std_logic; -- external reset button
    rst_in2 : in std_logic; -- external reset button
    dip_sw : in std_logic_vector(3 downto 0);
    leds : out std_logic_vector(7 downto 0)
  );
end top;

architecture Behavioral of top is
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
    COMPONENT sgmii_adapter_lvds_0_core
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


    signal sysclk125_u, sysclk125: std_logic;
    --signal mmcm_locked, clk_fb: std_logic;
    signal clk2mhz, clk2mhz_del, clk2mhz_edge: std_logic := '0'; -- slow generated clocks
    signal slowclk, slowclk_del, slowedge: std_logic := '0'; -- slow generated clocks
    signal rst_chain : std_logic_vector(4 downto 0) := (others => '1');
    signal rst_phy : std_logic := '1';
    signal phy_prog_done : std_logic := '0';
    signal clketh, sloweth, eth17, eth17_del, eth17_edge : std_logic := '0';
    signal mdio_t : std_logic := '1';
    signal mdio_i : std_logic := '0';
    signal mdio_o : std_logic := '0';
    
    constant VCU118_PHYADD : std_logic_vector(4 downto 0) := b"00011";
    constant MDIO_REG_0xD : std_logic_vector(4 downto 0) := b"01101";
    constant MDIO_REG_0xE : std_logic_vector(4 downto 0) := b"01110";
    constant MDIO_WRITE_ADDR : std_logic_vector(15 downto 0) := b"00_000000000_11111";
    constant MDIO_WRITE_VALUE : std_logic_vector(15 downto 0) := b"01_000000000_11111";

    function encode_mdio_reg_write( phyad : std_logic_vector(4 downto 0); 
                                    regad : std_logic_vector(4 downto 0);
                                    data  : std_logic_vector(15 downto 0))
                                    return std_logic_vector is
    begin
        return x"FFFF_FFFF" & b"01" & b"01" & phyad & regad & b"10" & data;
    end;
    function encode_mdio_extreg_write( phyad : std_logic_vector(4 downto 0); 
                                    extreg : std_logic_vector(15 downto 0);
                                    data   : std_logic_vector(15 downto 0))
                                    return std_logic_vector is
    begin
        return  encode_mdio_reg_write( phyad, MDIO_REG_0xD, MDIO_WRITE_ADDR ) &
                encode_mdio_reg_write( phyad, MDIO_REG_0xE, extreg ) &
                encode_mdio_reg_write( phyad, MDIO_REG_0xD, MDIO_WRITE_VALUE ) &
                encode_mdio_reg_write( phyad, MDIO_REG_0xE, data ) ;
    end;
    -- normal operation
    signal mdio_data_0 : std_logic_vector(0 to 1023) := encode_mdio_extreg_write( VCU118_PHYADD, x"00D3", x"4000" ) & -- eable sgmii clk
                                                        encode_mdio_extreg_write( VCU118_PHYADD, x"0032", x"0000" ) & -- disable rgmii
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10000", x"0800")    & -- enable sgmii
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    ; -- clear error counter 
    -- mii loopback (no AN)
    signal mdio_data_1 : std_logic_vector(0 to 1023) := encode_mdio_extreg_write( VCU118_PHYADD, x"00D3", x"4000" ) & -- eable sgmii clk
                                                        encode_mdio_extreg_write( VCU118_PHYADD, x"0032", x"0000" ) & -- disable rgmii
                                                        encode_mdio_extreg_write( VCU118_PHYADD, x"00FE", x"E720" ) & -- Loopback register
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10000", x"F860")    & -- enable sgmii
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"00000", x"4140")    & -- set 1000 full duplex, loopback, no AN
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10110", x"0040")    & -- also transmitd data out in MII loopback
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"11111", x"4000")    ; -- soft reset (does not change registers)
    -- digital loopback (AN)
    signal mdio_data_2 : std_logic_vector(0 to 1023) := encode_mdio_extreg_write( VCU118_PHYADD, x"00D3", x"4000" ) & -- eable sgmii clk
                                                        encode_mdio_extreg_write( VCU118_PHYADD, x"0032", x"0000" ) & -- disable rgmii
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10000", x"F860")    & -- enable sgmii
                                                        encode_mdio_extreg_write( VCU118_PHYADD, x"00FE", x"E720" ) & -- Loopback register
                                                        --encode_mdio_reg_write( VCU118_PHYADD, b"00000", x"0140")  & -- set 1000 full duplex, disable AN 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10110", x"0004")    & -- Enable Digital loopback!!! 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"11111", x"4000")    ; -- soft reset (does not change registers)
    -- reverse loopback
    signal mdio_data_3 : std_logic_vector(0 to 1023) := encode_mdio_extreg_write( VCU118_PHYADD, x"00D3", x"4000" ) & -- eable sgmii clk
                                                        encode_mdio_extreg_write( VCU118_PHYADD, x"0032", x"0000" ) & -- disable rgmii
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10000", x"F860")    & -- enable sgmii
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10110", x"00A0")    & -- Enable reverse loopback 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    & -- clear error counter 
                                                        encode_mdio_reg_write( VCU118_PHYADD, b"10101", x"0000")    ; -- clear error counter 

    signal mdio_data_addr : unsigned(10 downto 0) := (others => '0');

    signal tx_locked, rx_locked: std_logic := '0';
    signal rsteth : std_logic := '1';
    signal mac_gmii_txd, mac_gmii_rxd: std_logic_vector(7 downto 0) := (others => '0');
    signal mac_gmii_tx_en, mac_gmii_tx_er, mac_gmii_rx_dv, mac_gmii_rx_er: std_logic := '0';
    signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0) := (others => '0');
    signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic := '0';
    signal rx_statistics_vector : std_logic_vector(27 downto 0);
    signal rx_statistics_valid : std_logic := '0';
    signal tx_statistics_vector : std_logic_vector(31 downto 0);
    signal tx_statistics_valid : std_logic := '0';
    signal rx_count_good, rx_count_bad, tx_count_good, tx_count_bad : unsigned(7 downto 0) := (others => '0');
    signal tx_data, rx_data:  std_logic_vector(7 downto 0) := (others => '0');
    signal tx_valid, tx_last, tx_error, tx_ready: std_logic := '0';
    signal rx_valid, rx_last, rx_error: std_logic := '0';
    signal tx_clock_u, rx_clock_u, tx_clock, rx_clock, slowtx, slowrx : std_logic := '0';
    signal tx_reset_out, rx_reset_out : std_logic := '1';
    signal led_reset_rx, led_reset_tx, led_reset_eth : std_logic_vector(1 downto 0) := (others => '0');
    signal mac_resetn_async : std_logic := '0';
    signal mac_resetn : std_logic_vector(4 downto 0) := (others => '0');
    signal sgmii_signal_detect : std_logic := '0';
    signal sgmii_reset : std_logic := '1';
    signal sgmii_configuration_vector : std_logic_vector(4 downto 0) := (others => '0');


    signal send_pkg : std_logic := '0';
    signal rec_pkg : std_logic_vector(3 downto 0) := (others => '0');
    signal det_pkg : std_logic_vector(4 downto 0) := (others => '0');
    signal tx_debug : std_logic_vector(3 downto 0) := (others => '0');
    signal packet_count : unsigned(3 downto 0) := (others => '0');
    signal delay_count : unsigned(31 downto 0) := (others => '0');
    subtype byte is std_logic_vector(7 downto 0);
    type bytes is array(natural range <>) of byte;

    signal packet : bytes(0 to 41) := ( 
            -- ARP who has 192.168.200.17? please teel 192.168.200.16 (MAC 50:7b:9d:3b:0f:95)
            x"FF", x"FF", x"FF", x"FF",   x"FF", x"FF", x"50", x"7B",          x"9D", x"3B", x"0F", x"95",   x"08", x"06", x"00", x"01", 
            x"08", x"00", x"06", x"04",   x"00", x"01", x"50", x"7B",          x"9D", x"3B", x"0F", x"95",   x"C0", x"A8", x"C8", x"11",
            x"00", x"00", x"00", x"00",   x"00", x"00", x"C0", x"A8",          x"C8", x"10" );
    signal packet_offs : integer range 0 to 42 := 0;
    signal packet_wait : std_logic := '0';
begin

input_sys125 : IBUFGDS
    port map ( I  => sysclk125_in_p, IB => sysclk125_in_n, O  => sysclk125_u);

buf_sys125 : BUFG
    port map ( I => sysclk125_u, O => sysclk125);

clkdiv: entity work.ipbus_clock_div
    port map( clk => sysclk125, d7 => clk2mhz, d28 => slowclk ); 

make_slowedge: process(sysclk125)
    begin
        if rising_edge(sysclk125) then -- ff's with CE
            slowclk_del <= slowclk;
        end if;
    end process;
    slowedge <= '1' when (slowclk = '1' and slowclk_del /= '1') else '0';

make_2mhzedge: process(sysclk125)
    begin
        if rising_edge(sysclk125) then -- ff's with CE
            clk2mhz_del <= clk2mhz;
        end if;
    end process;
    clk2mhz_edge <= '1' when (clk2mhz = '1' and clk2mhz_del /= '1') else '0';


rst_req: process(sysclk125,rst_in) -- async-presettables ff's with CE
    begin
        if rst_in = '1' then
            rst_chain <= (others => '1');
        elsif rising_edge(sysclk125) then
            if slowedge = '1' then
               rst_chain <= "0" & rst_chain(4 downto 1);
            end if;
        end if;
    end process;

rst_phy <= rst_chain(3);

phy_on <= '1';
phy_resetb <= not rst_phy;

    -- synchronize reset buttons to clk125
led_reset_sync_rx: process(rx_clock,rst_in1)
    begin
        if rst_in1 = '1' then
            led_reset_rx <= (others => '1');
        elsif rising_edge(rx_clock) then
            led_reset_rx <= "0" & led_reset_rx(1 downto 1);
        end if;
    end process;
    -- synchronize reset buttons to clk125
led_reset_sync_tx: process(tx_clock,rst_in1)
    begin
        if rst_in1 = '1' then
            led_reset_tx <= (others => '1');
        elsif rising_edge(tx_clock) then
            led_reset_tx <= "0" & led_reset_tx(1 downto 1);
        end if;
    end process;
        -- synchronize reset buttons to clk125
led_reset_sync_eth: process(clketh,rst_in1)
    begin
        if rst_in1 = '1' then
            led_reset_eth <= (others => '1');
        elsif rising_edge(clketh) then
            led_reset_eth <= "0" & led_reset_eth(1 downto 1);
        end if;
    end process;

            -- synchronize reset buttons to clk125
mac_resetn_async <= (phy_prog_done and rx_locked and tx_locked and (not rsteth) and (not rst_in2));
mac_resetn_sync: process(clketh,mac_resetn_async)
    begin
        if mac_resetn_async = '0' then
            mac_resetn <= (others => '0');
        elsif rising_edge(clketh) then
            if eth17_edge = '1' then
                mac_resetn <= "0" & mac_resetn(4 downto 1);
            end if;
        end if;
    end process;


mdio_3st: IOBUF
    port map( T => mdio_t, I => mdio_o, O => mdio_i, IO => phy_mdio );
phy_mdc <= clk2mhz;

phy_prog: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            if clk2mhz_edge = '1' then
                if rst_chain(3 downto 0) = b"0000" then
                    if mdio_data_addr(10) = '0' then
                        mdio_t <= '0'; -- write
                        --case dip_sw(3 downto 2) is
                        --    when "00" =>
                                mdio_o <= mdio_data_0(to_integer(mdio_data_addr(9 downto 0)));
                        --  when "01" =>
                        --      mdio_o <= mdio_data_1(to_integer(mdio_data_addr(9 downto 0)));
                        --  when "10" =>
                        --      mdio_o <= mdio_data_2(to_integer(mdio_data_addr(9 downto 0)));
                        --  when "11" =>
                        --      mdio_o <= mdio_data_0(to_integer(mdio_data_addr(9 downto 0)));
                        --end case;
                        mdio_data_addr <= mdio_data_addr + 1;
                    else
                        phy_prog_done <= '1';
                        mdio_t <= '1'; -- read/dont-care
                    end if;
                else
                    mdio_data_addr <= (others => '0');
                    mdio_t <= '1'; -- read/dont-care
                    phy_prog_done <= '0';
                end if;
            end if;
        end if;
    end process;

--input_625 : IBUFGDS
--    port map ( I  => clk625_p, IB => clk625_n, O  => clketh);

ethdiv: entity work.ipbus_clock_div
    port map( clk => clketh, d17 => eth17, d28 => sloweth ); 

make_eth17_edge: process(clketh)
    begin
        if rising_edge(clketh) then -- ff's with CE
            eth17_del <= eth17;
        end if;
    end process;
    eth17_edge <= '1' when (eth17 = '1' and eth17_del /= '1') else '0';

txblink: entity work.ipbus_clock_div
    port map( clk => tx_clock, d28 => slowtx ); 

rxblink: entity work.ipbus_clock_div
    port map( clk => rx_clock, d28 => slowrx ); 

    set_leds: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            case dip_sw(2 downto 0) is 
                when "000" =>
                    leds(0) <= sloweth;
                    leds(1) <= rst_chain(4);
                    leds(2) <= rst_chain(3);
                    leds(3) <= rst_chain(1);
                    leds(4) <= rst_chain(0);
                    leds(5) <= phy_prog_done;
                    leds(6) <= mac_resetn(1);
                    leds(7) <= mac_resetn(0);
                   --leds(1) <= tx_debug(0);
                   --leds(2) <= tx_debug(1);
                   --leds(3) <= tx_debug(2);
                   --leds(4) <= packet_count(0);
                   --leds(5) <= packet_count(1);
                   --leds(6) <= packet_count(2);
                   --leds(7) <= packet_count(3);
                when "001" =>
                    leds(0) <= slowclk;
                    leds(1) <= phy_prog_done;
                    leds(2) <= (slowtx and not tx_reset_out);
                    leds(3) <= (slowrx and not rx_reset_out);
                    leds(4) <= send_pkg;
                    leds(5) <= rec_pkg(1);
                    leds(6) <= rec_pkg(2);
                    leds(7) <= rec_pkg(3);
                when "010" =>
                    leds(0) <= sloweth and mac_resetn(0);
                    leds(1) <= rsteth;
                    leds(2) <= tx_locked;
                    leds(3) <= rx_locked;
                    leds(4) <= tx_valid;
                    leds(5) <= tx_last;
                    leds(6) <= tx_ready;
                    leds(7) <= gmii_tx_en;
                when "011" =>
                    leds(0) <= slowclk;
                    leds(1) <= phy_prog_done;
                    leds(2) <= (slowtx and not tx_reset_out);
                    leds(3) <= (slowrx and not rx_reset_out);
                    leds(4) <= det_pkg(1);
                    leds(5) <= det_pkg(2);
                    leds(6) <= det_pkg(3);
                    leds(7) <= det_pkg(4);
                when "100" =>
                    leds(7 downto 0) <= std_logic_vector(rx_count_good);
                when "101" =>
                    leds(7 downto 0) <= std_logic_vector(rx_count_bad);
                when "110" =>
                    leds(7 downto 0) <= std_logic_vector(tx_count_good);
                when "111" =>
                    leds(7 downto 0) <= std_logic_vector(tx_count_bad);
            end case;
        end if;
    end process;

    mac: temac_gbe_v9_0
        port map(
            gtx_clk => clketh,
            glbl_rstn => mac_resetn(0),
            rx_axi_rstn => '1',
            tx_axi_rstn => '1',
            rx_statistics_vector => rx_statistics_vector,
            rx_statistics_valid => rx_statistics_valid,
            rx_mac_aclk => rx_clock_u,
            rx_reset => rx_reset_out,
            rx_axis_mac_tdata => rx_data,
            rx_axis_mac_tvalid => rx_valid, 
            rx_axis_mac_tlast => rx_last,
            rx_axis_mac_tuser => rx_error,
            tx_ifg_delay => X"00",
            tx_statistics_vector => tx_statistics_vector,
            tx_statistics_valid => tx_statistics_valid,
            tx_mac_aclk => tx_clock_u,
            tx_reset => tx_reset_out,
            tx_axis_mac_tdata => tx_data,
            tx_axis_mac_tvalid => tx_valid,
            tx_axis_mac_tlast => tx_last,
            tx_axis_mac_tuser(0) => tx_error,
            tx_axis_mac_tready => tx_ready,
            pause_req => '0',
            pause_val => X"0000",
            gmii_txd => mac_gmii_txd,
            gmii_tx_en => mac_gmii_tx_en,
            gmii_tx_er => mac_gmii_tx_er,
            gmii_rxd => mac_gmii_rxd,
            gmii_rx_dv => mac_gmii_rx_dv,
            gmii_rx_er => mac_gmii_rx_er,
            rx_configuration_vector => X"0000_0000_0000_0000_0802", -- try 0B02 to disable length and type checks
            tx_configuration_vector => X"0000_0000_0000_0000_0002"  -- flow control disabled in both (0x10)
        );
    buf_tx_clock : BUFG port map ( I => tx_clock_u, O => tx_clock);
    buf_rx_clock : BUFG port map ( I => rx_clock_u, O => rx_clock);


    sgmii_signal_detect <= not rst_chain(0);
    sgmii_configuration_vector <= (4 => '1', 3 => not(phy_prog_done), others => '0');
    sgmii_reset <= not phy_prog_done;
    sgmii: sgmii_adapter_lvds_0_core
        port map ( 
            refclk625_p => clk625_p,
            refclk625_n => clk625_n,
            txp_0 => txp,
            txn_0 => txn,
            rxp_0 => rxp,
            rxn_0 => rxn,
            signal_detect_0 => sgmii_signal_detect, --?
            an_adv_config_vector_0 => b"1001_1000_0000_0001", -- 0:SGMII: 10-11: 1000Mbps 12: Full Duplex  14: ACK 15: Link up 
            an_restart_config_0 => '0', --useless, it doesn't reach: the phy
            an_interrupt_0 => open, --useless, it doesn't come from the phy
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
            status_vector_0 => open, --status_vector, --useless, it doesn't come from the phy
            configuration_vector_0 => sgmii_configuration_vector, -- useless, it doesn't reach the PHY
            clk125_out => clketh,
            rst_125_out => rsteth, 
            rx_locked => rx_locked,
            tx_locked => tx_locked,
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
            reset => sgmii_reset -- otherwise we reset the PLLs and they will never lock!
        );


    packet_inject: process(tx_clock,tx_reset_out)
    begin
        if tx_reset_out = '1' then
            tx_valid <= '0';
            tx_last <= '0';
            tx_data <= (others => '0');
            packet_offs <= 0;
            delay_count <= (others => '0');
            packet_wait <= '0';
            send_pkg <= '1';
        elsif rising_edge(tx_clock) then
            if led_reset_tx(0) = '1' then
                tx_debug <= (others => '0');
            end if;
            delay_count <= delay_count + 1;
            if send_pkg = delay_count(24) then
                if packet_wait = '0' or tx_ready = '1' then
                    if packet_offs = 42 then
                        tx_valid <= '0';
                        tx_last  <= '0';
                        packet_wait <= '0';
                        send_pkg <= not delay_count(24);
                        tx_debug(2) <= '1';
                        packet_count <= packet_count + 1;
                    else
                        tx_valid <= '1';
                        tx_debug(0) <= '1';
                        packet_offs <= packet_offs + 1;
                        tx_data <= std_logic_vector(packet(packet_offs));
                        if packet_offs = 41 then
                            tx_last <= '1';
                            tx_debug(1) <= '1';
                        else
                            tx_last <= '0';
                        end if;
                        if tx_ready = '0' then
                            packet_wait <= '1';
                        end if;
                    end if;
                end if;
            else
                tx_valid <= '0';
                tx_last <= '0';
                tx_data <= (others => '0');
                packet_offs <= 0;
                packet_wait <= '0';
            end if;
        end if;
    end process;

    packet_receive: process(rx_clock,rx_reset_out)
    begin
        if rx_reset_out = '1' then
            rec_pkg <= (others => '0');
        elsif rising_edge(rx_clock) then
            if (rec_pkg(0) = slowclk) or (led_reset_rx(0) = '1') then
                rec_pkg <= (0 => not slowclk, others => '0');
            else
                if rx_valid = '1' then rec_pkg(1) <= '1'; end if;
                if rx_last  = '1' then rec_pkg(2) <= '1'; end if;
                if rx_error = '1' then rec_pkg(3) <= '1'; end if;
            end if;
        end if;
    end process;

    packet_detect: process(clketh)
    begin
        if rising_edge(clketh) then
            if (det_pkg(0) = slowclk) or (led_reset_eth(0) = '1') then
                det_pkg <= (0 => not slowclk, others => '0');
            else
                if gmii_rx_dv = '1' then det_pkg(1) <= '1'; end if;
                if gmii_rx_er = '1' then det_pkg(2) <= '1'; end if;
                if gmii_tx_en = '1' then det_pkg(3) <= '1'; end if;
                if gmii_tx_er = '1' then det_pkg(4) <= '1'; end if;
            end if;
        end if;
    end process;

   boh: process(clketh)
   begin
       if rising_edge(clketh) then
           if dip_sw(3) = '0' then
               gmii_txd <= mac_gmii_txd;
               gmii_tx_en <= mac_gmii_tx_en;
               gmii_tx_er <= mac_gmii_tx_er;
               mac_gmii_rxd <= gmii_rxd;
               mac_gmii_rx_dv <= gmii_rx_dv;
               mac_gmii_rx_er <= gmii_rx_er;
           else
               gmii_txd <= mac_gmii_txd;
               gmii_tx_en <= mac_gmii_tx_en;
               gmii_tx_er <= mac_gmii_tx_er;
               mac_gmii_rxd <= mac_gmii_txd;
               mac_gmii_rx_dv <= mac_gmii_tx_en;
               mac_gmii_rx_er <= mac_gmii_tx_er;
           end if; 
       end if;
   end process;

   tx_count: process(tx_clock)
   begin
       if rising_edge(tx_clock) then
           if (led_reset_tx(0) or tx_reset_out) = '1' then
                tx_count_good <= (others => '0');
           elsif tx_statistics_valid = '1' then
               if tx_statistics_vector(0) = '1' then 
                    tx_count_good <= tx_count_good + 1; 
               end if;
               if (tx_statistics_vector(3) or tx_statistics_vector(21) or tx_statistics_vector(23)) = '1' then 
                   tx_count_bad <= tx_count_bad + 1; 
               end if;
           end if;
       end if;
   end process;

   rx_count: process(rx_clock)
   begin
       if rising_edge(rx_clock) then
           if (led_reset_rx(0) or rx_reset_out) = '1' then
                 rx_count_good <= (others => '0');
           elsif rx_statistics_valid = '1' then
               if rx_statistics_vector(0) = '1' then 
                    rx_count_good <= rx_count_good + 1; 
               end if;
               if rx_statistics_vector(1) = '1' then 
                   rx_count_bad <= rx_count_bad + 1; 
               end if;
           end if;
       end if;
   end process;

end Behavioral;
