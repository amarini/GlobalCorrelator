library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity regionizer_m2 is
    port(
            ap_clk : IN STD_LOGIC;
            ap_rst : IN STD_LOGIC;
            ap_start : IN STD_LOGIC;
            ap_done : OUT STD_LOGIC;
            ap_idle : OUT STD_LOGIC;
            ap_ready : OUT STD_LOGIC;
            newevent : IN STD_LOGIC;
            tracks_in_0_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_1_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_2_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_0_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_1_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_2_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_0_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_0_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_1_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_2_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_3_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_3_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_4_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_4_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_5_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_5_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_3_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_4_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_5_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_3_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_3_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_4_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_4_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_5_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_5_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_6_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_6_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_7_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_7_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_8_0_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_8_1_pt_V : IN STD_LOGIC_VECTOR (13 downto 0);
            tracks_in_6_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_0_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_1_eta_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_7_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_0_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_8_1_phi_V : IN STD_LOGIC_VECTOR (11 downto 0);
            tracks_in_6_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_6_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_7_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_7_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_8_0_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);
            tracks_in_8_1_rest_V : IN STD_LOGIC_VECTOR (25 downto 0);

            tracks_out_0_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_0_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_0_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_0_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_1_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_1_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_1_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_1_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_2_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_2_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_2_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_2_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_3_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_3_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_3_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_3_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_4_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_4_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_4_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_4_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_5_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_5_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_5_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_5_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_6_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_6_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_6_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_6_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_7_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_7_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_7_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_7_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_8_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_8_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_8_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_8_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_9_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_9_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_9_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_9_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_10_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_10_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_10_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_10_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_11_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_11_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_11_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_11_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_12_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_12_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_12_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_12_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_13_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_13_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_13_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_13_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_14_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_14_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_14_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_14_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_15_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_15_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_15_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_15_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_16_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_16_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_16_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_16_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_17_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_17_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_17_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_17_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_18_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_18_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_18_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_18_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_19_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_19_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_19_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_19_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_20_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_20_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_20_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_20_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_21_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_21_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_21_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_21_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_22_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_22_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_22_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_22_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_23_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_23_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_23_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_23_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_24_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_24_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_24_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_24_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_25_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_25_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_25_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_25_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_26_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_26_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_26_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_26_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            --dbg_sec0_fifo0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo2 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo3 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo4 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo5 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo2 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo3 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo4 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo5 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo2 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo3 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo4 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo5 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo0_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo1_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo2_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo3_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo4_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_fifo5_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo0_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo1_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo2_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo3_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo4_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_fifo5_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo0_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo1_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo2_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo3_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo4_d : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_fifo5_d : OUT STD_LOGIC_VECTOR(63 downto 0);

            --dbg_sec0_merge0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_merge1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec0_merge2 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_merge0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_merge1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec1_merge2 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_merge0 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_merge1 : OUT STD_LOGIC_VECTOR(63 downto 0);
            --dbg_sec2_merge2 : OUT STD_LOGIC_VECTOR(63 downto 0);

            newevent_out : OUT STD_LOGIC

    );
end regionizer_m2;

architecture Behavioral of regionizer_m2 is
    constant NREGIONS  : natural := NSECTORS*(NFIFOS/2);
    constant NALLFIFOS : natural := NSECTORS*NFIFOS;

    --type w64_vec     is array(natural range <>) of std_logic_vector(63 downto 0);

    signal links_in :       particles(NSECTORS*NFIBERS-1 downto 0);
    signal fifo_in :        particles(NALLFIFOS-1 downto 0);
    signal fifo_in_write :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_in_roll  :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');

    signal fifo_out :         particles(NALLFIFOS-1 downto 0);
    signal fifo_out_valid :   std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_out_full:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_out_roll:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    --signal fifo_dbg :         w64_vec(NALLFIFOS-1 downto 0);

    signal merged_out :        particles(NREGIONS-1 downto 0);
    signal merged_out_valid :  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal merged_out_roll:    std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    --signal merged_dbg :        w64_vec(NREGIONS-1 downto 0);

    signal regions_out :      particles(NREGIONS-1 downto 0);
    signal regions_out_valid: std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal regions_out_roll:  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');

