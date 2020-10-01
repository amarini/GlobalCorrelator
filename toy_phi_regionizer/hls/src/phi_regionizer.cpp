#include "phi_regionizer.h"

class rolling_ram_fifo {
    public:    
        rolling_ram_fifo() ;
        void update(
                bool roll,        
                const Track & din,
                Track & dout,   
                bool & valid,
                bool wasread,    
                bool &roll_out
        );
        void update_stream(
                bool roll,        
                const Track & din,
                hls::stream<Track> & dout,
                bool &roll_out
        );

    private:
        typedef ap_uint<6> ptr_t;
        bool roll_delayed;
        ptr_t wr_ptr;  // where we have last read the data
        ptr_t rd_ptr;  // where we have read the data
        ap_uint<64> data[64];
};


rolling_ram_fifo::rolling_ram_fifo() {
    rd_ptr = 0;
    wr_ptr = 0;
    roll_delayed = 0;
}


void rolling_ram_fifo::update(bool roll,     
                                 const Track & din, 
                                 Track & dout, bool & valid, bool wasread, bool &roll_out) 
{
    #pragma HLS DEPENDENCE variable=data inter false
    #pragma HLS inline
    // implement read port
    valid  = (roll_delayed ? (wr_ptr == 1) :                              // better to code it here than after updating rd_ptr
                 wasread   ? ((rd_ptr+1) < wr_ptr) : (rd_ptr < wr_ptr));  // otherwise HLS serializes the two and doesn't meet timing
    rd_ptr = (roll_delayed ? ptr_t(0) : 
                 wasread   ? ptr_t(rd_ptr+1) : rd_ptr);
    dout = unpackTrack(data[rd_ptr]);

    // implement write port
    if (roll) wr_ptr = 0;
    if (din.pt != 0) {
        data[wr_ptr] = packTrack(din);
        wr_ptr++;
    }
    roll_out = roll_delayed;
    roll_delayed = roll;
}

void rolling_ram_fifo::update_stream(bool roll,     
                                 const Track & din, 
                                 hls::stream<Track> & dout, bool &roll_out) 
{
    #pragma HLS DEPENDENCE variable=data inter false
    // implement read port
    if (roll_delayed) {
        rd_ptr = 0;
    } else {
        if (dout.empty() && (rd_ptr < wr_ptr)) {
            dout.write(unpackTrack(data[rd_ptr]));
            rd_ptr++;
        }
    }

    // implement write port
    if (roll) wr_ptr = 0;
    if (din.pt != 0) {
        data[wr_ptr] = packTrack(din);
        wr_ptr++;
    }
    roll_out = roll_delayed;
    roll_delayed = roll;
}


void route_link2fifo(const Track & in, Track & center, Track & after, Track & before) {
    #pragma HSL inline
    center = in;
    if (in.phi > 0) { after  = in; after.phi  -= PHI_SHIFT; } else { clear(after); }
    if (in.phi < 0) { before = in; before.phi += PHI_SHIFT; } else { clear(before); }
}

void reduce_2(
        bool  read,
        const Track & fifo1, 
        const Track & fifo2, 
        bool valid1,
        bool valid2,
        Track & out, 
        bool  & valid,
        bool  & wasread1,
        bool  & wasread2) 
{
    #pragma HLS inline
    if (read) {
        if      (valid1) { out = fifo1; valid = 1; wasread1 = 1; wasread2 = 0; }
        else if (valid2) { out = fifo2; valid = 1; wasread1 = 0; wasread2 = 1; }
        else             { clear(out);  valid = 0; wasread1 = 0; wasread2 = 0; }
    } else {
        // don't touch out & valid, but switch off wasreads (we're stalled)
        wasread1 = 0; wasread2 = 0;
    }
}

void reduce_3(
        const Track & wait1, 
        const Track & wait2, 
        const Track & wait3, 
        bool valid1,
        bool valid2,
        bool valid3,
        Track & out, 
        bool  & wasread1,
        bool  & wasread2,
        bool  & wasread3) 
{
    #pragma HLS inline
    if      (valid1) { out = wait1; wasread1 = 1; wasread2 = 0; wasread3 = 0; }
    else if (valid2) { out = wait2; wasread1 = 0; wasread2 = 1; wasread3 = 0; }
    else if (valid3) { out = wait3; wasread1 = 0; wasread2 = 0; wasread3 = 1; }
    else             { clear(out);  wasread1 = 0; wasread2 = 0; wasread3 = 0; }
}

