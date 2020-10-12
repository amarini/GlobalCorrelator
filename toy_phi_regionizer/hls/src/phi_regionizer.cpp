#include "phi_regionizer.h"

class rolling_ram_fifo {
    public:    
        rolling_ram_fifo() ;
        void update(
                bool roll,        
                const Track & din,
                bool write,
                Track & dout,   
                bool & valid,
                bool full,    
                bool &roll_out
        );

    private:
        typedef ap_uint<6> ptr_t;
        bool roll_delayed;
        ptr_t wr_ptr;  // where we have last read the data
        ptr_t rd_ptr;  // where we have read the data
        ap_uint<64> data[64];
        ap_uint<64> cache;
        bool        cache_valid;
};


rolling_ram_fifo::rolling_ram_fifo() {
    rd_ptr = 2;
    wr_ptr = 1;
    roll_delayed = 0;
    cache_valid  = 0;
}


void rolling_ram_fifo::update(bool roll,     
                                 const Track & din, bool write,
                                 Track & dout, bool & valid, bool full, bool &roll_out) 
{
    #pragma HLS DEPENDENCE variable=data inter false
    #pragma HLS inline

#ifndef __SYNTHESIS__
    //printf("\nupdate with (%1d, pt %3d), roll %d, full %d, wr_ptr %3d rd_ptr %3d last output (%1d, pt %3d)",
    //            int(write), din.pt.to_int(), int(roll), int(full), 
    //            wr_ptr.to_int(), rd_ptr.to_int(),int(cache_valid), unpackTrack(cache).pt.to_int());
#endif
    // implement RAM read
    ap_uint<64> mem_out = data[rd_ptr]; 
    bool mem_out_valid = (rd_ptr < wr_ptr);

    bool full_and_valid_out = full && cache_valid && !roll_delayed;
    if (full_and_valid_out) {
        dout = unpackTrack(cache); 
        valid = cache_valid;
    } else {
        cache = mem_out;
        cache_valid = mem_out_valid;
        dout = unpackTrack(mem_out);
        valid = mem_out_valid;
    }
    roll_out = roll_delayed;

    if (roll) {
        rd_ptr = 1;
    } else if (not(full_and_valid_out) && mem_out_valid) {
        rd_ptr++;
    }

    // implement write port
    if (roll) wr_ptr = 1;
    if (write) {
        data[wr_ptr] = packTrack(din);
        wr_ptr++;
    }

#ifndef __SYNTHESIS__
    //printf(" -->  (%1d, pt %3d), wr_ptr %3d rd_ptr %3d, cache (%1d, pt %3d)\n",
    //            int(valid), dout.pt.to_int(), wr_ptr.to_int(), rd_ptr.to_int(),int(cache_valid), unpackTrack(cache).pt.to_int());
#endif

    roll_delayed = roll;
}

class fifo_merge2 {
    public:    
        fifo_merge2 () ;
        void update(
                bool roll,        
                const Track & din1,
                const Track & din2,
                bool valid1, 
                bool valid2,
                Track & dout,   
                bool  & valid,
                bool &full1,    
                bool &full2,    
                bool &roll_out
        );

    private:
        Track queue_;
        bool  queue_valid_, full2_;
};


fifo_merge2::fifo_merge2() {
    queue_valid_ = false; full2_ = false;
}


