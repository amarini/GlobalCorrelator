library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

use work.ultra_data_types.all;
use work.ultra_constants.all;
use work.board_constants.all;

-- synchronizes the falling edge of rst_in to a clk edge
-- rising edge remains async

entity reset_bridge is
 port (
    clk: in std_logic;
    rst_in : in std_logic;
    rst    : out std_logic
  );
end reset_bridge;

architecture Behavioral of reset_bridge is
    signal rst_u, rst_meta : std_logic;
begin

rst_bridge_1: FDPE port map ( D => '0',      PRE => rst_in, CE => '1', C => clk, Q => rst_meta );
rst_bridge_2: FDPE port map ( D => rst_meta, PRE => rst_in, CE => '1', C => clk, Q => rst_u);
rst_buf : BUFG port map (I => rst_u, O => rst);
end Behavioral;
