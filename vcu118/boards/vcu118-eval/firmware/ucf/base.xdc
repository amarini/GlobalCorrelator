# FROM UG1224 VCU118 board user guide, chapter 3, section Linear BPI Flash Memory
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property CONFIG_MODE BPI16 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
##set_property CFGBVS GND [current_design] ## not on ultrascale+
set_property CONFIG_VOLTAGE 1.8 [current_design]

# FROM UG899 IO & Clock Planning, chapter 2, "Setting Device Configuration Modes"
# keep configuration pin reserved for configuration
set_property BITSTREAM.CONFIG.PERSIST YES [current_design]
