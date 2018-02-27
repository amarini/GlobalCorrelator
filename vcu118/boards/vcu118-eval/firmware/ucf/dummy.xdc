
# Also using 125 MHz system clock from the board
set_property IOSTANDARD LVDS [get_ports sysclk125_in_p]
set_property IOSTANDARD LVDS [get_ports sysclk125_in_n]
set_property PACKAGE_PIN AY24 [get_ports sysclk125_in_p]
set_property PACKAGE_PIN AY23 [get_ports sysclk125_in_n]

# Table 3-29 of UG1224 VCU118 board user guide
set_property IOSTANDARD LVCMOS12 [get_ports {leds[*]}]
set_property PACKAGE_PIN AT32 [get_ports {leds[0]}]
set_property PACKAGE_PIN AV34 [get_ports {leds[1]}]
set_property PACKAGE_PIN AY30 [get_ports {leds[2]}]
set_property PACKAGE_PIN BB32 [get_ports {leds[3]}]
set_property PACKAGE_PIN BF32 [get_ports {leds[4]}]
set_property PACKAGE_PIN AU37 [get_ports {leds[5]}]
set_property PACKAGE_PIN AV36 [get_ports {leds[6]}]
set_property PACKAGE_PIN BA37 [get_ports {leds[7]}]
# push-button SW 10 pin GPIO_SW_N
set_property IOSTANDARD LVCMOS18 [get_ports rst_in]
set_property IOSTANDARD LVCMOS18 [get_ports rst_in1]
set_property IOSTANDARD LVCMOS18 [get_ports rst_in2]
set_property PACKAGE_PIN BB24 [get_ports rst_in]
set_property PACKAGE_PIN BE23 [get_ports rst_in1]
set_property PACKAGE_PIN BF22 [get_ports rst_in2]

set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 31.9 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.PERSIST YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]

set_property IOSTANDARD LVCMOS12 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN B17 [get_ports dip_sw[0]]
set_property PACKAGE_PIN G16 [get_ports dip_sw[1]]
set_property PACKAGE_PIN J16 [get_ports dip_sw[2]]
set_property PACKAGE_PIN D21 [get_ports dip_sw[3]]

############  Receive Clock
set_property IOSTANDARD LVDS [get_ports clk625_p]
set_property IOSTANDARD LVDS [get_ports clk625_n]
set_property PACKAGE_PIN AT22 [get_ports clk625_p]
set_property PACKAGE_PIN AU22 [get_ports clk625_n]

 
############  Other controls 
set_property IOSTANDARD LVCMOS18 [get_ports phy_on]
set_property IOSTANDARD LVCMOS18 [get_ports phy_resetb]
set_property PACKAGE_PIN AR24 [get_ports phy_on]
set_property PACKAGE_PIN BA21 [get_ports phy_resetb]


set_property IOSTANDARD LVCMOS18 [get_ports phy_on]
set_property IOSTANDARD LVCMOS18 [get_ports phy_resetb]
set_property PACKAGE_PIN AR24 [get_ports phy_on]
set_property PACKAGE_PIN BA21 [get_ports phy_resetb]

set_property IOSTANDARD LVCMOS18 [get_ports phy_mdio]
set_property IOSTANDARD LVCMOS18 [get_ports phy_mdc]
set_property PACKAGE_PIN AR23 [get_ports phy_mdio]
set_property PACKAGE_PIN AV23 [get_ports phy_mdc]

############  Receive Pins 
#IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports rxn]
set_property IOSTANDARD LVDS [get_ports rxp]
# Equalization can be set to EQ_LEVEL0-4 based on the loss in the channel. EQ_NONE is an invalid option
set_property EQUALIZATION EQ_LEVEL0 [get_ports rxn]
set_property EQUALIZATION EQ_LEVEL0 [get_ports rxp]
#DQS_BIAS is to be set to TRUE if internal DC biasing is used - this is recommended.
#If the signal is biased externally on the board, should be set to FALSE
set_property DQS_BIAS TRUE [get_ports rxn]
set_property DQS_BIAS TRUE [get_ports rxp]
# DIFF_TERM is to be set to TERM_100 if internal Diff term is used - this is
#recommended. If differential termination is external on the board, should be set to TERM_NONE
set_property DIFF_TERM_ADV TERM_100 [get_ports rxn]
set_property DIFF_TERM_ADV TERM_100 [get_ports rxp]
set_property PACKAGE_PIN AV24 [get_ports rxn]
set_property PACKAGE_PIN AU24 [get_ports rxp]

############  Transmit Pins
#LVDS_PRE_EMPHASIS can be set to TRUE/FALSE based on loss in the line if pre-emphasis
#is desired or not. Note, if PRE -emphasis is desired, ENABLE_PRE_EMPHASIS attribute
#in TXBITSLICE needs to be set to TRUE as well.
set_property LVDS_PRE_EMPHASIS FALSE [get_ports txn]
set_property LVDS_PRE_EMPHASIS FALSE [get_ports txp]
#IO standard has to be LVDS
set_property IOSTANDARD LVDS [get_ports txn]
set_property IOSTANDARD LVDS [get_ports txp]
set_property PACKAGE_PIN AV21 [get_ports txn]
set_property PACKAGE_PIN AU21 [get_ports txp]

