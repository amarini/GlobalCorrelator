#include "src/multitap_sr.h"
#include <algorithm>

void sorting_multitap_sr_ref(bool newRecord, const myData64 newValue, myData64 tap[NTAPS]) {
    static myData64 cells[NTAPS+1]; // one extra record at the end, i.e. the first of the discarded elements

    if (newRecord) {
        for (int i = NTAPS; i >= 0; --i) { cells[i].pt = 0; cells[i].stuff = 0; }
    } else {
        // shift all cells down (drop cells[NTAP])
        for (int i = NTAPS; i > 0; --i) cells[i] = cells[i-1];
    }

    // add new value on top
    cells[0] = newValue; 
    // have it float down if necessary
    for (int i = 1; i <= NTAPS; ++i) {
        if (cells[i].pt > cells[i-1].pt) std::swap(cells[i], cells[i-1]);
    }
    for (int i = 0; i < NTAPS; ++i) {
        tap[i] = cells[i];
    }
}


