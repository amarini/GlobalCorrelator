library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pftm_data_types.all;
use work.pftm_constants.all;

entity regionizer_mp7_pipelined is
    generic(
        N_OBJ_SECTOR : natural;
        N_OBJ_SECTOR_ETA : natural;
        N_OBJ : natural;
        N_FIBERS_SECTOR : natural range 1 to 2 := 1;
        N_FIBERS_OBJ : natural range 1 to 2 := 2;
        SECTOR_VALID_BIT_DELAY : natural := 0
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        mp7_valid : in std_logic_vector(N_FIBERS_SECTOR*N_SECTORS-1 downto 0); -- 1 if words are valid
        mp7_in    : in  words32(N_FIBERS_SECTOR*N_SECTORS-1 downto 0); -- input particles 
        mp7_out   : out words32(N_FIBERS_OBJ*N_OBJ-1 downto 0);        -- output particles
        mp7_outv  : out std_logic_vector(N_FIBERS_OBJ*N_OBJ-1 downto 0);-- true if mp7_out contains valid data
        --debug_out   : out particles(N_OBJ-1 downto 0); 
        --debug_valid : out std_logic; 
        --spy_out   : out particles(3*N_OBJ_SECTOR_ETA-1 downto 0); 
        --spy_valid : out std_logic
        mp7_cnts  : out word32;
        mp7_bits  : out word32
    );
end regionizer_mp7_pipelined;

architecture Behavioral of regionizer_mp7_pipelined is
    type counters is array (natural range <>) of natural range 0 to N_CLOCK-1;
    ----- stuff to go from our initial state to the regionizer input
    signal read_in  : std_logic_vector(N_SECTORS-1 downto 0); -- whether we're sending data to the regionizer to be read 
    signal links_in : particles(N_SECTORS-1 downto 0); -- input particles for the regionizer
    --signal in_counter: counters(N_SECTORS-1 downto 0);   -- counter in sync with input particles for the regionizer
    signal in_first: std_logic_vector(N_SECTORS-1 downto 0);   -- counter in sync with input particles for the regionizer
    signal in_last: std_logic_vector(N_SECTORS-1 downto 0);   -- counter in sync with input particles for the regionizer
    ----- stuff to go from sector processor to muxer 
    signal region_eta_load : std_logic_vector(3*N_SECTORS-1 downto 0);
    signal region_eta_in   : particles(3*N_OBJ_SECTOR_ETA*N_SECTORS-1 downto 0);
    signal region_eta_load_delayed : std_logic_vector(3*N_SECTORS-1 downto 0);
    ----- stuff to go from muxer to sorter
    signal mux_valid:   std_logic; 
    signal mux_go:      std_logic; -- use to send outputs at half frequency
    signal mux_counter: natural range 0 to N_PHI;
    signal mux_count36: natural range 0 to N_CLOCK;
    signal mux_sector1 : particles(N_OBJ_SECTOR_ETA -1 downto 0);
    signal mux_sector2 : particles(N_OBJ_SECTOR_ETA -1 downto 0);
    signal mux_sector3 : particles(N_OBJ_SECTOR_ETA -1 downto 0);
    ----- stuff to go from out process input to our output ports
    signal links_out   : particles(N_OBJ-1 downto 0); -- input particles for the regionizer
    signal links_valid : std_logic; -- valid output from the regionizer