void fifo_merge2::update(bool roll,     
                              const Track & din1,
                              const Track & din2,
                              bool valid1, 
                              bool valid2,
                              Track & dout,   
                              bool  & valid,
                              bool  & full1,    
                              bool  & full2,    
                              bool  & roll_out) 
{
#ifndef __SYNTHESIS__
   //printf("\nAsked to merge (%1d, pt %3d) and (%1d, pt %3d), roll %1d, queue (%1d, pt %3d), old full2 %1d: ",
   //            int(valid1), din1.pt.to_int(),
   //            int(valid2), din2.pt.to_int(), roll,
   //            int(queue_valid_), queue_.pt.to_int(), int(full2_));
#endif
    #pragma HLS inline
    if (roll) {
        dout = (valid1 ? din1 : din2);
        valid = valid1 || valid2;
        queue_ = din2;
        queue_valid_ = valid1 && valid2;
        full2_ = valid1 && valid2;
    } else {
        bool load2 = (valid1 || queue_valid_) and not full2_;
        dout = (valid1 ? din1 : (queue_valid_ ? queue_ : din2));
        valid = valid1 || valid2 || queue_valid_;
        full2_ = valid1 && (valid2 || queue_valid_);
        if (load2) {
            queue_ = din2;
            queue_valid_ = valid2;
        } else {
            queue_valid_ = valid1 and queue_valid_;
        }
    }
    roll_out = roll;
    full1 = false;
    full2 = full2_;
#ifndef __SYNTHESIS__
    //printf(" --> (%1d, pt %3d) full2 %1d\n", int(valid), dout.pt.to_int(), int(full2));
#endif
}




