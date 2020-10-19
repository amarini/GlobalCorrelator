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

An additional "mux" mode is implemented doing also the next steps for the preparation of the PF block inputs. It is assumed that the PF block output will run in a separate clock domain at an II>1 (II=4 is used in the example, as in the TDR).
 * build in each region a (sorted) list of the N highest pT tracks (N=24 in this example)
 * after a full TMUX period, gather in the list of N tracks from each region, buffer them in, and stream them out N/II at each clock
The idea is that the N/II streams will be sent to dual-clock FIFOs in order to perform the clock domain transition, and the fragments reassembled and fed into PF.

## Implementation status:
 * "no merge" mode:
   * working reference c++ implementation in the HLS testbench
   * HLS implementation passes synthesis and co-simulation, and standalone behavioural simulation in VHDL
   * VHDL native implementation (still in the HLS directory), that passes standalone behavioural simulation in VHDL
 * "merge 2" mode:
   * working reference c++ implementation in the HLS testbench
   * VHDL native implementation passes standalone behavioural simulation in VHDL and passes synthesis & implementation (incl. timing) as emp payload
   * HLS implementation in one go doesn't work (Vivado can't understand the dependency of the data flow), but a version in which separate slices are implemented as separate IP cores of latency=1 and II=1 works (passes HLS synthesis for all modules, and standalone behavioural simulation in VHDL)
 * "full merge" mode:
   * working reference c++ implementation in the HLS testbench
   * VHDL native implementation passes standalone behavioural simulation in VHDL and passes synthesis & implementation (incl. timing) as emp payload
   * HLS implementation in one go doesn't work (Vivado can't understand the dependency of the data flow), but a version in which separate slices are implemented as separate IP cores of latency=1 and II=1 works (passes HLS synthesis for all modules, and standalone behavioural simulation in VHDL)
 * "mux" mode:
   * working reference c++ implementation in the HLS testbench
   * VHDL native implementation passes standalone behavioural simulation in VHDL, and synthesis & implementation (incl. timing) as emp payload. The resource usage for the EMP payload is 23.4k LUTs (2%), 42.2k FFs (1.9%), 54 BRAM36 (2.5%), where the percentage are for the total of the VU9P.

## Running

In the HLS directory:
 * `run_hls_xyz.tcl` for the HLS
 * `run_vhdltb.sh` for the behavioural simulation in VHDL

For the EMP project, from the top-level directory
````
bash scripts/setupProject.sh toy_phi_regionizer --nohls
bash scrips/buildFirmware.sh toy_phi_regionizer a 
bash scrips/buildFirmware.sh toy_phi_regionizer resource-usage
````

