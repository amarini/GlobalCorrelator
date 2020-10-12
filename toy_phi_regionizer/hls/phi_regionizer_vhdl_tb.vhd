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
    constant NSECTORS : natural := 9;
    constant NFIBERS : natural := 2;
    constant NFIFOS : natural := 6;
    constant NREGIONS : natural := NSECTORS;

    type pt_vect     is array(natural range <>) of std_logic_vector(13 downto 0);
    type etaphi_vect is array(natural range <>) of std_logic_vector(11 downto 0);
    type rest_vect   is array(natural range <>) of std_logic_vector(25 downto 0);
    
    --type w64_vec     is array(natural range <>) of std_logic_vector(63 downto 0);

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

    --signal fifo_dbg, fifo_dbg_d: w64_vec(NSECTORS*NFIFOS-1 downto 0);
    --signal merger2_dbg: w64_vec(NREGIONS*(NFIFOS/2)-1 downto 0);
    --signal merger_dbg: w64_vec(NREGIONS-1 downto 0);

    file Fi : text open read_mode is "input.txt";
    file Fo : text open write_mode is "output_vhdl_tb.txt";
    --file Fd : text open write_mode is "debug_vhdl_tb.txt";


begin
    clk  <= not clk after 1.25 ns;
    
    uut : entity work.regionizer
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
                 -- begin debug
                 --dbg_sec0_fifo0 => fifo_dbg(0),
                 --dbg_sec0_fifo1 => fifo_dbg(1),
                 --dbg_sec0_fifo2 => fifo_dbg(2),
                 --dbg_sec0_fifo3 => fifo_dbg(3),
                 --dbg_sec0_fifo4 => fifo_dbg(4),
                 --dbg_sec0_fifo5 => fifo_dbg(5),
                 --dbg_sec1_fifo0 => fifo_dbg(6),
                 --dbg_sec1_fifo1 => fifo_dbg(7),
                 --dbg_sec1_fifo2 => fifo_dbg(8),
                 --dbg_sec1_fifo3 => fifo_dbg(9),
                 --dbg_sec1_fifo4 => fifo_dbg(10),
                 --dbg_sec1_fifo5 => fifo_dbg(11),
                 --dbg_sec2_fifo0 => fifo_dbg(12),
                 --dbg_sec2_fifo1 => fifo_dbg(13),
                 --dbg_sec2_fifo2 => fifo_dbg(14),
                 --dbg_sec2_fifo3 => fifo_dbg(15),
                 --dbg_sec2_fifo4 => fifo_dbg(16),
                 --dbg_sec2_fifo5 => fifo_dbg(17),
                 --dbg_sec0_fifo0_d => fifo_dbg_d(0),
                 --dbg_sec0_fifo1_d => fifo_dbg_d(1),
                 --dbg_sec0_fifo2_d => fifo_dbg_d(2),
                 --dbg_sec0_fifo3_d => fifo_dbg_d(3),
                 --dbg_sec0_fifo4_d => fifo_dbg_d(4),
                 --dbg_sec0_fifo5_d => fifo_dbg_d(5),
                 --dbg_sec1_fifo0_d => fifo_dbg_d(6),
                 --dbg_sec1_fifo1_d => fifo_dbg_d(7),
                 --dbg_sec1_fifo2_d => fifo_dbg_d(8),
                 --dbg_sec1_fifo3_d => fifo_dbg_d(9),
                 --dbg_sec1_fifo4_d => fifo_dbg_d(10),
                 --dbg_sec1_fifo5_d => fifo_dbg_d(11),
                 --dbg_sec2_fifo0_d => fifo_dbg_d(12),
                 --dbg_sec2_fifo1_d => fifo_dbg_d(13),
                 --dbg_sec2_fifo2_d => fifo_dbg_d(14),
                 --dbg_sec2_fifo3_d => fifo_dbg_d(15),
                 --dbg_sec2_fifo4_d => fifo_dbg_d(16),
                 --dbg_sec2_fifo5_d => fifo_dbg_d(17),
                 --dbg_sec0_merge0 => merger2_dbg(0),
                 --dbg_sec0_merge1 => merger2_dbg(1),
                 --dbg_sec0_merge2 => merger2_dbg(2),
                 --dbg_sec1_merge0 => merger2_dbg(3),
                 --dbg_sec1_merge1 => merger2_dbg(4),
                 --dbg_sec1_merge2 => merger2_dbg(5),
                 --dbg_sec2_merge0 => merger2_dbg(6),
                 --dbg_sec2_merge1 => merger2_dbg(7),
                 --dbg_sec2_merge2 => merger2_dbg(8),
                 --dbg_sec0_merge  => merger_dbg(0),
                 --dbg_sec1_merge  => merger_dbg(1),
                 --dbg_sec2_merge  => merger_dbg(2),
                 -- end debug
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
            for i in 0 to NREGIONS-1 loop 
                write(Lo, to_integer(unsigned(pt_out(i))),   field => 5); 
                write(Lo, to_integer(signed(eta_out(i))),    field => 5); 
                write(Lo, to_integer(signed(phi_out(i))),    field => 5); 
                write(Lo, to_integer(unsigned(rest_out(i))), field => 5); 
            end loop;
            --write(Lo, string'(" |  ready ")); 
            --write(Lo, ready); 
            --write(Lo, string'("   idle ")); 
            --write(Lo, idle); 
            --write(Lo, string'("  done ")); 
            --write(Lo, done); 
            writeline(Fo, Lo);
            ---- debug
            --write(Lo, frame, field=>5);  
            --write(Lo, string'(" ")); 
            --for isec in 0 to NSECTORS-1 loop 
            --    for imerge in 0 to (NFIFOS/2)-1 loop 
            --        for ififo in 2*imerge to 2*imerge+1 loop
            --            write(Lo, fifo_dbg(isec*NFIFOS+ififo)(4)); 
            --            write(Lo, to_integer(unsigned(fifo_dbg(isec*NFIFOS+ififo)(37 downto 32))), field => 3); 
            --            write(Lo, to_integer(unsigned(fifo_dbg(isec*NFIFOS+ififo)(21 downto 16))), field => 3); 
            --            write(Lo, string'(" ")); 
            --            write(Lo, fifo_dbg(isec*NFIFOS+ififo)(0)); 
            --            write(Lo, fifo_dbg(isec*NFIFOS+ififo)(1)); 
            --            write(Lo, fifo_dbg(isec*NFIFOS+ififo)(2)); 
            --            write(Lo, to_integer(unsigned(fifo_dbg(isec*NFIFOS+ififo)(61 downto 48))), field => 4); 
            --            write(Lo, string'(" ")); 
            --            write(Lo, fifo_dbg_d(isec*NFIFOS+ififo)(32)); 
            --            write(Lo, fifo_dbg_d(isec*NFIFOS+ififo)(33)); 
            --            write(Lo, to_integer(unsigned(fifo_dbg_d(isec*NFIFOS+ififo)(13 downto 0))), field => 4); 
            --            write(Lo, string'(" "));
            --            write(Lo, fifo_dbg_d(isec*NFIFOS+ififo)(34)); 
            --            write(Lo, string'(" | ")); 
            --        end loop;
            --        write(Lo, merger2_dbg(isec*NFIFOS/2+imerge)(14)); 
            --        write(Lo, to_integer(unsigned(merger2_dbg(isec*NFIFOS/2+imerge)(13 downto 0))), field => 4); 
            --        write(Lo, string'(" "));
            --        write(Lo, merger2_dbg(isec*NFIFOS/2+imerge)(29)); 
            --        write(Lo, to_integer(unsigned(merger2_dbg(isec*NFIFOS/2+imerge)(28 downto 15))), field => 4); 
            --        write(Lo, string'(" "));
            --        write(Lo, merger2_dbg(isec*NFIFOS/2+imerge)(62)); 
            --        write(Lo, merger2_dbg(isec*NFIFOS/2+imerge)(63)); 
            --        write(Lo, to_integer(unsigned(merger2_dbg(isec*NFIFOS/2+imerge)(60 downto 47))), field => 4); 
            --        write(Lo, string'(" "));
            --        write(Lo, merger2_dbg(isec*NFIFOS/2+imerge)(61)); 
            --        write(Lo, string'(" || ")); 
            --    end loop;
            --    write(Lo, merger_dbg(isec)(14)); 
            --    write(Lo, to_integer(unsigned(merger_dbg(isec)(13 downto 0))), field => 4); 
            --    write(Lo, string'(" "));
            --    write(Lo, merger_dbg(isec)(29)); 
            --    write(Lo, to_integer(unsigned(merger_dbg(isec)(28 downto 15))), field => 4); 
            --    write(Lo, string'(" "));
            --    write(Lo, merger_dbg(isec)(62)); 
            --    write(Lo, merger_dbg(isec)(63)); 
            --    write(Lo, to_integer(unsigned(merger_dbg(isec)(61 downto 48))), field => 4); 
            --    write(Lo, string'(" ||| ")); 
            --end loop;
            --writeline(Fd, Lo);
            frame := frame + 1;
            --if frame >= 50 then finish(0); end if;
        end loop;
        wait for 50 ns;
        finish(0);
    end process;

    
end Behavioral;
