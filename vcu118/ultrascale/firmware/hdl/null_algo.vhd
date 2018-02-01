library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ultra_data_types.all;
use work.ultra_constants.all;
use work.board_constants.all;

entity ultra_null_algo is
    port (
       clk : in std_logic;
       rst : in std_logic;
       d   : in ndata(4*N_QUADS-1 downto 0);
       q   : out ndata(4*N_QUADS-1 downto 0)
    );
end ultra_null_algo;

architecture behavioral of ultra_null_algo is
    constant N_QQUADS : natural := (N_QUADS+3)/4;
    subtype int16 is signed(15 downto 0);
    type vint16 is array (natural range <>) of int16;
    -- some buffers to help the thing meet the timing
    -- also, some attributes to tell Vivado to not optimize out the buffers
    -- merging them or absorbing them into a SLR16E, which defeats 
    -- the purpose of putting them...
    signal buff_in : ndata(4*N_QUADS-1 downto 0);
    signal buff_out : ndata(4*N_QUADS-1 downto 0);
    signal buff_out1 : ndata(4*N_QUADS-1 downto 0);
    signal buff_out2 : ndata(4*N_QUADS-1 downto 0);
    attribute shreg_extract : string;
    attribute dont_touch : string;
    attribute shreg_extract of buff_out1 : signal is "no";
    attribute shreg_extract of buff_out2 : signal is "no";
    attribute dont_touch of buff_out1 : signal is "yes";
    attribute dont_touch of buff_out2 : signal is "yes";
    -- let's do something that has some non-trivial routing
    signal fibers_hi: vint16(4*N_QUADS-1 downto 0);
    signal fibers_lo: vint16(4*N_QUADS-1 downto 0);
    signal fibers_ok: std_logic_vector(4*N_QUADS-1 downto 0);
    signal quads_hi: vint16(N_QUADS-1 downto 0);
    signal quads_lo: vint16(N_QUADS-1 downto 0);
    signal quads_ok: std_logic_vector(N_QUADS-1 downto 0);
    signal qquads_hi: vint16(N_QQUADS-1 downto 0);
    signal qquads_lo: vint16(N_QQUADS-1 downto 0);
    signal qquads_ok: std_logic_vector(N_QQUADS-1 downto 0);
    signal tot_hi: int16;
    signal tot_lo: int16;
    signal tot_ok: std_logic;
begin
    buffers: process(clk)
    begin
        if rising_edge(clk) then
            buff_in <= d;
            buff_out1 <= buff_out;
            buff_out2 <= buff_out1;
            q <= buff_out2;
        end if;
    end process buffers;

    mkf: process(clk,rst)
    begin
        if rst = '1' then
            for i in 4*N_QUADS-1 downto 0 loop
                fibers_ok(i) <= '0';
            end loop;
        elsif rising_edge(clk) then
            for i in 4*N_QUADS-1 downto 0 loop
                fibers_hi(i) <= signed(buff_in(i).data(31 downto 16));
                fibers_lo(i) <= signed(buff_in(i).data(15 downto  0));
                fibers_ok(i) <= buff_in(i).valid;
            end loop;
        end if;
    end process;

    mkq: process(clk,rst)
    begin
        if rst = '1' then
            for i in N_QUADS-1 downto 0 loop
                quads_ok(i) <= '0';
            end loop;
        elsif rising_edge(clk) then
            for i in N_QUADS-1 downto 0 loop
                quads_hi(i) <= fibers_hi(4*i+0) + fibers_hi(4*i+1) + fibers_hi(4*i+2) + fibers_hi(4*i+3);
                quads_lo(i) <= fibers_lo(4*i+0) + fibers_lo(4*i+1) + fibers_lo(4*i+2) + fibers_lo(4*i+3);
                quads_ok(i) <= (fibers_ok(4*i+0) and fibers_ok(4*i+1) and fibers_ok(4*i+2) and fibers_ok(4*i+3));
            end loop;
        end if;
    end process;

    mkqq: process(clk,rst)
        variable sum_hi, sum_lo : int16;
        variable and_ok : std_logic;
    begin
        if rst = '1' then
            for i in N_QQUADS-1 downto 0 loop
                qquads_ok(i) <= '0';
            end loop;
        elsif rising_edge(clk) then
            for i in N_QQUADS-1 downto 0 loop
                sum_hi := to_signed(0,int16'length);
                sum_lo := to_signed(0,int16'length);
                and_ok := '1';
                for j in 4*i+3 downto 4*i loop
                    if j < N_QUADS then
                        sum_hi := sum_hi + quads_hi(j);
                        sum_lo := sum_lo + quads_lo(j);
                        and_ok := and_ok and quads_ok(j);
                    end if;
                end loop;
                qquads_hi(i) <= sum_hi;
                qquads_lo(i) <= sum_lo;
                qquads_ok(i) <= and_ok;
            end loop;
        end if;
    end process;

    mktot: process(clk,rst)
        variable sum_hi, sum_lo : int16;
        variable and_ok : std_logic;
    begin
        if rst = '1' then
            tot_ok <= '0';
        elsif rising_edge(clk) then
            sum_hi := to_signed(0,int16'length);
            sum_lo := to_signed(0,int16'length);
            and_ok := '1';
            for j in N_QQUADS-1 downto 0 loop
                sum_hi := sum_hi + qquads_hi(j);
                sum_lo := sum_lo + qquads_lo(j);
                and_ok := and_ok and qquads_ok(j);
            end loop;
            tot_hi <= sum_hi;
            tot_lo <= sum_lo;
            tot_ok <= and_ok;
        end if;
    end process;

    mko: process(clk)
    begin
        if rising_edge(clk) then
            for i in 4*N_QUADS-1 downto 0 loop
                buff_out(i).data(31 downto 16) <= std_logic_vector(tot_hi);
                buff_out(i).data(15 downto  0) <= std_logic_vector(tot_lo);
                buff_out(i).valid <= tot_ok;
            end loop;
        end if;
    end process;
end behavioral;
