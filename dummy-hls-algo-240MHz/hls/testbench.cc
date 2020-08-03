#include "src/dummy.h"
#include <cstdio>
#include <cstdlib>

int main() {
    srand(125);
    const int NDATA = TMUX*NCLK*6+10;
    w64 data[NLINKS][NDATA], in[NLINKS], out[3], refout[3];

    FILE * f_patterns_in, * f_patterns_out; char fnbuff[25]; 

    for (unsigned int itest = 0, ntest = 20; itest <= ntest; ++itest) {
        // create some input data
        bool isok = true;
        for (unsigned int j = 0; j < NLINKS; ++j) {
            for (unsigned int i = 0; i < NDATA; ++i) {
                data[j][i] = ap_uint<64>(rand() & 0xF);
            }
        }
        if (itest == 0) {
            for (unsigned int j = 0; j < NLINKS; ++j) {
                printf("L[%d]: ", j);
                for (unsigned int i = 0; i < NDATA; ++i) printf("%5d | ", int(data[j][i]));
                printf("\n");
            }
        }

        snprintf(fnbuff, 25, "patterns-in-%d.txt", itest);
        f_patterns_in = fopen(fnbuff, "w");
        snprintf(fnbuff, 25, "patterns-out-%d.txt", itest);
        f_patterns_out = fopen(fnbuff, "w");


        for (unsigned int iclock = 0; iclock <  NDATA; ++iclock) {

            fprintf(f_patterns_in,  "Frame %04u :", iclock);
            fprintf(f_patterns_out, "Frame %04u :", iclock);

            bool newev = (iclock % (TMUX*NCLK) == 0);
            refout[0] = 0;
            if (newev) { refout[1] = 0; refout[2] = 0; }

            for (unsigned int j = 0; j < NLINKS; ++j) {
                in[j] = data[j][iclock];
                fprintf(f_patterns_in, " 1v%016llx", in[j].to_uint64());
                refout[0] = std::max(refout[0], in[j]);
                refout[1] = std::max(refout[1], in[j]);
                refout[2] += (in[j] > THRESHOLD);
            }

            dummy_simple(newev, in, out);

            for (unsigned int j = 0; j < 3; ++j) {
                fprintf(f_patterns_out, " 1v%016llx", refout[j].to_uint64());
            }

            bool ok = true;
            for (unsigned int j = 0; j < 3; ++j) {
                ok = ok && (out[j] == refout[j]);
            }

            if (itest == 0) {
                printf("%04d |  ", iclock);
                for (unsigned int j = 0; j < NLINKS; ++j) printf("%6d ", int(in[j]));
                printf(" |  ");
                for (unsigned int j = 0; j < 3; ++j) printf("%6d ", int(out[j]));
                printf(" |  ");
                for (unsigned int j = 0; j < 3; ++j) printf("%6d ", int(refout[j]));
                printf(isok ? "\n" : "   <=== ERROR \n");
            }

            if (!ok) isok = false;

            fprintf(f_patterns_in, "\n");
            fprintf(f_patterns_out, "\n");
        }
        if (!isok) {
            printf("\ntest %d failed\n", itest);
            return 1;
        } else {
            printf("\ntest %d passed\n", itest);
        }
        fclose(f_patterns_in);
        fclose(f_patterns_out);
    }
    return 0;
}
