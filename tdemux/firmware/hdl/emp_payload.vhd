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

        constant TF_NSECTORS : integer := 1;
        constant TF_TMUX     : integer := 18;
        constant TF_TMUX_RATIO : integer := 3;

        constant TF_FRAME_LENGTH : integer := TF_TMUX*CLOCK_RATIO;

        constant USED_FIBERS : integer := TF_NSECTORS*TF_TMUX_RATIO;

        component tdemux_simple_0 is 
            port (
                out_0_V_ap_vld : OUT STD_LOGIC;
                out_1_V_ap_vld : OUT STD_LOGIC;
                out_2_V_ap_vld : OUT STD_LOGIC;
                ap_clk : IN STD_LOGIC;
                ap_rst : IN STD_LOGIC;
                ap_start : IN STD_LOGIC;
                ap_done : OUT STD_LOGIC;
                ap_idle : OUT STD_LOGIC;
                ap_ready : OUT STD_LOGIC;
                ap_return : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
                newEvent : IN STD_LOGIC;
                links_0_V : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
                links_1_V : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
                links_2_V : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
                out_0_V : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
                out_1_V : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
                out_2_V : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
              );
        end component;

        signal copy_in   : ldata(4 * N_REGION - 1 downto USED_FIBERS);
        signal copy_out  : ldata(4 * N_REGION - 1 downto USED_FIBERS);
        signal old_valid : std_logic := '0';
        signal in_valid : std_logic := '0';
        signal buff_in   : ldata(0 to TF_TMUX_RATIO-1);
        signal buff_out  : ldata(0 to TF_TMUX_RATIO-1);
        signal counter   : natural range 0 to TF_FRAME_LENGTH-1;

begin

	ipb_out <= IPB_RBUS_NULL;

        tdemux_inst : tdemux_simple_0 
            port map(
                out_0_V_ap_vld => buff_out(0).valid,
                out_1_V_ap_vld => buff_out(1).valid,
                out_2_V_ap_vld => buff_out(2).valid,
                ap_clk => clk_p,
                ap_rst => rst_loc(0),
                ap_start => clken_loc(0), 
                ap_done => open,
                ap_idle => open,
                ap_ready => open,
                ap_return => open,
                newEvent => in_valid,
                links_0_V => buff_in(0).data,
                links_1_V => buff_in(1).data,
                links_2_V => buff_in(2).data,
                out_0_V => buff_out(0).data,
                out_1_V => buff_out(1).data,
                out_2_V => buff_out(2).data
            );

        executor: process(clk_p)
            begin
                if rising_edge(clk_p) then
                    for j in TF_TMUX_RATIO-1 downto 0 loop
                        buff_in(j) <= d(0+j);
                        q(0+j).data   <= buff_out(j).data;
                        q(0+j).valid  <= buff_out(j).valid;
                        q(0+j).start  <= '1'; -- not sure what this is
                        q(0+j).strobe <= '1'; -- necessary for capture
                    end loop;
                    if d(0).valid = '1' then
                        if (old_valid = '0') or (counter = TF_FRAME_LENGTH-1) then
                            counter <= 0;
                            in_valid <= '1';
                        else
                            counter <= counter + 1;
                            in_valid <= '0';
                        end if;
                    else
                        counter <= 0;
                        in_valid <= '0';
                    end if;
                    old_valid <= d(0).valid;
                end if;
            end process executor;

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
