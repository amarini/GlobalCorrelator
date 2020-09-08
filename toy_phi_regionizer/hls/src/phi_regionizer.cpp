#include "phi_regionizer.h"

class rolling_ram_fifo {
    public:    
        rolling_ram_fifo() ;
        void update(
                bool roll,        /*in*/
                const Track & din,     /*in*/
                Track       & dout,    /*out*/
                bool        & valid,
                bool        wasread  /*in*/
        );
    private:
        typedef ap_uint<6> ptr_t;
        bool roll_delayed;
        ptr_t wr_ptr;  // where we will write the next data (i.e. one past the last written data)
        ptr_t rd_ptr;  // where we have read the data
        Track data[64];
};


rolling_ram_fifo::rolling_ram_fifo() {
    rd_ptr = 0;
    wr_ptr = 0;
    roll_delayed = 0;
}


void rolling_ram_fifo::update(bool roll,     
                                 const Track & din, 
                                 Track & dout, bool & valid, bool wasread) 
{
    #pragma HLS inline
    // implement read port
    rd_ptr = (roll_delayed ? ptr_t(0) : (wasread ? ptr_t(rd_ptr+1) : rd_ptr));
    dout = data[rd_ptr];
    valid = rd_ptr < wr_ptr;

    // implement write port
    if (roll) wr_ptr = 0;
    if (din.pt != 0) {
        data[wr_ptr] = din;
        wr_ptr++;
    }
    roll_delayed = roll;
}

void route_link2fifo(const Track & in, Track & center, Track & after, Track & before) {
    #pragma HSL inline
    center = in;
    if (in.phi > 0) { after  = in; after.phi  -= PHI_SHIFT; } else { clear(after); }
    if (in.phi < 0) { before = in; before.phi += PHI_SHIFT; } else { clear(before); }
}

void pick_and_read(
        const Track & fifo1, 
        const Track & fifo2, 
        const Track & fifo3, 
        const Track & fifo4, 
        const Track & fifo5, 
        const Track & fifo6, 
        bool valid1,
        bool valid2,
        bool valid3,
        bool valid4,
        bool valid5,
        bool valid6,
        Track & out, 
        bool & wasread1, 
        bool & wasread2, 
        bool & wasread3, 
        bool & wasread4, 
        bool & wasread5, 
        bool & wasread6) 
{
    #pragma HSL inline
    // no round-robin version for the moment
    if      (valid1) { out = fifo1; wasread1 = 1; wasread2 = 0; wasread3 = 0; wasread4 = 0; wasread5 = 0; wasread6 = 0; }
    else if (valid2) { out = fifo2; wasread1 = 0; wasread2 = 1; wasread3 = 0; wasread4 = 0; wasread5 = 0; wasread6 = 0; }
    else if (valid3) { out = fifo3; wasread1 = 0; wasread2 = 0; wasread3 = 1; wasread4 = 0; wasread5 = 0; wasread6 = 0; }
    else if (valid4) { out = fifo4; wasread1 = 0; wasread2 = 0; wasread3 = 0; wasread4 = 1; wasread5 = 0; wasread6 = 0; }
    else if (valid5) { out = fifo5; wasread1 = 0; wasread2 = 0; wasread3 = 0; wasread4 = 0; wasread5 = 1; wasread6 = 0; }
    else if (valid6) { out = fifo6; wasread1 = 0; wasread2 = 0; wasread3 = 0; wasread4 = 0; wasread5 = 0; wasread6 = 1; }
    else             { clear(out);  wasread1 = 0; wasread2 = 0; wasread3 = 0; wasread4 = 0; wasread5 = 0; wasread6 = 0; }
}

void router_monolythic(bool newevent, const Track tracks_in[NSECTORS][NFIBERS], Track tracks_out[NSECTORS])
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

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        pick_and_read(fifo_out[i][0],  fifo_out[i][1],  fifo_out[i][2],  fifo_out[i][3],  fifo_out[i][4],  fifo_out[i][5],
                      valid_out[i][0], valid_out[i][1], valid_out[i][2], valid_out[i][3], valid_out[i][4], valid_out[i][5],
                      tracks_out[i],
                      was_read[i][0], was_read[i][1], was_read[i][2], was_read[i][3], was_read[i][4], was_read[i][5]);
    }


    static rolling_ram_fifo fifos[NSECTORS*NFIFOS];
    #pragma HLS array_partition variable=fifos complete dim=1

    for (int i = 0; i < NSECTORS; ++i) {
        #pragma HLS unroll
        for (int j = 0; j < NFIFOS; ++j) {
            #pragma HLS unroll
            fifos[i*NFIFOS+j].update(newevent, fifo_in[i][j], fifo_out[i][j], valid_out[i][j], was_read[i][j]);
        }
    }
}
 

