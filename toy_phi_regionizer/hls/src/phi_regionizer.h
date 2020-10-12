#ifndef fifo_unit_tests_h
#define fifo_unit_tests_h

#include "ap_int.h"
#include "hls_stream.h"

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



//#define REGIONIZER_SMALL
//#define ROUTER_NOMERGE
//#define ROUTER_M2

#ifdef REGIONIZER_SMALL
#define NSECTORS 3
#else 
#define NSECTORS 9
#endif

#define NFIBERS  2
#define NFIFOS   6
#define NSORTED  28
#define PFLOWII  4
#define NPFSTREAMS ((NSORTED+PFLOWII-1)/PFLOWII)
#define NREGIONS NSECTORS

#ifdef ROUTER_MUX
    #define NOUTLINKS NPFSTREAMS
    #define ALGO_LATENCY 3
#elif defined(ROUTER_NOMERGE)
    #define NOUTLINKS NSECTORS*NFIFOS
    #define ALGO_LATENCY 2
#elif defined(ROUTER_M2)
    #define NOUTLINKS NSECTORS*(NFIFOS/2)
    #define ALGO_LATENCY 1
#else
    #define NOUTLINKS NSECTORS
    #define ALGO_LATENCY 3
#endif

#define PHI_SHIFT 200 // size of a phi sector (random number for the moment)

void router_monolythic(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS], bool & newevent_out);
void router_nomerge(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NOUTLINKS], bool & newevent_out);
void router_m2(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NOUTLINKS], bool & newevent_out);

void wrapped_router_monolythic(bool newevent, const ap_uint<64> tracks_in[NSECTORS][NFIBERS], ap_uint<64> tracks_out[NSECTORS], bool & newevent_out);

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
    //fprintf(f,"%3d %+2d %02d  ", t.pt.to_int(), shortphi, t.rest.to_int());
    fprintf(f,"%3d.%04d ", t.pt.to_int(), t.rest.to_int());
}
#endif

#endif