void route_link2fifo(const Track & in, Track & center, bool & write_center, Track & after, bool & write_after, Track & before, bool & write_before) {
    #pragma HSL inline
    bool valid = (in.pt != 0);
    write_center = valid;                 center = in; 
    write_after  = valid && (in.phi > 0);  after = in; after.phi  -= PHI_SHIFT; 
    write_before = valid && (in.phi < 0); before = in; before.phi += PHI_SHIFT;
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

void route_all_sectors(const Track tracks_in[NSECTORS][NFIBERS], Track fifo_in[NSECTORS][NFIFOS], bool fifo_write[NSECTORS][NFIFOS]) {
    #pragma HLS inline
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_write  complete dim=0
    #pragma HLS interface ap_none port=fifo_in
    #pragma HLS interface ap_none port=fifo_write

#if NSECTORS == 9
    route_link2fifo(tracks_in[0][0], fifo_in[0][0], fifo_write[0][0], fifo_in[1][2], fifo_write[1][2], fifo_in[8][4], fifo_write[8][4]);
    route_link2fifo(tracks_in[0][1], fifo_in[0][1], fifo_write[0][1], fifo_in[1][3], fifo_write[1][3], fifo_in[8][5], fifo_write[8][5]);
    route_link2fifo(tracks_in[1][0], fifo_in[1][0], fifo_write[1][0], fifo_in[2][2], fifo_write[2][2], fifo_in[0][4], fifo_write[0][4]);
    route_link2fifo(tracks_in[1][1], fifo_in[1][1], fifo_write[1][1], fifo_in[2][3], fifo_write[2][3], fifo_in[0][5], fifo_write[0][5]);
    route_link2fifo(tracks_in[2][0], fifo_in[2][0], fifo_write[2][0], fifo_in[3][2], fifo_write[3][2], fifo_in[1][4], fifo_write[1][4]);
    route_link2fifo(tracks_in[2][1], fifo_in[2][1], fifo_write[2][1], fifo_in[3][3], fifo_write[3][3], fifo_in[1][5], fifo_write[1][5]);
    route_link2fifo(tracks_in[3][0], fifo_in[3][0], fifo_write[3][0], fifo_in[4][2], fifo_write[4][2], fifo_in[2][4], fifo_write[2][4]);
    route_link2fifo(tracks_in[3][1], fifo_in[3][1], fifo_write[3][1], fifo_in[4][3], fifo_write[4][3], fifo_in[2][5], fifo_write[2][5]);
    route_link2fifo(tracks_in[4][0], fifo_in[4][0], fifo_write[4][0], fifo_in[5][2], fifo_write[5][2], fifo_in[3][4], fifo_write[3][4]);
    route_link2fifo(tracks_in[4][1], fifo_in[4][1], fifo_write[4][1], fifo_in[5][3], fifo_write[5][3], fifo_in[3][5], fifo_write[3][5]);
    route_link2fifo(tracks_in[5][0], fifo_in[5][0], fifo_write[5][0], fifo_in[6][2], fifo_write[6][2], fifo_in[4][4], fifo_write[4][4]);
    route_link2fifo(tracks_in[5][1], fifo_in[5][1], fifo_write[5][1], fifo_in[6][3], fifo_write[6][3], fifo_in[4][5], fifo_write[4][5]);
    route_link2fifo(tracks_in[6][0], fifo_in[6][0], fifo_write[6][0], fifo_in[7][2], fifo_write[7][2], fifo_in[5][4], fifo_write[5][4]);
    route_link2fifo(tracks_in[6][1], fifo_in[6][1], fifo_write[6][1], fifo_in[7][3], fifo_write[7][3], fifo_in[5][5], fifo_write[5][5]);
    route_link2fifo(tracks_in[7][0], fifo_in[7][0], fifo_write[7][0], fifo_in[8][2], fifo_write[8][2], fifo_in[6][4], fifo_write[6][4]);
    route_link2fifo(tracks_in[7][1], fifo_in[7][1], fifo_write[7][1], fifo_in[8][3], fifo_write[8][3], fifo_in[6][5], fifo_write[6][5]);
    route_link2fifo(tracks_in[8][0], fifo_in[8][0], fifo_write[8][0], fifo_in[0][2], fifo_write[0][2], fifo_in[7][4], fifo_write[7][4]);
    route_link2fifo(tracks_in[8][1], fifo_in[8][1], fifo_write[8][1], fifo_in[0][3], fifo_write[0][3], fifo_in[7][5], fifo_write[7][5]);
#elif NSECTORS == 3
    route_link2fifo(tracks_in[0][0], fifo_in[0][0], fifo_write[0][0], fifo_in[1][2], fifo_write[1][2], fifo_in[2][4], fifo_write[2][4]);
    route_link2fifo(tracks_in[0][1], fifo_in[0][1], fifo_write[0][1], fifo_in[1][3], fifo_write[1][3], fifo_in[2][5], fifo_write[2][5]);
    route_link2fifo(tracks_in[1][0], fifo_in[1][0], fifo_write[1][0], fifo_in[2][2], fifo_write[2][2], fifo_in[0][4], fifo_write[0][4]);
    route_link2fifo(tracks_in[1][1], fifo_in[1][1], fifo_write[1][1], fifo_in[2][3], fifo_write[2][3], fifo_in[0][5], fifo_write[0][5]);
    route_link2fifo(tracks_in[2][0], fifo_in[2][0], fifo_write[2][0], fifo_in[0][2], fifo_write[0][2], fifo_in[1][4], fifo_write[1][4]);
    route_link2fifo(tracks_in[2][1], fifo_in[2][1], fifo_write[2][1], fifo_in[0][3], fifo_write[0][3], fifo_in[1][5], fifo_write[1][5]);
#else
    #error "Unsupported number of sectors"
#endif

}

void router_nomerge(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS*NFIFOS], bool & newevent_out)
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete

    Track fifo_in[NSECTORS][NFIFOS]; bool fifo_write[NSECTORS][NFIFOS];
    static Track fifo_out[NSECTORS][NFIFOS];
    static bool valid_out[NSECTORS][NFIFOS];
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_write  complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=valid_out complete dim=0

    static bool roll_out[NSECTORS][NFIFOS];
    #pragma HLS array_partition variable=roll_out complete dim=0

    static rolling_ram_fifo fifos[NSECTORS*NFIFOS];
    #pragma HLS array_partition variable=fifos complete dim=1 // must be 1D array to avoid unrolling also the RAM

    route_all_sectors(tracks_in, fifo_in, fifo_write);

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
        }
    }

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            //if (i == 0) printf("\non fifo[%d][%d] write %d, pt %4d\n", i, j, int(fifo_write[i][j]) , fifo_in[i][j].pt.to_int());
            fifos[i*NFIFOS+j].update(newevent, fifo_in[i][j], fifo_write[i][j], fifo_out[i][j], valid_out[i][j], false, roll_out[i][j]);
            //if (i == 0) printf("\non fifo[%d][%d] out valid %d, pt %4d\n", i, j, int(valid_out[i][j]) , fifo_out[i][j].pt.to_int());
        }
    }
}

