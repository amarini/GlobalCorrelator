#create_clock -period 1.600 -name clk625_p [get_ports clk625_p]
create_clock -period 8.000 -name sys125_clk [get_ports sysclk125_in_p]

## Here comes the magic
set_clock_groups -asynchronous -group [ get_clocks -include_generated_clocks clk625_p ]  -group [ get_clocks -include_generated_clocks sys125_clk ] 

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

false_path {leds[*]} sys125_clk
false_path {leds[*]} clk625_p

false_path rst_in sys125_clk
false_path phy_resetb sys125_clk
