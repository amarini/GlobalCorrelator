#ifndef multitap_sr_h
#define multitap_sr_h

#include <ap_int.h>

typedef ap_uint<64> w64;

#define TMUX 6
#define NLINKS   3 
#define NCLK     6 // 240 MHz
#define THRESHOLD 10

void dummy_simple(bool newEvent, const w64 links[NLINKS], w64 out[3]) ;

#endif
