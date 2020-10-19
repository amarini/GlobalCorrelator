library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity regionizer_mux is
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
            tracks_out : OUT particles(NSTREAM-1 downto 0);
            tracks_out_valid : OUT std_logic_vector(NSTREAM-1 downto 0);
            newevent_out : OUT STD_LOGIC
    );
end regionizer_mux;

architecture Behavioral of regionizer_mux is
    constant NREGIONS  : natural := NSECTORS;
    constant NALLFIFOS : natural := NSECTORS*NFIFOS;
    constant NMERGE2   : natural := NSECTORS*(NFIFOS/2);

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

    signal merged2_out :        particles(NMERGE2-1 downto 0);
    signal merged2_out_valid :  std_logic_vector(NMERGE2-1 downto 0) := (others => '0');
    signal merged2_out_roll:    std_logic_vector(NMERGE2-1 downto 0) := (others => '0');
    signal merged2_out_full:    std_logic_vector(NMERGE2-1 downto 0) := (others => '0');
    --signal merged2_dbg :        w64_vec(NMERGE2-1 downto 0);

    signal merged_out :        particles(NREGIONS-1 downto 0);
    signal merged_out_valid :  std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    signal merged_out_roll:    std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
    --signal merged_dbg :        w64_vec(NREGIONS-1 downto 0);

    signal sorted_out :        particles(NREGIONS*NSORTED-1 downto 0);
    signal sorted_out_valid :  std_logic_vector(NREGIONS*NSORTED-1 downto 0) := (others => '0');
    signal sorted_out_roll :   std_logic_vector(NREGIONS-1 downto 0) := (others => '0');
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
                                 --dbg_w64 =>  fifo_dbg(ireg),
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
                                 --dbg_w64    => merged2_dbg(imerge),
                                 roll_out   => merged2_out_roll(imerge)
                            );
        end generate gen_merger2s;

    gen_merger3s: for imerge in NREGIONS-1 downto 0 generate
        reg_merger3 : entity work.fifo_merge3
                        --generic map(FIFO_INDEX => imerge+1)
                        port map(ap_clk => ap_clk, 
                                 d1_in => merged2_out(imerge*3),
                                 d2_in => merged2_out(imerge*3+1),
                                 d3_in => merged2_out(imerge*3+2),
                                 d1_valid => merged2_out_valid(imerge*3),
                                 d2_valid => merged2_out_valid(imerge*3+1),
                                 d3_valid => merged2_out_valid(imerge*3+2),
                                 roll     => merged2_out_roll(imerge*3),
                                 d_out      => merged_out(imerge),
                                 valid_out  => merged_out_valid(imerge),
                                 full1      => merged2_out_full(imerge*3),  
                                 full2      => merged2_out_full(imerge*3+1),
                                 full3      => merged2_out_full(imerge*3+2),
                                 --dbg_w64    => merged_dbg(imerge),
                                 roll_out   => merged_out_roll(imerge)
                            );
        end generate gen_merger3s;

    gen_sorters: for isort in NREGIONS-1 downto 0 generate
        reg_sorter : entity work.stream_sort
                            generic map(NITEMS => NSORTED)
                            port map(ap_clk => ap_clk,
                                d_in => merged_out(isort),
                                valid_in => merged_out_valid(isort),
                                roll => merged_out_roll(isort),
                                d_out => sorted_out((isort+1)*NSORTED-1 downto isort*NSORTED),
                                valid_out => sorted_out_valid((isort+1)*NSORTED-1 downto isort*NSORTED),
                                roll_out => sorted_out_roll(isort)
                            );
        end generate gen_sorters;

    mux_and_stream: entity work.region_mux_stream
                            generic map(NREGIONS => NREGIONS)
                            port map(ap_clk => ap_clk,
                                roll => sorted_out_roll(0),
                                d_in => sorted_out,
                                valid_in => sorted_out_valid,
                                d_out => tracks_out,
                                valid_out => tracks_out_valid,
                                roll_out => newevent_out);

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

end Behavioral;
