library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.pftm_data_types.all;
use work.pftm_constants.all;

entity pipelined_merger is
    generic(
        N_OBJ_SECTOR_ETA : natural;
        N_OBJ: natural;
        phiShift1: etaphi_t := to_etaphi(-PHI_SHIFT_SECTOR);
        phiShift2: etaphi_t := to_etaphi(0);
        phiShift3: etaphi_t := to_etaphi(PHI_SHIFT_SECTOR)
    );
    port(
        clk : in std_logic;    
        rst : in std_logic;
        go       : std_logic;
        valid_in : std_logic;
        list1_in : in particles(N_OBJ_SECTOR_ETA-1 downto 0);  -- \
        list2_in : in particles(N_OBJ_SECTOR_ETA-1 downto 0);  -- |- pt-sorted list of input objects in each phi sector
        list3_in : in particles(N_OBJ_SECTOR_ETA-1 downto 0);  -- /
        list_out:  out particles(N_OBJ-1 downto 0);            -- pt-sorted list of output objects
        valid_out: out std_logic                               -- whether list_out is valid
        --spy_out   : out particles(3*N_OBJ_SECTOR_ETA-1 downto 0); -- input particles for the regionizer
        --spy_valid : out std_logic -- valid output from the regionizer
    );   
end pipelined_merger;

architecture Behavioral of pipelined_merger is
    type   work_bench is array (natural range <>) of particles(3*N_OBJ_SECTOR_ETA-1 downto 0);
    signal work  : work_bench(0 to 2*N_OBJ_SECTOR_ETA-1);
    signal valid : std_logic_vector(0 to 2*N_OBJ_SECTOR_ETA-1);
begin

    -- I can't understand why, but Vivado fails to synthethise this correctly as registers if I use a process block.
    -- so, I have to put by hand the FDCE's (flip-flops with asynchronous clear)
    propv: for step in 2*N_OBJ_SECTOR_ETA-2 downto 0 generate
        FDCE_inst : FDCE
            generic map ( INIT => '0' )
            port map ( CE  => '1', C   => clk, CLR => rst, D => valid(step), Q => valid(step+1) );
    end generate propv;
    FDCE_zero : FDCE 
        generic map ( INIT => '0' ) 
        port map ( CE  => go, C => clk, CLR => rst, D => valid_in, Q => valid(0) );
 
    stepper: process(clk)
        variable pivot : particle;
        variable N_SORTED : natural;
    begin
        if rising_edge(clk) then
            --if go = '1' then
                for i in N_OBJ_SECTOR_ETA-1 downto 0 loop
                    work(0)(i+0*N_OBJ_SECTOR_ETA) <= shift_phi(list1_in(i), phiShift1);
                    work(0)(i+1*N_OBJ_SECTOR_ETA) <= shift_phi(list2_in(i), phiShift2);
                    work(0)(i+2*N_OBJ_SECTOR_ETA) <= shift_phi(list3_in(i), phiShift3);
                end loop;
            --end if;
 
            for step in 1 to 2*N_OBJ_SECTOR_ETA-1 loop
                N_SORTED := N_OBJ_SECTOR_ETA - 1 + step; -- number objects already sorted in input to this step
                pivot := work(step-1)(N_SORTED);

                if pivot.pt > work(step-1)(0).pt then
                    work(step)(0) <= pivot;
                else
                    work(step)(0) <= work(step-1)(0);
                end if;

                for j in 1 to N_SORTED-1 loop
                    if pivot.pt > work(step-1)(j-1).pt then
                        work(step)(j) <= work(step-1)(j-1);
                    elsif pivot.pt > work(step-1)(j).pt then
                        work(step)(j) <= pivot;
                    else
                        work(step)(j) <= work(step-1)(j);
                    end if;
                end loop;

                if pivot.pt > work(step-1)(N_SORTED-1).pt then
                    work(step)(N_SORTED) <= work(step-1)(N_SORTED-1);
                else
                    work(step)(N_SORTED) <= pivot;
                end if;

                if step < 2*N_OBJ_SECTOR_ETA-1 then
                    for j in 3*N_OBJ_SECTOR_ETA-1 downto N_SORTED+1 loop
                        work(step)(j) <= work(step-1)(j);
                    end loop;
                end if;
            end loop;
       end if;
    end process stepper;

    list_out(N_OBJ-1 downto 0) <= work(2*N_OBJ_SECTOR_ETA-1)(N_OBJ-1 downto 0);
    valid_out <= valid(2*N_OBJ_SECTOR_ETA-1);
    --spy_out(3*N_OBJ_SECTOR_ETA-1 downto 0) <= work(0)(3*N_OBJ_SECTOR_ETA-1 downto 0);
    --spy_valid <= valid(0);
end Behavioral;


