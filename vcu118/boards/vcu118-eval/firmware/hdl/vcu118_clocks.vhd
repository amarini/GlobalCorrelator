-- FIXME mostly replace with version from Dinyar when ready

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity vcu118_clocks is
    port (
     -- external pins for board clocks
        sysclk_in_p : in std_logic; -- 300 MHz (used to derive algo clocks)
        sysclk_in_n : in std_logic; -- 300 MHz
        sysclk125_in_p : in std_logic; -- 125 MHz (used to derive system and ipbus clocks)
        sysclk125_in_n : in std_logic; -- 125 MHz
     -- output clocks (all on BUFGs)
        sysclk125 : out std_logic; -- system clock (125 MHz)
        ipbclk    : out std_logic; -- ipbus clock (31.25 MHz)
        clk       : out std_logic; -- algo clock (240 MHz)
        clk40     : out std_logic; -- 40 MHz output clock
        --clkslow   : out std_logic; -- slow algo clock (120 MHz)
        --clkfast   : out std_logic; -- very fast algo clock (400 MHz)
     -- controls & status for clocks
        mmcm_reset : in std_logic;
        mmcm_locked: out std_logic
    );
end vcu118_clocks;

architecture rtl of vcu118_clocks is
    signal sysclk_in, clk_u, clk40_u, clk30_u : std_logic;
    --signal clkslow_u, clkfast_u: std_logic;
    signal sysclk125_u, sysclk125_i: std_logic;
    -- for MMCM
    signal clk_fb : std_logic;
begin

input_sys : IBUFGDS
  port map ( I  => sysclk_in_p, IB => sysclk_in_n, O  => sysclk_in);

mmcm: MMCME4_BASE
    generic map(
      clkin1_period => 3.333,
      clkfbout_mult_f => 4.0,  -- Setting VCO to frequency 1200 ( within [800, 1600] MHz, as required in DS923 for Virtex Ultrascale+)
      clkout1_divide => 5,
      --clkout2_divide => 10,
      --clkout3_divide => 3,
      clkout4_divide => 30,
      clkout5_divide => 40
    )
    port map(
      clkin1 => sysclk_in,
      clkfbin => clk_fb,
      clkfbout => clk_fb,
      clkout1 => clk_u,
      --clkout2 => clkslow_u,
      --clkout3 => clkfast_u,
      clkout4 => clk40_u,
      clkout5 => clk30_u,
      rst => mmcm_reset,
      pwrdwn => '0',
      locked => mmcm_locked
    );


buf_clk : BUFG port map ( I => clk_u, O => clk);
buf_clk40 : BUFG port map ( I => clk40_u, O => clk40);
--buf_clkslow : BUFG port map ( I => clkslow_u, O => clkslow);
--buf_clkfast : BUFG port map ( I => clkfast_u, O => clkfast);

input_sys125 : IBUFGDS
    port map ( I  => sysclk125_in_p, IB => sysclk125_in_n, O  => sysclk125_u);

buf_sys125 : BUFG
    port map ( I => sysclk125_u, O => sysclk125_i);
sysclk125 <= sysclk125_i;

buf_ibpc : BUFG
    port map (I => clk30_u, O => ipbclk);

end rtl;
