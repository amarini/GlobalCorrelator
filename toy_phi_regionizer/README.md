# Toy phi regionizer: route Track Finder input data to build regions for PF

Tracks come in from N=9 phi sectors, with two "fibers" per sector (64 bit tracks @ 360 MHz; in reality there are 3 links but tracks are 96 bits, so it's still 2 tracks per clock, and PF only uses )
PF runs in the same number N=9 of phi regions, with overlaps.
Tracks from sector (i) are always routed to region (i), and either to region (i+1) or (i-1). In this proof-of-concept implementation this depends on whether the local phi is > 0 or < 0, and the phi is shifted when the track is moved by one sector.
In the implementation, regions each have 6 input FIFO buffers, one for each possible contributing sector and fiber.

The output of the system should be one track per region per clock cycle, to be sent in a region builder implemented as the sorting multitap SR project. 
As the merging of the FIFO output to fully implement this is not yet there in the firmware, the setup can also be compiled in two "reduced" modes: 
 * "no merge" mode: all 6 FIFOs are read out at each clock &rarr; the output is 6 tracks per region
 * "merge 2"  mode: pairs of FIFOs are merged  &rarr; the output is 3 tracks per region

The whole system assumes TMUX=6, and 360 MHz (clock ratio 9), so 54 clocks per event. 
There is one additional boolean input that is set to true in the first clock cycle of the event, and one additional boolean output that becomes true when block outputs the first track of the new event.

## Implementation status:
 * "no merge" mode:
   * working reference c++ implementation in the HLS testbench
   * HLS implementation passes synthesis and co-simulation, and standalone behavioural simulation in VHDL
   * VHDL native implementation (still in the HLS directory), that passes standalone behavioural simulation in VHDL
 * "merge 2" mode:
   * working reference c++ implementation in the HLS testbench
   * HLS implementation doesn't work (requires II=2), and doesn't even pass c-simulation
   * VHDL native implementation passes standalone behavioural simulation in VHDL and meets timing 
 * "full merge" mode:
   * working reference c++ implementation in the HLS testbench
   * HLS implementation doesn't work (didn't even try), and doesn't even pass c-simulation
   * VHDL native implementation passes standalone behavioural simulation in VHDL

## Running

In the HLS directory:
 * `run_hls_xyz.tcl` for the HLS
 * `run_vhdltb.sh` for the behavioural simulation in VHDL

