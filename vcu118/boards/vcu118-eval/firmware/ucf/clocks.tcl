# Clocks

## 300 MHz system input clock used to derive all data & ipbus clocks
create_clock -name main_clk -period 3.333 [get_ports sysclk_in_p]

## 625 MHz clock from external ethernet (for clocking the ethernet domain)
# create_clock -period 1.600 -name sgmii_clk [get_ports clk625_p]
### this is already done by the core in Vivado 2017.4

## Free-running system 125 MHz clock (used only to time the rest signals to the ethernet device)
create_clock -period 8.000 -name sys125_clk [get_ports sysclk125_in_p]

## Here comes the magic
set_clock_groups -asynchronous -group [ get_clocks -include_generated_clocks main_clk ]  -group [ get_clocks -include_generated_clocks clk625_p ]  -group [ get_clocks -include_generated_clocks sys125_clk ] 

proc false_path {patt clk} {
    set p [get_ports -quiet $patt -filter {direction != out}]
    if {[llength $p] != 0} {
        set_input_delay 0 -clock [get_clocks $clk] [get_ports $patt -filter {direction != out}]
        set_false_path -from [get_ports $patt -filter {direction != out}]
    }
    set p [get_ports -quiet $patt -filter {direction != in}]
    if {[llength $p] != 0} {
       	set_output_delay 0 -clock [get_clocks $clk] [get_ports $patt -filter {direction != in}]
	    set_false_path -to [get_ports $patt -filter {direction != in}]
	}
}

false_path {leds[*]} main_clk
false_path {rst_in[*]} sys125_clk
false_path {dip_sw[*]} sys125_clk
false_path phy_resetb sys125_clk
false_path phy_mdio sys125_clk
false_path phy_mdc sys125_clk