void route_all_sectors(const Track tracks_in[NSECTORS][NFIBERS], Track fifo_in[NSECTORS][NFIFOS]) {
    #pragma HLS inline
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=fifo_in  complete dim=0

#if NSECTORS == 9
    route_link2fifo(tracks_in[0][0], fifo_in[0][0], fifo_in[1][2], fifo_in[8][4]);
    route_link2fifo(tracks_in[0][1], fifo_in[0][1], fifo_in[1][3], fifo_in[8][5]);
    route_link2fifo(tracks_in[1][0], fifo_in[1][0], fifo_in[2][2], fifo_in[0][4]);
    route_link2fifo(tracks_in[1][1], fifo_in[1][1], fifo_in[2][3], fifo_in[0][5]);
    route_link2fifo(tracks_in[2][0], fifo_in[2][0], fifo_in[3][2], fifo_in[1][4]);
    route_link2fifo(tracks_in[2][1], fifo_in[2][1], fifo_in[3][3], fifo_in[1][5]);
    route_link2fifo(tracks_in[3][0], fifo_in[3][0], fifo_in[4][2], fifo_in[2][4]);
    route_link2fifo(tracks_in[3][1], fifo_in[3][1], fifo_in[4][3], fifo_in[2][5]);
    route_link2fifo(tracks_in[4][0], fifo_in[4][0], fifo_in[5][2], fifo_in[3][4]);
    route_link2fifo(tracks_in[4][1], fifo_in[4][1], fifo_in[5][3], fifo_in[3][5]);
    route_link2fifo(tracks_in[5][0], fifo_in[5][0], fifo_in[6][2], fifo_in[4][4]);
    route_link2fifo(tracks_in[5][1], fifo_in[5][1], fifo_in[6][3], fifo_in[4][5]);
    route_link2fifo(tracks_in[6][0], fifo_in[6][0], fifo_in[7][2], fifo_in[5][4]);
    route_link2fifo(tracks_in[6][1], fifo_in[6][1], fifo_in[7][3], fifo_in[5][5]);
    route_link2fifo(tracks_in[7][0], fifo_in[7][0], fifo_in[8][2], fifo_in[6][4]);
    route_link2fifo(tracks_in[7][1], fifo_in[7][1], fifo_in[8][3], fifo_in[6][5]);
    route_link2fifo(tracks_in[8][0], fifo_in[8][0], fifo_in[0][2], fifo_in[7][4]);
    route_link2fifo(tracks_in[8][1], fifo_in[8][1], fifo_in[0][3], fifo_in[7][5]);
#elif NSECTORS == 3
    route_link2fifo(tracks_in[0][0], fifo_in[0][0], fifo_in[1][2], fifo_in[2][4]);
    route_link2fifo(tracks_in[0][1], fifo_in[0][1], fifo_in[1][3], fifo_in[2][5]);
    route_link2fifo(tracks_in[1][0], fifo_in[1][0], fifo_in[2][2], fifo_in[0][4]);
    route_link2fifo(tracks_in[1][1], fifo_in[1][1], fifo_in[2][3], fifo_in[0][5]);
    route_link2fifo(tracks_in[2][0], fifo_in[2][0], fifo_in[0][2], fifo_in[1][4]);
    route_link2fifo(tracks_in[2][1], fifo_in[2][1], fifo_in[0][3], fifo_in[1][5]);
#else
    #error "Unsupported number of sectors"
#endif

}

void router_nomerge(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS*NFIFOS], bool & newevent_out)
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete

    Track fifo_in[NSECTORS][NFIFOS];
    static Track fifo_out[NSECTORS][NFIFOS];
    static bool valid_out[NSECTORS][NFIFOS], was_read[NSECTORS][NFIFOS];
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=valid_out complete dim=0
    #pragma HLS array_partition variable=was_read  complete dim=0

    static bool roll_out[NSECTORS][NFIFOS];
    #pragma HLS array_partition variable=roll_out complete dim=0

    static rolling_ram_fifo fifos[NSECTORS*NFIFOS];
    #pragma HLS array_partition variable=fifos complete dim=1 // must be 1D array to avoid unrolling also the RAM

    route_all_sectors(tracks_in, fifo_in);

    newevent_out = roll_out[0][0];

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            if (valid_out[i][j]) {
                tracks_out[i*NFIFOS+j] = fifo_out[i][j];
            } else {
                clear(tracks_out[i*NFIFOS+j]);
            }
            was_read[i][j] = valid_out[i][j];
        }
    }

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            fifos[i*NFIFOS+j].update(newevent, fifo_in[i][j], fifo_out[i][j], valid_out[i][j], was_read[i][j], roll_out[i][j]);
        }
    }
}

