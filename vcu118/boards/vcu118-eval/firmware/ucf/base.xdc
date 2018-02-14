set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 31.9 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
##set_property CFGBVS GND [current_design] ## not on ultrascale+
set_property CONFIG_VOLTAGE 1.8 [current_design]

# FROM UG899 IO & Clock Planning, chapter 2, "Setting Device Configuration Modes"
# keep configuration pin reserved for configuration
set_property BITSTREAM.CONFIG.PERSIST YES [current_design]

