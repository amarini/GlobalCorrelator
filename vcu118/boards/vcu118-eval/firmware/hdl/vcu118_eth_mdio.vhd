library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity vcu118_eth_mdio is
 port (
    sysclk125: in std_logic; -- clock
    rst_phy:   in std_logic; -- reset signal of the phy (sync to sysclk125)
    done:      out std_logic; -- phy was programmed successfully
    poll_done:   out std_logic; -- phy was polled successfully
    status_reg1: out std_logic_vector(15 downto 0); -- phy status reg 1
    status_reg2: out std_logic_vector(15 downto 0); -- phy status reg 2
    status_reg3: out std_logic_vector(15 downto 0); -- phy status reg 2
    status_reg4: out std_logic_vector(15 downto 0); -- phy status reg 2
    status_reg5: out std_logic_vector(15 downto 0); -- phy status reg 2
    phy_mdio: inout std_logic; -- control line to program the PHY chip
    phy_mdc : out std_logic    -- clock line (must be < 2.5 MHz)
  );
end vcu118_eth_mdio;

architecture Behavioral of vcu118_eth_mdio is
    signal clk2mhz, clk2mhz_del, clk2mhz_edge: std_logic := '0'; -- 2MHz generated clock for MDIO/MDC interface
    signal slowclk, slowclk_del, slowedge: std_logic := '0';     -- very slow clock (~Hz), for waiting until device is ready 
    
    signal rst_chain : std_logic_vector(4 downto 0) := (others => '1'); -- delay chain 

    signal mdio_t : std_logic := '1'; --\
    signal mdio_i : std_logic := '0'; --+--- tri-state inputs for mdio
    signal mdio_o : std_logic := '0'; --/

    -- encode a MDIO write sequence: see Xiling PG047 (Gigabit Ethernet PCS/PMA IP) under "MDIO management interface" (page 42 of the 4 Oct 2017 version)
    -- note that it has to be transmitted from MSB to LSB
    function encode_mdio_reg_write( phyad : std_logic_vector(4 downto 0); 
                                    regad : std_logic_vector(4 downto 0);
                                    data  : std_logic_vector(15 downto 0))
                                    return std_logic_vector is
    begin
        return x"FFFF_FFFF" & b"01" & b"01" & phyad & regad & b"10" & data;
    end;

    -- encode a MDIO read sequence: see Xiling PG047 (Gigabit Ethernet PCS/PMA IP) under "MDIO management interface" (page 42 of the 4 Oct 2017 version)
    -- note that it has to be transmitted from MSB to LSB
    -- see mask below for which bits to send
    function encode_mdio_reg_read( phyad : std_logic_vector(4 downto 0); 
                                    regad : std_logic_vector(4 downto 0))
                                    return std_logic_vector is
    begin
        return x"FFFF_FFFF" & b"01" & b"10" & phyad & regad & b"00" & x"0000";
    end;
    -- returns a mask, aligned with the one from encode_mdio_reg_read, where '1' means write to PHY, '0' means read from PHY
    function mdio_reg_read_mask return std_logic_vector is
    begin
        return x"FFFF_FFFF" & b"11" & b"11" & b"11111" & b"11111" & b"00" & x"0000";
    end;

    --- encode an extended register write (see data sheet of TI DP83867, section 8.6.12 "Extended Register Addressing" )
    -- note that it has to be transmitted from MSB to LSB
    function encode_mdio_extreg_write( phyad : std_logic_vector(4 downto 0); 
                                    extreg : std_logic_vector(15 downto 0);
                                    data   : std_logic_vector(15 downto 0))
                                    return std_logic_vector is
        constant MDIO_REG_0xD :  std_logic_vector(4 downto 0) := b"01101";
        constant MDIO_REG_0xE :  std_logic_vector(4 downto 0) := b"01110";
        constant MDIO_WRITE_ADDR : std_logic_vector(15 downto 0) := b"00_000000000_11111";  
        constant MDIO_WRITE_VALUE: std_logic_vector(15 downto 0) := b"01_000000000_11111";
    begin
        return  encode_mdio_reg_write( phyad, MDIO_REG_0xD, MDIO_WRITE_ADDR ) &
                encode_mdio_reg_write( phyad, MDIO_REG_0xE, extreg ) &
                encode_mdio_reg_write( phyad, MDIO_REG_0xD, MDIO_WRITE_VALUE ) &
                encode_mdio_reg_write( phyad, MDIO_REG_0xE, data ) ;
    end;

    -- predefined MDIO PHYADD for the VCU118 PHY, from UG1224 (vcu118 user manual)
    constant VCU118_PHYADD : std_logic_vector(4 downto 0) := b"00011";
    -- enable SGMII 6-wire mode (i.e. send out 625 Mhz clock to FPGA)
    -- see https://www.xilinx.com/support/answers/69494.html, and data sheet of TI DP83867, section 8.6.40 "SGMII Control Register 1"
    -- also, disable RGMII mode (unclear if it's needed)
    -- we bit-reverse it in the definition, so that we can send LSB to MSB 
    signal mdio_data : std_logic_vector(0 to 1023) := encode_mdio_extreg_write( VCU118_PHYADD, x"00D3", x"4000" ) & -- eable sgmii clk
                                                      encode_mdio_extreg_write( VCU118_PHYADD, x"0032", x"0000" ) & -- disable rgmii
                                                      encode_mdio_reg_write( VCU118_PHYADD, b"10000", x"0800")    & -- enable sgmii
                                                      encode_mdio_reg_write( VCU118_PHYADD, b"10100", x"0380")    & -- enable AN and speed opt 
                                                      encode_mdio_reg_write( VCU118_PHYADD, b"11111", x"0000")    & -- clear error counter 
                                                      encode_mdio_extreg_write( VCU118_PHYADD, x"0031", x"0160" ) & -- disable rgmii
                                                      encode_mdio_reg_write( VCU118_PHYADD, b"00000", x"3300")    ; -- enable & restart AN
    signal mdio_data_addr : unsigned(10 downto 0) := (others => '0');

    signal mdio_poll_data : std_logic_vector(0 to 319) := encode_mdio_reg_read( VCU118_PHYADD, b"00001" ) & -- basic mode status register
                                                          encode_mdio_reg_read( VCU118_PHYADD, b"01010" ) & -- status register 1
                                                          encode_mdio_reg_read( VCU118_PHYADD, b"00101" ) & -- Auto-Negotiation Link Partner Ability Register
                                                          encode_mdio_reg_read( VCU118_PHYADD, b"10001" ) & -- PHY Status Register 
                                                          encode_mdio_reg_read( VCU118_PHYADD, b"11111" ) ; -- error counter
    signal mdio_poll_mask : std_logic_vector(0 to  63) := mdio_reg_read_mask;
    signal mdio_poll_addr : unsigned(8 downto 0) := (others => '0');
    signal mdio_polled_data : std_logic_vector(0 to 320) := (others => '0');
    signal mdio_poll_last, mdio_poll_done : std_logic := '0';
begin


clkdiv: entity work.ipbus_clock_div
    port map( clk => sysclk125, d7 => clk2mhz, d28 => slowclk ); 

make_slowedge: process(sysclk125)
    begin
        if rising_edge(sysclk125) then 
            slowclk_del <= slowclk;
        end if;
    end process;
    slowedge <= '1' when (slowclk = '1' and slowclk_del /= '1') else '0';

make_2mhzedge: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            clk2mhz_del <= clk2mhz;
        end if;
    end process;
    clk2mhz_edge <= '1' when (clk2mhz = '1' and clk2mhz_del /= '1') else '0';

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

mdio_3st: IOBUF
    port map( T => mdio_t, I => mdio_o, O => mdio_i, IO => phy_mdio );

phy_mdc <= clk2mhz;

phy_prog: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            if clk2mhz_edge = '1' then
                if rst_chain(0) = '0' then
                    if mdio_data_addr(10) = '0' then
                        mdio_t <= '0'; -- write
                        mdio_o <= mdio_data(to_integer(mdio_data_addr(9 downto 0)));
                        mdio_data_addr <= mdio_data_addr + 1;
                        mdio_poll_last <= slowclk;
                    else
                       if mdio_poll_last /= slowclk then
                           mdio_poll_addr <= (others => '0');
                           mdio_poll_last <= slowclk;
                           mdio_poll_done <= '0';
                       elsif mdio_poll_done = '0' then
                           mdio_poll_addr <= mdio_poll_addr + 1;
                           if mdio_poll_mask(to_integer(mdio_poll_addr(5 downto 0))) = '1' then
                               mdio_t <= '0';
                               mdio_o <= mdio_poll_data(to_integer(mdio_poll_addr));
                            else
                               mdio_t <= '1';
                               mdio_polled_data(to_integer(mdio_poll_addr)) <= mdio_i;
                            end if;
                            if mdio_poll_addr = to_unsigned(319, 9) then
                                mdio_poll_done <= '1';
                            end if;
                       else
                            mdio_t <= '1'; -- read/dont-care
                        end if;
                    end if;
                else
                    mdio_data_addr <= (others => '0');
                    mdio_t <= '1'; -- read/dont-care
                end if;
            end if;
        end if;
    end process;

done <= mdio_data_addr(10);
poll_done <= mdio_poll_done;

phy_stat: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            for I in 15 downto 0 loop
                status_reg1(I) <= mdio_polled_data(63-I);
                status_reg2(I) <= mdio_polled_data(127-I);
                status_reg3(I) <= mdio_polled_data(191-I);
                status_reg4(I) <= mdio_polled_data(255-I);
                status_reg5(I) <= mdio_polled_data(319-I);
            end loop;
        end if;
    end process;


end Behavioral;
