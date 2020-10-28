library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity calo_regionizer is
    port(
            ap_clk : IN STD_LOGIC;
            ap_rst : IN STD_LOGIC;
            ap_start : IN STD_LOGIC;
            ap_done : OUT STD_LOGIC;
            ap_idle : OUT STD_LOGIC;
            ap_ready : OUT STD_LOGIC;
            newevent : IN STD_LOGIC;
            tracks_in_0_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_0_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_0_2_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_2_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_2_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_2_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_0_3_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_3_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_3_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_3_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_2_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_2_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_2_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_2_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_3_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_3_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_3_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_3_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_2_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_2_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_2_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_2_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_3_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_3_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_3_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_3_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);

            tracks_out :       OUT particles(NSECTORS-1 downto 0);
            tracks_out_valid : OUT std_logic_vector(NSECTORS-1 downto 0);

            dbg_fifo0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo2 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo3 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo4 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo5 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo6 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo7 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo0_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo1_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo2_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo3_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo4_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo5_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo6_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_fifo7_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_merge2_0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_merge2_1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_merge2_2 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_merge2_3 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_merge4_0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_merge4_1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            dbg_merge    : OUT STD_LOGIC_VECTOR(63 downto 0);
            newevent_out : OUT STD_LOGIC

    );
end calo_regionizer;

architecture Behavioral of calo_regionizer is
    constant NREGIONS  : natural := NSECTORS;
    constant NALLFIFOS : natural := NCALOSECTORS*NCALOFIFOS;
    constant NMERGE2   : natural := NALLFIFOS/2;
    constant NMERGE4   : natural := NALLFIFOS/4;

    constant DEBUG_REGION : natural := 2;
    constant DEBUG_SECTOR : natural := DEBUG_REGION/3;
    constant DEBUG_FIFO   : natural := (DEBUG_SECTOR*5+3)*NCALOFIBERS;
    constant DEBUG_EXT    : boolean := true; -- true if it's a 8-fifo region

    type w64_vec     is array(natural range <>) of std_logic_vector(63 downto 0);

    signal links_in :       particles(NCALOSECTORS*NCALOFIBERS-1 downto 0);
    signal fifo_in :        particles(NALLFIFOS-1 downto 0);
    signal fifo_in_write :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_in_roll  :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');

    signal fifo_out :         particles(NALLFIFOS-1 downto 0);
    signal fifo_out_valid :   std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_out_full:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_out_roll:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_dbg :         w64_vec(NALLFIFOS-1 downto 0);

    signal merged2_out :        particles(NMERGE2-1 downto 0);
    signal merged2_out_valid :  std_logic_vector(NMERGE2-1 downto 0) := (others => '0');
    signal merged2_out_roll:    std_logic_vector(NMERGE2-1 downto 0) := (others => '0');
    signal merged2_out_full:    std_logic_vector(NMERGE2-1 downto 0) := (others => '0');
    signal merged2_dbg :        w64_vec(NMERGE2-1 downto 0);

    signal merged4_out :        particles(NMERGE4-1 downto 0);
    signal merged4_out_valid :  std_logic_vector(NMERGE4-1 downto 0) := (others => '0');
    signal merged4_out_roll:    std_logic_vector(NMERGE4-1 downto 0) := (others => '0');
    signal merged4_out_full:    std_logic_vector(NMERGE4-1 downto 0) := (others => '0');
    signal merged4_dbg :        w64_vec(NMERGE4-1 downto 0);

    signal merged_out :        particles(NREGIONS-1 downto 0);
    signal merged_out_valid :  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal merged_out_roll:    std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal merged_dbg :        w64_vec(NREGIONS-1 downto 0);

