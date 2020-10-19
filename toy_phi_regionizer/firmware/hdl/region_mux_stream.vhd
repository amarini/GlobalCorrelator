library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

use work.regionizer_data.all;

entity region_mux_stream is
    generic(
        NREGIONS : natural := 9
    );
    port(
        ap_clk  : in std_logic;
        roll    : in  std_logic;
        d_in     : in particles(NSORTED*NREGIONS-1 downto 0);
        valid_in : in std_logic_vector(NSORTED*NREGIONS-1 downto 0);
        d_out      : out particles(NSTREAM-1 downto 0);
        valid_out  : out std_logic_vector(NSTREAM-1 downto 0);
        roll_out   : out std_logic
    );
end region_mux_stream;

architecture Behavioral of region_mux_stream is
    signal regions : particles(NREGIONS*NSORTED-1 downto 0);
    signal valid   : std_logic_vector(NREGIONS*NSORTED-1 downto 0) := (others => '0');
    signal count   : integer range 0 to PFII-1 := 0;
begin

     logic: process(ap_clk) 
           variable below : std_logic_vector(NSORTED-1 downto 0);
        begin
            if rising_edge(ap_clk) then
                if roll = '1' then
                    regions <= d_in;
                    valid   <= valid_in;
                    count    <= 0;
                else
                    if count < PFII-1 then
                        regions(NSORTED-2 downto 0) <= regions(NSORTED-1 downto 1);
                        valid(NSORTED-2 downto 0)   <= valid(NSORTED-1 downto 1);
                        valid(NSORTED-1)            <= '0';
                        count <= count + 1;
                    else
                        for r in 0 to NREGIONS-2 loop
                            for i in 0 to NSORTED-1 loop
                                regions(r*NSORTED+i) <= regions((r+1)*NSORTED+i);
                                valid(  r*NSORTED+i) <= valid(  (r+1)*NSORTED+i);
                            end loop;
                        end loop;
                        for i in 0 to NSORTED-1 loop
                            valid((NREGIONS-1)*NSORTED+i) <= '0';
                        end loop;
                        count <= 0;
                    end if;
                end if;
                roll_out <= roll;
            end if;
        end process logic;

    gen_out: for i in 0 to NSTREAM-1 generate
        d_out(i) <= regions(i*PFII);
        valid_out(i) <= valid(i*PFII);
    end generate gen_out;


end Behavioral;
