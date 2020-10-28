library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity tk_router is
    port(
      ap_clk   : IN STD_LOGIC;
      enabled  : IN STD_LOGIC;
      newevent : IN STD_LOGIC;
      links_in      : IN particles(NSECTORS*NFIBERS-1 downto 0);
      fifo_in       : OUT particles(NSECTORS*NFIFOS-1 downto 0);
      fifo_in_write : OUT std_logic_vector(NSECTORS*NFIFOS-1 downto 0);
      fifo_in_roll  : OUT std_logic_vector(NSECTORS*NFIFOS-1 downto 0)
    );
end tk_router;

architecture Behavioral of tk_router is
begin

     reg_input_first : entity work.tk_router_element
            port map(ap_clk => ap_clk, 
                     enabled => enabled,
                     newevent => newevent,
                     links_in => links_in(NFIBERS-1 downto 0),
                     fifo_same => fifo_in(     0      *NFIFOS+1*NFIBERS-1 downto      0      *NFIFOS),
                     fifo_next => fifo_in(     1      *NFIFOS+2*NFIBERS-1 downto      1      *NFIFOS+1*NFIBERS),
                     fifo_prev => fifo_in((NSECTORS-1)*NFIFOS+3*NFIBERS-1 downto (NSECTORS-1)*NFIFOS+2*NFIBERS),
                     fifo_same_write => fifo_in_write(     0      *NFIFOS+1*NFIBERS-1 downto      0      *NFIFOS),
                     fifo_next_write => fifo_in_write(     1      *NFIFOS+2*NFIBERS-1 downto      1      *NFIFOS+1*NFIBERS),
                     fifo_prev_write => fifo_in_write((NSECTORS-1)*NFIFOS+3*NFIBERS-1 downto (NSECTORS-1)*NFIFOS+2*NFIBERS),
                     fifo_same_roll  => fifo_in_roll (     0      *NFIFOS+1*NFIBERS-1 downto      0      *NFIFOS),
                     fifo_next_roll  => fifo_in_roll (     1      *NFIFOS+2*NFIBERS-1 downto      1      *NFIFOS+1*NFIBERS),
                     fifo_prev_roll  => fifo_in_roll ((NSECTORS-1)*NFIFOS+3*NFIBERS-1 downto (NSECTORS-1)*NFIFOS+2*NFIBERS)
                 );
    gen_inputs: for isec in NSECTORS-2 downto 1 generate
         reg_input : entity work.tk_router_element
                port map(ap_clk => ap_clk, 
                         enabled => enabled,
                         newevent => newevent,
                         links_in => links_in((isec+1)*NFIBERS-1 downto isec*NFIBERS),
                         fifo_same => fifo_in( isec   *NFIFOS+1*NFIBERS-1 downto  isec   *NFIFOS),
                         fifo_next => fifo_in((isec+1)*NFIFOS+2*NFIBERS-1 downto (isec+1)*NFIFOS+1*NFIBERS),
                         fifo_prev => fifo_in((isec-1)*NFIFOS+3*NFIBERS-1 downto (isec-1)*NFIFOS+2*NFIBERS),
                         fifo_same_write => fifo_in_write( isec   *NFIFOS+1*NFIBERS-1 downto  isec   *NFIFOS),
                         fifo_next_write => fifo_in_write((isec+1)*NFIFOS+2*NFIBERS-1 downto (isec+1)*NFIFOS+1*NFIBERS),
                         fifo_prev_write => fifo_in_write((isec-1)*NFIFOS+3*NFIBERS-1 downto (isec-1)*NFIFOS+2*NFIBERS),
                         fifo_same_roll  => fifo_in_roll ( isec   *NFIFOS+1*NFIBERS-1 downto  isec   *NFIFOS),
                         fifo_next_roll  => fifo_in_roll ((isec+1)*NFIFOS+2*NFIBERS-1 downto (isec+1)*NFIFOS+1*NFIBERS),
                         fifo_prev_roll  => fifo_in_roll ((isec-1)*NFIFOS+3*NFIBERS-1 downto (isec-1)*NFIFOS+2*NFIBERS)
                     );
        end generate gen_inputs;

     reg_input_last : entity work.tk_router_element
            port map(ap_clk => ap_clk, 
                     enabled => enabled,
                     newevent => newevent,
                     links_in => links_in(NSECTORS*NFIBERS-1 downto (NSECTORS-1)*NFIBERS),
                     fifo_same => fifo_in((NSECTORS-1)*NFIFOS+1*NFIBERS-1 downto (NSECTORS-1)*NFIFOS),
                     fifo_next => fifo_in(     0      *NFIFOS+2*NFIBERS-1 downto      0      *NFIFOS+1*NFIBERS),
                     fifo_prev => fifo_in((NSECTORS-2)*NFIFOS+3*NFIBERS-1 downto (NSECTORS-2)*NFIFOS+2*NFIBERS),
                     fifo_same_write => fifo_in_write((NSECTORS-1)*NFIFOS+1*NFIBERS-1 downto (NSECTORS-1)*NFIFOS),
                     fifo_next_write => fifo_in_write(     0      *NFIFOS+2*NFIBERS-1 downto      0      *NFIFOS+1*NFIBERS),
                     fifo_prev_write => fifo_in_write((NSECTORS-2)*NFIFOS+3*NFIBERS-1 downto (NSECTORS-2)*NFIFOS+2*NFIBERS),
                     fifo_same_roll  => fifo_in_roll ((NSECTORS-1)*NFIFOS+1*NFIBERS-1 downto (NSECTORS-1)*NFIFOS),
                     fifo_next_roll  => fifo_in_roll (     0      *NFIFOS+2*NFIBERS-1 downto      0      *NFIFOS+1*NFIBERS),
                     fifo_prev_roll  => fifo_in_roll ((NSECTORS-2)*NFIFOS+3*NFIBERS-1 downto (NSECTORS-2)*NFIFOS+2*NFIBERS)
                 );

end Behavioral;
