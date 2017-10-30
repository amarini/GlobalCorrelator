library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pftm_constants.all;

package pftm_data_types is
    subtype pt_t is signed(15 downto 0);
    subtype etaphi_t is signed(9 downto 0);

    type particle is record
        pt  : pt_t;
        eta : etaphi_t;
        phi : etaphi_t;
        emPt : pt_t;
        isEM : std_logic;
    end record;

    type particles is array(natural range <>) of particle;
    subtype region is particles(N_OBJ-1 downto 0);
    type regions is array(natural range <>) of region;

    subtype word32 is std_logic_vector(31 downto 0);
    type words32 is array(natural range <>) of word32;
 
    function null_particle return particle;
    function to_etaphi(constant ieta : integer) return etaphi_t;
    function to_pt(constant ipt : integer) return pt_t;
    function to_32b_hi(constant p : particle) return word32;
    function to_32b_lo(constant p : particle) return word32;
    function to_particle(constant hi : word32; constant lo : word32) return particle;
end;

package body pftm_data_types is

    function null_particle return particle is
    begin
        return (pt => (others=>'0'), eta => (others=>'0'), phi => (others=>'0'), emPt => (others=>'0'), isEM => '0');
    end;

    function to_etaphi(constant ieta : integer) return etaphi_t is
    begin
        return to_signed(ieta, etaphi_t'length);
    end;

    function to_pt(constant ipt : integer) return pt_t is
    begin
        return to_signed(ipt, pt_t'length);
    end;
    
    function to_32b_hi(constant p : particle) return word32 is
    variable ret : word32;
    begin
        ret(31 downto 0) := (others => '0');
        ret(20 downto 0) := p.isEM & std_logic_vector(p.phi) & std_logic_vector(p.eta);
        return ret;
    end;

    function to_32b_lo(constant p : particle) return word32 is
    variable ret : word32;
    begin
        ret(31 downto 16) := std_logic_vector(p.emPt);
        ret(15 downto  0) := std_logic_vector(p.pt);
        return ret;
    end;

    function to_particle(constant hi : word32; constant lo : word32) return particle is
    begin
        return (pt => pt_t(lo(15 downto 0)), 
                eta => etaphi_t(hi(9 downto 0)), 
                phi => etaphi_t(hi(19 downto 10)),
                emPt => pt_t(lo(31 downto 15)),
                isEM => hi(20));
    end;
end;
