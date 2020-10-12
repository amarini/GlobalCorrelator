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
end package;


