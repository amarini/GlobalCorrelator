library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ultra_data_types.all;
use work.ultra_constants.all;
use work.board_constants.all;

entity ultra_null_algo is
    port (
       clk : in std_logic;
       rst : in std_logic;
       d   : in ldata(4*N_QUADS-1 downto 0);
       q   : out ldata(4*N_QUADS-1 downto 0)
    );
end ultra_null_algo;

architecture behavioral of ultra_null_algo is
    signal buff_in : ldata(4*N_QUADS-1 downto 0);
    signal buff_out : ldata(4*N_QUADS-1 downto 0);

begin
    buffers: process(clk)
    begin
        if rising_edge(clk) then
            buff_in <= d;
            buff_out <= buff_in;
            q <= buff_out;
        end if;
    end process buffers;
end behavioral;
