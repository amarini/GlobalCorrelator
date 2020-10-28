library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package regionizer_data is 
    type particle is record
        pt : std_logic_vector(13 downto 0);
        eta : std_logic_vector(11 downto 0);
        phi : std_logic_vector(11 downto 0);
        rest : std_logic_vector(25 downto 0);
    end record;
    type particles   is array(natural range <>) of particle;

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


