library std;
use std.textio.all;
use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use work.pftm_data_types.all;
use work.pftm_constants.all;

package pftm_mp7_textio is
    procedure read_mp7_word32( variable L: inout line; variable w : out word32; variable valid : out std_logic );
    procedure write_mp7_word32(variable L: inout line; variable w : in  word32; variable valid : in std_logic );

    procedure read_mp7_frame( file F: text; 
                          variable data : out words32(N_SECTORS-1 downto 0);
                          variable valid : out std_logic );
    procedure write_mp7_frame(file F: text; 
                          variable frame : integer;
                          variable data : in words32(2*N_OBJ-1 downto 0);
                          variable valid : in std_logic );
end;

package body pftm_mp7_textio is
    procedure read_mp7_word32( variable L: inout line; variable w : out word32; variable valid : out std_logic ) is
        variable str : string(1 to 11);
        variable Ltmp : line;
    begin
        read(L, str);
        --report "read string of length " & integer'image(str'length) & ": ==>" & str & "<==";
        if str(2 to 2) = "1" then
            valid := '1';
        else
            valid := '0';
        end if; 
        write(Ltmp, str(4 to 11));
        hread(Ltmp, w);
    end procedure;

    procedure write_mp7_word32( variable L: inout line; variable w : in word32; variable valid : std_logic ) is
    begin
        write(L, string'(" "));
        write(L, valid);
        write(L, string'("v"));
        hwrite(L, w);
    end procedure;

    procedure read_mp7_frame(file F: text; 
                             variable data : out words32(N_SECTORS-1 downto 0);
                             variable valid : out std_logic ) is
        variable L : line;
        variable id    : string(1 to 5);
        variable iframe: integer;
        variable colon : string(1 to 2);
        variable this_valid : std_logic;
        variable all_valid : std_logic;
    begin
        readline(F, L);
        loop -- skip lines that don't start with Frame, e.g. headers
            exit when endfile(F) or (L.all'length > 5 and L.all(1 to 5) = "Frame");
            readline(F, L);
        end loop;
        --report "read line of length " & integer'image(L.all'length);
        if L.all'length = 0 or L.all(1 to 5) /= "Frame" then
            valid := '0'; data := (others => (others => '0'));
        else
            read(L, id); read(L, iframe); read(L, colon);
            --report "read frame " & integer'image(ifame);
            all_valid := '1';
            for i in 0 to N_SECTORS-1 loop
                read_mp7_word32(L, data(i), this_valid);
                all_valid := (all_valid and this_valid);
            end loop;
            valid := all_valid;
        end if;
    end procedure;

    procedure write_mp7_frame(file F: text; 
                          variable frame : integer;
                          variable data : in words32(2*N_OBJ-1 downto 0);
                          variable valid : in std_logic ) is
        variable L : line;
    begin
        write(L, string'("Frame ")); 
        write(L, frame, field => 4); 
        write(L, string'(" :"));  
        for i in 0 to 2*N_OBJ-1 loop
            write_mp7_word32(L, data(i), valid);
        end loop;
        writeline(F, L);
    end procedure;
end;