void router_m2(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NREGIONS], bool & newevent_out)
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete

    Track fifo_in[NSECTORS][NFIFOS];
    static Track fifo_out[NSECTORS][NFIFOS], merged_out[NSECTORS][NFIFOS/2];
    static bool valid_out[NSECTORS][NFIFOS], was_read[NSECTORS][NFIFOS], valid_merge[NSECTORS][NFIFOS/2];
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=mergedout complete dim=0
    #pragma HLS array_partition variable=valid_out complete dim=0
    #pragma HLS array_partition variable=was_read  complete dim=0

    static bool roll_out[NSECTORS][NFIFOS], premerge_roll;
    #pragma HLS array_partition variable=roll_out complete dim=0

    static rolling_ram_fifo fifos[NSECTORS*NFIFOS];
    #pragma HLS array_partition variable=fifos complete dim=1 // must be 1D array to avoid unrolling also the RAM

    route_all_sectors(tracks_in, fifo_in);

    newevent_out = premerge_roll;
    premerge_roll = roll_out[0][0];

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS/2; ++j) {
            #pragma HLS unroll
            if (valid_merge[i][j]) {
                tracks_out[i*(NFIFOS/2)+j] = merged_out[i][j];
            } else {
                clear(tracks_out[i*(NFIFOS/2)+j]);
            }
        }
    }


    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS/2; ++j) {
            #pragma HLS unroll
            if (valid_out[i][2*j]) {
                merged_out[i][j]  = fifo_out[i][2*j];
                valid_merge[i][j] = true;
                was_read[i][2*j+0] = 1;
                was_read[i][2*j+1] = 0;
            /*} else if (valid_out[i][2*j+1]) {
                merged_out[i][j]  = fifo_out[i][2*j+1];
                valid_merge[i][j] = true;
                was_read[i][2*j+0] = 0;
                was_read[i][2*j+1] = 1;*/
            } else {
                clear(merged_out[i][j]);
                valid_merge[i][j] = false;
                was_read[i][2*j+0] = 0;
                was_read[i][2*j+1] = 0;
            }
        }
    }

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            fifos[i*NFIFOS+j].update(newevent, fifo_in[i][j], fifo_out[i][j], valid_out[i][j], was_read[i][j], roll_out[i][j]);
        }
    }
}

#if 0
void merge_stream(hls::stream<Track> &in1, hls::stream<Track> &in2, hls::stream<Track> &out, bool roll, bool & roll_out) {
    if (roll) {
        if (!in1.empty()) in1.read(); // discard whatever was there
        if (!in2.empty()) in2.read();   
    } else {
        if (!in1.empty()) {
            out.write(in1.read());
        } else if (!in2.empty()) {
            out.write(in2.read());
        } 
    }
    roll_out = roll;
}
void read_or_null(hls::stream<Track> &in, bool roll, Track & out) {
    Track ret;
    if (roll || !in.read_nb(ret)) {
        clear(ret); 
    }
    out = ret;
}

void router_m2(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NREGIONS], bool & newevent_out)
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete

    Track fifo_in[NSECTORS][NFIFOS];
    static hls::stream<Track> fifo_out[NSECTORS][NFIFOS], merged_out[NSECTORS][NFIFOS/2];
    static bool roll_out[NSECTORS][NFIFOS], merge_roll[NSECTORS][NFIFOS/2], out_delay;
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=merged_out complete dim=0
    #pragma HLS array_partition variable=roll_out complete dim=0
    #pragma HLS array_partition variable=merge_roll complete dim=0
    #pragma HLS stream variable=fifo_out depth=1
    #pragma HLS stream variable=merged_out depth=1

    static rolling_ram_fifo fifos[NSECTORS*NFIFOS];
    #pragma HLS array_partition variable=fifos complete dim=1 // must be 1D array to avoid unrolling also the RAM

    route_all_sectors(tracks_in, fifo_in);

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            fifos[i*NFIFOS+j].update_stream(newevent, fifo_in[i][j], fifo_out[i][j], roll_out[i][j]);
        }
    }

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS/2; ++j) {
            #pragma HLS unroll
            merge_stream(fifo_out[i][2*j], fifo_out[i][2*j+1], merged_out[i][j], roll_out[i][2*j], merge_roll[i][j]);
        }
    }

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS/2; ++j) {
            #pragma HLS unroll
            read_or_null(merged_out[i][j], merge_roll[i][j], tracks_out[i*(NFIFOS/2)+j]);
        }
    }

    newevent_out = merge_roll[0][0];

}
#endif

