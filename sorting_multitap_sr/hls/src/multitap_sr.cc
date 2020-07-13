#include "multitap_sr.h"

void sorting_multitap_sr(bool newRecord, const myData64 newValue, myData64 tap[NTAPS]) {
    #pragma HLS PIPELINE ii=1
    #pragma HLS ARRAY_PARTITION variable=tap complete
    #pragma HLS INTERFACE ap_none port=tap
    static myData64 cells[NTAPS];
    #pragma HLS ARRAY_PARTITION variable=cells complete

    bool below[NTAPS];
    #pragma HLS ARRAY_PARTITION variable=below complete
    for (int i = 0; i < NTAPS; ++i) below[i] = !newRecord && (cells[i].pt <= newValue.pt);

    for (int i = NTAPS-1; i >= 1; --i) {
        if      (below[i])  cells[i] = (below[i-1] ? cells[i-1] : newValue);
        else if (newRecord) { cells[i].pt = 0; cells[i].stuff = 0; }
    }
    if (newRecord || below[0]) cells[0] = newValue;

    // push output
    for (unsigned int i = 0; i < NTAPS; ++i) {
        #pragma HLS unroll
        tap[i] = cells[i];
    }
}

