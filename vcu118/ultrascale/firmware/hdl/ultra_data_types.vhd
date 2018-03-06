library ieee;
use ieee.std_logic_1164.all;

-- mimic mp7_data_types for source-level compatibility without actual dependency
package ultra_data_types is
    constant LWORD_WIDTH: integer := 32;
    type lword is record 
        data : std_logic_vector(LWORD_WIDTH-1 downto 0);
        valid : std_logic;
        start: std_logic;
        strobe: std_logic;
    end record;
    type ldata is array (natural range <>) of lword;

    constant LWORD_NULL : lword := ((others => '0'), '0', '0', '0');
end;
