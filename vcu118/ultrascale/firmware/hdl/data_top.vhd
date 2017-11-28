library ieee;
use ieee.std_logic_1164.all;

library unisim;

use work.ultra_data_types.all;
use work.ultra_constants.all;
use work.board_constants.all;

entity data_top is
 port (
    clk: in std_logic;
    rst: in std_logic;
    leds : out std_logic_vector(1 downto 0)
  );
end data_top;

architecture Behavioral of data_top is
    signal data_to_algo   : ndata(4*N_QUADS-1 downto 0);
    signal data_from_algo : ndata(4*N_QUADS-1 downto 0);
begin

blink: entity work.dummy_blinker
   port map(
        clk => clk,
        rst => rst,
        l1 => leds(0),
        l2 => leds(1)
   );

gen_buffers: for Q in N_QUADS-1 downto 0 generate
    buffs : entity work.ultra_buffer
        port map(clk => clk, rst => rst, we => '1', rx_out => data_to_algo(4*(Q+1)-1 downto 4*Q), tx_in => data_from_algo(4*(Q+1)-1 downto 4*Q));
end generate gen_buffers;
 
algo: entity work.ultra_null_algo
    port map(clk => clk, rst => rst, d => data_to_algo, q => data_from_algo);

end Behavioral;