void router_m2_input_slice(const Track tracks_in[NSECTORS][NFIBERS], Track fifo_in[NSECTORS][NFIFOS], bool fifo_write[NSECTORS][NFIFOS]) {
    #pragma HLS pipeline II=1 
    #pragma HLS latency min=1 max=1
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_write  complete dim=0
    #pragma HLS array_partition variable=fifo_in complete dim=0
    #pragma HLS array_partition variable=fifo_write complete dim=0
    #pragma HLS interface ap_none port=fifo_in
    #pragma HLS interface ap_none port=fifo_write

    route_all_sectors(tracks_in, fifo_in, fifo_write);
}

void router_m2_fifo_slice(bool newevent, 
                          const Track fifo_in[NSECTORS][NFIFOS], const bool fifo_write[NSECTORS][NFIFOS], const bool fifo_full[NSECTORS][NFIFOS],
                          Track fifo_out[NSECTORS][NFIFOS], bool fifo_out_valid[NSECTORS][NFIFOS], bool fifo_out_roll[NSECTORS][NFIFOS])
{
    #pragma HLS pipeline II=1 
    #pragma HLS latency min=1 max=1
    #pragma HLS array_partition variable=fifo_in complete dim=0
    #pragma HLS array_partition variable=fifo_write complete dim=0
    #pragma HLS array_partition variable=fifo_full complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=fifo_out_valid complete dim=0
    #pragma HLS array_partition variable=fifo_out_roll complete dim=0
    #pragma HLS interface ap_none port=fifo_out
    #pragma HLS interface ap_none port=fifo_out_valid
    #pragma HLS interface ap_none port=fifo_out_roll

    static rolling_ram_fifo fifos[NSECTORS*NFIFOS];
    #pragma HLS array_partition variable=fifos complete dim=1 // must be 1D array to avoid unrolling also the RAM

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            fifos[i*NFIFOS+j].update(newevent, fifo_in[i][j], fifo_write[i][j], fifo_out[i][j], fifo_out_valid[i][j], fifo_full[i][j], fifo_out_roll[i][j]);
        }
    }
}

void router_m2_merge2_slice( const Track fifo_out[NSECTORS][NFIFOS], const bool fifo_out_valid[NSECTORS][NFIFOS], const bool fifo_out_roll[NSECTORS][NFIFOS],
        bool fifo_full[NSECTORS][NFIFOS],
        Track merged_out[NSECTORS][NFIFOS/2], bool merged_out_valid[NSECTORS][NFIFOS/2], bool merged_out_roll[NSECTORS][NFIFOS/2])
{
    #pragma HLS pipeline II=1 
    #pragma HLS latency min=1 max=1

    #pragma HLS array_partition variable=fifo_full complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=fifo_out_valid complete dim=0
    #pragma HLS array_partition variable=fifo_out_roll complete dim=0
    #pragma HLS array_partition variable=merged_out complete dim=0
    #pragma HLS array_partition variable=merged_out_valid  complete dim=0
    #pragma HLS array_partition variable=merged_out_roll  complete dim=0

    #pragma HLS interface ap_none port=fifo_full
    #pragma HLS interface ap_none port=merged_out
    #pragma HLS interface ap_none port=merged_out_valid
    #pragma HLS interface ap_none port=merged_out_roll

    static fifo_merge2 merger[NSECTORS*NFIFOS/2];
    #pragma HLS array_partition variable=mergers complete dim=1 

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS/2; ++j) {
            #pragma HLS unroll
            merger[i*(NFIFOS/2)+j].update(fifo_out_roll[i][2*j],
                                          fifo_out[i][2*j], fifo_out[i][2*j+1], 
                                          fifo_out_valid[i][2*j], fifo_out_valid[i][2*j+1], 
                                          merged_out[i][j], 
                                          merged_out_valid[i][j],
                                          fifo_full[i][2*j], fifo_full[i][2*j+1], 
                                          merged_out_roll[i][j]);
        }
    }

}

