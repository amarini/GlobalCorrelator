#ifndef fifo_unit_tests_h
#define fifo_unit_tests_h

#include "ap_int.h"

struct Track {
    ap_uint<14> pt;
    ap_int<12>  eta, phi;
    ap_uint<24> rest;
};


inline void clear(Track & t) { 
    t.pt = 0; 
    t.eta = 0; t.phi = 0; t.rest = 0; 
}

#define NSECTORS 3 // 9
#define NFIBERS  2
#define NREGIONS NSECTORS
#define NFIFOS   6
#define PHI_SHIFT 200 // size of a phi sector (random number for the moment)

void router_monolythic(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS], bool & newevent_out);


#endif

