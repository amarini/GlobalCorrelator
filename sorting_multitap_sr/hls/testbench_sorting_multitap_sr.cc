#include "src/multitap_sr.h"
#include <cstdio>
#include <cstdlib>

int main() {
    srand(125);
    const int NDATA = NTAPS+10;
    myData64 a[NDATA], ret_tap[NTAPS], ref_tap[NTAPS];
    for (unsigned int itest = 0, ntest = 20; itest <= ntest; ++itest) {
        // create some input data
        for (unsigned int i = 0; i < NDATA; ++i) {
            a[i].pt    = ap_int<16>(rand() % 50); // intentionally narrow range to get some equals
            a[i].stuff = ap_uint<48>(rand() & 0xFFFF);
        }
        if (itest <= 3) {
            printf("input  A[]:  ");
            for (unsigned int i = 0; i < NDATA; ++i) printf(" #%02u = [ %2d; %4X ] ", i, int(a[i].pt), a[i].stuff.to_uint());
            printf("\n");
        }

        for (unsigned int iclock = 0; iclock <  NDATA; ++iclock) {
            bool ok = true, print = false;
            print = (itest <= 3);
            sorting_multitap_sr(iclock == 0, a[iclock], ret_tap);
            sorting_multitap_sr_ref(iclock == 0, a[iclock], ref_tap);
            for (unsigned int icheck = 0; icheck < NTAPS; ++icheck) {
                if (ret_tap[icheck].pt != ref_tap[icheck].pt || ret_tap[icheck].stuff != ref_tap[icheck].stuff ) {
                    printf("ERROR: sorting multitap_sr_push_simple: test %2u clock %2u: ret_tap[%2d] = [ %2d; %4X ] while [ %2d; %4X ]  expected\n", 
                            itest, iclock, icheck,  int(ret_tap[icheck].pt), ret_tap[icheck].stuff.to_uint(),  int(ref_tap[icheck].pt), ref_tap[icheck].stuff.to_uint());
                    ok = false;
                }
            }
            if (print || !ok) {
                printf("output  @%2u: ", iclock);
                for (unsigned int i = 0; i < NTAPS; ++i) printf(" #%02u = [ %2d; %4X ] ", i, int(ret_tap[i].pt), ret_tap[i].stuff.to_uint());
                printf("\n");
                printf("expect  @%2u: ", iclock);
                for (unsigned int i = 0; i < NTAPS; ++i) printf(" #%02u = [ %2d; %4X ] ", i, int(ref_tap[i].pt), ref_tap[i].stuff.to_uint());
                printf("\n");
                if (!ok) return 1;
            }

        }

        printf("test %u passed\n", itest);
    }
}
