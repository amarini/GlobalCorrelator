#include "src/phi_regionizer.h"

#include <cstdlib>
#include <cstdio>
#include <list>
#include <vector>

#define NTEST 10
#define TLEN  36

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

bool operator==(const Track & one, const Track & other) { 
    if (one.pt == 0) return (other.pt == 0);
    return one.pt == other.pt && one.eta == other.eta && one.phi == other.phi && one.rest == other.rest;
}
void printTrack(FILE *f, const Track & t) { 
    fprintf(f,"%3d %+4d %+4d %4d  ", t.pt.to_int(), t.eta.to_int(), t.phi.to_int(), t.rest.to_int());
}
void printTrackShort(FILE *f, const Track & t) { 
    int shortphi = 0;
    if      (t.phi > 300) shortphi = +4;
    else if (t.phi > 200) shortphi = +3;
    else if (t.phi > 100) shortphi = +2;
    else if (t.phi >   0) shortphi = +1;
    else if (t.phi <-300) shortphi = -4;
    else if (t.phi <-200) shortphi = -3;
    else if (t.phi <-100) shortphi = -2;
    else if (t.phi <   0) shortphi = -1;
    fprintf(f,"%3d %+2d %02d  ", t.pt.to_int(), shortphi, t.rest.to_int());
    //fprintf(f,"%3d %02d  ", t.pt.to_int(), t.rest.to_int());
}

struct RegionBuffer { 
    std::list<Track> fifos[NFIFOS]; 
    void flush() { 
        for (int j = 0; j < NFIFOS; ++j) fifos[j].clear(); 
    }
    void push(int f, const Track & tk, int phi_shift=0) {
        fifos[f].push_front(shiftedTrack(tk, phi_shift));
    }
    Track pop_next() {
        Track ret; clear(ret);
        for (int j = 0; j < NFIFOS; ++j) {
            if (!fifos[j].empty()) {
                ret = fifos[j].back(); 
                fifos[j].pop_back(); 
                break;
            }
        }
        return ret;
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
            out[i] = buffers[i].pop_next();
        }
    }
};

void router_ref(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS]) {
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
    

    int frame = 0; //int latency = 3; int pingpong = 0;

    for (int itest = 0; itest < NTEST; ++itest) {
        std::vector<Track> inputs[NSECTORS][NFIBERS];
        //std::vector<Track> output[NREGIONS][2], output_ref[NREGIONS];
        for (int s = 0; s < NSECTORS; ++s) {
            for (int f = 0; f < NFIBERS; ++f) {
                int ntracks = abs(rand())%7 + 3;
                for (int i = 0; i < ntracks; ++i) {
                    inputs[s][f].push_back(randTrack(10*(s+1)+f+1));
                }
            }
        }
        for (int i = 0; i < TLEN; ++i, ++frame) {
            fprintf(fin,    "%05d %1d   ", frame, int(i==0));
            fprintf(stdout, "%03d %1d   ", frame, int(i==0));

            Track links_in[NSECTORS][NFIBERS];
            for (int s = 0; s < NSECTORS; ++s) {
                for (int f = 0; f < NFIBERS; ++f) {
                    clear(links_in[s][f]);
                    if (i < int(inputs[s][f].size())) {
                        links_in[s][f]  = inputs[s][f][i];
                    }
                    printTrack(fin, links_in[s][f]);
                    printTrackShort(stdout, links_in[s][f]);
                }
            }
            fprintf(fin, "\n");
            fprintf(stdout, " | ");

            Track links_out[NREGIONS], links_ref[NREGIONS];
            router_monolythic(i == 0, links_in, links_out);
            router_ref(i == 0, links_in, links_ref);

            fprintf(fout, "%5d    ", frame);
            fprintf(fref, "%5d    ", frame);
            for (int r = 0; r < NREGIONS; ++r) printTrack(fout, links_out[r]);
            for (int r = 0; r < NREGIONS; ++r) printTrack(fref, links_ref[r]);
            fprintf(fout, "\n");
            fprintf(fref, "\n");

            for (int r = 0; r < NREGIONS; ++r) printTrackShort(stdout, links_ref[r]);
            fprintf(stdout, " | ");
            for (int r = 0; r < NREGIONS; ++r) printTrackShort(stdout, links_out[r]);
            fprintf(stdout, "\n"); fflush(stdout);
#if 0
            for (int r = 0; r < NREGIONS; ++r) {
                if (frame >= latency) {
                    output[r].push_back(links_out[r]);
                }
                output_ref[r][pingpong].push_back(links_ref[r]);
            }
            if (i == latency) {
            }
#endif

        }

    } 
    fclose(fin);
    fclose(fref);
    fclose(fout);
}
