library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity regionizer_nomerge is
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
            tracks_out_0_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_0_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_0_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_0_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_0_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_0_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_0_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_0_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_1_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_1_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_1_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_1_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_1_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_2_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_2_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_2_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_2_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_2_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_3_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_3_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_3_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_3_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_3_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_4_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_4_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_4_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_4_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_4_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_5_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_5_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_5_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_5_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_5_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_6_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_6_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_6_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_6_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_6_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_7_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_7_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_7_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_7_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_7_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_8_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_8_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_8_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_8_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_8_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_9_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_9_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_9_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_9_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_9_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_10_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_10_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_10_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_10_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_10_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_11_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_11_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_11_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_11_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_11_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_12_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_12_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_12_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_12_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_12_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_13_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_13_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_13_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_13_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_13_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_14_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_14_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_14_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_14_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_14_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_15_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_15_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_15_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_15_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_15_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_16_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_16_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_16_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_16_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_16_rest_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_eta_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_17_eta_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_phi_V : OUT STD_LOGIC_VECTOR (11 downto 0);
            tracks_out_17_phi_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_pt_V : OUT STD_LOGIC_VECTOR (13 downto 0);
            tracks_out_17_pt_V_ap_vld : OUT STD_LOGIC;
            tracks_out_17_rest_V : OUT STD_LOGIC_VECTOR (25 downto 0);
            tracks_out_17_rest_V_ap_vld : OUT STD_LOGIC;
            newevent_out : OUT STD_LOGIC;
            newevent_out_ap_vld : OUT STD_LOGIC 
    );
end regionizer_nomerge;

architecture Behavioral of regionizer_nomerge is
    constant NREGIONS : natural := NSECTORS*NFIFOS;

    signal links_in :       particles(NSECTORS*NFIBERS-1 downto 0);
    signal fifo_in :        particles(NREGIONS-1 downto 0);
    signal fifo_in_write :  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal fifo_in_roll  :  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');

    signal fifo_out :        particles(NREGIONS-1 downto 0);
    signal fifo_out_valid :  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal fifo_out_roll:    std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal regions_out :      particles(NREGIONS-1 downto 0);
    signal regions_out_valid: std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal regions_out_roll:  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');

