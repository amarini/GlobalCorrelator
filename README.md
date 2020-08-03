# EMP framework demos for Correlator Trigger Layer 1 firmware pieces

## General instructions

This is a collection of simple modules that can be build as firmware bitfiles for the VCU118 dev kit.
Many have an HLS IP core and a very simple VHDL wrapper around.

To setup a project, from the top-level directy of this project do `./scripts/setupProject.sh project_name`, 
which will setup the prerequisites (ipbb, ipbus, emp-fwk, ...), create the vivado project and if necessary compile the IP core from HLS.

The script `./scripts/buildFirmware.sh` can then be used to build firmware.

## Modules

### `tdemux`: a time-demultiplexer from TM 18 to TM 6

A module that reads from 3 links corresponding to 3 different time slices at TM 18 with time offsets 0 BX, 6 BX, 12 BX, and reassembles the frames outputing events at TM 6.
Internally, it uses 6 BRAM36, to have the bandwith to store 3 x 64 bits input data.

### `sorting_multitap_sr`: a multitap shift register with pT sorting

A module that streams in objects serially, sorts them by pT on input, and outputs in parallel the top N candidates. 

Objects are 64-bit, with a 16-bit pT, and the shift register is implemented using fabric resources, FFs and LUTs, in order to have a parallel output.

### `dummy-hls-algo-240MHz`: example interfacing the 360 MHz links with a 240 MHz HLS IP core

Independent clock FIFOs used to ferry the data across the clock domain crossing, implemented with FIFO36E2 primitives (instantiated in VHDL).
The IP core runs at II=1 taking in 3 64-bit words plus a 1-bit signal marking the start of a new event (every 6 BX)
