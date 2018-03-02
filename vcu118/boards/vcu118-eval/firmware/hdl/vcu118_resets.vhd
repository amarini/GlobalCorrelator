library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity vcu118_resets is
    port (
        -- input clocks (to synchronize resets)
        sysclk125 : in std_logic; -- system clock (125 MHz)
        ethclk125 : in std_logic; -- ethernet clock (125 MHz)
        ipbclk    : in std_logic; -- ipbus clock (30 MHz)
        clk       : in std_logic; -- algo clock (240 MHz)
        clk40     : in std_logic; -- 40 MHz output clock
        -- status signals that may trigger a reset 
        mmcm_locked: in std_logic;
        eth_locked:  in std_logic;
        request_hard_rst_ext: in std_logic; -- these comes in unclocked
        request_hard_rst_ipb: in std_logic; -- these come in on the ipbus clock
        request_soft_rst_ipb: in std_logic; -- these come in on the ipbus clock
        -- output reset signals
        rst   : out std_logic;
        rst40 : out std_logic;
        rst_ipb : out std_logic; 
        rst_ipb_ctrl : out std_logic; 
        rst_phy: out std_logic;
        -- this is on when all resets are complete
        status_ok: out std_logic
    );
end vcu118_resets;

architecture rtl of vcu118_resets is
    constant N_FF_IMPORT : natural := 2;
    signal twokhz, twokhz_del : std_logic; -- slow clocks for reset
    signal hard_rst : std_logic := '1'; -- hard reset: ON at boot
    signal soft_rst : std_logic := '0';
    signal hard_rst_del1, hard_rst_del2 : std_logic := '0';
    signal request_hard_rst_sys_i, request_soft_rst_sys_i : std_logic_vector(N_FF_IMPORT-1 downto 0);-- bring into the sys domain
    signal rst_u, rst40_u, rst_ipb_u : std_logic; -- resets before going into BUFGs
begin

    clkdiv: entity work.ipbus_clock_div
            port map( clk => sysclk125, d17 => twokhz); 


    hard_reset_logic: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            twokhz_del <= twokhz;
            if twokhz = '1' and twokhz_del = '0' then -- 500 us intervals
                -- hard reset requests are delayed by ~1ms 
                hard_rst_del1 <= request_hard_rst_sys_i(0); 
                hard_rst_del2 <= hard_rst_del1; 
                -- mmcm out of lock triggers hard reset immediately
                hard_rst <= hard_rst_del2 or not mmcm_locked;
                -- ethernet hard rest is delayed by 500 us
                rst_phy <= hard_rst; -- and the phy device
            end if;
        end if;
    end process;

    import_rst_requests: process(sysclk125)
    begin
        if rising_edge(sysclk125) then
            request_hard_rst_sys_i(N_FF_IMPORT-1) <= request_hard_rst_ext or request_hard_rst_ipb;
            request_soft_rst_sys_i(N_FF_IMPORT-1) <= request_soft_rst_ipb;
            if N_FF_IMPORT > 1 then
                request_hard_rst_sys_i(N_FF_IMPORT-2 downto 0) <= request_hard_rst_sys_i(N_FF_IMPORT-1 downto 1);
                request_soft_rst_sys_i(N_FF_IMPORT-2 downto 0) <= request_soft_rst_sys_i(N_FF_IMPORT-1 downto 1);
            end if;
        end if;
    end process;

    export_rst_clk: process(clk)
    begin
        if rising_edge(clk) then
            rst_u <= hard_rst or soft_rst;
        end if;
    end process;
    buf_rst : BUFG 
        port map ( I => rst_u, O => rst );

    export_rst_clk40: process(clk40)
    begin
        if rising_edge(clk40) then
            rst40_u <= hard_rst or soft_rst;
        end if;
    end process;
    buf_rst40 : BUFG 
        port map ( I => rst40_u, O => rst40 );


    export_rst_ipb: process(ipbclk)
    begin
        if rising_edge(ipbclk) then
            rst_ipb_u <= hard_rst or soft_rst;
            rst_ipb_ctrl <= hard_rst;
        end if;
    end process;
    buf_rst_ipb : BUFG 
        port map ( I => rst_ipb_u, O => rst_ipb );

    status_ok <= mmcm_locked and eth_locked and (not hard_rst) and (not soft_rst);
end rtl;

