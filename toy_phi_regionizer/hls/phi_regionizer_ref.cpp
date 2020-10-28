#include "src/phi_regionizer.h"

#include <list>
#include <vector>

Track rePhiTrack(const Track & t, int phi) {
    Track ret = t;
    ret.phi = phi;
    return ret;
}



struct RegionBufferTK { 
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

struct RegionBufferCalo { 
    static const int REGION_SIZE = PHI_SHIFT;
    static const int SECTOR_SIZE = REGION_SIZE * 3;
    static const int INT_PI  = (REGION_SIZE * 9)/2;

    RegionBufferCalo() :
        ireg(999), nfifo(0), phi_center(0),
        fifos(), staging_area(), queue(), queue2()
    {
    }    
    
    RegionBufferCalo(unsigned int iregion) :
        ireg(iregion),
        nfifo((iregion % 3 == 0) ? 4 : 8),
        phi_center(iregion * REGION_SIZE),
        fifos(nfifo),
        staging_area(nfifo/2), queue(nfifo/2),  staging_area2(nfifo/4), queue2(nfifo/4)
    {
    }
    unsigned int ireg, nfifo, phi_center;
    std::vector<std::list<Track>> fifos; 
    std::vector<Track> staging_area, queue, staging_area2, queue2;

    void flush() { 
        for (auto & f : fifos) f.clear(); 
        for (auto & t : staging_area) clear(t);
        for (auto & t : queue) clear(t);
        for (auto & t : staging_area2) clear(t);
        for (auto & t : queue2) clear(t);
    }
    void maybe_push(unsigned int sector, unsigned int fiber, const Track & tk) {
        int phi_shift = int(sector) * SECTOR_SIZE - phi_center;
        int local_phi = tk.phi.to_int() + phi_shift;
        if (local_phi >= INT_PI) local_phi -= 2*INT_PI;
        if (local_phi < -INT_PI) local_phi += 2*INT_PI;
        if (std::abs(local_phi) <= REGION_SIZE/2+PHI_BORDER) {
            int ififo = fiber + ((sector == ireg/3) ? 0 : 4);
            //if (fiber == 0) printf("test calo sec %u -> reg %u: phi calo %+4d  global %+4d  local %+4d -> ififo %d\n",
            //                            sector, ireg, tk.phi.to_int(), tk.phi.to_int() + int(sector) * SECTOR_SIZE, local_phi, ififo);
            assert(ififo < nfifo);
            fifos[ififo].push_front(rePhiTrack(tk, local_phi)); // don't use shiftedTrack that that has no wrap-around
        }
        //else if (fiber == 0) printf("test calo sec %u -> reg %u: phi calo %+4d  global %+4d  local %+4d -> not accepted\n",
        //                                sector, ireg, tk.phi.to_int(), tk.phi.to_int() + int(sector) * SECTOR_SIZE, local_phi);
    }
    Track pop_next() {
        Track ret; clear(ret);
        // shift data from each pair of fifos to the staging area
        for (int j = 0; j < nfifo/2; ++j) {
            if (staging_area[j].pt != 0) continue;
            for (int i = 2*j; i <= 2*j+1; ++i) {
                if (!fifos[i].empty()) {
                    staging_area[j] = fifos[i].back();
                    fifos[i].pop_back(); 
                    break;
                }
            }
        }
        // then from staging area to queue
        for (int j = 0; j < nfifo/2; ++j) {
            if (staging_area[j].pt != 0 && queue[j].pt == 0) {
                queue[j] = staging_area[j];
                clear(staging_area[j]);
            }
        }
        // then from queue to staging2
        for (int j = 0; j < nfifo/4; ++j) {
            if (staging_area2[j].pt != 0) continue;
            for (int i = 2*j; i <= 2*j+1; ++i) {
                if (queue[i].pt != 0) {
                    staging_area2[j] = queue[i];
                    clear(queue[i]);
                    break;
                }
            }
        }
        // then from staging2 to queue2
        for (int j = 0; j < nfifo/4; ++j) {
            if (staging_area2[j].pt != 0 && queue2[j].pt == 0) {
                queue2[j] = staging_area2[j];
                clear(staging_area2[j]);
            }
        }
        // and finally out
        for (int j = 0; j < nfifo/4; ++j) {
            if (queue2[j].pt != 0) {
                ret = queue2[j];
                clear(queue2[j]);
                break;
            }
        }
        return ret;
    }
    void pop_all(Track out[]) {
        for (int j = 0; j < nfifo; ++j) {
            if (!fifos[j].empty()) {
                out[j] = fifos[j].back();
                fifos[j].pop_back(); 
            } else {
                clear(out[j]);
            }
        }
    }

};


template<unsigned int NSORT>
struct RegionBuilder {
    Track sortbuffer[NSORT];
    void push(bool newevt, const Track in, Track outsorted[NSORT]) {
        if (newevt) {
            for (int i = 0; i < NSORT; ++i) { 
                outsorted[i] = sortbuffer[i]; 
                clear(sortbuffer[i]); 
            }
        }
        int i = 0; Track work = in;
        while (i < NSORT && in.pt <= sortbuffer[i].pt) i++;
        while (i < NSORT) { std::swap(work, sortbuffer[i]); i++; } 
    }
    void dump(bool newline=true) {
            printf("buff %p", &sortbuffer[0]);
            for (int i = 0; i < NSORT; ++i) printf(" %3d.%03d", sortbuffer[i].pt.to_int(), sortbuffer[i].eta.to_int());
            if (newline) printf("\n");
    }
};

template<unsigned int NSORT, unsigned int NOUT>
struct RegionMux {
    Track buffer[NREGIONS][NSORT];
    unsigned int iter, ireg;
    RegionMux() { 
        iter = 0; ireg = NREGIONS; 
        for (int i = 0; i < NREGIONS; ++i) {
            for (int j = 0; j < NSORT; ++j) clear(buffer[i][j]);
        }
    }
    bool stream(bool newevt, Track stream_out[NOUT]) {
        if (newevt) { iter = 0; ireg = 0; }
        if (ireg < NREGIONS) {
            for (int i = 0; i < NOUT; ++i) {
                stream_out[i] = buffer[ireg][PFLOWII*i];
            }
            for (int i = 1; i < NSORT; ++i) {
                buffer[ireg][i-1] = buffer[ireg][i];
            }
            if (++iter == PFLOWII) {
                ireg++; iter = 0;
            }
            return true;
        } else {
            for (int i = 0; i < NOUT; ++i) {
                clear(stream_out[i]);
            }
            return false;
        }
    }
};

struct Regionizer {
    RegionBufferTK buffers[NREGIONS];
    RegionBuilder<NSORTED> builder[NREGIONS];
    RegionMux<NSORTED,NPFSTREAMS> bigmux;
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
                bool link_next = tk.phi >= +(PHI_SHIFT/2-PHI_BORDER);
                bool link_prev = tk.phi <= -(PHI_SHIFT/2-PHI_BORDER);
                if (link_next) buffers[inext%NSECTORS].push(j+2, tk, -PHI_SHIFT);
                if (link_prev) buffers[iprev%NSECTORS].push(j+4, tk, +PHI_SHIFT);
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


struct CaloRegionizer {
    RegionBufferCalo buffers[NREGIONS];
    RegionBuilder<NCALOSORTED> builder[NREGIONS];
    RegionMux<NCALOSORTED,NCALOPFSTREAMS> bigmux;
    unsigned int nevt;
    CaloRegionizer() { 
        for (int r = 0; r < NREGIONS; ++r) buffers[r] = RegionBufferCalo(r);
        nevt = 0; 
    }
    void flush() { 
        for (int i = 0; i < NREGIONS; ++i) buffers[i].flush();
    }
    void read_in(const Track in[NCALOSECTORS][NCALOFIBERS]) {
        for (int i = 0; i < NCALOSECTORS; ++i) {
            for (int j = 0; j < NCALOFIBERS; ++j) {
                if (in[i][j].pt == 0) continue;
                for (int r = 0; r < NREGIONS; ++r) {
                    buffers[r].maybe_push(i,j,in[i][j]);
                }
            }
        }
    }
    void write_out(Track out[NCALOOUT]) {
        for (unsigned int i = 0, offs = 0; i < NREGIONS; ++i) {
#if defined(ROUTER_NOMERGE)
            buffers[i].pop_all(&out[offs]);
            offs += buffers[i].nfifo;
#else
            out[i] = buffers[i].pop_next();
#endif
        }
    }
    bool run(bool newevt, const Track in[NCALOSECTORS][NCALOFIBERS], Track out[NCALOOUT]) {
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


bool router_calo_ref(bool newevent, const Track tracks_in[NCALOSECTORS][NCALOFIBERS], Track tracks_out[]) {
    static CaloRegionizer impl;
    return impl.run(newevent, tracks_in, tracks_out);
}
