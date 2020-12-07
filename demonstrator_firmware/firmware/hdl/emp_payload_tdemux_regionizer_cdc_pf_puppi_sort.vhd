library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.regionizer_data.all;

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
        constant N_DELAY_IN  : natural := 5;
        constant N_DELAY_OUT : natural := 8;

        constant NPATTERNS_TK_IN   : natural := NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS;
        constant NPATTERNS_CALO_IN : natural := NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS;
        constant NPATTERNS_MU_IN   : natural := TDEMUX_FACTOR*TDEMUX_NMUFIBERS;
        constant N_IN    : natural := NPATTERNS_TK_IN + NPATTERNS_CALO_IN + NPATTERNS_MU_IN + 1;
        constant IPATTERN_TK_START : natural := 0;
        constant IPATTERN_TK_END   : natural := NPATTERNS_TK_IN-1;
        constant IPATTERN_CALO_START : natural := NPATTERNS_TK_IN;
        constant IPATTERN_CALO_END   : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN-1;
        constant IPATTERN_MU_START : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN;
        constant IPATTERN_MU_END   : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN+NPATTERNS_MU_IN-1;
        constant IPATTERN_PV       : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN+NPATTERNS_MU_IN;

        constant NPFSTREAM360    : natural := (NPFTOT+PFII-1)/PFII;
        constant NPUPPISTREAM360 : natural := (NPUPPIFINALSORTED+PFII-1)/PFII;

        constant N_OUT_REG   : natural := NTKSTREAM + NCALOSTREAM + NMUSTREAM;
        constant N_OUT_PF    : natural := NPFSTREAM360;
        constant N_OUT_PUPPI : natural := NPUPPISTREAM360;
        constant LINK0_PF    : natural := N_OUT_REG;
        constant LINK0_PUPPI : natural := N_OUT_REG + N_OUT_PF;
        constant N_OUT : natural := N_OUT_REG + N_OUT_PF + N_OUT_PUPPI;
       
        constant RST_CHAIN_DELAY : natural := 6;
        signal rst240, rst240_u : std_logic := '0';
        signal rst240_chain : std_logic_vector(RST_CHAIN_DELAY downto 0):= (others => '0');
        attribute ASYNC_REG : string;
        attribute ASYNC_REG of rst240_u : signal is "TRUE";
        attribute KEEP : string;
        attribute KEEP of rst240_chain : signal is "TRUE";
        attribute SHREG_EXTRACT : string;
        attribute SHREG_EXTRACT of rst240_chain : signal is "FALSE";

        signal links_in:  w64s(4*N_REGION-1 downto 0) := (others => (others => '0'));
        signal valid_in: std_logic_vector(4*N_REGION-1 downto 0) := (others => '0');

        signal tk_links_in : w64s(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS-1 downto 0);
        signal tk_valid_in : STD_LOGIC_VECTOR(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS-1 downto 0);
        signal calo_links_in : w64s(NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS-1 downto 0);
        signal calo_valid_in : STD_LOGIC_VECTOR(NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS-1 downto 0);
        signal mu_links_in : w64s(TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0);
        signal mu_valid_in : STD_LOGIC_VECTOR(TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0);
        signal vtx_link_in : word64;
        signal vtx_valid_in : STD_LOGIC;


        -- Regionizer: 360 MHz stuff
        signal regionizer_out: w64s(NTKSTREAM+NCALOSTREAM+NMUSTREAM-1 downto 0);
        signal regionizer_done, regionizer_valid : STD_LOGIC := '0';

        -- PF: 360 MHz stuff
        signal pf_out: w64s(NPFTOT - 1 downto 0);
        signal pf_start, pf_read, pf_valid, pf_done : STD_LOGIC;
        signal pf_empty : STD_LOGIC_VECTOR(NPFSTREAM-1 downto 0);
        signal pf_out_stream: w64s(NPFSTREAM360 - 1 downto 0);
        signal pf_valid_stream: STD_LOGIC_VECTOR(NPFSTREAM360 - 1 downto 0);


        -- Puppi: 360 MHz stuff
        signal puppi_out  : w64s(NPUPPIFINALSORTED - 1 downto 0);
        signal puppi_start, puppi_read, puppi_done, puppi_valid : STD_LOGIC;
        signal puppi_empty : STD_LOGIC_VECTOR(NTKSTREAM+NCALOSTREAM-1 downto 0);
        signal puppi_out_stream: w64s(NPUPPISTREAM360 - 1 downto 0);
        signal puppi_valid_stream: STD_LOGIC_VECTOR(NPUPPISTREAM360 - 1 downto 0);

