
Tracks come in from 9 phi sectors, with two fibers per sector (64 bit tracks @ 360 MHz)
PF runs in 9 phi sectors. Tracks from sector (i) are always routed to sectors (i), and either to sector (i+1) or (i-1) depending on whether the local phi is > 0 or < 0.

We have 54 clock cycles to read each event (TM 6, clock ratio 9)

For the monolithic HLS approach, the module has 9 * 2 track inputs and 1 "new event" signal, and 9 track outputs + 1 "new event" signal

