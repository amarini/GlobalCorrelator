-- Wrapper for HLS block that runs at 240 MHz
-- Use FIFOs 
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

library unisim;
use unisim.vcomponents.all;

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

        constant NLINKS_IN  : integer := 3;
        constant NLINKS_OUT : integer := 3;
        constant TMUX       : integer := 6;
        constant NCLK       : integer := 6;

        constant USED_FIBERS : integer := NLINKS_OUT+1;

        constant FRAME_LENGTH_F : integer := TMUX*CLOCK_RATIO;
        constant FRAME_LENGTH_S : integer := TMUX*NCLK;

        component dummy_simple_0 is 
            port (
                ap_clk : IN STD_LOGIC;
                ap_rst : IN STD_LOGIC;
                ap_start : IN STD_LOGIC;
                ap_done : OUT STD_LOGIC;
                ap_idle : OUT STD_LOGIC;
                ap_ready : OUT STD_LOGIC;
                newevent : IN STD_LOGIC;
                links_0_V : IN STD_LOGIC_VECTOR (63 downto 0);
                links_1_V : IN STD_LOGIC_VECTOR (63 downto 0);
                links_2_V : IN STD_LOGIC_VECTOR (63 downto 0);
                out_0_V : OUT STD_LOGIC_VECTOR (63 downto 0);
                out_0_V_ap_vld : OUT STD_LOGIC;
                out_1_V : OUT STD_LOGIC_VECTOR (63 downto 0);
                out_1_V_ap_vld : OUT STD_LOGIC;
                out_2_V : OUT STD_LOGIC_VECTOR (63 downto 0);
                out_2_V_ap_vld : OUT STD_LOGIC
              );
        end component;

        
        signal copy_in   : ldata(4 * N_REGION - 1 downto USED_FIBERS);
        signal copy_out  : ldata(4 * N_REGION - 1 downto USED_FIBERS);
        signal buff_in_f  : ldata(0 to NLINKS_IN-1);
        signal buff_in_s  : ldata(0 to NLINKS_IN-1);
        signal buff_out_f : ldata(0 to NLINKS_OUT-1);
        signal buff_out_s : ldata(0 to NLINKS_OUT-1);
        signal counter   : natural range 0 to FRAME_LENGTH_F;
        signal old_valid, new_event : std_logic := '0';
        signal hls_ip_rst : std_logic := '1';
        signal hls_ip_en : std_logic := '0';
        signal fifo_write_f, fifo_reset_f, fifo_rderr_s : std_logic_vector(0 to NLINKS_IN-1);
        signal fifo_write_s, fifo_reset_s, fifo_rderr_f : std_logic_vector(0 to NLINKS_OUT-1);

