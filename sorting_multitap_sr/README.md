# `sorting_multitap_sr`: a multitap shift register with pT sorting

A module that streams in objects serially, sorts them by pT on input, and outputs in parallel the top N candidates. 

Objects are 64-bit, with a 16-bit pT, and the shift register is implemented using fabric resources, FFs and LUTs, in order to have a parallel output.

See parent directory for building instructions
