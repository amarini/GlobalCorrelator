library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity calo_regionizer_nomerge is
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
            --
            tracks_out : OUT particles(NCALOSECTORS*NCALOFIFOS-1 downto 0);
            tracks_out_valid : OUT std_logic_vector(NCALOSECTORS*NCALOFIFOS-1 downto 0);
            newevent_out : OUT std_logic 

    );
end calo_regionizer_nomerge;

architecture Behavioral of calo_regionizer_nomerge is
    constant NREGIONS  : natural := NSECTORS;
    constant NALLFIFOS : natural := NCALOSECTORS*NCALOFIFOS;

    signal links_in :       particles(NCALOSECTORS*NCALOFIBERS-1 downto 0);
    signal fifo_in :        particles(NALLFIFOS-1 downto 0);
    signal fifo_in_write :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_in_roll  :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');

    signal fifo_out :         particles(NALLFIFOS-1 downto 0);
    signal fifo_out_valid :   std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    --signal fifo_out_full:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_out_roll:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
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
                                 full  => '0',
                                 roll_out  => fifo_out_roll(ireg)
                             );
        end generate gen_fifos;

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

    tracks_out <= fifo_out;
    tracks_out_valid <= fifo_out_valid;
    newevent_out <= fifo_out_roll(0);


end Behavioral;
