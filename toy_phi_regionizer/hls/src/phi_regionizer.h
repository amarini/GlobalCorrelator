#ifndef fifo_unit_tests_h
#define fifo_unit_tests_h

#include "ap_int.h"

struct Track {
    ap_uint<14> pt;
    ap_int<12>  eta, phi;
    ap_uint<26> rest;
};


inline void clear(Track & t) { 
    t.pt = 0; 
    t.eta = 0; t.phi = 0; t.rest = 0; 
}
inline bool operator==(const Track & one, const Track & other) { 
    if (one.pt == 0) return (other.pt == 0);
    return one.pt == other.pt && one.eta == other.eta && one.phi == other.phi && one.rest == other.rest;
}
inline ap_uint<64> packTrack(const Track & t) { 
    #pragma HLS inline
    ap_uint<64> ret = (t.pt, t.eta, t.phi, t.rest );
    return ret;
}
inline Track unpackTrack(const ap_uint<64> & word) { 
    #pragma HLS inline
    Track ret; 
    ret.pt   = word(63,50);
    ret.eta  = word(49,38);
    ret.phi  = word(37,26);
    ret.rest = word(25, 0);
    return ret;
}




#define NSECTORS 3 // 9
#define NFIBERS  2
#define NREGIONS NSECTORS
#define NFIFOS   6
#define PHI_SHIFT 200 // size of a phi sector (random number for the moment)

#define FIFO_READ_TREE // algorithm that those the 6->1 FIFO reduction with a tree

void router_monolythic(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS], bool & newevent_out);

#ifndef __SYNTHESIS__
#include <cstdio>

inline void printTrack(FILE *f, const Track & t) { 
    fprintf(f,"%3d % 4d % 4d %4d  ", t.pt.to_int(), t.eta.to_int(), t.phi.to_int(), t.rest.to_int()); // note no leading +'s or 0's, they confuse VHDL text parser
}
inline void printTrackShort(FILE *f, const Track & t) { 
    int shortphi = 0;
    if      (t.phi > 300) shortphi = +4;
    else if (t.phi > 200) shortphi = +3;
    else if (t.phi > 100) shortphi = +2;
    else if (t.phi >   0) shortphi = +1;
    else if (t.phi <-300) shortphi = -4;
    else if (t.phi <-200) shortphi = -3;
    else if (t.phi <-100) shortphi = -2;
    else if (t.phi <   0) shortphi = -1;
    fprintf(f,"%3d %+2d %02d  ", t.pt.to_int(), shortphi, t.rest.to_int());
    //fprintf(f,"%3d %02d  ", t.pt.to_int(), t.rest.to_int());
}
#endif

#endif

