library std;
use std.textio.all;
use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    constant NSECTORS : natural := 3;
    constant NFIBERS : natural := 2;
    constant NFIFOS : natural := 6;
    constant NREGIONS : natural := NSECTORS*NFIFOS;

    type pt_vect     is array(natural range <>) of std_logic_vector(13 downto 0);
    type etaphi_vect is array(natural range <>) of std_logic_vector(11 downto 0);
    type rest_vect   is array(natural range <>) of std_logic_vector(25 downto 0);

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start, ready, idle, done : std_logic;
    signal newevent, newevent_out : std_logic;

    signal pt_in:  pt_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(13 downto 0);
    signal pt_out: pt_vect(NREGIONS-1         downto 0); -- of std_logic_vector(13 downto 0);
    signal eta_in, phi_in:   etaphi_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(11 downto 0);
    signal eta_out, phi_out: etaphi_vect(NREGIONS-1         downto 0); -- of std_logic_vector(11 downto 0);
    signal rest_in:  rest_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(25 downto 0);
    signal rest_out: rest_vect(NREGIONS-1         downto 0); -- of std_logic_vector(25 downto 0);

    file Fi : text open read_mode is "input.txt";
    file Fo : text open write_mode is "output_vhdl_tb.txt";


begin
    clk  <= not clk after 1.25 ns;
    
    uut : entity work.regionizer_nomerge
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => start,
                 ap_ready => ready,
                 ap_idle =>  idle,
                 ap_done => done,
                 tracks_in_0_0_pt_V => pt_in(0),
                 tracks_in_0_1_pt_V => pt_in(1),
                 tracks_in_1_0_pt_V => pt_in(2),
                 tracks_in_1_1_pt_V => pt_in(3), 
                 tracks_in_2_0_pt_V => pt_in(4),
                 tracks_in_2_1_pt_V => pt_in(5),
                 tracks_in_0_0_eta_V => eta_in(0),
                 tracks_in_0_1_eta_V => eta_in(1),
                 tracks_in_1_0_eta_V => eta_in(2),
                 tracks_in_1_1_eta_V => eta_in(3), 
                 tracks_in_2_0_eta_V => eta_in(4),
                 tracks_in_2_1_eta_V => eta_in(5),
                 tracks_in_0_0_phi_V => phi_in(0),
                 tracks_in_0_1_phi_V => phi_in(1),
                 tracks_in_1_0_phi_V => phi_in(2),
                 tracks_in_1_1_phi_V => phi_in(3), 
                 tracks_in_2_0_phi_V => phi_in(4),
                 tracks_in_2_1_phi_V => phi_in(5),
                 tracks_in_0_0_rest_V => rest_in(0),
                 tracks_in_0_1_rest_V => rest_in(1),
                 tracks_in_1_0_rest_V => rest_in(2),
                 tracks_in_1_1_rest_V => rest_in(3), 
                 tracks_in_2_0_rest_V => rest_in(4),
                 tracks_in_2_1_rest_V => rest_in(5),
                 tracks_out_0_pt_V => pt_out(0),
                 tracks_out_0_eta_V => eta_out(0),
                 tracks_out_0_phi_V => phi_out(0),
                 tracks_out_0_rest_V => rest_out(0),
                 tracks_out_1_pt_V => pt_out(1),
                 tracks_out_1_eta_V => eta_out(1),
                 tracks_out_1_phi_V => phi_out(1),
                 tracks_out_1_rest_V => rest_out(1),
                 tracks_out_2_pt_V => pt_out(2),
                 tracks_out_2_eta_V => eta_out(2),
                 tracks_out_2_phi_V => phi_out(2),
                 tracks_out_2_rest_V => rest_out(2),
                 tracks_out_3_pt_V => pt_out(3),
                 tracks_out_3_eta_V => eta_out(3),
                 tracks_out_3_phi_V => phi_out(3),
                 tracks_out_3_rest_V => rest_out(3),
                 tracks_out_4_pt_V => pt_out(4),
                 tracks_out_4_eta_V => eta_out(4),
                 tracks_out_4_phi_V => phi_out(4),
                 tracks_out_4_rest_V => rest_out(4),
                 tracks_out_5_pt_V => pt_out(5),
                 tracks_out_5_eta_V => eta_out(5),
                 tracks_out_5_phi_V => phi_out(5),
                 tracks_out_5_rest_V => rest_out(5),
                 tracks_out_6_pt_V => pt_out(6),
                 tracks_out_6_eta_V => eta_out(6),
                 tracks_out_6_phi_V => phi_out(6),
                 tracks_out_6_rest_V => rest_out(6),
                 tracks_out_7_pt_V => pt_out(7),
                 tracks_out_7_eta_V => eta_out(7),
                 tracks_out_7_phi_V => phi_out(7),
                 tracks_out_7_rest_V => rest_out(7),
                 tracks_out_8_pt_V => pt_out(8),
                 tracks_out_8_eta_V => eta_out(8),
                 tracks_out_8_phi_V => phi_out(8),
                 tracks_out_8_rest_V => rest_out(8),
                 tracks_out_9_pt_V => pt_out(9),
                 tracks_out_9_eta_V => eta_out(9),
                 tracks_out_9_phi_V => phi_out(9),
                 tracks_out_9_rest_V => rest_out(9),
                 tracks_out_10_pt_V => pt_out(10),
                 tracks_out_10_eta_V => eta_out(10),
                 tracks_out_10_phi_V => phi_out(10),
                 tracks_out_10_rest_V => rest_out(10),
                 tracks_out_11_pt_V => pt_out(11),
                 tracks_out_11_eta_V => eta_out(11),
                 tracks_out_11_phi_V => phi_out(11),
                 tracks_out_11_rest_V => rest_out(11),
                 tracks_out_12_pt_V => pt_out(12),
                 tracks_out_12_eta_V => eta_out(12),
                 tracks_out_12_phi_V => phi_out(12),
                 tracks_out_12_rest_V => rest_out(12),
                 tracks_out_13_pt_V => pt_out(13),
                 tracks_out_13_eta_V => eta_out(13),
                 tracks_out_13_phi_V => phi_out(13),
                 tracks_out_13_rest_V => rest_out(13),
                 tracks_out_14_pt_V => pt_out(14),
                 tracks_out_14_eta_V => eta_out(14),
                 tracks_out_14_phi_V => phi_out(14),
                 tracks_out_14_rest_V => rest_out(14),
                 tracks_out_15_pt_V => pt_out(15),
                 tracks_out_15_eta_V => eta_out(15),
                 tracks_out_15_phi_V => phi_out(15),
                 tracks_out_15_rest_V => rest_out(15),
                 tracks_out_16_pt_V => pt_out(16),
                 tracks_out_16_eta_V => eta_out(16),
                 tracks_out_16_phi_V => phi_out(16),
                 tracks_out_16_rest_V => rest_out(16),
                 tracks_out_17_pt_V => pt_out(17),
                 tracks_out_17_eta_V => eta_out(17),
                 tracks_out_17_phi_V => phi_out(17),
                 tracks_out_17_rest_V => rest_out(17),
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
            write(Lo, string'(" ")); 
            write(Lo, newevent_out); 
            write(Lo, string'(" ")); 
            for i in 0 to NREGIONS-1 loop 
                write(Lo, to_integer(unsigned(pt_out(i))),   field => 6); 
                write(Lo, to_integer(signed(eta_out(i))),    field => 6); 
                write(Lo, to_integer(signed(phi_out(i))),    field => 6); 
                write(Lo, to_integer(unsigned(rest_out(i))), field => 6); 
            end loop;
            write(Lo, string'(" |  ready ")); 
            write(Lo, ready); 
            write(Lo, string'("   idle ")); 
            write(Lo, idle); 
            write(Lo, string'("  done ")); 
            write(Lo, done); 
            writeline(Fo, Lo);
            frame := frame + 1;
        end loop;
        wait for 50 ns;
        finish(0);
    end process;

    
end Behavioral;