begin

    ipb_out <= IPB_RBUS_NULL;

    export_rst240: process(clk_payload(0))
    begin
        if rising_edge(clk_payload(0)) then
            rst240_u <= rst_loc(0);
            rst240_chain(RST_CHAIN_DELAY) <= rst240_u;
            rst240_chain(RST_CHAIN_DELAY-1 downto 0) <= rst240_chain(RST_CHAIN_DELAY downto 1);
            rst240 <= rst240_chain(0);
        end if;
    end process export_rst240;


    algo_payload : entity work.tdemux_regionizer_cdc_pf_puppi_sort
        port map(clk => clk_p, clk240 => clk_payload(0), 
                 rst => '0', --rst_loc(0), 
                 rst240 => '0', --rst240, 

                 tk_links_in => tk_links_in,
                 tk_valid_in => tk_valid_in,
                 calo_links_in => calo_links_in,
                 calo_valid_in => calo_valid_in,
                 mu_links_in => mu_links_in,
                 mu_valid_in => mu_valid_in,
                 vtx_link_in => vtx_link_in,
                 vtx_valid_in => vtx_valid_in,

                 regionizer_out => regionizer_out,
                 regionizer_done => regionizer_done,
                 regionizer_valid => regionizer_valid,

                 pf_out => pf_out,
                 pf_start => pf_start,
                 pf_read => pf_read,
                 pf_done => pf_done,
                 pf_valid => pf_valid,
                 pf_empty => pf_empty,

                 puppi_out => puppi_out,
                 puppi_start => puppi_start,
                 puppi_read => puppi_read,
                 puppi_done => puppi_done,
                 puppi_valid => puppi_valid,
                 puppi_empty => puppi_empty
             );

    buffers_in: for i in 0 to 4*N_REGION-1 generate 
        -- we generate for all, and assume the unneded ones get killed
        skip_unnecessary: if (i < 4*4) or (4*9-1 < i and i < 4*17) or (4*24-1 < i and i < 4*27+3) generate
            buff_in : entity work.word_delay
                generic map(DELAY => N_DELAY_IN, N_BITS => 65)
                port    map(clk => clk_p, enable => '1',
                            d(63 downto 0) => d(i).data,
                            d(64)          => d(i).valid,
                            q(63 downto 0) => links_in(i),
                            q(64)          => valid_in(i));
        end generate skip_unnecessary;
    end generate buffers_in;

    input_link_map: process(clk_p)
    begin
        if rising_edge(clk_p) then
            -- region 0 fibers 1-3 mapped to muons --
            mu_links_in(2 downto 0) <= links_in(2 downto 0);
            mu_valid_in(2 downto 0) <= valid_in(2 downto 0);
            -- region 0 fiber 4 mapped to PV
            vtx_link_in  <= links_in(3);
            vtx_valid_in <= valid_in(3);
            -- regions 1-3 + 24-27 = 28 fibers mapped to tracker (3x9 fibers)
            tk_links_in(11 downto  0) <= links_in(4* 4-1 downto 4* 1); -- 12 links (4 sectors)
            tk_valid_in(11 downto  0) <= valid_in(4* 4-1 downto 4* 1); 
            tk_links_in(26 downto 12) <= links_in(4*27+2 downto 4*24); -- 15 links (5 sectors)
            tk_valid_in(26 downto 12) <= valid_in(4*27+2 downto 4*24);
            -- regions 9-17 = 36 fibers mapped to HGCal
            calo_links_in(NPATTERNS_CALO_IN-1 downto 0) <= links_in(4*17+3 downto 4*9);
            calo_valid_in(NPATTERNS_CALO_IN-1 downto 0) <= valid_in(4*17+3 downto 4*9);
        end if;
    end process input_link_map;

    buffers_reg_out: for i in 0 to N_OUT_REG-1 generate
        buff_reg_out : entity work.word_delay
            generic map(DELAY => N_DELAY_OUT, N_BITS => 65)
            port    map(clk => clk_p, enable => '1',
                        d(63 downto 0) => regionizer_out(i),
                        d(64)          => regionizer_valid,
                        q(63 downto 0) => q(i).data,
                        q(64)          => q(i).valid);
    end generate buffers_reg_out;

    tie_reg_strobe: for i in 0 to N_OUT_REG-1 generate 
        q(i).strobe <= '1';
    end generate;

    -- pf & puppi have to be serialized
    pf_streamer : entity work.parallel2serial
                generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM360)
                port map( ap_clk => clk_p,
                          roll   => pf_done,
                          data_in  => pf_out,
                          valid_in => (others => '1'),
                          data_out  => pf_out_stream,
                          valid_out => pf_valid_stream,
                          roll_out  => open);

    buffers_pf_out: for i in 0 to NPFSTREAM360-1 generate
        buff_pf_out : entity work.word_delay
            generic map(DELAY => N_DELAY_OUT, N_BITS => 65)
            port    map(clk => clk_p, enable => '1',
                        d(63 downto 0) => pf_out_stream(i),
                        d(64)          => pf_valid_stream(i),
                        q(63 downto 0) => q(LINK0_PF+i).data,
                        q(64)          => q(LINK0_PF+i).valid);
        end generate buffers_pf_out;

    tie_pf_strobe: for i in 0 to NPFSTREAM360-1 generate 
        q(LINK0_PF+i).strobe <= '1';
    end generate;

    puppi_streamer : entity work.parallel2serial
                generic map(NITEMS => NPUPPIFINALSORTED, NSTREAM => NPUPPISTREAM360)
                port map( ap_clk => clk_p,
                          roll   => puppi_done,
                          data_in  => puppi_out,
                          valid_in => (others => '1'),
                          data_out  => puppi_out_stream,
                          valid_out => puppi_valid_stream,
                          roll_out  => open);
    buffers_puppi_out: for i in 0 to NPUPPISTREAM360-1 generate
        buff_puppi_out : entity work.word_delay
            generic map(DELAY => N_DELAY_OUT, N_BITS => 65)
            port    map(clk => clk_p, enable => '1',
                        d(63 downto 0) => puppi_out_stream(i),
                        d(64)          => puppi_valid_stream(i),
                        q(63 downto 0) => q(LINK0_PUPPI+i).data,
                        q(64)          => q(LINK0_PUPPI+i).valid);
        end generate buffers_puppi_out;

    tie_puppi_strobe: for i in 0 to NPUPPISTREAM360-1 generate 
        q(LINK0_PUPPI+i).strobe <= '1';
    end generate;
    
    zerofill:	
        process(clk_p) 
        begin
            if rising_edge(clk_p) then
                for i in 4 * N_REGION - 1 downto N_OUT loop
                    q(i).data <= (others => '0');
                    q(i).valid <= '0';
                    q(i).strobe <= '1';
                end loop;
            end if;
        end process zerofill;

    
    bc0 <= '0';
    
    gpio <= (others => '0');
    gpio_en <= (others => '0');

end rtl;
