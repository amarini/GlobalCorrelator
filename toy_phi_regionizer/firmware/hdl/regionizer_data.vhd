library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package regionizer_data is 
    type particle is record
        pt : unsigned(13 downto 0);
        eta : signed(11 downto 0);
        phi : signed(11 downto 0);
        rest : unsigned(25 downto 0);
    end record;
    type particles   is array(natural range <>) of particle;
    constant PHI_SHIFT : signed(11 downto 0) := to_signed(160, 12); -- 2*pi/9, size of a phi nonant, track finder sector or fiducial part of one PF region
    constant PHI_BORDER : signed(11 downto 0) := to_signed(58, 12); -- 0.25 (0.30 would be 69) 
    constant PHI_MARGIN_POS : signed(11 downto 0) := to_signed(+(160/2-58), 12);  -- half-width of fiducial MINUS border (half-size of gap are between sector N and sector N+2)
    constant PHI_MARGIN_NEG : signed(11 downto 0) := to_signed(-(160/2-58), 12);  -- same but with negative sign
    constant PHI_HALFWIDTH_POS : signed(11 downto 0) := to_signed(+(160/2+58), 12); -- half size of a full region (fiducial PLUS border)
    constant PHI_HALFWIDTH_NEG : signed(11 downto 0) := to_signed(-(160/2+58), 12);  

    constant PHI_CALOSHIFT    : signed(11 downto 0) := to_signed( 480,        12);  -- 2*pi/3, size of an HGCal sector
    constant PHI_CALOSHIFT1   : signed(11 downto 0) := to_signed( 320,        12);  -- 2*pi/3 - 2*pi/9, distance between center of hgcal sector 1 and pf region 1 = 2 * size of a phi nonant
    constant PHI_CALOEDGE_POS : signed(11 downto 0) := to_signed(+(480/2-58), 12);  -- +(half-size of calo sector)-border
    constant PHI_CALOEDGE_NEG : signed(11 downto 0) := to_signed(-(480/2-58), 12);  -- -(half-size of calo sector)+border

    constant NSECTORS : natural := 9;
    constant NFIBERS : natural := 2;
    constant NFIFOS : natural := NFIBERS*3;
    constant NSORTED : natural := 24;
    constant PFII : natural := 4;
    constant NSTREAM : natural := (NSORTED+PFII-1)/PFII;

    constant NCALOSECTORS : natural := 3;
    constant NCALOFIBERS : natural := 4;
    constant NCALOFIFO0 : natural := NCALOFIBERS;
    constant NCALOFIFO12 : natural := 2*NCALOFIBERS;
    constant NCALOFIFOS : natural := NCALOFIFO0+2*NCALOFIFO12;
    constant NCALOSORTED : natural := 20;
    constant NCALOSTREAM : natural := (NCALOSORTED+PFII-1)/PFII;

end package;


