#include "dummy.h"
#include <cassert>

void dummy_simple(bool newEvent, const w64 links[NLINKS], w64 out[3]) {
    #pragma HLS PIPELINE ii=1
    #pragma HLS ARRAY_PARTITION variable=links complete
    #pragma HLS ARRAY_PARTITION variable=out complete
    //#pragma HLS INTERFACE ap_none port=out

    w64 this_best;
    static w64 evt_best, count_thr;

    this_best = links[0];
    for (int i = 1; i < NLINKS; ++i) {
        #pragma HLS unroll
        if (links[i] > this_best) this_best = links[i];
    }
    
    evt_best = (newEvent || this_best > evt_best) ? this_best : evt_best;

    ap_uint<4> n10 = 0;
    for (int i = 0; i < NLINKS; ++i) {
        #pragma HLS unroll
        if (links[i] > THRESHOLD) n10++;
    }
    
    count_thr = newEvent ? w64(n10) : w64(count_thr + n10);

    out[0] = this_best;
    out[1] = evt_best;
    out[2] = count_thr;
}
