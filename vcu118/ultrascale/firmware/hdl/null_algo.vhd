library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ultra_data_types.all;
use work.ultra_constants.all;
use work.board_constants.all;

use work.pftm_data_types.all;
use work.pftm_constants.all;

entity ultra_null_algo is
    port (
       clk : in std_logic;
       rst : in std_logic;
       d   : in ndata(4*N_QUADS-1 downto 0);
       q   : out ndata(4*N_QUADS-1 downto 0)
    );
end ultra_null_algo;

architecture behavioral of ultra_null_algo is
    constant N_IN  : natural := 4*N_SECTORS;
    constant N_OUT : natural := (N_CALO+N_EMCALO+N_TRACK);
    signal sav_in_good : std_logic_vector(N_IN - 1 downto 0);
    signal sav_in  : words32(N_IN - 1 downto 0);
    signal reg_in_good : std_logic_vector(N_IN - 1 downto 0);
    signal reg_in  : words32(N_IN - 1 downto 0);
    signal reg_out : words32(N_OUT - 1 downto 0);
    signal reg_out_good : std_logic_vector(N_OUT-1 downto 0);
    signal reg_cnts  : words32(2 downto 0);
    signal reg_bits  : words32(2 downto 0);
begin
    calo : entity work.regionizer_mp7_pipelined
        generic map(N_OBJ_SECTOR => N_CALO_SECTOR, N_OBJ_SECTOR_ETA => N_CALO_SECTOR_ETA, N_OBJ => N_CALO, N_FIBERS_SECTOR => 1, N_FIBERS_OBJ => 1 )
        port map(clk => clk, rst => rst, 
                 mp7_valid => reg_in_good(1*N_SECTORS-1 downto 0*N_SECTORS), 
                 mp7_in => reg_in(1*N_SECTORS-1 downto 0*N_SECTORS), 
                 mp7_out  => reg_out(N_CALO-1 downto 0), 
                 mp7_outv => reg_out_good(N_CALO-1 downto 0), 
                 mp7_cnts => reg_cnts(0), mp7_bits => reg_bits(0));

    emcalo : entity work.regionizer_mp7_pipelined
        generic map(N_OBJ_SECTOR => N_EMCALO_SECTOR, N_OBJ_SECTOR_ETA => N_EMCALO_SECTOR_ETA, N_OBJ => N_EMCALO, N_FIBERS_SECTOR => 1, N_FIBERS_OBJ => 1, 
                   SECTOR_VALID_BIT_DELAY => 4)
        port map(clk => clk, rst => rst, 
                 mp7_valid => reg_in_good(2*N_SECTORS-1 downto 1*N_SECTORS), 
                 mp7_in => reg_in(2*N_SECTORS-1 downto 1*N_SECTORS), 
                 mp7_out  => reg_out(N_CALO+N_EMCALO-1 downto N_CALO), 
                 mp7_outv => reg_out_good(N_CALO+N_EMCALO-1 downto N_CALO), 
                 mp7_cnts => reg_cnts(1), mp7_bits => reg_bits(1));

    track : entity work.regionizer_mp7_pipelined
        generic map(N_OBJ_SECTOR => N_TRACK_SECTOR, N_OBJ_SECTOR_ETA => N_TRACK_SECTOR_ETA, N_OBJ => N_TRACK, N_FIBERS_SECTOR => 2, N_FIBERS_OBJ => 1, 
                   SECTOR_VALID_BIT_DELAY => 6 )
        port map(clk => clk, rst => rst, 
                 mp7_valid => reg_in_good(4*N_SECTORS-1 downto 2*N_SECTORS),  
                 mp7_in => reg_in(4*N_SECTORS-1 downto 2*N_SECTORS), 
                 mp7_out  => reg_out(N_CALO+N_EMCALO+N_TRACK-1 downto N_CALO+N_EMCALO), 
                 mp7_outv => reg_out_good(N_CALO+N_EMCALO+N_TRACK-1 downto N_CALO+N_EMCALO), 
                 mp7_cnts => reg_cnts(2), mp7_bits => reg_bits(2));

    -- yet another register buffer
    get_input: process(clk)
    begin
        if clk'event and clk = '1' then
            for i in N_IN-1 downto 0 loop
                sav_in_good(i) <= d(0).valid;
                sav_in(i) <= d(i).data;
                reg_in_good(i) <= sav_in_good(i);
                reg_in(i) <= sav_in(i);
            end loop;
        end if;
    end process get_input;

    -- yet another register buffer
    get_output: process(clk)
    begin
        if clk'event and clk = '1' then
            for i in N_OUT-1 downto 0 loop
                q(i).data <= reg_out(i);
                q(i).valid <= reg_out_good(i);
            end loop;
        end if;
    end process get_output;

    debug_output: process(clk)
    begin
        if clk'event and clk = '1' then
            for i in 0 to 2 loop
                q(N_OUT+2*i+0).data <= reg_cnts(i);
                q(N_OUT+2*i+0).valid <= '1';
                q(N_OUT+2*i+1).data <= reg_bits(i);
                q(N_OUT+2*i+1).valid <= '1';
            end loop;
        end if;
    end process debug_output;

    dummy_output: process(clk)
    begin
        if clk'event and clk = '1' then
            for i in  4 * N_QUADS - 1 downto N_OUT+6 loop
                q(i).data <= (others => '1');
                q(i).valid <= '1';
            end loop;
        end if;
    end process dummy_output;
end behavioral;
