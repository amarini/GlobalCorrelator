#include "src/phi_regionizer.h"

#include <cstdlib>
#include <cstdio>
#include <vector>

#ifdef REGIONIZER_SMALL
    #define TLEN  36
#else
    #define TLEN  54
    //#define TLEN  10
#endif

bool router_ref(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NOUTLINKS]) ;
bool readEvent(FILE *file, std::vector<Track> inputs[NSECTORS][NFIBERS]) ;


int main(int argc, char **argv) {
    FILE *fMC  = fopen("trackDump_hgcalPos.txt", "r");
    if (!fMC) return 2;

    FILE *fin  = fopen("input.txt", "w");
    FILE *fref = fopen("output-ref.txt", "w");
    FILE *fout = fopen("output.txt", "w");
    FILE *fref_emp = fopen("output-ref-emp.txt", "w");
    FILE *fin_emp = fopen("input-emp.txt", "w");
    

    int frame = 0; int pingpong = 1; 
    int latency = -1;

    bool ok = true, break_next = false;
    for (int itest = 0; itest < 10000; ++itest) {
        std::vector<Track> inputs[NSECTORS][NFIBERS];
        Track output[NOUTLINKS][TLEN], output_ref[NOUTLINKS][2*TLEN];

        if (!readEvent(fMC, inputs)) break;

        for (int i = 0; i < TLEN; ++i, ++frame) {
            Track links_in[NSECTORS][NFIBERS];
            ap_uint<64> links64_in[NSECTORS][NFIBERS];
            for (int s = 0; s < NSECTORS; ++s) {
                for (int f = 0; f < NFIBERS; ++f) {
                    clear(links_in[s][f]);
                    if (i == TLEN-1) continue; // emp protocol, must leave one null frame at the end
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
                fprintf(stdout, "\n"); fflush(stdout);
            }

#ifdef NO_VALIDATE
            continue;
#endif
            // begin validation
            if (newev_ref) { 
                pingpong = 1-pingpong;
                for (int r = 0; r < NCALOOUT; ++r) for (int k = 0; k < TLEN; ++k) clear(output_ref[r][TLEN*pingpong+k]);
            }
            for (int r = 0; r < NCALOOUT; ++r) { 
                output_ref[r][TLEN*pingpong+i] = links_ref[r];
            }
            if (newev_out) {
                if (latency == -1) { latency = i; printf("Detected latency = %d\n", latency); } 
                if (i != latency) { printf("ERROR in latency\n"); ok = false; break; }
                if (itest > 1) { 
                    for (int r = 0; r < NCALOOUT; ++r) {
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
                for (int r = 0; r < NCALOOUT; ++r) for (int k = 0; k < TLEN; ++k) clear(output[r][k]);
            }
            if (frame >= latency) {
                for (int r = 0; r < NCALOOUT; ++r) output[r][(frame-latency) % TLEN] = links_out[r];
            }
            // end validation


        }
        if (!ok) break;
    } 
    fclose(fMC);
    fclose(fin);
    fclose(fref);
    fclose(fout);
    fclose(fin_emp);
    fclose(fref_emp);

    return ok ? 0 : 1;
}