begin

    gen_fifos: for ireg in NREGIONS-1 downto 0 generate
        reg_buffer : entity work.rolling_fifo
                        port map(ap_clk => ap_clk, 
                                 d_in    => fifo_in(ireg),
                                 write_in  => fifo_in_write(ireg),
                                 roll   => fifo_in_roll(ireg),
                                 d_out    => fifo_out(ireg),
                                 valid_out  => fifo_out_valid(ireg),
                                 full  => '0',
                                 roll_out  => fifo_out_roll(ireg)
                             );
    end generate;
   
    links_in(0).pt <= unsigned(tracks_in_0_0_pt_V);
    links_in(1).pt <= unsigned(tracks_in_0_1_pt_V);
    links_in(2).pt <= unsigned(tracks_in_1_0_pt_V);
    links_in(3).pt <= unsigned(tracks_in_1_1_pt_V);
    links_in(4).pt <= unsigned(tracks_in_2_0_pt_V);
    links_in(5).pt <= unsigned(tracks_in_2_1_pt_V);
    links_in(0).eta <= signed(tracks_in_0_0_eta_V);
    links_in(1).eta <= signed(tracks_in_0_1_eta_V);
    links_in(2).eta <= signed(tracks_in_1_0_eta_V);
    links_in(3).eta <= signed(tracks_in_1_1_eta_V);
    links_in(4).eta <= signed(tracks_in_2_0_eta_V);
    links_in(5).eta <= signed(tracks_in_2_1_eta_V);
    links_in(0).phi <= signed(tracks_in_0_0_phi_V);
    links_in(1).phi <= signed(tracks_in_0_1_phi_V);
    links_in(2).phi <= signed(tracks_in_1_0_phi_V);
    links_in(3).phi <= signed(tracks_in_1_1_phi_V);
    links_in(4).phi <= signed(tracks_in_2_0_phi_V);
    links_in(5).phi <= signed(tracks_in_2_1_phi_V);
    links_in(0).rest <= unsigned(tracks_in_0_0_rest_V);
    links_in(1).rest <= unsigned(tracks_in_0_1_rest_V);
    links_in(2).rest <= unsigned(tracks_in_1_0_rest_V);
    links_in(3).rest <= unsigned(tracks_in_1_1_rest_V);
    links_in(4).rest <= unsigned(tracks_in_2_0_rest_V);
    links_in(5).rest <= unsigned(tracks_in_2_1_rest_V);

    link2fifo : process(ap_clk)
        constant PHI_SHIFT : signed(11 downto 0) := to_signed(200, 12);
        variable isec_next, isec_prev : integer range 0 to NSECTORS-1;
        variable link_this, link_next, link_prev : std_logic;
    begin
        if rising_edge(ap_clk) then
            for isec in 0 to NSECTORS-1 loop
                if isec = 0 then
                    isec_next := isec + 1;
                    isec_prev := NSECTORS-1;
                elsif isec = NSECTORS-1 then
                    isec_next := 0;
                    isec_prev := isec - 1;
                else
                    isec_next := isec + 1;
                    isec_prev := isec - 1;
                end if;
                for ifib in 0 to NFIBERS-1 loop
                    if ap_start = '0' or links_in(isec*NFIBERS+ifib).pt = 0 then
                        link_this := '0';
                        link_prev := '0';
                        link_next := '0';
                    else
                        link_this := '1';
                        if links_in(isec*NFIBERS+ifib).phi > 0 then
                            link_prev := '0';
                            link_next := '1';
                        elsif links_in(isec*NFIBERS+ifib).phi < 0 then
                            link_prev := '1';
                            link_next := '0';
                        else
                            link_prev := '0';
                            link_next := '0';
                        end if;
                    end if;
                    fifo_in(isec     *NFIFOS+ifib  ) <= links_in(isec*NFIBERS+ifib);
                    fifo_in(isec_next*NFIFOS+ifib+2).pt   <= links_in(isec*NFIBERS+ifib).pt;
                    fifo_in(isec_next*NFIFOS+ifib+2).eta  <= links_in(isec*NFIBERS+ifib).eta;
                    fifo_in(isec_next*NFIFOS+ifib+2).phi  <= links_in(isec*NFIBERS+ifib).phi - PHI_SHIFT;
                    fifo_in(isec_next*NFIFOS+ifib+2).rest <= links_in(isec*NFIBERS+ifib).rest;
                    fifo_in(isec_prev*NFIFOS+ifib+4).pt   <= links_in(isec*NFIBERS+ifib).pt;
                    fifo_in(isec_prev*NFIFOS+ifib+4).eta  <= links_in(isec*NFIBERS+ifib).eta;
                    fifo_in(isec_prev*NFIFOS+ifib+4).phi  <= links_in(isec*NFIBERS+ifib).phi + PHI_SHIFT;
                    fifo_in(isec_prev*NFIFOS+ifib+4).rest <= links_in(isec*NFIBERS+ifib).rest;
                    fifo_in_write(isec     *NFIFOS+ifib  ) <= link_this;
                    fifo_in_write(isec_next*NFIFOS+ifib+2) <= link_next;
                    fifo_in_write(isec_prev*NFIFOS+ifib+4) <= link_prev;
                    fifo_in_roll(isec     *NFIFOS+ifib  ) <= newevent;
                    fifo_in_roll(isec_next*NFIFOS+ifib+2) <= newevent;
                    fifo_in_roll(isec_prev*NFIFOS+ifib+4) <= newevent;
                end loop;
            end loop;
        end if;
    end process link2fifo;

    fifo2regions : process(ap_clk)
    begin
        if rising_edge(ap_clk) then
            for ireg in 0 to NREGIONS-1 loop
                if fifo_out_valid(ireg) = '1' then
                    regions_out(ireg) <= fifo_out(ireg);
                    regions_out_valid(ireg) <= '1';
                else
                    regions_out(ireg).pt   <= (others => '0');
                    regions_out(ireg).eta  <= (others => '0');
                    regions_out(ireg).phi  <= (others => '0');
                    regions_out(ireg).rest <= (others => '0');
                    regions_out_valid(ireg) <= '1';
                end if;
                regions_out_roll(ireg) <= fifo_out_roll(ireg);
            end loop;
        end if;
    end process fifo2regions;

    tracks_out_0_pt_V <= std_logic_vector(regions_out(0).pt);
    tracks_out_0_pt_V_ap_vld <= regions_out_valid(0);
    tracks_out_0_eta_V <= std_logic_vector(regions_out(0).eta);
    tracks_out_0_eta_V_ap_vld <= regions_out_valid(0);
    tracks_out_0_phi_V <= std_logic_vector(regions_out(0).phi);
    tracks_out_0_phi_V_ap_vld <= regions_out_valid(0);
    tracks_out_0_rest_V <= std_logic_vector(regions_out(0).rest);
    tracks_out_0_rest_V_ap_vld <= regions_out_valid(0);
    tracks_out_1_pt_V <= std_logic_vector(regions_out(1).pt);
    tracks_out_1_pt_V_ap_vld <= regions_out_valid(1);
    tracks_out_1_eta_V <= std_logic_vector(regions_out(1).eta);
    tracks_out_1_eta_V_ap_vld <= regions_out_valid(1);
    tracks_out_1_phi_V <= std_logic_vector(regions_out(1).phi);
    tracks_out_1_phi_V_ap_vld <= regions_out_valid(1);
    tracks_out_1_rest_V <= std_logic_vector(regions_out(1).rest);
    tracks_out_1_rest_V_ap_vld <= regions_out_valid(1);
    tracks_out_2_pt_V <= std_logic_vector(regions_out(2).pt);
    tracks_out_2_pt_V_ap_vld <= regions_out_valid(2);
    tracks_out_2_eta_V <= std_logic_vector(regions_out(2).eta);
    tracks_out_2_eta_V_ap_vld <= regions_out_valid(2);
    tracks_out_2_phi_V <= std_logic_vector(regions_out(2).phi);
    tracks_out_2_phi_V_ap_vld <= regions_out_valid(2);
    tracks_out_2_rest_V <= std_logic_vector(regions_out(2).rest);
    tracks_out_2_rest_V_ap_vld <= regions_out_valid(2);
    tracks_out_3_pt_V <= std_logic_vector(regions_out(3).pt);
    tracks_out_3_pt_V_ap_vld <= regions_out_valid(3);
    tracks_out_3_eta_V <= std_logic_vector(regions_out(3).eta);
    tracks_out_3_eta_V_ap_vld <= regions_out_valid(3);
    tracks_out_3_phi_V <= std_logic_vector(regions_out(3).phi);
    tracks_out_3_phi_V_ap_vld <= regions_out_valid(3);
    tracks_out_3_rest_V <= std_logic_vector(regions_out(3).rest);
    tracks_out_3_rest_V_ap_vld <= regions_out_valid(3);
    tracks_out_4_pt_V <= std_logic_vector(regions_out(4).pt);
    tracks_out_4_pt_V_ap_vld <= regions_out_valid(4);
    tracks_out_4_eta_V <= std_logic_vector(regions_out(4).eta);
    tracks_out_4_eta_V_ap_vld <= regions_out_valid(4);
    tracks_out_4_phi_V <= std_logic_vector(regions_out(4).phi);
    tracks_out_4_phi_V_ap_vld <= regions_out_valid(4);
    tracks_out_4_rest_V <= std_logic_vector(regions_out(4).rest);
    tracks_out_4_rest_V_ap_vld <= regions_out_valid(4);
    tracks_out_5_pt_V <= std_logic_vector(regions_out(5).pt);
    tracks_out_5_pt_V_ap_vld <= regions_out_valid(5);
    tracks_out_5_eta_V <= std_logic_vector(regions_out(5).eta);
    tracks_out_5_eta_V_ap_vld <= regions_out_valid(5);
    tracks_out_5_phi_V <= std_logic_vector(regions_out(5).phi);
    tracks_out_5_phi_V_ap_vld <= regions_out_valid(5);
    tracks_out_5_rest_V <= std_logic_vector(regions_out(5).rest);
    tracks_out_5_rest_V_ap_vld <= regions_out_valid(5);
    tracks_out_6_pt_V <= std_logic_vector(regions_out(6).pt);
    tracks_out_6_pt_V_ap_vld <= regions_out_valid(6);
    tracks_out_6_eta_V <= std_logic_vector(regions_out(6).eta);
    tracks_out_6_eta_V_ap_vld <= regions_out_valid(6);
    tracks_out_6_phi_V <= std_logic_vector(regions_out(6).phi);
    tracks_out_6_phi_V_ap_vld <= regions_out_valid(6);
    tracks_out_6_rest_V <= std_logic_vector(regions_out(6).rest);
    tracks_out_6_rest_V_ap_vld <= regions_out_valid(6);
    tracks_out_7_pt_V <= std_logic_vector(regions_out(7).pt);
    tracks_out_7_pt_V_ap_vld <= regions_out_valid(7);
    tracks_out_7_eta_V <= std_logic_vector(regions_out(7).eta);
    tracks_out_7_eta_V_ap_vld <= regions_out_valid(7);
    tracks_out_7_phi_V <= std_logic_vector(regions_out(7).phi);
    tracks_out_7_phi_V_ap_vld <= regions_out_valid(7);
    tracks_out_7_rest_V <= std_logic_vector(regions_out(7).rest);
    tracks_out_7_rest_V_ap_vld <= regions_out_valid(7);
    tracks_out_8_pt_V <= std_logic_vector(regions_out(8).pt);
    tracks_out_8_pt_V_ap_vld <= regions_out_valid(8);
    tracks_out_8_eta_V <= std_logic_vector(regions_out(8).eta);
    tracks_out_8_eta_V_ap_vld <= regions_out_valid(8);
    tracks_out_8_phi_V <= std_logic_vector(regions_out(8).phi);
    tracks_out_8_phi_V_ap_vld <= regions_out_valid(8);
    tracks_out_8_rest_V <= std_logic_vector(regions_out(8).rest);
    tracks_out_8_rest_V_ap_vld <= regions_out_valid(8);
    tracks_out_9_pt_V <= std_logic_vector(regions_out(9).pt);
    tracks_out_9_pt_V_ap_vld <= regions_out_valid(9);
    tracks_out_9_eta_V <= std_logic_vector(regions_out(9).eta);
    tracks_out_9_eta_V_ap_vld <= regions_out_valid(9);
    tracks_out_9_phi_V <= std_logic_vector(regions_out(9).phi);
    tracks_out_9_phi_V_ap_vld <= regions_out_valid(9);
    tracks_out_9_rest_V <= std_logic_vector(regions_out(9).rest);
    tracks_out_9_rest_V_ap_vld <= regions_out_valid(9);
    tracks_out_10_pt_V <= std_logic_vector(regions_out(10).pt);
    tracks_out_10_pt_V_ap_vld <= regions_out_valid(10);
    tracks_out_10_eta_V <= std_logic_vector(regions_out(10).eta);
    tracks_out_10_eta_V_ap_vld <= regions_out_valid(10);
    tracks_out_10_phi_V <= std_logic_vector(regions_out(10).phi);
    tracks_out_10_phi_V_ap_vld <= regions_out_valid(10);
    tracks_out_10_rest_V <= std_logic_vector(regions_out(10).rest);
    tracks_out_10_rest_V_ap_vld <= regions_out_valid(10);
    tracks_out_11_pt_V <= std_logic_vector(regions_out(11).pt);
    tracks_out_11_pt_V_ap_vld <= regions_out_valid(11);
    tracks_out_11_eta_V <= std_logic_vector(regions_out(11).eta);
    tracks_out_11_eta_V_ap_vld <= regions_out_valid(11);
    tracks_out_11_phi_V <= std_logic_vector(regions_out(11).phi);
    tracks_out_11_phi_V_ap_vld <= regions_out_valid(11);
    tracks_out_11_rest_V <= std_logic_vector(regions_out(11).rest);
    tracks_out_11_rest_V_ap_vld <= regions_out_valid(11);
    tracks_out_12_pt_V <= std_logic_vector(regions_out(12).pt);
    tracks_out_12_pt_V_ap_vld <= regions_out_valid(12);
    tracks_out_12_eta_V <= std_logic_vector(regions_out(12).eta);
    tracks_out_12_eta_V_ap_vld <= regions_out_valid(12);
    tracks_out_12_phi_V <= std_logic_vector(regions_out(12).phi);
    tracks_out_12_phi_V_ap_vld <= regions_out_valid(12);
    tracks_out_12_rest_V <= std_logic_vector(regions_out(12).rest);
    tracks_out_12_rest_V_ap_vld <= regions_out_valid(12);
    tracks_out_13_pt_V <= std_logic_vector(regions_out(13).pt);
    tracks_out_13_pt_V_ap_vld <= regions_out_valid(13);
    tracks_out_13_eta_V <= std_logic_vector(regions_out(13).eta);
    tracks_out_13_eta_V_ap_vld <= regions_out_valid(13);
    tracks_out_13_phi_V <= std_logic_vector(regions_out(13).phi);
    tracks_out_13_phi_V_ap_vld <= regions_out_valid(13);
    tracks_out_13_rest_V <= std_logic_vector(regions_out(13).rest);
    tracks_out_13_rest_V_ap_vld <= regions_out_valid(13);
    tracks_out_14_pt_V <= std_logic_vector(regions_out(14).pt);
    tracks_out_14_pt_V_ap_vld <= regions_out_valid(14);
    tracks_out_14_eta_V <= std_logic_vector(regions_out(14).eta);
    tracks_out_14_eta_V_ap_vld <= regions_out_valid(14);
    tracks_out_14_phi_V <= std_logic_vector(regions_out(14).phi);
    tracks_out_14_phi_V_ap_vld <= regions_out_valid(14);
    tracks_out_14_rest_V <= std_logic_vector(regions_out(14).rest);
    tracks_out_14_rest_V_ap_vld <= regions_out_valid(14);
    tracks_out_15_pt_V <= std_logic_vector(regions_out(15).pt);
    tracks_out_15_pt_V_ap_vld <= regions_out_valid(15);
    tracks_out_15_eta_V <= std_logic_vector(regions_out(15).eta);
    tracks_out_15_eta_V_ap_vld <= regions_out_valid(15);
    tracks_out_15_phi_V <= std_logic_vector(regions_out(15).phi);
    tracks_out_15_phi_V_ap_vld <= regions_out_valid(15);
    tracks_out_15_rest_V <= std_logic_vector(regions_out(15).rest);
    tracks_out_15_rest_V_ap_vld <= regions_out_valid(15);
    tracks_out_16_pt_V <= std_logic_vector(regions_out(16).pt);
    tracks_out_16_pt_V_ap_vld <= regions_out_valid(16);
    tracks_out_16_eta_V <= std_logic_vector(regions_out(16).eta);
    tracks_out_16_eta_V_ap_vld <= regions_out_valid(16);
    tracks_out_16_phi_V <= std_logic_vector(regions_out(16).phi);
    tracks_out_16_phi_V_ap_vld <= regions_out_valid(16);
    tracks_out_16_rest_V <= std_logic_vector(regions_out(16).rest);
    tracks_out_16_rest_V_ap_vld <= regions_out_valid(16);
    tracks_out_17_pt_V <= std_logic_vector(regions_out(17).pt);
    tracks_out_17_pt_V_ap_vld <= regions_out_valid(17);
    tracks_out_17_eta_V <= std_logic_vector(regions_out(17).eta);
    tracks_out_17_eta_V_ap_vld <= regions_out_valid(17);
    tracks_out_17_phi_V <= std_logic_vector(regions_out(17).phi);
    tracks_out_17_phi_V_ap_vld <= regions_out_valid(17);
    tracks_out_17_rest_V <= std_logic_vector(regions_out(17).rest);
    tracks_out_17_rest_V_ap_vld <= regions_out_valid(17);

    newevent_out <= regions_out_roll(0);

end Behavioral;