void router_m2_output_slice(const Track merged_out[NSECTORS][NFIFOS/2], const bool merged_out_valid[NSECTORS][NFIFOS/2], const bool merged_out_roll[NSECTORS][NFIFOS/2],
                            Track tracks_out[NOUTLINKS], bool & newevent_out)
{
    #pragma HLS pipeline II=1 
    #pragma HLS latency min=1 max=1

    #pragma HLS array_partition variable=merged_out complete dim=0
    #pragma HLS array_partition variable=merged_out_valid  complete dim=0
    #pragma HLS array_partition variable=merged_out_roll  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete
    #pragma HLS interface ap_none port=tracks_out

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS/2; ++j) {
            #pragma HLS unroll
            if (merged_out_valid[i][j]) {
                tracks_out[i*(NFIFOS/2)+j] = merged_out[i][j];
            } else {
                clear(tracks_out[i*(NFIFOS/2)+j]);
            }
        }
    }

    newevent_out = merged_out_roll[0][0];
}



void router_m2(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NOUTLINKS], bool & newevent_out)
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete
    #pragma HLS interface ap_none port=tracks_out

    Track fifo_in[NSECTORS][NFIFOS]; bool fifo_write[NSECTORS][NFIFOS];
    static Track fifo_out[NSECTORS][NFIFOS], merged_out[NSECTORS][NFIFOS/2];
    static bool fifo_out_valid[NSECTORS][NFIFOS], fifo_full[NSECTORS][NFIFOS], merged_out_valid[NSECTORS][NFIFOS/2];
    static bool fifo_out_roll[NSECTORS][NFIFOS], merged_out_roll[NSECTORS][NFIFOS/2];
    #pragma HLS array_partition variable=fifo_in  complete dim=0
    #pragma HLS array_partition variable=fifo_write  complete dim=0
    #pragma HLS array_partition variable=fifo_full  complete dim=0
    #pragma HLS array_partition variable=fifo_out complete dim=0
    #pragma HLS array_partition variable=fifo_out_valid complete dim=0
    #pragma HLS array_partition variable=fifo_out_roll complete dim=0
    #pragma HLS array_partition variable=merged_out complete dim=0
    #pragma HLS array_partition variable=merged_out_valid  complete dim=0
    #pragma HLS array_partition variable=merged_out_roll complete dim=0

    router_m2_input_slice(tracks_in, fifo_in, fifo_write);
    router_m2_fifo_slice(newevent, fifo_in, fifo_write, fifo_full, fifo_out, fifo_out_valid, fifo_out_roll);
    router_m2_merge2_slice(fifo_out, fifo_out_valid, fifo_out_roll, fifo_full, merged_out, merged_out_valid, merged_out_roll);
    router_m2_output_slice(merged_out, merged_out_valid, merged_out_roll, tracks_out, newevent_out);
}

void router_monolythic(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS], bool & newevent_out)
{
#if 0
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS array_partition variable=tracks_in  complete dim=0
    #pragma HLS array_partition variable=tracks_out complete

    Track fifo_in[NSECTORS][NFIFOS];
    static Track fifo_out[NSECTORS][NFIFOS];
    static bool valid_out[NSECTORS][NFIFOS], full[NSECTORS][NFIFOS];
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


    route_all_sectors(tracks_in, fifo_in);

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
#endif
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



