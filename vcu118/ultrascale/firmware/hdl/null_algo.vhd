library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ultra_data_types.all;
use work.ultra_constants.all;
use work.board_constants.all;

use work.pftm_data_types.all;
use work.pftm_constants.all;
use work.pf_data_types.all;
use work.pf_constants.all;

entity ultra_null_algo is
    port (
       clk : in std_logic;
       rst : in std_logic;
       d   : in ndata(4*N_QUADS-1 downto 0);
       q   : out ndata(4*N_QUADS-1 downto 0)
    );
end ultra_null_algo;

architecture behavioral of ultra_null_algo is
    signal pf_in  : pf_data(8*N_DESERS - 1 downto 0);
    signal pf_out : pf_data(N_PF_OUT_CHANS - 1 downto 0);
    signal pf_out_good : std_logic;
    signal unused : ndata(4*N_QUADS - 1 downto 4*N_DESERS);
begin

    -- each deserializer takes 4 input fibers for 2 clocks, and produce 8 output numbers 
    generate_multiplex : for i in N_DESERS-1 downto 0 generate
        multiplex : entity work.deser
          PORT MAP (
            clk240 => clk,
            d_in   => d((4*i+3) downto (4*i)),
            d_out => pf_in((8*i+7) downto (8*i))
        );
    end generate generate_multiplex;

    pf_algo : entity work.pf_ip_wrapper_vcu118
      PORT MAP (
        clk    => clk,
        rst    => rst,
        start  => '1', 
        input  => pf_in(N_PF_IN_CHANS-1 downto 0),
        done   => pf_out_good,
        idle   => open,
        ready  => open,
        output => pf_out
      );

    demux : entity work.ser
      GENERIC MAP (
        N_CHANNELS => N_PF_OUT_CHANS,
        N_FIBERS => N_PF_OUT_FIBERS
      )
      PORT MAP (
        clk240   => clk,
        in_good  => pf_out_good,
        d_in     => pf_out,
        d_out    => q(N_PF_OUT_FIBERS-1 downto 0)
    );

    fill_odd: process(clk)
    begin
        if clk'event and clk = '1' then
            for i in 4*N_DESERS - 1 downto N_PF_OUT_FIBERS loop
                q(i).data <= (others => '0');
                q(i).valid <= '1';
            end loop;
        end if;
    end process fill_odd;

    -- the remaining fibers are configured to do an echo of the input
    echo_unused: process(clk)
    begin
        if clk'event and clk = '1' then
            for i in 4*N_QUADS - 1 downto 4*N_DESERS loop
                unused(i) <= d(i);
                q(i) <= unused(i);
            end loop;
        end if;
    end process echo_unused;

end behavioral;
