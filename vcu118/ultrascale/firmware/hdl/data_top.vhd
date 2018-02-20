library ieee;
use ieee.std_logic_1164.all;

library unisim;

use work.ultra_data_types.all;
use work.ultra_constants.all;
use work.board_constants.all;

use work.ipbus.all;

entity data_top is
 port (
    clk: in std_logic;
    rst: in std_logic;
    clk_ipb: in std_logic;
    rst_ipb: in std_logic;
    ipb_in: in ipb_wbus;
    ipb_out: out ipb_rbus;
    leds : out std_logic_vector(0 downto 0)
  );
end data_top;

architecture Behavioral of data_top is
--     signal data_to_algo   : ndata(4*N_QUADS-1 downto 0);
--     signal data_from_algo : ndata(4*N_QUADS-1 downto 0);
--     signal ipb_to_slaves:   ipb_wbus_array(N_QUADS-1 downto 0);
--     signal ipb_from_slaves: ipb_rbus_array(N_QUADS-1 downto 0);
begin

blink: entity work.dummy_blinker
   port map(
        clk => clk,
        rst => rst,
        l1 => leds(0)
        --l2 => leds(1)
   );

ipb_out <= IPB_RBUS_NULL;
-- gen_buffers: for Q in N_QUADS-1 downto 0 generate
--     buffs : entity work.ultra_buffer
--         port map(clk => clk, rst => rst, 
--                  clk_ipb => clk_ipb, rst_ipb => rst_ipb,
--                  ipb_in => ipb_to_slaves(Q), 
--                  ipb_out => ipb_from_slaves(Q),
--                  rx_out => data_to_algo(4*(Q+1)-1 downto 4*Q), 
--                  tx_in => data_from_algo(4*(Q+1)-1 downto 4*Q));
-- end generate gen_buffers;
--  
-- algo: entity work.ultra_null_algo
--     port map(clk => clk, rst => rst, d => data_to_algo, q => data_from_algo);
-- 
-- ipb_fab: entity work.ipbus_fabric_simple
--    generic map(NSLV => N_QUADS, DECODE_BASE => 12, DECODE_BITS => 5) -- N_QUADS < 31 => 5 bits; 0..N_QUADS-1 = individual quads
--    port map(ipb_in => ipb_in, ipb_out => ipb_out, ipb_to_slaves => ipb_to_slaves, ipb_from_slaves => ipb_from_slaves);

end Behavioral;