begin

    router : entity work.calo_router 
                port map(ap_clk => ap_clk, 
                             enabled => ap_start,
                             newevent => newevent,
                             links_in => links_in,
                             fifo_in => fifo_in,
                             fifo_in_write => fifo_in_write,
                             fifo_in_roll  => fifo_in_roll);

    gen_fifos: for ireg in NALLFIFOS-1 downto 0 generate
        reg_buffer : entity work.rolling_fifo
                        --generic map(FIFO_INDEX => ireg+1)
                        port map(ap_clk => ap_clk, 
                                 d_in    => fifo_in(ireg),
                                 write_in  => fifo_in_write(ireg),
                                 roll   => fifo_in_roll(ireg),
                                 d_out    => fifo_out(ireg),
                                 valid_out  => fifo_out_valid(ireg),
                                 dbg_w64 =>  fifo_dbg(ireg),
                                 full  => fifo_out_full(ireg),
                                 roll_out  => fifo_out_roll(ireg)
                             );
        end generate gen_fifos;

    gen_merger2s: for imerge in NMERGE2-1 downto 0 generate
        reg_merger2 : entity work.fifo_merge2_full
                        --generic map(FIFO_INDEX => imerge+1)
                        port map(ap_clk => ap_clk, 
                                 d1_in => fifo_out(imerge*2),
                                 d2_in => fifo_out(imerge*2+1),
                                 d1_valid => fifo_out_valid(imerge*2),
                                 d2_valid => fifo_out_valid(imerge*2+1),
                                 roll     => fifo_out_roll(imerge*2),
                                 full     => merged2_out_full(imerge),
                                 d_out      => merged2_out(imerge),
                                 valid_out  => merged2_out_valid(imerge),
                                 full1      => fifo_out_full(imerge*2),  
                                 full2      => fifo_out_full(imerge*2+1),
                                 dbg_w64    => merged2_dbg(imerge),
                                 roll_out   => merged2_out_roll(imerge)
                            );
        end generate gen_merger2s;

    gen_merger4s: for imerge in NMERGE4-1 downto 0 generate
        reg_merger4 : entity work.fifo_merge2_full
                        --generic map(FIFO_INDEX => imerge+1)
                        port map(ap_clk => ap_clk, 
                                 d1_in => merged2_out(imerge*2),
                                 d2_in => merged2_out(imerge*2+1),
                                 d1_valid => merged2_out_valid(imerge*2),
                                 d2_valid => merged2_out_valid(imerge*2+1),
                                 roll     => merged2_out_roll(imerge*2),
                                 full     => merged4_out_full(imerge),
                                 d_out      => merged4_out(imerge),
                                 valid_out  => merged4_out_valid(imerge),
                                 full1      => merged2_out_full(imerge*2),  
                                 full2      => merged2_out_full(imerge*2+1),
                                 dbg_w64    => merged4_dbg(imerge),
                                 roll_out   => merged4_out_roll(imerge)
                            );
        end generate gen_merger4s;

    gen_mergers_s: for isec in NCALOSECTORS-1 downto 0 generate
        delay_0 : process(ap_clk)
            constant iFROM : natural := 5*isec;
            constant iTO : natural := 3*isec;
        begin
            if rising_edge(ap_clk) then
                merged_out(iTO) <= merged4_out(iFROM);
                merged_out_valid(iTO) <= merged4_out_valid(iFROM);
                merged_out_roll(iTO) <= merged4_out_roll(iFROM);
                merged4_out_full(iFROM) <= '0';
            end if;
        end process delay_0;
            
        gen_mergers_12 : for imerge in 0 to 1 generate
            reg_merger : entity work.fifo_merge2
                            port map(ap_clk => ap_clk, 
                                     d1_in => merged4_out(5*isec+2*imerge+1),
                                     d2_in => merged4_out(5*isec+2*imerge+2),
                                     d1_valid => merged4_out_valid(5*isec+2*imerge+1),
                                     d2_valid => merged4_out_valid(5*isec+2*imerge+2),
                                     roll     => merged4_out_roll(3*isec+imerge+1),
                                     --full     => '0',
                                     d_out      => merged_out(3*isec+imerge+1),
                                     valid_out  => merged_out_valid(3*isec+imerge+1),
                                     full1      => merged4_out_full(5*isec+2*imerge+1),  
                                     full2      => merged4_out_full(5*isec+2*imerge+2),
                                     dbg_w64    => merged_dbg(3*isec+imerge+1),
                                     roll_out   => merged_out_roll(3*isec+imerge+1)
                                );
            end generate gen_mergers_12;
        end generate gen_mergers_s;


    links_in( 0).pt <= unsigned(tracks_in_0_0_pt_V);
    links_in( 1).pt <= unsigned(tracks_in_0_1_pt_V);
    links_in( 2).pt <= unsigned(tracks_in_0_2_pt_V);
    links_in( 3).pt <= unsigned(tracks_in_0_3_pt_V);
    links_in( 4).pt <= unsigned(tracks_in_1_0_pt_V);
    links_in( 5).pt <= unsigned(tracks_in_1_1_pt_V);
    links_in( 6).pt <= unsigned(tracks_in_1_2_pt_V);
    links_in( 7).pt <= unsigned(tracks_in_1_3_pt_V);
    links_in( 8).pt <= unsigned(tracks_in_2_0_pt_V);
    links_in( 9).pt <= unsigned(tracks_in_2_1_pt_V);
    links_in(10).pt <= unsigned(tracks_in_2_2_pt_V);
    links_in(11).pt <= unsigned(tracks_in_2_3_pt_V);
    links_in( 0).eta <= signed(tracks_in_0_0_eta_V);
    links_in( 1).eta <= signed(tracks_in_0_1_eta_V);
    links_in( 2).eta <= signed(tracks_in_0_2_eta_V);
    links_in( 3).eta <= signed(tracks_in_0_3_eta_V);
    links_in( 4).eta <= signed(tracks_in_1_0_eta_V);
    links_in( 5).eta <= signed(tracks_in_1_1_eta_V);
    links_in( 6).eta <= signed(tracks_in_1_2_eta_V);
    links_in( 7).eta <= signed(tracks_in_1_3_eta_V);
    links_in( 8).eta <= signed(tracks_in_2_0_eta_V);
    links_in( 9).eta <= signed(tracks_in_2_1_eta_V);
    links_in(10).eta <= signed(tracks_in_2_2_eta_V);
    links_in(11).eta <= signed(tracks_in_2_3_eta_V);
    links_in( 0).phi <= signed(tracks_in_0_0_phi_V);
    links_in( 1).phi <= signed(tracks_in_0_1_phi_V);
    links_in( 2).phi <= signed(tracks_in_0_2_phi_V);
    links_in( 3).phi <= signed(tracks_in_0_3_phi_V);
    links_in( 4).phi <= signed(tracks_in_1_0_phi_V);
    links_in( 5).phi <= signed(tracks_in_1_1_phi_V);
    links_in( 6).phi <= signed(tracks_in_1_2_phi_V);
    links_in( 7).phi <= signed(tracks_in_1_3_phi_V);
    links_in( 8).phi <= signed(tracks_in_2_0_phi_V);
    links_in( 9).phi <= signed(tracks_in_2_1_phi_V);
    links_in(10).phi <= signed(tracks_in_2_2_phi_V);
    links_in(11).phi <= signed(tracks_in_2_3_phi_V);
    links_in( 0).rest <= unsigned(tracks_in_0_0_rest_V);
    links_in( 1).rest <= unsigned(tracks_in_0_1_rest_V);
    links_in( 2).rest <= unsigned(tracks_in_0_2_rest_V);
    links_in( 3).rest <= unsigned(tracks_in_0_3_rest_V);
    links_in( 4).rest <= unsigned(tracks_in_1_0_rest_V);
    links_in( 5).rest <= unsigned(tracks_in_1_1_rest_V);
    links_in( 6).rest <= unsigned(tracks_in_1_2_rest_V);
    links_in( 7).rest <= unsigned(tracks_in_1_3_rest_V);
    links_in( 8).rest <= unsigned(tracks_in_2_0_rest_V);
    links_in( 9).rest <= unsigned(tracks_in_2_1_rest_V);
    links_in(10).rest <= unsigned(tracks_in_2_2_rest_V);
    links_in(11).rest <= unsigned(tracks_in_2_3_rest_V);

    newevent_out <= merged_out_roll(0);
    tracks_out <= merged_out;
    tracks_out_valid <= merged_out_valid;

    dbg_fifo0 <= fifo_dbg(DEBUG_FIFO+0);
    dbg_fifo1 <= fifo_dbg(DEBUG_FIFO+1);
    dbg_fifo2 <= fifo_dbg(DEBUG_FIFO+2);
    dbg_fifo3 <= fifo_dbg(DEBUG_FIFO+3);
    dbg_fifo0_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+0).pt);
    dbg_fifo1_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+1).pt);
    dbg_fifo2_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+2).pt);
    dbg_fifo3_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+3).pt);
    dbg_fifo0_d(31 downto 14) <= (others => '0');
    dbg_fifo1_d(31 downto 14) <= (others => '0');
    dbg_fifo2_d(31 downto 14) <= (others => '0');
    dbg_fifo3_d(31 downto 14) <= (others => '0');
    dbg_fifo0_d(32) <= fifo_out_valid(DEBUG_FIFO+0);
    dbg_fifo1_d(32) <= fifo_out_valid(DEBUG_FIFO+1);
    dbg_fifo2_d(32) <= fifo_out_valid(DEBUG_FIFO+2);
    dbg_fifo3_d(32) <= fifo_out_valid(DEBUG_FIFO+3);
    dbg_fifo0_d(33) <= fifo_out_roll(DEBUG_FIFO+0);
    dbg_fifo1_d(33) <= fifo_out_roll(DEBUG_FIFO+1);
    dbg_fifo2_d(33) <= fifo_out_roll(DEBUG_FIFO+2);
    dbg_fifo3_d(33) <= fifo_out_roll(DEBUG_FIFO+3);
    dbg_fifo0_d(34) <= fifo_out_full(DEBUG_FIFO+0);
    dbg_fifo1_d(34) <= fifo_out_full(DEBUG_FIFO+1);
    dbg_fifo2_d(34) <= fifo_out_full(DEBUG_FIFO+2);
    dbg_fifo3_d(34) <= fifo_out_full(DEBUG_FIFO+3);
    dbg_fifo0_d(63 downto 35) <= (others => '0');
    dbg_fifo1_d(63 downto 35) <= (others => '0');
    dbg_fifo2_d(63 downto 35) <= (others => '0');
    dbg_fifo3_d(63 downto 35) <= (others => '0');
    dbg_fifo4567_null: if not DEBUG_EXT generate
        dbg_fifo4 <= (others => '0');
        dbg_fifo5 <= (others => '0');
        dbg_fifo6 <= (others => '0');
        dbg_fifo7 <= (others => '0');
        dbg_fifo4_d <= (others => '0');
        dbg_fifo5_d <= (others => '0');
        dbg_fifo6_d <= (others => '0');
        dbg_fifo7_d <= (others => '0');
    end generate;
    dbg_fifo4567: if DEBUG_EXT generate
        dbg_fifo4 <= fifo_dbg(DEBUG_FIFO+4);
        dbg_fifo5 <= fifo_dbg(DEBUG_FIFO+5);
        dbg_fifo6 <= fifo_dbg(DEBUG_FIFO+6);
        dbg_fifo7 <= fifo_dbg(DEBUG_FIFO+7);
        dbg_fifo4_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+4).pt);
        dbg_fifo5_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+5).pt);
        dbg_fifo6_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+6).pt);
        dbg_fifo7_d(13 downto 0) <= std_logic_vector(fifo_out(DEBUG_FIFO+7).pt);
        dbg_fifo4_d(31 downto 14) <= (others => '0');
        dbg_fifo5_d(31 downto 14) <= (others => '0');
        dbg_fifo6_d(31 downto 14) <= (others => '0');
        dbg_fifo7_d(31 downto 14) <= (others => '0');
        dbg_fifo4_d(32) <= fifo_out_valid(DEBUG_FIFO+4);
        dbg_fifo5_d(32) <= fifo_out_valid(DEBUG_FIFO+5);
        dbg_fifo6_d(32) <= fifo_out_valid(DEBUG_FIFO+6);
        dbg_fifo7_d(32) <= fifo_out_valid(DEBUG_FIFO+7);
        dbg_fifo4_d(33) <= fifo_out_roll(DEBUG_FIFO+4);
        dbg_fifo5_d(33) <= fifo_out_roll(DEBUG_FIFO+5);
        dbg_fifo6_d(33) <= fifo_out_roll(DEBUG_FIFO+6);
        dbg_fifo7_d(33) <= fifo_out_roll(DEBUG_FIFO+7);
        dbg_fifo4_d(34) <= fifo_out_full(DEBUG_FIFO+4);
        dbg_fifo5_d(34) <= fifo_out_full(DEBUG_FIFO+5);
        dbg_fifo6_d(34) <= fifo_out_full(DEBUG_FIFO+6);
        dbg_fifo7_d(34) <= fifo_out_full(DEBUG_FIFO+7);
        dbg_fifo4_d(63 downto 35) <= (others => '0');
        dbg_fifo5_d(63 downto 35) <= (others => '0');
        dbg_fifo6_d(63 downto 35) <= (others => '0');
        dbg_fifo7_d(63 downto 35) <= (others => '0');
    end generate;

    dbg_merge2_0(46 downto 0) <= merged2_dbg(DEBUG_FIFO/2+0)(46 downto 0);
    dbg_merge2_1(46 downto 0) <= merged2_dbg(DEBUG_FIFO/2+1)(46 downto 0);
    dbg_merge2_0(60 downto 47) <= std_logic_vector(merged2_out(DEBUG_FIFO/2+0).pt);
    dbg_merge2_1(60 downto 47) <= std_logic_vector(merged2_out(DEBUG_FIFO/2+1).pt);
    dbg_merge2_0(61) <= merged2_out_full(DEBUG_FIFO/2+0);
    dbg_merge2_1(61) <= merged2_out_full(DEBUG_FIFO/2+1);
    dbg_merge2_0(62) <= merged2_out_valid(DEBUG_FIFO/2+0);
    dbg_merge2_1(62) <= merged2_out_valid(DEBUG_FIFO/2+1);
    dbg_merge2_0(63) <= merged2_out_roll(DEBUG_FIFO/2+0);
    dbg_merge2_1(63) <= merged2_out_roll(DEBUG_FIFO/2+1);
    dbg_merge223_null: if not DEBUG_EXT generate
        dbg_merge2_2 <= (others => '0');
        dbg_merge2_3 <= (others => '0');
    end generate;
    dbg_merge223: if DEBUG_EXT generate
        dbg_merge2_2(46 downto 0) <= merged2_dbg(DEBUG_FIFO/2+2)(46 downto 0);
        dbg_merge2_3(46 downto 0) <= merged2_dbg(DEBUG_FIFO/2+3)(46 downto 0);
        dbg_merge2_2(60 downto 47) <= std_logic_vector(merged2_out(DEBUG_FIFO/2+2).pt);
        dbg_merge2_3(60 downto 47) <= std_logic_vector(merged2_out(DEBUG_FIFO/2+3).pt);
        dbg_merge2_2(61) <= merged2_out_full(DEBUG_FIFO/2+2);
        dbg_merge2_3(61) <= merged2_out_full(DEBUG_FIFO/2+3);
        dbg_merge2_2(62) <= merged2_out_valid(DEBUG_FIFO/2+2);
        dbg_merge2_3(62) <= merged2_out_valid(DEBUG_FIFO/2+3);
        dbg_merge2_2(63) <= merged2_out_roll(DEBUG_FIFO/2+2);
        dbg_merge2_3(63) <= merged2_out_roll(DEBUG_FIFO/2+3);
    end generate;

    dbg_merge4_0(46 downto 0) <= merged4_dbg(DEBUG_FIFO/4+0)(46 downto 0);
    dbg_merge4_0(60 downto 47) <= std_logic_vector(merged4_out(DEBUG_FIFO/4+0).pt);
    dbg_merge4_0(61) <= merged4_out_full(DEBUG_FIFO/4+0);
    dbg_merge4_0(62) <= merged4_out_valid(DEBUG_FIFO/4+0);
    dbg_merge4_0(63) <= merged4_out_roll(DEBUG_FIFO/4+0);
    dbg_merge41_null: if not DEBUG_EXT generate
        dbg_merge4_1 <= (others => '0');
    end generate;
    dbg_merge41: if DEBUG_EXT generate
        dbg_merge4_1(46 downto 0) <= merged4_dbg(DEBUG_FIFO/4+1)(46 downto 0);
        dbg_merge4_1(60 downto 47) <= std_logic_vector(merged4_out(DEBUG_FIFO/4+1).pt);
        dbg_merge4_1(61) <= merged4_out_full(DEBUG_FIFO/4+1);
        dbg_merge4_1(62) <= merged4_out_valid(DEBUG_FIFO/4+1);
        dbg_merge4_1(63) <= merged4_out_roll(DEBUG_FIFO/4+1);
    end generate;

    dbg_merge(47 downto 0) <= merged_dbg(DEBUG_REGION)(47 downto 0);
    dbg_merge(61 downto 48) <= std_logic_vector(merged_out(DEBUG_REGION).pt);
    dbg_merge(62) <= merged_out_valid(DEBUG_REGION);
    dbg_merge(63) <= merged_out_roll(DEBUG_REGION);

end Behavioral;
