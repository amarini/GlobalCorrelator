library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ultra_data_types.all;
use work.ultra_constants.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ultra_buffer is
   generic(
       ADDR_WIDTH : natural := 10
   );
   port(
       clk : in std_logic;
       rst : in std_logic;
       clk_ipb: in std_logic;
       rst_ipb: in std_logic;
       ipb_in: in ipb_wbus;
       ipb_out: out ipb_rbus;
       tx_in : in ndata(3 downto 0);
       rx_out: out ndata(3 downto 0)
   );
end ultra_buffer;

architecture behavioral of ultra_buffer is
    attribute dont_touch : string;
    attribute dont_touch of behavioral : architecture is "yes";
    type mybuff is array (3 downto 0) of std_logic_vector(35 downto 0);
    signal inj_buff, cap_buff: mybuff;
    signal inj_buff_d, cap_buff_d: mybuff;
    signal addr: std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal ipb_to_slaves:   ipb_wbus_array(1 downto 0);
    signal ipb_from_slaves: ipb_rbus_array(1 downto 0);
    signal ipb_to_buff:   ipb_wbus_array(7 downto 0);
    signal ipb_from_buff: ipb_rbus_array(7 downto 0);
    signal we, re : std_logic_vector(3 downto 0) := (others => '0');
    signal we_meta, re_meta : std_logic_vector(3 downto 0) := (others => '0'); -- for clock domain transition
    signal ctrl_reg, stat_reg: ipb_reg_v(0 downto 0);
begin
    capture_enables: process(clk)
    begin
        if rising_edge(clk) then
            for i in 3 downto 0 loop
                re_meta(i) <= ctrl_reg(0)(2*i);
                we_meta(i) <= ctrl_reg(0)(2*i+1);
            end loop;
            we <= we_meta;
            re <= re_meta;
        end if;
    end process;


    gen_brams: for i in 3 downto 0 generate
        rx_bram : entity work.ipbus_ported_dpram36
            generic map (ADDR_WIDTH => ADDR_WIDTH)
            port map (clk => clk_ipb, rst => rst_ipb, ipb_in => ipb_to_buff(2*i), ipb_out => ipb_from_buff(2*i),
                      rclk => clk, we => '0', addr => addr, d => (others => '0'), q => inj_buff(i));
        tx_bram : entity work.ipbus_ported_dpram36
            generic map (ADDR_WIDTH => ADDR_WIDTH)
            port map (clk => clk_ipb, rst => rst_ipb, ipb_in => ipb_to_buff(2*i+1), ipb_out => ipb_from_buff(2*i+1),
                      rclk => clk, we => we(i), addr => addr, d => cap_buff_d(i), q => open);
    end generate;

    count: process(clk,rst)
    begin
        if rst = '1' then
            addr <= (others => '0');
        elsif rising_edge(clk) then
            if addr = b"1111111111" then
                addr <= (others => '0');
            else
                addr <= std_logic_vector(unsigned(addr) + to_unsigned(1, ADDR_WIDTH));
            end if;
        end if;
    end process;

    get_out: process(clk)
    begin
        if rising_edge(clk) then
            for i in 3 downto 0 loop
                cap_buff(i)(31 downto  0) <= tx_in(i).data;
                cap_buff(i)(     32     ) <= tx_in(i).valid;
                cap_buff(i)(35 downto 33) <= (others => '0');
                cap_buff_d(i) <= cap_buff(i);
                inj_buff_d(i) <= inj_buff(i);
                if re(i) = '1' then
                    rx_out(i).data  <= inj_buff_d(i)(31 downto 0);
                    rx_out(i).valid <= inj_buff_d(i)(32);
                else
                    rx_out(i).data  <= (others => '0');
                    rx_out(i).valid <= '0';
                end if;
            end loop;
        end if;
    end process;


   ipb_fab: entity work.ipbus_fabric_simple
       generic map(NSLV => 2, DECODE_BASE => 4, DECODE_BITS => 1) 
       port map(ipb_in => ipb_in, ipb_out => ipb_out, ipb_to_slaves => ipb_to_slaves, ipb_from_slaves => ipb_from_slaves);

   ipb_selbuf: entity work.ipbus_fabric_simple
       generic map(NSLV => 8, DECODE_BASE => 1, DECODE_BITS => 3) 
       port map(ipb_in => ipb_to_slaves(1), ipb_out => ipb_from_slaves(1), ipb_to_slaves => ipb_to_buff, ipb_from_slaves => ipb_from_buff);

   reg: entity work.ipbus_ctrlreg_v
         port map(
                 clk => clk_ipb,
                 reset => rst_ipb,
                 ipbus_in => ipb_to_slaves(0),
                 ipbus_out => ipb_from_slaves(0),
                 d => stat_reg,
                 q => ctrl_reg
             );

   do_reg: process(clk_ipb)
   begin
       if rising_edge(clk_ipb) then
           stat_reg <= ctrl_reg;
       end if;
   end process do_reg;

end behavioral;

