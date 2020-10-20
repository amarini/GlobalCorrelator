source configIP.tcl
set hlsTopFunc router_nomerge

open_project -reset "project_nomerge"

set_top ${hlsTopFunc}

add_files src/phi_regionizer.cpp -cflags "-std=c++0x -DROUTER_NOMERGE"
add_files -tb phi_regionizer_ref.cpp -cflags "-std=c++0x -DROUTER_NOMERGE"
add_files -tb phi_regionizer_test.cpp -cflags "-std=c++0x -DROUTER_NOMERGE"
#add_files -tb phi_regionizer_test.cpp -cflags "-std=c++0x -DEMP_PACKED_64 -DROUTER_NOMERGE"

open_solution -reset "solution"
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 2.5


csim_design
csynth_design
cosim_design -trace_level all
#export_design -format ip_catalog -vendor "cern-cms" -version ${hlsIPVersion} -description ${hlsTopFunc}
exit
