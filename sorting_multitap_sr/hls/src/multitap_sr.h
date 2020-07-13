#ifndef multitap_sr_h
#define multitap_sr_h

#include <ap_int.h>

#define NTAPS 25

struct myData64 {
    ap_int<16> pt;
    ap_uint<48> stuff;
};

void sorting_multitap_sr(bool newRecord, const myData64 newValue, myData64 tap[NTAPS]);
void sorting_multitap_sr_ref(bool newRecord, const myData64 newValue, myData64 tap[NTAPS]);
#endif
