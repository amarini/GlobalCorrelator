# define PBlocks for all quads

# VU9P quads, clock-wise from top right, commenting out the ones not in B2014 package 
# (and since TCL is a remarkably stupid language, moving the commented ones out of the list)
set quads {
  { 233  1 14 }
  { 232  1 13 }
  { 231  1 12 }
  { 230  1 11 }
  { 229  1 10 }
  { 228  1  9 }
  { 227  1  8 }
  { 226  1  7 }
  { 225  1  6 }
  { 224  1  5 }
  { 120  0  1 }
  { 121  0  2 }
  { 122  0  3 }
  { 123  0  4 }
  { 124  0  5 }
  { 125  0  6 }
  { 126  0  7 }
  { 127  0  8 }
  { 128  0  9 }
}
# { 223  1  4 }
# { 222  1  3 }
# { 221  1  2 }
# { 220  1  1 }
# { 219  1  0 }
# { 119  0  0 }
# { 129  0 10 }
# { 130  0 11 }
# { 131  0 12 }
# { 132  0 13 }
# { 133  0 14 }
for {set i 0} {$i < [ llength $quads ] } {incr i} {
    set quadline [ lindex $quads $i ]
    set quadid  [ lindex $quadline 0 ]
    set quadix  [ lindex $quadline 1 ]
    set quadiy  [ lindex $quadline 2 ]
    set bq [create_pblock quad_$quadid]
    ### Slice coordinates go from X=0 to X=11 on the left, and X=157 to X=168
    ###  Each quad is 60 units in Y, so from 0 to 899 for 15 quads
    set slice_x1 [ expr ($quadix * 157) + 0 ]
    set slice_x2 [ expr ($quadix * 157) + 11 ]
    set slice_y1 [ expr ($quadiy * 60) + 0 ]
    set slice_y2 [ expr ($quadiy * 60) + 59 ]
    set slice_range SLICE_X${slice_x1}Y${slice_y1}:SLICE_X${slice_x2}Y${slice_y2}
    resize_pblock $bq -add $slice_range
    set_property  gridtypes {RAMB36 RAMB18 SLICE} $bq
    #add_cells_to_pblock $bq "data/gen_buffers\[${i}\].buffs"
}


create_pblock eth
resize_pblock eth -add CLOCKREGION_X4Y5:CLOCKREGION_X4Y5
add_cells_to_pblock eth "infra/eth"
#add_cells_to_pblock eth "infra/ipbus"