begin

    router : entity work.tk_router 
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
                                 --dbg_w64 =>  fifo_dbg(ireg),
                                 full  => fifo_out_full(ireg),
                                 roll_out  => fifo_out_roll(ireg)
                             );
        end generate gen_fifos;

    gen_mergers: for imerge in NREGIONS-1 downto 0 generate
        reg_merger : entity work.fifo_merge2
                        --generic map(FIFO_INDEX => imerge+1)
                        port map(ap_clk => ap_clk, 
                                 d1_in => fifo_out(imerge*2),
                                 d2_in => fifo_out(imerge*2+1),
                                 d1_valid => fifo_out_valid(imerge*2),
                                 d2_valid => fifo_out_valid(imerge*2+1),
                                 roll     => fifo_out_roll(imerge*2),
                                 d_out      => merged_out(imerge),
                                 valid_out  => merged_out_valid(imerge),
                                 full1      => fifo_out_full(imerge*2),  
                                 full2      => fifo_out_full(imerge*2+1),
                                 --dbg_w64    =>  merged_dbg(imerge),
                                 roll_out   => merged_out_roll(imerge)
                            );


        end generate gen_mergers;
   
    links_in( 0).pt <= unsigned(tracks_in_0_0_pt_V);
    links_in( 1).pt <= unsigned(tracks_in_0_1_pt_V);
    links_in( 2).pt <= unsigned(tracks_in_1_0_pt_V);
    links_in( 3).pt <= unsigned(tracks_in_1_1_pt_V);
    links_in( 4).pt <= unsigned(tracks_in_2_0_pt_V);
    links_in( 5).pt <= unsigned(tracks_in_2_1_pt_V);
    links_in( 6).pt <= unsigned(tracks_in_3_0_pt_V);
    links_in( 7).pt <= unsigned(tracks_in_3_1_pt_V);
    links_in( 8).pt <= unsigned(tracks_in_4_0_pt_V);
    links_in( 9).pt <= unsigned(tracks_in_4_1_pt_V);
    links_in(10).pt <= unsigned(tracks_in_5_0_pt_V);
    links_in(11).pt <= unsigned(tracks_in_5_1_pt_V);
    links_in(12).pt <= unsigned(tracks_in_6_0_pt_V);
    links_in(13).pt <= unsigned(tracks_in_6_1_pt_V);
    links_in(14).pt <= unsigned(tracks_in_7_0_pt_V);
    links_in(15).pt <= unsigned(tracks_in_7_1_pt_V);
    links_in(16).pt <= unsigned(tracks_in_8_0_pt_V);
    links_in(17).pt <= unsigned(tracks_in_8_1_pt_V);
    links_in( 0).eta <= signed(tracks_in_0_0_eta_V);
    links_in( 1).eta <= signed(tracks_in_0_1_eta_V);
    links_in( 2).eta <= signed(tracks_in_1_0_eta_V);
    links_in( 3).eta <= signed(tracks_in_1_1_eta_V);
    links_in( 4).eta <= signed(tracks_in_2_0_eta_V);
    links_in( 5).eta <= signed(tracks_in_2_1_eta_V);
    links_in( 6).eta <= signed(tracks_in_3_0_eta_V);
    links_in( 7).eta <= signed(tracks_in_3_1_eta_V);
    links_in( 8).eta <= signed(tracks_in_4_0_eta_V);
    links_in( 9).eta <= signed(tracks_in_4_1_eta_V);
    links_in(10).eta <= signed(tracks_in_5_0_eta_V);
    links_in(11).eta <= signed(tracks_in_5_1_eta_V);
    links_in(12).eta <= signed(tracks_in_6_0_eta_V);
    links_in(13).eta <= signed(tracks_in_6_1_eta_V);
    links_in(14).eta <= signed(tracks_in_7_0_eta_V);
    links_in(15).eta <= signed(tracks_in_7_1_eta_V);
    links_in(16).eta <= signed(tracks_in_8_0_eta_V);
    links_in(17).eta <= signed(tracks_in_8_1_eta_V);
    links_in( 0).phi <= signed(tracks_in_0_0_phi_V);
    links_in( 1).phi <= signed(tracks_in_0_1_phi_V);
    links_in( 2).phi <= signed(tracks_in_1_0_phi_V);
    links_in( 3).phi <= signed(tracks_in_1_1_phi_V);
    links_in( 4).phi <= signed(tracks_in_2_0_phi_V);
    links_in( 5).phi <= signed(tracks_in_2_1_phi_V);
    links_in( 6).phi <= signed(tracks_in_3_0_phi_V);
    links_in( 7).phi <= signed(tracks_in_3_1_phi_V);
    links_in( 8).phi <= signed(tracks_in_4_0_phi_V);
    links_in( 9).phi <= signed(tracks_in_4_1_phi_V);
    links_in(10).phi <= signed(tracks_in_5_0_phi_V);
    links_in(11).phi <= signed(tracks_in_5_1_phi_V);
    links_in(12).phi <= signed(tracks_in_6_0_phi_V);
    links_in(13).phi <= signed(tracks_in_6_1_phi_V);
    links_in(14).phi <= signed(tracks_in_7_0_phi_V);
    links_in(15).phi <= signed(tracks_in_7_1_phi_V);
    links_in(16).phi <= signed(tracks_in_8_0_phi_V);
    links_in(17).phi <= signed(tracks_in_8_1_phi_V);
    links_in( 0).rest <= unsigned(tracks_in_0_0_rest_V);
    links_in( 1).rest <= unsigned(tracks_in_0_1_rest_V);
    links_in( 2).rest <= unsigned(tracks_in_1_0_rest_V);
    links_in( 3).rest <= unsigned(tracks_in_1_1_rest_V);
    links_in( 4).rest <= unsigned(tracks_in_2_0_rest_V);
    links_in( 5).rest <= unsigned(tracks_in_2_1_rest_V);
    links_in( 6).rest <= unsigned(tracks_in_3_0_rest_V);
    links_in( 7).rest <= unsigned(tracks_in_3_1_rest_V);
    links_in( 8).rest <= unsigned(tracks_in_4_0_rest_V);
    links_in( 9).rest <= unsigned(tracks_in_4_1_rest_V);
    links_in(10).rest <= unsigned(tracks_in_5_0_rest_V);
    links_in(11).rest <= unsigned(tracks_in_5_1_rest_V);
    links_in(12).rest <= unsigned(tracks_in_6_0_rest_V);
    links_in(13).rest <= unsigned(tracks_in_6_1_rest_V);
    links_in(14).rest <= unsigned(tracks_in_7_0_rest_V);
    links_in(15).rest <= unsigned(tracks_in_7_1_rest_V);
    links_in(16).rest <= unsigned(tracks_in_8_0_rest_V);
    links_in(17).rest <= unsigned(tracks_in_8_1_rest_V);


    merged2regions : process(ap_clk)
    begin
        if rising_edge(ap_clk) then
            for ireg in 0 to NREGIONS-1 loop
                if merged_out_valid(ireg) = '1' then
                    regions_out(ireg) <= merged_out(ireg);
                    regions_out_valid(ireg) <= '1';
                else
                    regions_out(ireg).pt   <= (others => '0');
                    regions_out(ireg).eta  <= (others => '0');
                    regions_out(ireg).phi  <= (others => '0');
                    regions_out(ireg).rest <= (others => '0');
                    regions_out_valid(ireg) <= '1';
                end if;
                regions_out_roll(ireg) <= merged_out_roll(ireg);
            end loop;
        end if;
    end process merged2regions;

    tracks_out_0_pt_V <= std_logic_vector(regions_out(0).pt);
    tracks_out_0_eta_V <= std_logic_vector(regions_out(0).eta);
    tracks_out_0_phi_V <= std_logic_vector(regions_out(0).phi);
    tracks_out_0_rest_V <= std_logic_vector(regions_out(0).rest);
    tracks_out_1_pt_V <= std_logic_vector(regions_out(1).pt);
    tracks_out_1_eta_V <= std_logic_vector(regions_out(1).eta);
    tracks_out_1_phi_V <= std_logic_vector(regions_out(1).phi);
    tracks_out_1_rest_V <= std_logic_vector(regions_out(1).rest);
    tracks_out_2_pt_V <= std_logic_vector(regions_out(2).pt);
    tracks_out_2_eta_V <= std_logic_vector(regions_out(2).eta);
    tracks_out_2_phi_V <= std_logic_vector(regions_out(2).phi);
    tracks_out_2_rest_V <= std_logic_vector(regions_out(2).rest);
    tracks_out_3_pt_V <= std_logic_vector(regions_out(3).pt);
    tracks_out_3_eta_V <= std_logic_vector(regions_out(3).eta);
    tracks_out_3_phi_V <= std_logic_vector(regions_out(3).phi);
    tracks_out_3_rest_V <= std_logic_vector(regions_out(3).rest);
    tracks_out_4_pt_V <= std_logic_vector(regions_out(4).pt);
    tracks_out_4_eta_V <= std_logic_vector(regions_out(4).eta);
    tracks_out_4_phi_V <= std_logic_vector(regions_out(4).phi);
    tracks_out_4_rest_V <= std_logic_vector(regions_out(4).rest);
    tracks_out_5_pt_V <= std_logic_vector(regions_out(5).pt);
    tracks_out_5_eta_V <= std_logic_vector(regions_out(5).eta);
    tracks_out_5_phi_V <= std_logic_vector(regions_out(5).phi);
    tracks_out_5_rest_V <= std_logic_vector(regions_out(5).rest);
    tracks_out_6_pt_V <= std_logic_vector(regions_out(6).pt);
    tracks_out_6_eta_V <= std_logic_vector(regions_out(6).eta);
    tracks_out_6_phi_V <= std_logic_vector(regions_out(6).phi);
    tracks_out_6_rest_V <= std_logic_vector(regions_out(6).rest);
    tracks_out_7_pt_V <= std_logic_vector(regions_out(7).pt);
    tracks_out_7_eta_V <= std_logic_vector(regions_out(7).eta);
    tracks_out_7_phi_V <= std_logic_vector(regions_out(7).phi);
    tracks_out_7_rest_V <= std_logic_vector(regions_out(7).rest);
    tracks_out_8_pt_V <= std_logic_vector(regions_out(8).pt);
    tracks_out_8_eta_V <= std_logic_vector(regions_out(8).eta);
    tracks_out_8_phi_V <= std_logic_vector(regions_out(8).phi);
    tracks_out_8_rest_V <= std_logic_vector(regions_out(8).rest);
    tracks_out_9_pt_V <= std_logic_vector(regions_out(9).pt);
    tracks_out_9_eta_V <= std_logic_vector(regions_out(9).eta);
    tracks_out_9_phi_V <= std_logic_vector(regions_out(9).phi);
    tracks_out_9_rest_V <= std_logic_vector(regions_out(9).rest);
    tracks_out_10_pt_V <= std_logic_vector(regions_out(10).pt);
    tracks_out_10_eta_V <= std_logic_vector(regions_out(10).eta);
    tracks_out_10_phi_V <= std_logic_vector(regions_out(10).phi);
    tracks_out_10_rest_V <= std_logic_vector(regions_out(10).rest);
    tracks_out_11_pt_V <= std_logic_vector(regions_out(11).pt);
    tracks_out_11_eta_V <= std_logic_vector(regions_out(11).eta);
    tracks_out_11_phi_V <= std_logic_vector(regions_out(11).phi);
    tracks_out_11_rest_V <= std_logic_vector(regions_out(11).rest);
    tracks_out_12_pt_V <= std_logic_vector(regions_out(12).pt);
    tracks_out_12_eta_V <= std_logic_vector(regions_out(12).eta);
    tracks_out_12_phi_V <= std_logic_vector(regions_out(12).phi);
    tracks_out_12_rest_V <= std_logic_vector(regions_out(12).rest);
    tracks_out_13_pt_V <= std_logic_vector(regions_out(13).pt);
    tracks_out_13_eta_V <= std_logic_vector(regions_out(13).eta);
    tracks_out_13_phi_V <= std_logic_vector(regions_out(13).phi);
    tracks_out_13_rest_V <= std_logic_vector(regions_out(13).rest);
    tracks_out_14_pt_V <= std_logic_vector(regions_out(14).pt);
    tracks_out_14_eta_V <= std_logic_vector(regions_out(14).eta);
    tracks_out_14_phi_V <= std_logic_vector(regions_out(14).phi);
    tracks_out_14_rest_V <= std_logic_vector(regions_out(14).rest);
    tracks_out_15_pt_V <= std_logic_vector(regions_out(15).pt);
    tracks_out_15_eta_V <= std_logic_vector(regions_out(15).eta);
    tracks_out_15_phi_V <= std_logic_vector(regions_out(15).phi);
    tracks_out_15_rest_V <= std_logic_vector(regions_out(15).rest);
    tracks_out_16_pt_V <= std_logic_vector(regions_out(16).pt);
    tracks_out_16_eta_V <= std_logic_vector(regions_out(16).eta);
    tracks_out_16_phi_V <= std_logic_vector(regions_out(16).phi);
    tracks_out_16_rest_V <= std_logic_vector(regions_out(16).rest);
    tracks_out_17_pt_V <= std_logic_vector(regions_out(17).pt);
    tracks_out_17_eta_V <= std_logic_vector(regions_out(17).eta);
    tracks_out_17_phi_V <= std_logic_vector(regions_out(17).phi);
    tracks_out_17_rest_V <= std_logic_vector(regions_out(17).rest);
    tracks_out_18_pt_V <= std_logic_vector(regions_out(18).pt);
    tracks_out_18_eta_V <= std_logic_vector(regions_out(18).eta);
    tracks_out_18_phi_V <= std_logic_vector(regions_out(18).phi);
    tracks_out_18_rest_V <= std_logic_vector(regions_out(18).rest);
    tracks_out_19_pt_V <= std_logic_vector(regions_out(19).pt);
    tracks_out_19_eta_V <= std_logic_vector(regions_out(19).eta);
    tracks_out_19_phi_V <= std_logic_vector(regions_out(19).phi);
    tracks_out_19_rest_V <= std_logic_vector(regions_out(19).rest);
    tracks_out_20_pt_V <= std_logic_vector(regions_out(20).pt);
    tracks_out_20_eta_V <= std_logic_vector(regions_out(20).eta);
    tracks_out_20_phi_V <= std_logic_vector(regions_out(20).phi);
    tracks_out_20_rest_V <= std_logic_vector(regions_out(20).rest);
    tracks_out_21_pt_V <= std_logic_vector(regions_out(21).pt);
    tracks_out_21_eta_V <= std_logic_vector(regions_out(21).eta);
    tracks_out_21_phi_V <= std_logic_vector(regions_out(21).phi);
    tracks_out_21_rest_V <= std_logic_vector(regions_out(21).rest);
    tracks_out_22_pt_V <= std_logic_vector(regions_out(22).pt);
    tracks_out_22_eta_V <= std_logic_vector(regions_out(22).eta);
    tracks_out_22_phi_V <= std_logic_vector(regions_out(22).phi);
    tracks_out_22_rest_V <= std_logic_vector(regions_out(22).rest);
    tracks_out_23_pt_V <= std_logic_vector(regions_out(23).pt);
    tracks_out_23_eta_V <= std_logic_vector(regions_out(23).eta);
    tracks_out_23_phi_V <= std_logic_vector(regions_out(23).phi);
    tracks_out_23_rest_V <= std_logic_vector(regions_out(23).rest);
    tracks_out_24_pt_V <= std_logic_vector(regions_out(24).pt);
    tracks_out_24_eta_V <= std_logic_vector(regions_out(24).eta);
    tracks_out_24_phi_V <= std_logic_vector(regions_out(24).phi);
    tracks_out_24_rest_V <= std_logic_vector(regions_out(24).rest);
    tracks_out_25_pt_V <= std_logic_vector(regions_out(25).pt);
    tracks_out_25_eta_V <= std_logic_vector(regions_out(25).eta);
    tracks_out_25_phi_V <= std_logic_vector(regions_out(25).phi);
    tracks_out_25_rest_V <= std_logic_vector(regions_out(25).rest);
    tracks_out_26_pt_V <= std_logic_vector(regions_out(26).pt);
    tracks_out_26_eta_V <= std_logic_vector(regions_out(26).eta);
    tracks_out_26_phi_V <= std_logic_vector(regions_out(26).phi);
    tracks_out_26_rest_V <= std_logic_vector(regions_out(26).rest);


    newevent_out <= regions_out_roll(0);

    --dbg_sec0_fifo0 <= fifo_dbg(0);
    --dbg_sec0_fifo1 <= fifo_dbg(1);
    --dbg_sec0_fifo2 <= fifo_dbg(2);
    --dbg_sec0_fifo3 <= fifo_dbg(3);
    --dbg_sec0_fifo4 <= fifo_dbg(4);
    --dbg_sec0_fifo5 <= fifo_dbg(5);
    --dbg_sec1_fifo0 <= fifo_dbg(6);
    --dbg_sec1_fifo1 <= fifo_dbg(7);
    --dbg_sec1_fifo2 <= fifo_dbg(8);
    --dbg_sec1_fifo3 <= fifo_dbg(9);
    --dbg_sec1_fifo4 <= fifo_dbg(10);
    --dbg_sec1_fifo5 <= fifo_dbg(11);
    --dbg_sec2_fifo0 <= fifo_dbg(12);
    --dbg_sec2_fifo1 <= fifo_dbg(13);
    --dbg_sec2_fifo2 <= fifo_dbg(14);
    --dbg_sec2_fifo3 <= fifo_dbg(15);
    --dbg_sec2_fifo4 <= fifo_dbg(16);
    --dbg_sec2_fifo5 <= fifo_dbg(17);

    --dbg_sec0_fifo0_d(13 downto 0) <= std_logic_vector(fifo_out(0).pt);
    --dbg_sec0_fifo1_d(13 downto 0) <= std_logic_vector(fifo_out(1).pt);
    --dbg_sec0_fifo2_d(13 downto 0) <= std_logic_vector(fifo_out(2).pt);
    --dbg_sec0_fifo3_d(13 downto 0) <= std_logic_vector(fifo_out(3).pt);
    --dbg_sec0_fifo4_d(13 downto 0) <= std_logic_vector(fifo_out(4).pt);
    --dbg_sec0_fifo5_d(13 downto 0) <= std_logic_vector(fifo_out(5).pt);
    --dbg_sec1_fifo0_d(13 downto 0) <= std_logic_vector(fifo_out(6).pt);
    --dbg_sec1_fifo1_d(13 downto 0) <= std_logic_vector(fifo_out(7).pt);
    --dbg_sec1_fifo2_d(13 downto 0) <= std_logic_vector(fifo_out(8).pt);
    --dbg_sec1_fifo3_d(13 downto 0) <= std_logic_vector(fifo_out(9).pt);
    --dbg_sec1_fifo4_d(13 downto 0) <= std_logic_vector(fifo_out(10).pt);
    --dbg_sec1_fifo5_d(13 downto 0) <= std_logic_vector(fifo_out(11).pt);
    --dbg_sec2_fifo0_d(13 downto 0) <= std_logic_vector(fifo_out(12).pt);
    --dbg_sec2_fifo1_d(13 downto 0) <= std_logic_vector(fifo_out(13).pt);
    --dbg_sec2_fifo2_d(13 downto 0) <= std_logic_vector(fifo_out(14).pt);
    --dbg_sec2_fifo3_d(13 downto 0) <= std_logic_vector(fifo_out(15).pt);
    --dbg_sec2_fifo4_d(13 downto 0) <= std_logic_vector(fifo_out(16).pt);
    --dbg_sec2_fifo5_d(13 downto 0) <= std_logic_vector(fifo_out(17).pt);

    --dbg_sec0_fifo0_d(31 downto 14) <= (others => '0');
    --dbg_sec0_fifo1_d(31 downto 14) <= (others => '0');
    --dbg_sec0_fifo2_d(31 downto 14) <= (others => '0');
    --dbg_sec0_fifo3_d(31 downto 14) <= (others => '0');
    --dbg_sec0_fifo4_d(31 downto 14) <= (others => '0');
    --dbg_sec0_fifo5_d(31 downto 14) <= (others => '0');
    --dbg_sec1_fifo0_d(31 downto 14) <= (others => '0');
    --dbg_sec1_fifo1_d(31 downto 14) <= (others => '0');
    --dbg_sec1_fifo2_d(31 downto 14) <= (others => '0');
    --dbg_sec1_fifo3_d(31 downto 14) <= (others => '0');
    --dbg_sec1_fifo4_d(31 downto 14) <= (others => '0');
    --dbg_sec1_fifo5_d(31 downto 14) <= (others => '0');
    --dbg_sec2_fifo0_d(31 downto 14) <= (others => '0');
    --dbg_sec2_fifo1_d(31 downto 14) <= (others => '0');
    --dbg_sec2_fifo2_d(31 downto 14) <= (others => '0');
    --dbg_sec2_fifo3_d(31 downto 14) <= (others => '0');
    --dbg_sec2_fifo4_d(31 downto 14) <= (others => '0');
    --dbg_sec2_fifo5_d(31 downto 14) <= (others => '0');

    --dbg_sec0_fifo0_d(32) <= fifo_out_valid(0);
    --dbg_sec0_fifo1_d(32) <= fifo_out_valid(1);
    --dbg_sec0_fifo2_d(32) <= fifo_out_valid(2);
    --dbg_sec0_fifo3_d(32) <= fifo_out_valid(3);
    --dbg_sec0_fifo4_d(32) <= fifo_out_valid(4);
    --dbg_sec0_fifo5_d(32) <= fifo_out_valid(5);
    --dbg_sec1_fifo0_d(32) <= fifo_out_valid(6);
    --dbg_sec1_fifo1_d(32) <= fifo_out_valid(7);
    --dbg_sec1_fifo2_d(32) <= fifo_out_valid(8);
    --dbg_sec1_fifo3_d(32) <= fifo_out_valid(9);
    --dbg_sec1_fifo4_d(32) <= fifo_out_valid(10);
    --dbg_sec1_fifo5_d(32) <= fifo_out_valid(11);
    --dbg_sec2_fifo0_d(32) <= fifo_out_valid(12);
    --dbg_sec2_fifo1_d(32) <= fifo_out_valid(13);
    --dbg_sec2_fifo2_d(32) <= fifo_out_valid(14);
    --dbg_sec2_fifo3_d(32) <= fifo_out_valid(15);
    --dbg_sec2_fifo4_d(32) <= fifo_out_valid(16);
    --dbg_sec2_fifo5_d(32) <= fifo_out_valid(17);


    --dbg_sec0_fifo0_d(33) <= fifo_out_roll(0);
    --dbg_sec0_fifo1_d(33) <= fifo_out_roll(1);
    --dbg_sec0_fifo2_d(33) <= fifo_out_roll(2);
    --dbg_sec0_fifo3_d(33) <= fifo_out_roll(3);
    --dbg_sec0_fifo4_d(33) <= fifo_out_roll(4);
    --dbg_sec0_fifo5_d(33) <= fifo_out_roll(5);
    --dbg_sec1_fifo0_d(33) <= fifo_out_roll(6);
    --dbg_sec1_fifo1_d(33) <= fifo_out_roll(7);
    --dbg_sec1_fifo2_d(33) <= fifo_out_roll(8);
    --dbg_sec1_fifo3_d(33) <= fifo_out_roll(9);
    --dbg_sec1_fifo4_d(33) <= fifo_out_roll(10);
    --dbg_sec1_fifo5_d(33) <= fifo_out_roll(11);
    --dbg_sec2_fifo0_d(33) <= fifo_out_roll(12);
    --dbg_sec2_fifo1_d(33) <= fifo_out_roll(13);
    --dbg_sec2_fifo2_d(33) <= fifo_out_roll(14);
    --dbg_sec2_fifo3_d(33) <= fifo_out_roll(15);
    --dbg_sec2_fifo4_d(33) <= fifo_out_roll(16);
    --dbg_sec2_fifo5_d(33) <= fifo_out_roll(17);

    --dbg_sec0_fifo0_d(34) <= fifo_out_full(0);
    --dbg_sec0_fifo1_d(34) <= fifo_out_full(1);
    --dbg_sec0_fifo2_d(34) <= fifo_out_full(2);
    --dbg_sec0_fifo3_d(34) <= fifo_out_full(3);
    --dbg_sec0_fifo4_d(34) <= fifo_out_full(4);
    --dbg_sec0_fifo5_d(34) <= fifo_out_full(5);
    --dbg_sec1_fifo0_d(34) <= fifo_out_full(6);
    --dbg_sec1_fifo1_d(34) <= fifo_out_full(7);
    --dbg_sec1_fifo2_d(34) <= fifo_out_full(8);
    --dbg_sec1_fifo3_d(34) <= fifo_out_full(9);
    --dbg_sec1_fifo4_d(34) <= fifo_out_full(10);
    --dbg_sec1_fifo5_d(34) <= fifo_out_full(11);
    --dbg_sec2_fifo0_d(34) <= fifo_out_full(12);
    --dbg_sec2_fifo1_d(34) <= fifo_out_full(13);
    --dbg_sec2_fifo2_d(34) <= fifo_out_full(14);
    --dbg_sec2_fifo3_d(34) <= fifo_out_full(15);
    --dbg_sec2_fifo4_d(34) <= fifo_out_full(16);
    --dbg_sec2_fifo5_d(34) <= fifo_out_full(17);

    --dbg_sec0_fifo0_d(63 downto 35) <= (others => '0');
    --dbg_sec0_fifo1_d(63 downto 35) <= (others => '0');
    --dbg_sec0_fifo2_d(63 downto 35) <= (others => '0');
    --dbg_sec0_fifo3_d(63 downto 35) <= (others => '0');
    --dbg_sec0_fifo4_d(63 downto 35) <= (others => '0');
    --dbg_sec0_fifo5_d(63 downto 35) <= (others => '0');
    --dbg_sec1_fifo0_d(63 downto 35) <= (others => '0');
    --dbg_sec1_fifo1_d(63 downto 35) <= (others => '0');
    --dbg_sec1_fifo2_d(63 downto 35) <= (others => '0');
    --dbg_sec1_fifo3_d(63 downto 35) <= (others => '0');
    --dbg_sec1_fifo4_d(63 downto 35) <= (others => '0');
    --dbg_sec1_fifo5_d(63 downto 35) <= (others => '0');
    --dbg_sec2_fifo0_d(63 downto 35) <= (others => '0');
    --dbg_sec2_fifo1_d(63 downto 35) <= (others => '0');
    --dbg_sec2_fifo2_d(63 downto 35) <= (others => '0');
    --dbg_sec2_fifo3_d(63 downto 35) <= (others => '0');
    --dbg_sec2_fifo4_d(63 downto 35) <= (others => '0');
    --dbg_sec2_fifo5_d(63 downto 35) <= (others => '0');


    --dbg_sec0_merge0(47 downto 0) <= merged_dbg(0)(47 downto 0);
    --dbg_sec0_merge1(47 downto 0) <= merged_dbg(1)(47 downto 0);
    --dbg_sec0_merge2(47 downto 0) <= merged_dbg(2)(47 downto 0);
    --dbg_sec1_merge0(47 downto 0) <= merged_dbg(3)(47 downto 0);
    --dbg_sec1_merge1(47 downto 0) <= merged_dbg(4)(47 downto 0);
    --dbg_sec1_merge2(47 downto 0) <= merged_dbg(5)(47 downto 0);
    --dbg_sec2_merge0(47 downto 0) <= merged_dbg(6)(47 downto 0);
    --dbg_sec2_merge1(47 downto 0) <= merged_dbg(7)(47 downto 0);
    --dbg_sec2_merge2(47 downto 0) <= merged_dbg(8)(47 downto 0);

    --dbg_sec0_merge0(61 downto 48) <= std_logic_vector(merged_out(0).pt);
    --dbg_sec0_merge1(61 downto 48) <= std_logic_vector(merged_out(1).pt);
    --dbg_sec0_merge2(61 downto 48) <= std_logic_vector(merged_out(2).pt);
    --dbg_sec1_merge0(61 downto 48) <= std_logic_vector(merged_out(3).pt);
    --dbg_sec1_merge1(61 downto 48) <= std_logic_vector(merged_out(4).pt);
    --dbg_sec1_merge2(61 downto 48) <= std_logic_vector(merged_out(5).pt);
    --dbg_sec2_merge0(61 downto 48) <= std_logic_vector(merged_out(6).pt);
    --dbg_sec2_merge1(61 downto 48) <= std_logic_vector(merged_out(7).pt);
    --dbg_sec2_merge2(61 downto 48) <= std_logic_vector(merged_out(8).pt);

    --dbg_sec0_merge0(62) <= merged_out_valid(0);
    --dbg_sec0_merge1(62) <= merged_out_valid(1);
    --dbg_sec0_merge2(62) <= merged_out_valid(2);
    --dbg_sec1_merge0(62) <= merged_out_valid(3);
    --dbg_sec1_merge1(62) <= merged_out_valid(4);
    --dbg_sec1_merge2(62) <= merged_out_valid(5);
    --dbg_sec2_merge0(62) <= merged_out_valid(6);
    --dbg_sec2_merge1(62) <= merged_out_valid(7);
    --dbg_sec2_merge2(62) <= merged_out_valid(8);

    --dbg_sec0_merge0(63) <= merged_out_roll(0);
    --dbg_sec0_merge1(63) <= merged_out_roll(1);
    --dbg_sec0_merge2(63) <= merged_out_roll(2);
    --dbg_sec1_merge0(63) <= merged_out_roll(3);
    --dbg_sec1_merge1(63) <= merged_out_roll(4);
    --dbg_sec1_merge2(63) <= merged_out_roll(5);
    --dbg_sec2_merge0(63) <= merged_out_roll(6);
    --dbg_sec2_merge1(63) <= merged_out_roll(7);
    --dbg_sec2_merge2(63) <= merged_out_roll(8);




end Behavioral;
