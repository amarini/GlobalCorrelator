library std;
use std.textio.all;
use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.regionizer_data.all;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    constant NREGIONS : natural := NSECTORS;

    type pt_vect     is array(natural range <>) of std_logic_vector(13 downto 0);
    type etaphi_vect is array(natural range <>) of std_logic_vector(11 downto 0);
    type rest_vect   is array(natural range <>) of std_logic_vector(25 downto 0);
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start, ready, idle, done : std_logic;
    signal newevent, newevent_out : std_logic;

    signal pt_in:  pt_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(13 downto 0);
    signal eta_in, phi_in:   etaphi_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(11 downto 0);
    signal rest_in:  rest_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(25 downto 0);
    signal tracks_out: particles(NSTREAM-1 downto 0);
    signal tracks_out_valid: std_logic_vector(NSTREAM-1 downto 0);

    file Fi : text open read_mode is "input.txt";
    file Fo : text open write_mode is "output_vhdl_tb.txt";
    file Fs : text open write_mode is "output_short_vhdl_tb.txt";
    --file Fd : text open write_mode is "debug_vhdl_tb.txt";


begin
    clk  <= not clk after 1.25 ns;
    
    uut : entity work.regionizer_mux
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => start,
                 ap_ready => ready,
                 ap_idle =>  idle,
                 ap_done => done,
                 tracks_in_0_0_pt_V => pt_in( 0),
                 tracks_in_0_1_pt_V => pt_in( 1),
                 tracks_in_1_0_pt_V => pt_in( 2),
                 tracks_in_1_1_pt_V => pt_in( 3), 
                 tracks_in_2_0_pt_V => pt_in( 4),
                 tracks_in_2_1_pt_V => pt_in( 5),
                 tracks_in_3_0_pt_V => pt_in( 6),
                 tracks_in_3_1_pt_V => pt_in( 7),
                 tracks_in_4_0_pt_V => pt_in( 8),
                 tracks_in_4_1_pt_V => pt_in( 9), 
                 tracks_in_5_0_pt_V => pt_in(10),
                 tracks_in_5_1_pt_V => pt_in(11),
                 tracks_in_6_0_pt_V => pt_in(12),
                 tracks_in_6_1_pt_V => pt_in(13),
                 tracks_in_7_0_pt_V => pt_in(14),
                 tracks_in_7_1_pt_V => pt_in(15), 
                 tracks_in_8_0_pt_V => pt_in(16),
                 tracks_in_8_1_pt_V => pt_in(17),
                 tracks_in_0_0_eta_V => eta_in( 0),
                 tracks_in_0_1_eta_V => eta_in( 1),
                 tracks_in_1_0_eta_V => eta_in( 2),
                 tracks_in_1_1_eta_V => eta_in( 3), 
                 tracks_in_2_0_eta_V => eta_in( 4),
                 tracks_in_2_1_eta_V => eta_in( 5),
                 tracks_in_3_0_eta_V => eta_in( 6),
                 tracks_in_3_1_eta_V => eta_in( 7),
                 tracks_in_4_0_eta_V => eta_in( 8),
                 tracks_in_4_1_eta_V => eta_in( 9), 
                 tracks_in_5_0_eta_V => eta_in(10),
                 tracks_in_5_1_eta_V => eta_in(11),
                 tracks_in_6_0_eta_V => eta_in(12),
                 tracks_in_6_1_eta_V => eta_in(13),
                 tracks_in_7_0_eta_V => eta_in(14),
                 tracks_in_7_1_eta_V => eta_in(15), 
                 tracks_in_8_0_eta_V => eta_in(16),
                 tracks_in_8_1_eta_V => eta_in(17),
                 tracks_in_0_0_phi_V => phi_in( 0),
                 tracks_in_0_1_phi_V => phi_in( 1),
                 tracks_in_1_0_phi_V => phi_in( 2),
                 tracks_in_1_1_phi_V => phi_in( 3), 
                 tracks_in_2_0_phi_V => phi_in( 4),
                 tracks_in_2_1_phi_V => phi_in( 5),
                 tracks_in_3_0_phi_V => phi_in( 6),
                 tracks_in_3_1_phi_V => phi_in( 7),
                 tracks_in_4_0_phi_V => phi_in( 8),
                 tracks_in_4_1_phi_V => phi_in( 9), 
                 tracks_in_5_0_phi_V => phi_in(10),
                 tracks_in_5_1_phi_V => phi_in(11),
                 tracks_in_6_0_phi_V => phi_in(12),
                 tracks_in_6_1_phi_V => phi_in(13),
                 tracks_in_7_0_phi_V => phi_in(14),
                 tracks_in_7_1_phi_V => phi_in(15), 
                 tracks_in_8_0_phi_V => phi_in(16),
                 tracks_in_8_1_phi_V => phi_in(17),
                 tracks_in_0_0_rest_V => rest_in( 0),
                 tracks_in_0_1_rest_V => rest_in( 1),
                 tracks_in_1_0_rest_V => rest_in( 2),
                 tracks_in_1_1_rest_V => rest_in( 3), 
                 tracks_in_2_0_rest_V => rest_in( 4),
                 tracks_in_2_1_rest_V => rest_in( 5),
                 tracks_in_3_0_rest_V => rest_in( 6),
                 tracks_in_3_1_rest_V => rest_in( 7),
                 tracks_in_4_0_rest_V => rest_in( 8),
                 tracks_in_4_1_rest_V => rest_in( 9), 
                 tracks_in_5_0_rest_V => rest_in(10),
                 tracks_in_5_1_rest_V => rest_in(11),
                 tracks_in_6_0_rest_V => rest_in(12),
                 tracks_in_6_1_rest_V => rest_in(13),
                 tracks_in_7_0_rest_V => rest_in(14),
                 tracks_in_7_1_rest_V => rest_in(15), 
                 tracks_in_8_0_rest_V => rest_in(16),
                 tracks_in_8_1_rest_V => rest_in(17),
                 tracks_out => tracks_out,
                 tracks_out_valid => tracks_out_valid,
                 newevent => newevent,
                 newevent_out => newevent_out
             );
   

    runit : process 
        variable remainingEvents : integer := 5;
        variable frame : integer := 0;
        variable Li, Lo : line;
        variable itest, iobj : integer;
    begin
        rst <= '1';
        wait for 5 ns;
        rst <= '0';
        start <= '0';
        wait until rising_edge(clk);
        while remainingEvents > 0 loop
            if not endfile(Fi) then
                readline(Fi, Li);
                read(Li, itest);
                read(Li, iobj); if (iobj > 0) then newevent <= '1'; else newevent <= '0'; end if;
                for i in 0 to NSECTORS*NFIBERS-1  loop
                    read(Li, iobj); pt_in(i)   <= std_logic_vector(to_unsigned(iobj, 14));
                    read(Li, iobj); eta_in(i)  <= std_logic_vector(to_signed(  iobj, 12));
                    read(Li, iobj); phi_in(i)  <= std_logic_vector(to_signed(  iobj, 12));
                    read(Li, iobj); rest_in(i) <= std_logic_vector(to_unsigned(iobj, 26));
                end loop;
                start <= '1';
             else
                remainingEvents := remainingEvents - 1;
                newevent <= '0';
                pt_in <= (others => (others => '0'));
                eta_in <= (others => (others => '0'));
                phi_in <= (others => (others => '0'));
                rest_in <= (others => (others => '0'));
                start <= '1';
            end if;
           -- ready to dispatch ---
            wait until rising_edge(clk);
            -- write out the output --
            write(Lo, frame, field=>5);  
            write(Lo, string'(" 1 ")); 
            write(Lo, newevent_out);
            write(Lo, string'(" ")); 
            for i in 0 to NSTREAM-1 loop 
                if (tracks_out_valid(i) = '0') then -- this is not yet done in the VHDL
                    write(Lo, 0, field => 9); 
                    write(Lo, 0, field => 9); 
                    write(Lo, 0, field => 9); 
                    write(Lo, 0, field => 9); 
                else
                    write(Lo, to_integer(tracks_out(i).pt  ),   field => 9); 
                    write(Lo, to_integer(tracks_out(i).eta ),   field => 9); 
                    write(Lo, to_integer(tracks_out(i).phi ),   field => 9); 
                    write(Lo, to_integer(tracks_out(i).rest),   field => 9); 
                end if;
            end loop;
            writeline(Fo, Lo);
            -- write out the short output --
            write(Lo, frame, field=>5);  
            write(Lo, string'(" 1 ")); 
            write(Lo, newevent_out);
            write(Lo, string'(" ")); 
            for i in 0 to NSTREAM-1 loop 
                if (tracks_out_valid(i) = '0') then
                    write(Lo, -1, field => 5); 
                else
                    write(Lo, to_integer(tracks_out(i).pt), field => 5); 
                end if;
            end loop;
            writeline(Fs, Lo);
            frame := frame + 1;
            --if frame >= 50 then finish(0); end if;
        end loop;
        wait for 50 ns;
        finish(0);
    end process;

    
end Behavioral;