begin

	ipb_out <= IPB_RBUS_NULL;

        global_init_counter:  process(clk_p)
            begin
                if rising_edge(clk_p) then
                    if d(0).valid = '1' then
                        if (old_valid = '0') or (counter = FRAME_LENGTH_F) then
                            counter <= 0;
                            new_event <= '1';
                            for i in NLINKS_IN-1 downto 0 loop
                                fifo_reset_f(i) <= '0';
                                fifo_write_f(i) <= '1';
                            end loop;
                        else
                            counter <= counter + 1;
                            new_event <= '0';
                            for i in NLINKS_IN-1 downto 0 loop
                                fifo_reset_f(i) <= '0';
                                if counter < (FRAME_LENGTH_S) then
                                    fifo_write_f(i) <= '1';
                                else
                                    fifo_write_f(i) <= '0';
                                end if;
                            end loop;
                        end if;
                    else
                        counter <= 0;
                        new_event <= '0';
                        for i in NLINKS_IN-1 downto 0 loop
                            fifo_reset_f(i) <= '1';
                            fifo_write_f(i) <= '0';
                        end loop;
                    end if;
                    old_valid <= d(0).valid;
                end if;
            end process global_init_counter;

        input_f: process(clk_p)
            begin
                if rising_edge(clk_p) then
                    for i in NLINKS_IN-1 downto 0 loop
                        buff_in_f(i).data <= d(i).data;
                        buff_in_f(i).valid  <= d(i).valid;
                    end loop;
                end if;
            end process input_f;


        gen_fifos_f2s: for i in 0 to NLINKS_IN-1 generate
            signal fifo_full, fifo_wrerr: std_logic; -- on WRCLK
            signal fifo_empty: std_logic; -- on RDCLK
            begin
                bram_fifo_f2s : FIFO36E2
                    generic map(
                        WRITE_WIDTH => 72,
                        READ_WIDTH => 72,
                        REGISTER_MODE => "REGISTERED",
                        CLOCK_DOMAINS => "INDEPENDENT"
                    )
                    port map(
                        PROGEMPTY => open,
                        PROGFULL => open,
                        DIN => buff_in_f(i).data,
                        DINP(0) => buff_in_f(i).valid,
                        DINP(1) => new_event,
                        DINP(7 downto 2) => (others => '0'),
                        DOUT => buff_in_s(i).data,
                        DOUTP(0) => buff_in_s(i).valid,
                        DOUTP(1) => buff_in_s(i).strobe,
                        DOUTP(7 downto 2) => open,
                        EMPTY => fifo_full,
                        FULL => fifo_empty,
                        RDCLK => clk_payload(2),
                        RDCOUNT => open,
                        RDEN => '1',
                        RDERR => fifo_rderr_s(i),
                        RDRSTBUSY => open,
                        RST => fifo_reset_f(i),
                        WRCLK => clk_p,
                        WREN => fifo_write_f(i),
                        WRERR => fifo_wrerr,
                        WRRSTBUSY => open,
                        -- unused inputs for cascading
                        REGCE => '1',
                        RSTREG => '0',
                        SLEEP => '0',
                        CASDIN => (others=>'0'),
                        CASDINP => (others=>'0'),
                        CASPRVEMPTY => '0',
                        CASNXTRDEN => '0', 
                        CASOREGIMUX => '0',
                        CASOREGIMUXEN => '1',
                        CASDOMUX => '0',
                        CASDOMUXEN => '1',
                        INJECTSBITERR => '0',
                        INJECTDBITERR => '0'
                    );
            end generate gen_fifos_f2s;


        hls_ip_rst <= fifo_rderr_s(0) or fifo_rderr_s(1) or fifo_rderr_s(2);
        hls_ip_en <= not(fifo_rderr_s(0) or fifo_rderr_s(1) or fifo_rderr_s(2));

        hls_ip : dummy_simple_0 
                    port map(
                        ap_clk => clk_payload(2),
                        ap_rst => hls_ip_rst,
                        ap_start => hls_ip_en, 
                        ap_done => open,
                        ap_idle => open,
                        ap_ready => open,
                        newevent => buff_in_s(0).strobe,
                        links_0_V => buff_in_s(0).data,
                        links_1_V => buff_in_s(1).data,
                        links_2_V => buff_in_s(2).data,
                        out_0_V => buff_out_s(0).data,
                        out_1_V => buff_out_s(1).data,
                        out_2_V => buff_out_s(2).data,
                        out_0_V_ap_vld => buff_out_s(0).valid,
                        out_1_V_ap_vld => buff_out_s(1).valid,
                        out_2_V_ap_vld => buff_out_s(2).valid
                    );

        gen_fifos_s2f: for i in 0 to NLINKS_OUT-1 generate
            signal fifo_full, fifo_wrerr: std_logic; -- on WRCLK
            signal fifo_empty: std_logic; -- on RDCLK
            begin
                bram_fifo_f2s : FIFO36E2
                    generic map(
                        WRITE_WIDTH => 72,
                        READ_WIDTH => 72,
                        REGISTER_MODE => "REGISTERED",
                        CLOCK_DOMAINS => "INDEPENDENT"
                    )
                    port map(
                        PROGEMPTY => open,
                        PROGFULL => open,
                        DIN => buff_out_s(i).data,
                        DINP(0) => buff_out_s(i).valid,
                        DINP(7 downto 1) => (others => '0'),
                        DOUT => buff_out_f(i).data,
                        DOUTP(0) => buff_out_f(i).valid,
                        DOUTP(7 downto 1) => open,
                        EMPTY => fifo_full,
                        FULL => fifo_empty,
                        RDCLK => clk_p,
                        RDCOUNT => open,
                        RDEN => '1',
                        RDERR => fifo_rderr_f(i),
                        RDRSTBUSY => open,
                        RST => hls_ip_rst,-- fifo_reset_s(i), -- don't know how to set this so using hls_ip_rst for the moment
                        WRCLK => clk_payload(2),
                        WREN => '1',
                        WRERR => fifo_wrerr,
                        WRRSTBUSY => open,
                        -- unused inputs for cascading
                        REGCE => '0',
                        RSTREG => '0',
                        SLEEP => '0',
                        CASDIN => (others=>'0'),
                        CASDINP => (others=>'0'),
                        CASPRVEMPTY => '0',
                        CASNXTRDEN => '0', 
                        CASOREGIMUX => '0',
                        CASOREGIMUXEN => '1',
                        CASDOMUX => '0',
                        CASDOMUXEN => '1',
                        INJECTSBITERR => '0',
                        INJECTDBITERR => '0'
                    );
            end generate gen_fifos_s2f;

        output_f: process(clk_p)
            begin
                if rising_edge(clk_p) then
                    for i in NLINKS_OUT-1 downto 0 loop
                        q(i).data <= buff_out_f(i).data;
                        q(i).valid <= buff_out_f(i).valid;
                        q(i).strobe <= '1';
                    end loop;
                    q(NLINKS_OUT).data <= (others => '0');
                    for i in NLINKS_OUT-1 downto 0 loop
                        q(NLINKS_OUT).data(i*4) <= fifo_rderr_f(i);
                    end loop;
                    q(NLINKS_OUT).valid  <= '1';
                    q(NLINKS_OUT).strobe <= '1';
                end if;
            end process output_f;

        copy:	
            process(clk_p) 
            begin
                if rising_edge(clk_p) then
                    for i in 4 * N_REGION - 1 downto USED_FIBERS loop
                        copy_in(i) <= d(i);
                        copy_out(i) <= copy_in(i);
                        q(i) <= copy_out(i);
                    end loop;
                end if;
            end process copy;
    
	
	bc0 <= '0';
	
	gpio <= (others => '0');
	gpio_en <= (others => '0');

end rtl;
