#include "src/phi_regionizer.h"

#include <list>
#include <vector>

Track shiftedTrack(const Track & t, int phi_shift) {
    Track ret = t;
    ret.phi = ap_int<12>(t.phi.to_int() + phi_shift);
    return ret;
}


struct RegionBuffer { 
    std::list<Track> fifos[NFIFOS]; 
    Track staging_area[NFIFOS/2], queue[NFIFOS/2];
    void flush() { 
        for (int j = 0; j < NFIFOS; ++j) fifos[j].clear(); 
        for (int j = 0; j < NFIFOS/2; ++j) clear(staging_area[j]);
        for (int j = 0; j < NFIFOS/2; ++j) clear(queue[j]);
    }
    void push(int f, const Track & tk, int phi_shift=0) {
        fifos[f].push_front(shiftedTrack(tk, phi_shift));
    }
    Track pop_next() {
        Track ret; clear(ret);
        // shift data from each pair of fifos to the staging area
        for (int j = 0; j < NFIFOS/2; ++j) {
            if (staging_area[j].pt != 0) continue;
            if (!fifos[2*j].empty()) {
                staging_area[j] = fifos[2*j].back();
                fifos[2*j].pop_back(); 
            } else if (!fifos[2*j+1].empty()) {
                staging_area[j] = fifos[2*j+1].back();
                fifos[2*j+1].pop_back(); 
            }
        }
        // then from staging area to output
        for (int j = 0; j < NFIFOS/2; ++j) {
            if (staging_area[j].pt != 0 && queue[j].pt == 0) {
                queue[j] = staging_area[j];
                clear(staging_area[j]);
            }
        }
        for (int j = 0; j < NFIFOS/2; ++j) {
            if (queue[j].pt != 0) {
                ret = queue[j];
                clear(queue[j]);
                break;
            }
        }
        return ret;
    }
    void pop_all(Track out[]) {
#ifdef ROUTER_M2
        for (int j = 0; j < NFIFOS/2; ++j) {
            clear(out[j]); 
            for (int f = 2*j; f <= 2*j+1; ++f) {
                if (!fifos[f].empty()) {
                    out[j] = fifos[f].back();
                    fifos[f].pop_back(); 
                    break;
                }
            }
        }
#else
        for (int j = 0; j < NFIFOS; ++j) {
            if (!fifos[j].empty()) {
                out[j] = fifos[j].back();
                fifos[j].pop_back(); 
            } else {
                clear(out[j]);
            }
        }
#endif
    }

};
struct RegionBuilder {
    Track sortbuffer[NSORTED];
    void push(bool newevt, const Track in, Track outsorted[NSORTED]) {
        if (newevt) {
            for (int i = 0; i < NSORTED; ++i) { 
                outsorted[i] = sortbuffer[i]; 
                clear(sortbuffer[i]); 
            }
        }
        int i = 0; Track work = in;
        while (i < NSORTED && in.pt <= sortbuffer[i].pt) i++;
        while (i < NSORTED) { std::swap(work, sortbuffer[i]); i++; } 
    }
    void dump(bool newline=true) {
            printf("buff %p", &sortbuffer[0]);
            for (int i = 0; i < NSORTED; ++i) printf(" %3d.%03d", sortbuffer[i].pt.to_int(), sortbuffer[i].eta.to_int());
            if (newline) printf("\n");
    }
};
struct RegionMux {
    Track buffer[NREGIONS][NSORTED];
    unsigned int iter, ireg;
    RegionMux() { 
        iter = 0; ireg = NREGIONS; 
        for (int i = 0; i < NREGIONS; ++i) {
            for (int j = 0; j < NSORTED; ++j) clear(buffer[i][j]);
        }
    }
    bool stream(bool newevt, Track stream_out[NPFSTREAMS]) {
        if (newevt) { iter = 0; ireg = 0; }
        if (ireg < NREGIONS) {
            for (int i = 0; i < NPFSTREAMS; ++i) {
                stream_out[i] = buffer[ireg][PFLOWII*i];
            }
            for (int i = 1; i < NSORTED; ++i) {
                buffer[ireg][i-1] = buffer[ireg][i];
            }
            if (++iter == PFLOWII) {
                ireg++; iter = 0;
            }
            return true;
        } else {
            for (int i = 0; i < NPFSTREAMS; ++i) {
                clear(stream_out[i]);
            }
            return false;
        }
    }
};

struct Regionizer {
    RegionBuffer buffers[NREGIONS];
    RegionBuilder builder[NREGIONS];
    RegionMux bigmux;
    unsigned int nevt;
    Regionizer() { nevt = 0; }
    void flush() { 
        for (int i = 0; i < NREGIONS; ++i) buffers[i].flush();
    }
    void read_in(const Track in[NSECTORS][NFIBERS]) {
        for (int i = 0; i < NSECTORS; ++i) {
            for (int j = 0; j < NFIBERS; ++j) {
                const Track & tk = in[i][j];
                if (tk.pt == 0) continue;
                buffers[i].push(j, tk);
                int inext = (i+1), iprev = i+NSECTORS-1;
                if (tk.phi > 0) buffers[inext%NSECTORS].push(j+2, tk, -PHI_SHIFT);
                if (tk.phi < 0) buffers[iprev%NSECTORS].push(j+4, tk, +PHI_SHIFT);
            }
        }
    }
    void write_out(Track out[NREGIONS]) {
        for (int i = 0; i < NSECTORS; ++i) {
#ifdef ROUTER_M2
            buffers[i].pop_all(&out[i*(NFIFOS/2)]);
#elif defined(ROUTER_NOMERGE)
            buffers[i].pop_all(&out[i*NFIFOS]);
#else
            out[i] = buffers[i].pop_next();
#endif
        }
    }
    bool run(bool newevt, const Track in[NSECTORS][NFIBERS], Track out[NSORTED]) {
        if (newevt) { flush(); nevt++; }
        read_in(in);
#ifdef ROUTER_MUX
        Track routed[NREGIONS];
        write_out(routed);
        for (int i = 0; i < NREGIONS; ++i) {
            builder[i].push(newevt, routed[i], &bigmux.buffer[i][0]);
        }
        return bigmux.stream(newevt && (nevt > 1), out);
#else
        write_out(out);
        return true;
#endif
    }
};

bool router_ref(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NOUTLINKS]) {
    static Regionizer impl;
    return impl.run(newevent, tracks_in, tracks_out);
}
