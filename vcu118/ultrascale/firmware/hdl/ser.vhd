library ieee;

use ieee.std_logic_1164.all;

use work.ultra_data_types.all;

use work.pf_data_types.all;
use work.pf_constants.all;

entity ser is
    generic(
        N_CHANNELS : natural;
        N_FIBERS : natural -- note: must be >= N_CHANNELS/2 for current implementation to make sense
    );
    port (
        clk240: in std_logic;
        in_good: in std_logic; -- whether input bits are good
        d_in:  in  pf_data(N_CHANNELS - 1 downto 0); -- what we get from the PF 
        d_out: out ndata(N_FIBERS - 1 downto 0) -- we use only half of the channels
    );

end ser;

architecture rtl of ser is

  signal A : pf_data(N_FIBERS - 1 downto 0); -- buffer for first half of the event
  signal B : pf_data(N_FIBERS - 1 downto 0); -- buffer for second half of the event
  signal O : ndata(N_FIBERS -1 downto 0); -- output buffer
  signal reading : std_logic; -- has read a frame to be de-serialized, so next input clock cycle will not read anything useful
  signal sending : std_logic; -- has just sent a valid frame frame

   --  reading  sending  in_good  -->   reading   sending    A     B     O
   --     0        0       0               0        0        *     *     =                
   --     0        0       1               1        0        in    in    =                
   --     1        *       *               0        1        A     B     A                
   --     0        1       1               1        *        in    in    B                
   --     0        1       0               0        0        A     B     B                
   --                  
   --  reading  sending  in_good  -->   reading   sending    A     B     O
   --     1        *       *               0        1        A     B     A                
   --                  
   --  reading  sending  in_good  -->   reading   sending    A     B     O
   --     0        ?       1               1        *        in    in    ?                
   --     0        ?       1               1        *        in    in    ?                
   --     0        ?       0               0        0        *     *     ?                
   --     0        ?       0               0        0        A     B     ?                
   --                  
   --  reading  sending  in_good  -->   reading   sending    A     B     O
   --     0        0       ?               ?        0        ??    ??    =                
   --     0        0       ?               ?        0        ??    ??    =                
   --     0        1       ?               ?        *(0)     ??    ??    B                
   --     0        1       ?               ?        0        ??    ??    B                
 
 begin

  work : process(clk240)
  begin -- process work
    if clk240'event and clk240 = '1' then  -- rising clock edge

        if reading = '1' then 
            reading <= '0';
            sending <= '1';
            for i in N_FIBERS - 1 downto 0 loop
                O(i).data <= A(i);
                O(i).valid <= '1';
            end loop;
        else
            if in_good = '1' then
                reading <= '1';
                for i in N_FIBERS - 1 downto 0 loop
                    A(i) <= d_in(2*i);
                    B(i) <= d_in(2*i+1);
                end loop;
            end if;

            if sending = '1' then
                sending <= '0';
                for i in N_FIBERS - 1 downto 0 loop
                    O(i).data <= B(i);
                    O(i).valid <= '1';
                end loop;
            else
                for i in N_FIBERS - 1 downto 0 loop
                    O(i).data <= (others => '1'); -- write 1vffffffff instead of 0v00000000 or 1v0000000 to make it easier to read the capture
                    O(i).valid <= '1';            -- for the moment
                end loop;
            end if;

        end if; -- reading
    end if;


    -- output pins always identical to output buffer
    for i in N_FIBERS - 1 downto 0 loop
        d_out(i) <= O(i);
    end loop;

  end process work;
end rtl;
