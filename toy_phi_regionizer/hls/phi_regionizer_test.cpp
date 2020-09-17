#include "src/phi_regionizer.h"

#include <cstdlib>
#include <cstdio>
#include <list>
#include <vector>

//#ifdef REGIONIZER_SMALL
//    #define NTEST 10
 //   #define TLEN  36
//#else
    #define NTEST 15
    #define TLEN  54
    //#define TLEN  10
//#endif

Track shiftedTrack(const Track & t, int phi_shift) {
    Track ret = t;
    ret.phi = ap_int<12>(t.phi.to_int() + phi_shift);
    return ret;
}
Track randTrack(int payload = -1, float prob=1) {
    Track ret;
    if (rand()/float(RAND_MAX) > prob) { clear(ret); return ret; }
    ret.pt  = (abs(rand()) % 199) + 1;
    ret.eta = (abs(rand()) % 301);
    ret.phi = (abs(rand()) % 601) - 300;
    ret.rest = (payload >= 0 ? payload : abs(rand() % 999));
    return ret;
}


struct RegionBuffer { 
    std::list<Track> fifos[NFIFOS]; 
    Track staging_area[NFIFOS/2];
    void flush() { 
        for (int j = 0; j < NFIFOS; ++j) fifos[j].clear(); 
        for (int j = 0; j < NFIFOS/2; ++j) clear(staging_area[j]);
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
            if (staging_area[j].pt != 0) {
                ret = staging_area[j];
                clear(staging_area[j]);
                break;
            }
        }
        return ret;
    }
    void pop_all(Track out[]) {
#ifdef ROUTER_M2
        for (int j = 0; j < NFIFOS/2; ++j) {
            clear(out[j]); 
            for (int f = 2*j; f < 2*j+1; ++f) {
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
struct Regionizer {
    RegionBuffer buffers[NREGIONS];
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
};

void router_ref(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NREGIONS]) {
    static Regionizer impl;
    if (newevent) impl.flush();
    impl.read_in(tracks_in);
    impl.write_out(tracks_out);

}


int main(int argc, char **argv) {
    srand(42);

    FILE *fin  = fopen("input.txt", "w");
    FILE *fref = fopen("output-ref.txt", "w");
    FILE *fout = fopen("output.txt", "w");
    FILE *fref_emp = fopen("output-ref-emp.txt", "w");
    FILE *fin_emp = fopen("input-emp.txt", "w");
    

    int frame = 0; int pingpong = 1; 
    const int latency = ALGO_LATENCY;

    bool ok = true;
    for (int itest = 0; itest < NTEST; ++itest) {
        std::vector<Track> inputs[NSECTORS][NFIBERS];
        Track output[NREGIONS][TLEN], output_ref[NREGIONS][2*TLEN];
        for (int s = 0; s < NSECTORS; ++s) {
            int ntracks = abs(rand())%3 + (TLEN/6) + itest/3; // start with some random number of tracks
            if ((itest % 2 == 1) && ((abs(rand()) % (NSECTORS/2)) == 0)) {
                ntracks += (TLEN/4 + abs(rand()) % (TLEN/2));  // in 1/2 of the events, may add some "jets" in some sectors
            }
            for (int f = 0; f < NFIBERS; ++f) {
                int ntracks_fiber = ntracks + abs(rand()) % 4; // and add a bit of randomness between the two fibers
                if (itest <= 2) ntracks_fiber = (s == 0 && f == 0 ? TLEN : 0);
                for (int i = 0; i < ntracks_fiber; ++i) {
                    inputs[s][f].push_back(randTrack(itest == 0 ? i+1 : 10*(s+1)+f+1));
                }
            }
        }
        for (int i = 0; i < TLEN; ++i, ++frame) {
            fprintf(fin,    "%05d %1d   ", frame, int(i==0));
            fprintf(stdout, "%03d %1d   ", frame, int(i==0));
            fprintf(fin_emp,  "Frame %04u : 1v%016llx", frame, uint64_t(i==0));

            Track links_in[NSECTORS][NFIBERS];
            ap_uint<64> links64_in[NSECTORS][NFIBERS];
            for (int s = 0; s < NSECTORS; ++s) {
                for (int f = 0; f < NFIBERS; ++f) {
                    clear(links_in[s][f]);
                    if (i < int(inputs[s][f].size())) {
                        links_in[s][f]  = inputs[s][f][i];
                    }
                    links64_in[s][f] = packTrack(links_in[s][f]);
                    printTrack(fin, links_in[s][f]);
                    printTrackShort(stdout, links_in[s][f]);
                    fprintf(fin_emp,  " 1v%016llx", links64_in[s][f].to_uint64());
                }
            }
            fprintf(fin, "\n");
            fprintf(fin_emp, "\n");

            Track links_out[NREGIONS], links_ref[NREGIONS];
            bool  newev_out, newev_ref = (i == 0);
#ifdef ROUTER_NOMERGE
            router_nomerge(i == 0, links_in, links_out, newev_out);
#elif defined(ROUTER_M2)
            router_m2(i == 0, links_in, links_out, newev_out);
#else
    #ifdef EMP_PACKED_64
            ap_uint<64> links64_out[NREGIONS];
            wrapped_router_monolythic(i == 0, links64_in, links64_out, newev_out);
            for (int r = 0; r < NREGIONS; ++r) links_out[r] = unpackTrack(links64_out[r]);
    #else
            router_monolythic(i == 0, links_in, links_out, newev_out);
    #endif
#endif
            router_ref(i == 0, links_in, links_ref);

            fprintf(fout, "%5d %1d   ", frame, int(newev_out));
            fprintf(fref, "%5d %1d   ", frame, int(newev_ref));
            fprintf(fref_emp, "Frame %04u : 1v%016llx", frame, uint64_t(newev_ref));
            for (int r = 0; r < NREGIONS; ++r) printTrack(fout, links_out[r]);
            for (int r = 0; r < NREGIONS; ++r) printTrack(fref, links_ref[r]);
            for (int r = 0; r < NREGIONS; ++r) fprintf(fref_emp, " 1v%016llx", packTrack(links_ref[r]).to_uint64());
            fprintf(fout, "\n");
            fprintf(fref, "\n");
            fprintf(fref_emp, "\n");

            fprintf(stdout, " | %1d  ", int(newev_ref));
            for (int r = 0; r < NREGIONS; ++r) printTrackShort(stdout, links_ref[r]);
            fprintf(stdout, " | %1d  ", int(newev_out));
            for (int r = 0; r < NREGIONS; ++r) printTrackShort(stdout, links_out[r]);
            fprintf(stdout, "\n"); fflush(stdout);

            // begin validation
            if (newev_ref) { 
                pingpong = 1-pingpong;
                for (int r = 0; r < NREGIONS; ++r) for (int k = 0; k < TLEN; ++k) clear(output_ref[r][TLEN*pingpong+k]);
            }
            for (int r = 0; r < NREGIONS; ++r) { 
                output_ref[r][TLEN*pingpong+i] = links_ref[r];
            }
            if (newev_out) {
                if (i != latency) { printf("ERROR in latency\n"); ok = false; break; }
                if (itest > 0) { 
                    for (int r = 0; r < NREGIONS; ++r) {
                        for (int k = 0; k < TLEN; ++k) {
                            if (!(output[r][k] == output_ref[r][TLEN*(1-pingpong)+k]))   {
                                printf("ERROR in region %d, object %d: expected ", r, k);
                                printTrack(stdout, output_ref[r][TLEN*(1-pingpong)+k]);
                                printf("   found "); 
                                printTrack(stdout, output[r][k]);
                                printf("\n");
                                ok = false; break; 
                            }
                        }
                    }
                    if (!ok) break; 
                }
                for (int r = 0; r < NREGIONS; ++r) for (int k = 0; k < TLEN; ++k) clear(output[r][k]);
            }
            if (frame >= latency) {
                for (int r = 0; r < NREGIONS; ++r) output[r][(frame-latency) % TLEN] = links_out[r];
            }
            // end validation
            
            if (!ok) break;
        }
        if (!ok) break;
    } 
    fclose(fin);
    fclose(fref);
    fclose(fout);
    fclose(fin_emp);
    fclose(fref_emp);

    return ok ? 0 : 1;
}
