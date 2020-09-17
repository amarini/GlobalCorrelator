library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

use work.regionizer_data.all;

entity rolling_fifo is
    port(
        ap_clk   : in std_logic;
        d_in     : in particle;
        write_in : in std_logic;
        d_out    : out particle;
        valid_out : out std_logic;
        will_read  : in std_logic;
        roll     : in  std_logic;
        roll_out : out std_logic
    );
end rolling_fifo;

architecture Behavioral of rolling_fifo is
    signal d64, q64 : std_logic_vector(63 downto 0);
    signal raddr, waddr : std_logic_vector(14 downto 0);
    signal rptr : unsigned(5 downto 0) := (0=>'1', others => '0'); -- need to count up to 63
    signal wptr : unsigned(5 downto 0) := (others => '0');         -- need to count up to 63
    signal wren, valid_next : std_logic := '0';
    signal roll_delay: std_logic_vector(2 downto 0) := (others => '0');
begin
    ram: RAMB36E2
        generic map(
            CLOCK_DOMAINS => "COMMON",
            DOA_REG => 0,
            DOB_REG => 0,
            READ_WIDTH_A => 72,
            WRITE_WIDTH_B => 72,
            WRITE_MODE_A => "WRITE_FIRST",
            WRITE_MODE_B => "WRITE_FIRST"
        )
        port map(
            ADDRENA => '1',
            ADDRENB => '1',
            ADDRARDADDR => raddr,
            ADDRBWRADDR => waddr,
            CLKARDCLK => ap_clk,
            CLKBWRCLK => ap_clk,
            DINADIN => d64(31 downto 0),
            DINBDIN => d64(63 downto 32),
            DINPADINP => (others => '0'),
            DINPBDINP => (others => '0'),
            DOUTADOUT => q64(31 downto 0),
            DOUTBDOUT => q64(63 downto 32),
            DOUTPADOUTP => open,
            DOUTPBDOUTP => open,
            ENARDEN => valid_next,
            ENBWREN => wren,
            REGCEAREGCE => '1',
            REGCEB => '0',
            RSTRAMARSTRAM => '0',
            RSTRAMB => '0',
            RSTREGARSTREG => '0',
            RSTREGB => '0',
            WEA => "0000",
            WEBWE => "11111111",
            CASDIMUXA => '0',
            CASDIMUXB => '0',
            CASDOMUXA => '0',
            CASDOMUXB => '0',
            CASDINA => (others => '0'),
            CASDINB => (others => '0'),
            CASDINPA => (others => '0'),
            CASDINPB => (others => '0'),
            CASDOMUXEN_A => '1',
            CASDOMUXEN_B => '1',
            CASINSBITERR => '0',
            CASINDBITERR => '0',
            CASOREGIMUXEN_A => '1',
            CASOREGIMUXEN_B => '1',
            CASOREGIMUXA => '0',
            CASOREGIMUXB => '0',
            INJECTSBITERR => '0',
            INJECTDBITERR => '0',
            ECCPIPECE => '1',
            SLEEP => '0'

        );

     --- combinatorical
     raddr(14 downto 12) <= (others => '0');
     waddr(14 downto 12) <= (others => '0');
     raddr(11 downto 6) <= std_logic_vector(rptr);
     waddr(11 downto 6) <= std_logic_vector(wptr);
     raddr(5 downto 0) <= (others => '0');
     waddr(5 downto 0) <= (others => '0');

     d_out.pt   <= unsigned(q64(63 downto 50));
     d_out.eta  <=   signed(q64(49 downto 38));
     d_out.phi  <=   signed(q64(37 downto 26));
     d_out.rest <= unsigned(q64(25 downto  0));

     roll_out <= roll_delay(2);
     
     logic: process(ap_clk) 
           variable rptr_next : unsigned(5 downto 0);
        begin
            if rising_edge(ap_clk) then
                if roll = '1' then
                    wptr <= (0 => write_in, others => '0');
                elsif write_in = '1' then
                    wptr <= wptr + to_unsigned(1, wptr'length);
                end if;
                wren <= write_in;

                d64(63 downto 50) <= std_logic_vector(d_in.pt);
                d64(49 downto 38) <= std_logic_vector(d_in.eta);
                d64(37 downto 26) <= std_logic_vector(d_in.phi);
                d64(25 downto  0) <= std_logic_vector(d_in.rest);

                roll_delay(0) <= roll;
                roll_delay(2 downto 1) <= roll_delay(1 downto 0);

                if roll_delay(0) = '1' then
                    rptr_next := to_unsigned(1, wptr'length);
                elsif will_read = '1' and valid_next = '1' then
                    rptr_next := rptr + to_unsigned(1, rptr'length);
                else
                    rptr_next := rptr;
                end if;
                rptr <= rptr_next;

                if rptr_next <= wptr then
                    valid_next <= '1';
                else
                    valid_next <= '0';
                end if;
                valid_out <= valid_next;

            end if;

        end process;

    
end Behavioral;
