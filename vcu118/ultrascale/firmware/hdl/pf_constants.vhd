library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pf_constants is
  -- these above are based on the current IP, which doesn't use all 72 inputs and outputs
  constant N_PF_IN_CHANS  : natural := 124;
  constant N_PF_OUT_CHANS : natural := 114;

  -- now, N inputs require N/2 fibers, and so N/8 deserializers, and you must round up
  constant N_DESERS : natural := (N_PF_IN_CHANS+7)/8;
  -- in output, we have N channels, so N/2 fibers
  constant N_PF_OUT_FIBERS : natural := (N_PF_OUT_CHANS+1)/2;
end;