begin
    generate_sorters: for i in N_SECTORS-1 downto 0 generate
        input_decoder_1f: if N_FIBERS_SECTOR = 1 generate
            input_decoder: entity work.regionizer_mp7_decoder
                generic map(N_OBJ_SECTOR => N_OBJ_SECTOR)
                port map(clk => clk, rst => rst, mp7_valid => mp7_valid(i), mp7_in => mp7_in(i), --, counter_out => in_counter(i)
                         read_out => read_in(i), links_out => links_in(i), first_out => in_first(i), last_out => in_last(i));
        end generate input_decoder_1f;

        input_decoder_2f: if N_FIBERS_SECTOR = 2 generate
            input_decoder: entity work.regionizer_mp7_decoder_twofibers
                generic map(N_OBJ_SECTOR => N_OBJ_SECTOR)
                port map(clk => clk, rst => rst, mp7_valid => mp7_valid(2*i+1 downto 2*i), mp7_in => mp7_in(2*i+1 downto 2*i), --, counter_out => in_counter(i)
                         read_out => read_in(i), links_out => links_in(i), first_out => in_first(i), last_out => in_last(i));
        end generate input_decoder_2f;

        sort1 : entity work.sector_processor
            generic map(N_OBJ_SECTOR => N_OBJ_SECTOR, N_OBJ_SECTOR_ETA => N_OBJ_SECTOR_ETA, MAX_COUNT => N_FIBERS_SECTOR*N_IN_CLOCK, etaMin => to_etaphi(-342), etaMax => to_etaphi(-57), etaShift => to_etaphi(171) ) --counter_in => in_counter(i), 
            port map(clk => clk, rst => rst, first_in => in_first(i), last_in => in_last(i), read_in => read_in(i), data_in => links_in(i), 
                      data_out => region_eta_in((i+1)*N_OBJ_SECTOR_ETA-1 downto (i)*N_OBJ_SECTOR_ETA), valid_out => region_eta_load(i));
        sort2 : entity work.sector_processor
            generic map(N_OBJ_SECTOR => N_OBJ_SECTOR, N_OBJ_SECTOR_ETA => N_OBJ_SECTOR_ETA, MAX_COUNT => N_FIBERS_SECTOR*N_IN_CLOCK, etaMin => to_etaphi(-171), etaMax => to_etaphi(+171), etaShift => to_etaphi(0) )
            port map(clk => clk, rst => rst, first_in => in_first(i), last_in => in_last(i), read_in => read_in(i), data_in => links_in(i), 
                      data_out => region_eta_in((i+N_SECTORS+1)*N_OBJ_SECTOR_ETA-1 downto (i+N_SECTORS)*N_OBJ_SECTOR_ETA), valid_out => region_eta_load(i+N_SECTORS));
        sort3 : entity work.sector_processor
            generic map(N_OBJ_SECTOR => N_OBJ_SECTOR, N_OBJ_SECTOR_ETA => N_OBJ_SECTOR_ETA, MAX_COUNT => N_FIBERS_SECTOR*N_IN_CLOCK, etaMin => to_etaphi(+57), etaMax => to_etaphi(+342), etaShift => to_etaphi(-171) )
            port map(clk => clk, rst => rst, first_in => in_first(i), last_in => in_last(i), read_in => read_in(i), data_in => links_in(i), 
                      data_out => region_eta_in((i+2*N_SECTORS+1)*N_OBJ_SECTOR_ETA-1 downto (i+2*N_SECTORS)*N_OBJ_SECTOR_ETA), valid_out => region_eta_load(i+2*N_SECTORS));
    end generate generate_sorters;

    gen_sector_valid_bit_delay: if SECTOR_VALID_BIT_DELAY > 0 generate
        sector_valid_bit_delayer : entity work.delay_line
            generic map(N_BITS => 3*N_SECTORS, DELAY => SECTOR_VALID_BIT_DELAY)
            port map(clk => clk, rst => rst, d => region_eta_load, q => region_eta_load_delayed);
            assert SECTOR_VALID_BIT_DELAY + N_OBJ_SECTOR*2/N_FIBERS_SECTOR + (N_FIBERS_SECTOR-1) < N_CLOCK 
                report "Too long delay on the sector valid bit, data will be corrupted by incoming frames"
                severity failure;
    end generate;
    gen_sector_valid_bit_nodelay: if SECTOR_VALID_BIT_DELAY = 0 generate
        region_eta_load_delayed <= region_eta_load;
    end generate;

    mux: entity work.trisector_muxer
            generic map(N_OBJ_SECTOR_ETA => N_OBJ_SECTOR_ETA)
            port map(clk => clk, rst => rst, region_eta_load => region_eta_load_delayed, region_eta_in => region_eta_in,
                     out_valid => mux_valid, out_go => mux_go, out_counter => mux_counter, out_count36 => mux_count36,
                     out_sector1 => mux_sector1, out_sector2 => mux_sector2, out_sector3 => mux_sector3); 

    merger : entity work.pipelined_merger
            generic map(N_OBJ_SECTOR_ETA => N_OBJ_SECTOR_ETA, N_OBJ => N_OBJ)
            port map(clk => clk, rst => rst, valid_in => mux_valid, go => mux_go, 
                     list1_in => mux_sector1, list2_in => mux_sector2, list3_in => mux_sector3,
                     list_out => links_out, valid_out => links_valid); --, spy_out => spy_out, spy_valid => spy_valid); 

    encoder_output_2f : if N_FIBERS_OBJ = 2 generate
      encode_output: entity work.regionizer_mp7_encoder
          generic map(N_OBJ => N_OBJ)
          port map(clk => clk, rst => rst, particles_in => links_out, particles_valid => links_valid, mp7_out => mp7_out, mp7_outv => mp7_outv);
    end generate encoder_output_2f;

    encoder_output_1f : if N_FIBERS_OBJ = 1 generate
      encode_output: entity work.regionizer_mp7_encoder_twoframes
          generic map(N_OBJ => N_OBJ)
          port map(clk => clk, rst => rst, particles_in => links_out, particles_valid => links_valid, mp7_out => mp7_out, mp7_outv => mp7_outv);
    end generate encoder_output_1f;
 
    process_output: process(clk)
    begin
        if rising_edge(clk) then
            mp7_cnts(15 downto  0) <= std_logic_vector(to_unsigned(mux_counter, 16));
            mp7_cnts(31 downto 16) <= std_logic_vector(to_unsigned(mux_count36, 16));
            mp7_bits <= (0 => mux_valid, 4=> mux_go, others => '0');
        end if;
    end process;

    --debug_out <= links_out;
    --debug_valid <= links_valid;
end Behavioral;
        

