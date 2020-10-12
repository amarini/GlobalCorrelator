-- Wrapper for HLS block that does time demultiplexing 18 -> 6
-- Runs only on the first 3 links, and assumes links 1 and 2 are delayed by 6 and 12 BX
--
-- Giovanni Petrucciani (CERN), July 2020 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

entity emp_payload is
	port(
		clk: in std_logic; -- ipbus signals
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk_payload: in std_logic_vector(2 downto 0);
		rst_payload: in std_logic_vector(2 downto 0);
		clk_p: in std_logic; -- data clock
		rst_loc: in std_logic_vector(N_REGION - 1 downto 0);
		clken_loc: in std_logic_vector(N_REGION - 1 downto 0);
		ctrs: in ttc_stuff_array;
		bc0: out std_logic;
		d: in ldata(4 * N_REGION - 1 downto 0); -- data in
		q: out ldata(4 * N_REGION - 1 downto 0); -- data out
		gpio: out std_logic_vector(29 downto 0); -- IO to mezzanine connector
		gpio_en: out std_logic_vector(29 downto 0) -- IO to mezzanine connector (three-state enables)
	);
		
end emp_payload;

architecture rtl of emp_payload is
        constant NSECTORS : natural := 9;
        constant NFIBERS : natural := 2;
        constant NFIFOS : natural := 6;
        constant NREGIONS : natural := NSECTORS;

        type pt_vect     is array(natural range <>) of std_logic_vector(13 downto 0);
        type etaphi_vect is array(natural range <>) of std_logic_vector(11 downto 0);
        type rest_vect   is array(natural range <>) of std_logic_vector(25 downto 0);

        signal newevent, newevent_out : std_logic;

        signal pt_in:  pt_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(13 downto 0);
        signal pt_out: pt_vect(NREGIONS-1         downto 0); -- of std_logic_vector(13 downto 0);
        signal eta_in, phi_in:   etaphi_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(11 downto 0);
        signal eta_out, phi_out: etaphi_vect(NREGIONS-1         downto 0); -- of std_logic_vector(11 downto 0);
        signal rest_in:  rest_vect(NSECTORS*NFIBERS-1 downto 0); -- of std_logic_vector(25 downto 0);
        signal rest_out: rest_vect(NREGIONS-1         downto 0); -- of std_logic_vector(25 downto 0);


        constant N_OUT : natural := NREGIONS+1;
        --signal copy_in   : ldata(4 * N_REGION - 1 downto N_OUT);
        --signal copy_out  : ldata(4 * N_REGION - 1 downto N_OUT);
begin

	ipb_out <= IPB_RBUS_NULL;


    uut : entity work.regionizer
        port map(ap_clk => clk_p, 
                 ap_rst => rst_loc(0), 
                 ap_start => '1',
                 --ap_ready => ready,
                 --ap_idle =>  idle,
                 --ap_done => done,
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
                 newevent => newevent,
                 newevent_out => newevent_out
             );


        executor: process(clk_p)
            begin
                if rising_edge(clk_p) then
                    q(0).data <= (0 => newevent_out, others => '0');
                    q(0).valid <= '1';
                    q(0).strobe <= '1';
                    for i in 0 to NREGIONS-1 loop
                        q(i+1).data(63 downto 50) <= pt_out(i);
                        q(i+1).data(49 downto 38) <= eta_out(i);
                        q(i+1).data(37 downto 26) <= phi_out(i);
                        q(i+1).data(25 downto  0) <= rest_out(i);
                    end loop;

                    newevent <= d(0).valid and d(0).data(0);
                    for i in 0 to NSECTORS*NFIBERS-1 loop
                        pt_in(i)   <= d(i+1).data(63 downto 50);
                        eta_in(i)  <= d(i+1).data(49 downto 38);
                        phi_in(i)  <= d(i+1).data(37 downto 26);
                        rest_in(i) <= d(i+1).data(25 downto  0);
                    end loop;
                end if;
            end process executor;

        copy:	
            process(clk_p) 
            begin
                if rising_edge(clk_p) then
                    for i in 4 * N_REGION - 1 downto N_OUT loop
                        --copy_in(i) <= d(i);
                        --copy_out(i) <= copy_in(i);
                        --q(i) <= copy_out(i);
                        q(i).data <= (others => '0');
                        q(i).valid <= '0';
                        q(i).strobe <= '1';
                    end loop;
                end if;
            end process copy;
    
	
	bc0 <= '0';
	
	gpio <= (others => '0');
	gpio_en <= (others => '0');

end rtl;
