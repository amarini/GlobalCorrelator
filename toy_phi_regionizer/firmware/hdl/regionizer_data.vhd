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
    constant PHI_SHIFT : signed(11 downto 0) := to_signed(160, 12);

    constant NSECTORS : natural := 9;
    constant NFIBERS : natural := 2;
    constant NFIFOS : natural := NFIBERS*3;
    constant NSORTED : natural := 24;
    constant PFII : natural := 4;
    constant NSTREAM : natural := (NSORTED+PFII-1)/PFII;
end package;


