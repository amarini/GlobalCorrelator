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

        constant N_OUT : integer := 25;
        constant N_BUFF : integer := 3; -- how many more FFs to add after the algo to be able to route the result back to all the links

        component sorting_multitap_sr_0 is 
            port (
                ap_clk : IN STD_LOGIC;
                ap_rst : IN STD_LOGIC;
                ap_start : IN STD_LOGIC;
                ap_done : OUT STD_LOGIC;
                ap_idle : OUT STD_LOGIC;
                ap_ready : OUT STD_LOGIC;
                newRecord : IN STD_LOGIC;
                newValue_pt_V : IN STD_LOGIC_VECTOR (15 downto 0);
                newValue_stuff_V : IN STD_LOGIC_VECTOR (47 downto 0);
                tap_0_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_1_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_2_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_3_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_4_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_5_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_6_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_7_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_8_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_9_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_10_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_11_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_12_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_13_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_14_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_15_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_16_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_17_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_18_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_19_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_20_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_21_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_22_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_23_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_24_pt_V : OUT STD_LOGIC_VECTOR (15 downto 0);
                tap_0_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_1_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_2_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_3_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_4_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_5_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_6_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_7_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_8_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_9_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_10_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_11_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_12_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_13_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_14_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_15_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_16_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_17_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_18_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_19_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_20_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_21_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_22_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_23_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0);
                tap_24_stuff_V : OUT STD_LOGIC_VECTOR (47 downto 0)
              );
        end component;

        type output_buff_t is array(N_BUFF downto 0) of ldata(N_OUT-1 downto 0);
        signal copy_in   : ldata(4 * N_REGION - 1 downto N_OUT);
        signal copy_out  : ldata(4 * N_REGION - 1 downto N_OUT);
        signal buff_in   : ldata;
        signal buff_vld  : std_logic := '0';
        signal buff_out  : output_buff_t;
        signal out_vld   : std_logic := '0';

begin

	ipb_out <= IPB_RBUS_NULL;

        sorting_multitap_sr_inst : sorting_multitap_sr_0 
            port map(
                ap_clk => clk_p,
                ap_rst => rst_loc(0),
                ap_start => clken_loc(0), 
                ap_done => out_vld,
                ap_idle => open,
                ap_ready => open,
                newRecord => buff_vld,
                newValue_pt_V => buff_in.data(15 downto 0),
                newValue_suff_V => buff_vld.data(63 downto 16),
                tap_0_pt_V => buff_out(0)(0).data(15 downto 0),
                tap_0_stuff_V => buff_out(0)(0).data(63 downto 16),
                tap_1_pt_V => buff_out(0)(1).data(15 downto 0),
                tap_1_stuff_V => buff_out(0)(1).data(63 downto 16),
                tap_2_pt_V => buff_out(0)(2).data(15 downto 0),
                tap_2_stuff_V => buff_out(0)(2).data(63 downto 16),
                tap_3_pt_V => buff_out(0)(3).data(15 downto 0),
                tap_3_stuff_V => buff_out(0)(3).data(63 downto 16),
                tap_4_pt_V => buff_out(0)(4).data(15 downto 0),
                tap_4_stuff_V => buff_out(0)(4).data(63 downto 16),
                tap_5_pt_V => buff_out(0)(5).data(15 downto 0),
                tap_5_stuff_V => buff_out(0)(5).data(63 downto 16),
                tap_6_pt_V => buff_out(0)(6).data(15 downto 0),
                tap_6_stuff_V => buff_out(0)(6).data(63 downto 16),
                tap_7_pt_V => buff_out(0)(7).data(15 downto 0),
                tap_7_stuff_V => buff_out(0)(7).data(63 downto 16),
                tap_8_pt_V => buff_out(0)(8).data(15 downto 0),
                tap_8_stuff_V => buff_out(0)(8).data(63 downto 16),
                tap_9_pt_V => buff_out(0)(9).data(15 downto 0),
                tap_9_stuff_V => buff_out(0)(9).data(63 downto 16),
                tap_10_pt_V => buff_out(0)(10).data(15 downto 0),
                tap_10_stuff_V => buff_out(0)(10).data(63 downto 16),
                tap_11_pt_V => buff_out(0)(11).data(15 downto 0),
                tap_11_stuff_V => buff_out(0)(11).data(63 downto 16),
                tap_12_pt_V => buff_out(0)(12).data(15 downto 0),
                tap_12_stuff_V => buff_out(0)(12).data(63 downto 16),
                tap_13_pt_V => buff_out(0)(13).data(15 downto 0),
                tap_13_stuff_V => buff_out(0)(13).data(63 downto 16),
                tap_14_pt_V => buff_out(0)(14).data(15 downto 0),
                tap_14_stuff_V => buff_out(0)(14).data(63 downto 16),
                tap_15_pt_V => buff_out(0)(15).data(15 downto 0),
                tap_15_stuff_V => buff_out(0)(15).data(63 downto 16),
                tap_16_pt_V => buff_out(0)(16).data(15 downto 0),
                tap_16_stuff_V => buff_out(0)(16).data(63 downto 16),
                tap_17_pt_V => buff_out(0)(17).data(15 downto 0),
                tap_17_stuff_V => buff_out(0)(17).data(63 downto 16),
                tap_18_pt_V => buff_out(0)(18).data(15 downto 0),
                tap_18_stuff_V => buff_out(0)(18).data(63 downto 16),
                tap_19_pt_V => buff_out(0)(19).data(15 downto 0),
                tap_19_stuff_V => buff_out(0)(19).data(63 downto 16),
                tap_20_pt_V => buff_out(0)(20).data(15 downto 0),
                tap_20_stuff_V => buff_out(0)(20).data(63 downto 16),
                tap_21_pt_V => buff_out(0)(21).data(15 downto 0),
                tap_21_stuff_V => buff_out(0)(21).data(63 downto 16),
                tap_22_pt_V => buff_out(0)(22).data(15 downto 0),
                tap_22_stuff_V => buff_out(0)(22).data(63 downto 16),
                tap_23_pt_V => buff_out(0)(23).data(15 downto 0),
                tap_23_stuff_V => buff_out(0)(23).data(63 downto 16),
                tap_24_pt_V => buff_out(0)(24).data(15 downto 0),
                tap_24_stuff_V => buff_out(0)(24).data(63 downto 16),
            );

            for j in N_OUT-1 downto 0 generate
                buff_out(0)(j).valid <= out_vld;
            end generate;

        executor: process(clk_p)
            begin
                if rising_edge(clk_p) then
                    for j in N_OUT-1 downto 0 loop
                        q(j) <= buff_out(N_BUFF)(j);
                        for i in N_BUFF downto 1 loop
                            buff_out(i)(j) <= buff_out(i-1)(j);
                        end loop;
                    end loop;
                        
                    buff_vld <= d(0).valid and d(1).valid and d(0).data(0);
                    buff_in  <= d(1);
                end if;
            end process executor;

        copy:	
            process(clk_p) 
            begin
                if rising_edge(clk_p) then
                    for i in 4 * N_REGION - 1 downto N_OUT loop
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
