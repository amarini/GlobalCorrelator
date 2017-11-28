library ieee;

use ieee.std_logic_1164.all;

use work.ultra_data_types.all;
use work.pf_data_types.all;
use work.pf_constants.all;

entity deser is
    port (
        clk240: in std_logic;
        d_in: in ndata(3 downto 0); -- we use only half of the channels
        d_out: out pf_data(7 downto 0) -- what we feed into the PF 
    );

end deser;

architecture rtl of deser is

  signal A : pf_data(3 downto 0); -- buffer for first half of the event
  signal B : pf_data(3 downto 0); -- buffer for second half of the event
  signal O1 : pf_data(3 downto 0); -- output buffer
  signal O2 : pf_data(3 downto 0); -- output buffer
  signal O_load : std_logic; -- if true, load (A,B) -> O
  signal I_good : std_logic; -- FSM state (see below)
  signal I_first : std_logic;-- FSM state (see below)

  -- FSM with three states:
  --        S1 = has read invalid data (I_good = 0, I_first = any)
  --        S2 = has read first frame (I_good = 1, I_first = 1)
  --        S3 = has read second valid frame (I_good = 1, I_first = 0)
  --
  --   State mapping:
  --     state  I_good  I_first  d_in_valid d_in   -->    state  I_good  I_first     A       B   O_load
  --      S1     0       -          0        -     -->      S1      0        0       0       0      1     (no data)
  --      S1     0       -          1        x     -->      S2      1        1       x       0      0     (first frame of the series)
  --      S2     1       1          1        y     -->      S3      1        0       A       y      1     (second frame of an event)
  --      S2     1       1          0        -     -->      S1      0        0       0       0      1     (broken data: second frame is not valid: not expected to happen)
  --      S3     1       0          1        z     -->      S2      1        1       z       B      0     (first frame of next event)
  --      S3     1       0          0        -     -->      S1      0        0       0       0      0     (end of data)
  --
  --   can be re-sorted as 
  --     state  I_good  I_first  d_in_valid d_in   -->    state  I_good  I_first     A       B   O_load
  --      S1     0       -          0        -     -->      S1      0        0       0       0      1     (no data)
  --      S2     1       1          0        -     -->      S1      0        0       0       0      1     (broken data: second frame is not valid: not expected to happen)
  --      S3     1       0          0        -     -->      S1      0        0       0       0      0     (end of data)
  --         also summarized as:
  --                  A <= 0, B <= 0, I_good <= 0, I_first <= 0, 
  --                  O_load <= ( I_good == '0') OR (I_first == '1')
  --
  --     state  I_good  I_first  d_in_valid d_in   -->    state  I_good  I_first     A       B   O_load
  --      S1     0       -          1        x     -->      S2      1        1       x       0      0     
  --      S3     1       0          1        x     -->      S2      1        1       x       B      0     
  --      S2     1       1          1        x     -->      S3      1        0       A       x      1     (second frame of an event)
  --                  
 begin

  read_in : process(clk240)
  begin -- process read_in
    if clk240'event and clk240 = '1' then  -- rising clock edge

        if d_in(0).valid = '1' then -- FIXME we should AND all fibers, not just the first one
            I_good <= '1';
            if I_good = '0' then
                I_first <= '1';
                O_load <= '0';
                for i in 3 downto 0 loop
                    A(i) <= d_in(i).data;
                    B(i) <= (others => '0');
                end loop; --i
            elsif I_first = '0' then
                I_first <= '1';
                O_load <= '0';
                for i in 3 downto 0 loop
                    A(i) <= d_in(i).data;
                    -- B stays unmodified
                end loop; --i
            else
                I_first <= '0';
                O_load <= '1';
                for i in 3 downto 0 loop
                    -- A stays unmodified
                    B(i) <= d_in(i).data;
                end loop; --i
            end if;
        else -- d.valid
                I_first <= '0';
                I_good <= '0';
                --O_load <= ( I_good = '0') OR (I_first = '1');
                O_load <= (NOT(I_good)) OR (I_first);
                for i in 3 downto 0 loop
                    A(i) <= (others => '0');
                    B(i) <= (others => '0');
                end loop; --i
        end if; -- d.valid
    end if;
  end process read_in;

  write_out : process(clk240)
  begin -- process write_out
    if clk240'event and clk240 = '1' then  -- rising clock edge

        if O_load = '1' then
            for i in 3 downto 0 loop
                O1(i) <= A(i);
                O2(i) <= B(i);
            end loop; --i
        end if;
    end if;

    -- output pins always identical to output buffer
    for i in 3 downto 0 loop
        d_out(2*i)   <= O1(i);
        d_out(2*i+1) <= O2(i);
    end loop;

  end process write_out;

end rtl;