void router_monolythic(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS], bool & newevent_out)
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete

    Track fifo_in[NSECTORS][NFIFOS];
    static Track fifo_out[NSECTORS][NFIFOS];
    static bool valid_out[NSECTORS][NFIFOS], was_read[NSECTORS][NFIFOS];
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=valid_out complete dim=0
    #pragma HLS array_partition variable=was_read  complete dim=0

    static Track tmp_out[NSECTORS][NFIFOS/2];
    static bool valid_tmp[NSECTORS][NFIFOS/2], was_read_tmp[NSECTORS][NFIFOS/2];
    static bool newevent_out_del = false;
    #pragma HLS array_partition variable=tmp_out complete dim=0
    #pragma HLS array_partition variable=valid_tmp complete dim=0
    #pragma HLS array_partition variable=was_read_tmp  complete dim=0

    static bool roll_out[NSECTORS][NFIFOS];
    #pragma HLS array_partition variable=roll_out complete dim=0

    static rolling_ram_fifo fifos[NSECTORS*NFIFOS];
    #pragma HLS array_partition variable=fifos complete dim=1 // must be 1D array to avoid unrolling also the RAM


#if NSECTORS == 9
    route_link2fifo(tracks_in[0][0], fifo_in[0][0], fifo_in[1][2], fifo_in[8][4]);
    route_link2fifo(tracks_in[0][1], fifo_in[0][1], fifo_in[1][3], fifo_in[8][5]);
    route_link2fifo(tracks_in[1][0], fifo_in[1][0], fifo_in[2][2], fifo_in[0][4]);
    route_link2fifo(tracks_in[1][1], fifo_in[1][1], fifo_in[2][3], fifo_in[0][5]);
    route_link2fifo(tracks_in[2][0], fifo_in[2][0], fifo_in[3][2], fifo_in[1][4]);
    route_link2fifo(tracks_in[2][1], fifo_in[2][1], fifo_in[3][3], fifo_in[1][5]);
    route_link2fifo(tracks_in[3][0], fifo_in[3][0], fifo_in[4][2], fifo_in[2][4]);
    route_link2fifo(tracks_in[3][1], fifo_in[3][1], fifo_in[4][3], fifo_in[2][5]);
    route_link2fifo(tracks_in[4][0], fifo_in[4][0], fifo_in[5][2], fifo_in[3][4]);
    route_link2fifo(tracks_in[4][1], fifo_in[4][1], fifo_in[5][3], fifo_in[3][5]);
    route_link2fifo(tracks_in[5][0], fifo_in[5][0], fifo_in[6][2], fifo_in[4][4]);
    route_link2fifo(tracks_in[5][1], fifo_in[5][1], fifo_in[6][3], fifo_in[4][5]);
    route_link2fifo(tracks_in[6][0], fifo_in[6][0], fifo_in[7][2], fifo_in[5][4]);
    route_link2fifo(tracks_in[6][1], fifo_in[6][1], fifo_in[7][3], fifo_in[5][5]);
    route_link2fifo(tracks_in[7][0], fifo_in[7][0], fifo_in[8][2], fifo_in[6][4]);
    route_link2fifo(tracks_in[7][1], fifo_in[7][1], fifo_in[8][3], fifo_in[6][5]);
    route_link2fifo(tracks_in[8][0], fifo_in[8][0], fifo_in[0][2], fifo_in[7][4]);
    route_link2fifo(tracks_in[8][1], fifo_in[8][1], fifo_in[0][3], fifo_in[7][5]);
