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
            newevent_out : OUT STD_LOGIC;
            newevent_out_ap_vld : OUT STD_LOGIC 
    );
end regionizer_m2;

architecture Behavioral of regionizer_m2 is
    constant NREGIONS  : natural := NSECTORS*(NFIFOS/2);
    constant NALLFIFOS : natural := NSECTORS*NFIFOS;

    signal links_in :       particles(NSECTORS*NFIBERS-1 downto 0);
    signal fifo_in :        particles(NALLFIFOS-1 downto 0);
    signal fifo_in_write :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_in_roll  :  std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');

    signal fifo_out :         particles(NALLFIFOS-1 downto 0);
    signal fifo_out_valid :   std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_out_full:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');
    signal fifo_out_roll:     std_logic_vector(NALLFIFOS-1 downto 0) := (others => '0');

    signal merged_out :        particles(NREGIONS-1 downto 0);
    signal merged_out_valid :  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal merged_out_roll:    std_logic_vector(NREGIONS-1 downto 0) := (others => '0');

    signal regions_out :      particles(NREGIONS-1 downto 0);
    signal regions_out_valid: std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal regions_out_roll:  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');

begin

    gen_fifos: for ireg in NALLFIFOS-1 downto 0 generate
        reg_buffer : entity work.rolling_fifo
                        --generic map(FIFO_INDEX => ireg+1)
                        port map(ap_clk => ap_clk, 
                                 d_in    => fifo_in(ireg),
                                 write_in  => fifo_in_write(ireg),
                                 roll   => fifo_in_roll(ireg),
                                 d_out    => fifo_out(ireg),
                                 valid_out  => fifo_out_valid(ireg),
                                 full  => fifo_out_full(ireg),
                                 roll_out  => fifo_out_roll(ireg)
                             );
        end generate gen_fifos;

    gen_mergers: for imerge in NREGIONS-1 downto 0 generate
        reg_buffer : entity work.fifo_merge2
                        generic map(FIFO_INDEX => imerge+1)
                        port map(ap_clk => ap_clk, 
                                 d1_in => fifo_out(imerge*2),
                                 d2_in => fifo_out(imerge*2+1),
                                 d1_valid => fifo_out_valid(imerge*2),
                                 d2_valid => fifo_out_valid(imerge*2+1),
                                 roll     => fifo_out_roll(imerge*2),
                                 --out_full => '0',
                                 d_out      => merged_out(imerge),
                                 valid_out  => merged_out_valid(imerge),
                                 full1      => fifo_out_full(imerge*2),  
                                 full2      => fifo_out_full(imerge*2+1),
                                 roll_out   => merged_out_roll(imerge)
                            );


        end generate gen_mergers;
   
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

    newevent_out <= regions_out_roll(0);

end Behavioral;
