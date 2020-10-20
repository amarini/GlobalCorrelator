#include "src/phi_regionizer.h"

#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <cassert>
#include <vector>

bool readEvent(FILE *file, std::vector<Track> inputs[NSECTORS][NFIBERS]) {
    if (feof(file)) return false;

    uint32_t run, lumi; uint64_t event;
    if (fscanf(file, "event %u %u %lu\n", &run, &lumi, &event) != 3) return false;
    //printf("reading event  %u %u %lu\n", run, lumi, event);

    int nfound = 0, maxfib = 0, maxsec = 0;
    for (int s = 0; s < NSECTORS; ++s) {
        int sec; uint64_t ntracks;
        if (fscanf(file, "sector %d tracks %lu\n", &sec, &ntracks) != 2) return false;
        assert(sec == s);
        //printf("reading sector %d -> %d tracks\n", sec, int(ntracks));
        for (int f = 0; f < NFIBERS; ++f) inputs[s][f].clear();
        for (int i = 0, n = ntracks; i < n; ++i) {
            int hwPt, hwEta, hwPhi, hwCaloPtErr, hwZ0, hwCharge, hwTight;
            //printf("read track %d/%d of sector %d\n", i, n, sec);
            int ret = fscanf(file, "track ipt %d ieta %d iphi %d ipterr %d iz0 %d icharge %d iqual %d\n",
                                &hwPt, &hwEta, &hwPhi, &hwCaloPtErr, &hwZ0, &hwCharge, &hwTight);
            if (ret != 7) return false;
            Track t;
            t.pt = hwPt; t.eta = hwEta; t.phi = hwPhi;
            t.rest[0] = hwCharge;
            t.rest[1] = hwTight;
            t.rest(11, 2) = ap_int<10>(hwZ0);
            t.rest(25,12) = ap_uint<14>(hwCaloPtErr);
            inputs[s][i % NFIBERS].push_back(t);
            nfound++;
            maxfib = std::max<int>(maxfib, inputs[s][i % NFIBERS].size());
        }
        maxsec = std::max<int>(maxsec, ntracks);
    }
    printf("read %d tracks for this event. max %d tracks/sector, %d tracks/fiber\n", nfound, maxsec, maxfib);
    return true;
}