#elif NSECTORS == 3
    route_link2fifo(tracks_in[0][0], fifo_in[0][0], fifo_in[1][2], fifo_in[2][4]);
    route_link2fifo(tracks_in[0][1], fifo_in[0][1], fifo_in[1][3], fifo_in[2][5]);
    route_link2fifo(tracks_in[1][0], fifo_in[1][0], fifo_in[2][2], fifo_in[0][4]);
    route_link2fifo(tracks_in[1][1], fifo_in[1][1], fifo_in[2][3], fifo_in[0][5]);
    route_link2fifo(tracks_in[2][0], fifo_in[2][0], fifo_in[0][2], fifo_in[1][4]);
    route_link2fifo(tracks_in[2][1], fifo_in[2][1], fifo_in[0][3], fifo_in[1][5]);
#else
    #error "Unsupported number of sectors"
#endif

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll

        reduce_3(tmp_out[i][0],   tmp_out[i][1],   tmp_out[i][2],
                 valid_tmp[i][0], valid_tmp[i][1], valid_tmp[i][2],
                 tracks_out[i],
                 was_read_tmp[i][0], was_read_tmp[i][1], was_read_tmp[i][2]);
#ifndef __SYNTHESIS__
        /*if (i == 1) {
            fprintf(stderr,"\nsector %d 3-queue: valid %1d %1d %1d  tracks ", i, int(valid_tmp[i][0]), int(valid_tmp[i][1]), int(valid_tmp[i][2])); 
            printTrackShort(stderr,tmp_out[i][0]); printTrackShort(stderr,tmp_out[i][1]); printTrackShort(stderr,tmp_out[i][2]);
            fprintf(stderr,"  --> track "); 
            printTrackShort(stderr,tracks_out[i]);
            fprintf(stderr,"  read %1d %1d %1d\n", int(was_read_tmp[i][0]), int(was_read_tmp[i][1]), int(was_read_tmp[i][2])); 
            
        }*/
#endif

        for (int j = 0; j < NFIFOS/2; j++) {
            bool read = roll_out[i][j*2] || was_read_tmp[i][j] || !valid_tmp[i][j];
            reduce_2(read,
                     fifo_out[i][j*2], fifo_out[i][j*2+1], 
                     valid_out[i][j*2], valid_out[i][j*2+1],
                     tmp_out[i][j],
                     valid_tmp[i][j],
                     was_read[i][j*2], was_read[i][j*2+1]);

#ifndef __SYNTHESIS__
            /*if (i == 1) {
                fprintf(stderr,"sector %d 2-queue %d: read %1d valid %1d %1d  tracks ", i, j, int(read), int(valid_out[i][2*j]), int(valid_out[i][2*j+1])); 
                printTrackShort(stderr,fifo_out[i][2*j]);
                printTrackShort(stderr,fifo_out[i][2*j+1]);
                fprintf(stderr,"  --> valid %1d track ", int(valid_tmp[i][j])); 
                printTrackShort(stderr,tmp_out[i][j]);
                fprintf(stderr,"  read %1d %1d\n", int(was_read[i][j*2]), int(was_read[i][j*2+1])); 
                
            }*/
#endif
        }

    }

    newevent_out = newevent_out_del;
    newevent_out_del = roll_out[0][0];

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            fifos[i*NFIFOS+j].update(newevent, fifo_in[i][j], fifo_out[i][j], valid_out[i][j], was_read[i][j], roll_out[i][j]);
        }
    }
}

void wrapped_router_monolythic(bool newevent, const ap_uint<64> tracks_in[NSECTORS][NFIBERS], ap_uint<64> tracks_out[NSECTORS], bool & newevent_out) 
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete

    Track unpacked_tracks_in[NSECTORS][NFIBERS], unpacked_tracks_out[NSECTORS]; 
    bool  unpacked_newevent, unpacked_newevent_out;
    #pragma HLS array_partition variable=unpacked_tracks_in  complete dim=0
    #pragma HLS array_partition variable=unpacked_tracks_out complete
    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIBERS; ++j) {
            #pragma HLS unroll
            unpacked_tracks_in[i][j] = unpackTrack(tracks_in[i][j]);
        }
    }
    unpacked_newevent = newevent;

    router_monolythic(unpacked_newevent, unpacked_tracks_in, unpacked_tracks_out, unpacked_newevent_out);

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        tracks_out[i] = packTrack(unpacked_tracks_out[i]);
    }
    newevent_out = unpacked_newevent_out;
}



