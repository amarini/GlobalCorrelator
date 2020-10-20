source configIP.tcl
open_project -reset "project_muxMC"

set_top ${hlsTopFunc}

add_files src/phi_regionizer.cpp -cflags "-std=c++0x -DROUTER_MUX"
add_files -tb phi_regionizer_ref.cpp -cflags "-std=c++0x -DROUTER_MUX"
add_files -tb readMC.cpp -cflags "-std=c++0x -DROUTER_MUX"
add_files -tb phi_regionizer_testMC.cpp -cflags "-std=c++0x -DROUTER_MUX"
add_files -tb data/trackDump_hgcalPos.txt

open_solution -reset "solution"
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 2.5


csim_design
#csynth_design
#cosim_design -trace_level all
#export_design -format ip_catalog -vendor "cern-cms" -version ${hlsIPVersion} -description ${hlsTopFunc}
exit
