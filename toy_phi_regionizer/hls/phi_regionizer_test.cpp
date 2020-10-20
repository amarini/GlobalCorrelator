#include "src/phi_regionizer.h"

#include <cstdlib>
#include <cstdio>
#include <vector>

#ifdef REGIONIZER_SMALL
    #define NTEST 10
    #define TLEN  36
#else
    #define NTEST 50
    #define TLEN  54
    //#define TLEN  10
#endif

Track randTrack(int payload = -1, float prob=1) {
    Track ret;
    if (rand()/float(RAND_MAX) > prob) { clear(ret); return ret; }
    ret.pt  = (abs(rand()) % 199) + 1;
    ret.eta = (abs(rand()) % 301);
    ret.phi = (abs(rand()) % 601) - 300;
    ret.rest = (payload >= 0 ? payload : abs(rand() % 999));
    return ret;
}

bool router_ref(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NOUTLINKS]) ;

int main(int argc, char **argv) {
    srand(42);

    FILE *fin  = fopen("input.txt", "w");
    FILE *fref = fopen("output-ref.txt", "w");
    FILE *fout = fopen("output.txt", "w");
    FILE *fref_emp = fopen("output-ref-emp.txt", "w");
    FILE *fin_emp = fopen("input-emp.txt", "w");
    

    int frame = 0; int pingpong = 1; 
    const int latency = ALGO_LATENCY;

    bool ok = true, break_next = false;
    for (int itest = 0; itest < NTEST && !break_next; ++itest) {
        std::vector<Track> inputs[NSECTORS][NFIBERS];
        Track output[NOUTLINKS][TLEN], output_ref[NOUTLINKS][2*TLEN], debug_out[NSECTORS*(NFIFOS+NFIFOS/2)]; ap_uint<8> debug_flags[NSECTORS*(NFIFOS+NFIFOS/2)];
        for (int s = 0; s < NSECTORS; ++s) {
            int ntracks = abs(rand())%3 + (TLEN/6) + itest/(NTEST/5); // start with some random number of tracks
            if ((itest % 2 == 1) && ((abs(rand()) % (NSECTORS/2)) == 0)) {
                ntracks += (TLEN/4 + abs(rand()) % (TLEN/2));  // in 1/2 of the events, may add some "jets" in some sectors
            }
            for (int f = 0; f < NFIBERS; ++f) {
                int ntracks_fiber = ntracks + abs(rand()) % 4; // and add a bit of randomness between the two fibers
                if (itest <= 2) ntracks_fiber = (s == 0 && f == 0 ? TLEN : 0);
                ntracks_fiber /= 4;
                for (int i = 0; i < ntracks_fiber; ++i) {
                    inputs[s][f].push_back(randTrack(itest <= 2 ? 100*itest+i+1 : 100*itest+10*(s+1)+f+1));
                }
            }
        }
        for (int i = 0; i < TLEN; ++i, ++frame) {
            Track links_in[NSECTORS][NFIBERS];
            ap_uint<64> links64_in[NSECTORS][NFIBERS];
            for (int s = 0; s < NSECTORS; ++s) {
                for (int f = 0; f < NFIBERS; ++f) {
                    clear(links_in[s][f]);
                    if (i < int(inputs[s][f].size())) {
                        links_in[s][f]  = inputs[s][f][i];
                    }
                    links64_in[s][f] = packTrack(links_in[s][f]);
                }
            }

            Track links_out[NOUTLINKS], links_ref[NOUTLINKS];
            bool good = true, newev_out, newev_ref = (i == 0);
            bool ref_good = router_ref(i == 0, links_in, links_ref);

#ifdef ROUTER_NOMERGE
            router_nomerge(i == 0, links_in, links_out, newev_out);
#elif defined(ROUTER_M2)
            router_m2(i == 0, links_in, links_out, newev_out);
#elif defined(ROUTER_MUX)
            newev_out = 0;
            for (int j = 0; j < NOUTLINKS; ++j) clear(links_out[j]); 
#else
    #ifdef EMP_PACKED_64
            ap_uint<64> links64_out[NOUTLINKS];
            wrapped_router_monolythic(i == 0, links64_in, links64_out, newev_out);
            for (int r = 0; r < NOUTLINKS; ++r) links_out[r] = unpackTrack(links64_out[r]);
    #else
            //router_full_d(i == 0, links_in, links_out, newev_out, debug_out, debug_flags);
            router_full(i == 0, links_in, links_out, newev_out);
    #endif
#endif

            fprintf(fin,    "%05d %1d   ", frame, int(i==0));
            fprintf(fin_emp,  "Frame %04u : 1v%016llx", frame, uint64_t(i==0));
            if (itest <= 4) fprintf(stdout, "%03d %1d   ", frame, int(i==0));
            for (int s = 0; s < NSECTORS; ++s) {
                for (int f = 0; f < NFIBERS; ++f) {
                    printTrack(fin, links_in[s][f]);
                    fprintf(fin_emp,  " 1v%016llx", links64_in[s][f].to_uint64());
                    if ((s == 0 || s == 1 || s == NSECTORS-1) && itest <= 4) printTrackShort(stdout, links_in[s][f]);
                }
            }
            fprintf(fin, "\n");
            fprintf(fin_emp, "\n");


            fprintf(fout, "%5d %1d %1d   ", frame, int(good), int(newev_out && good));
            fprintf(fref, "%5d %1d %1d   ", frame, int(ref_good), int(ref_good && newev_ref));
            fprintf(fref_emp, "Frame %04u : 1v%016llx", frame, uint64_t(1*newev_ref+2*ref_good));
            for (int r = 0; r < NOUTLINKS; ++r) printTrack(fout, links_out[r]);
            for (int r = 0; r < NOUTLINKS; ++r) printTrack(fref, links_ref[r]);
            for (int r = 0; r < NOUTLINKS; ++r) fprintf(fref_emp, " 1v%016llx", packTrack(links_ref[r]).to_uint64());
            fprintf(fout, "\n");
            fprintf(fref, "\n");
            fprintf(fref_emp, "\n");

            if (itest <= 4) {
                fprintf(stdout, " | %1d %1d  ", int(ref_good), int(ref_good && newev_ref));
                for (int r = 0; r < NOUTLINKS && r < 6; ++r) printTrackShort(stdout, links_ref[r]);
                fprintf(stdout, " | %1d %1d  ", int(good), int(newev_out && good));
                for (int r = 0; r < NOUTLINKS && r < 6; ++r) printTrackShort(stdout, links_out[r]);
                fprintf(stdout, " | ");
                //for (int i = 0; i < NFIFOS+NFIFOS/2; ++i) { 
                //    printTrackShort(stdout, debug_out[0*(NFIFOS+NFIFOS/2)+i]); 
                //    for (int j = 0; j < 2; ++j) printf("%1d", int(debug_flags[0*(NFIFOS+NFIFOS/2)+i][j]));
                //    printf(" ");
                //}
                fprintf(stdout, "\n"); fflush(stdout);
            }

#ifdef NO_VALIDATE
            continue;
#endif
            // begin validation
            if (newev_ref) { 
                pingpong = 1-pingpong;
                for (int r = 0; r < NOUTLINKS; ++r) for (int k = 0; k < TLEN; ++k) clear(output_ref[r][TLEN*pingpong+k]);
            }
            for (int r = 0; r < NOUTLINKS; ++r) { 
                output_ref[r][TLEN*pingpong+i] = links_ref[r];
            }
            if (newev_out) {
                if (i != latency) { printf("ERROR in latency\n"); ok = false; break; }
                if (itest > 1) { 
                    for (int r = 0; r < NOUTLINKS; ++r) {
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
                for (int r = 0; r < NOUTLINKS; ++r) for (int k = 0; k < TLEN; ++k) clear(output[r][k]);
            }
            if (frame >= latency) {
                for (int r = 0; r < NOUTLINKS; ++r) output[r][(frame-latency) % TLEN] = links_out[r];
            }
            // end validation
            
            if (!ok) break_next = true;
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
