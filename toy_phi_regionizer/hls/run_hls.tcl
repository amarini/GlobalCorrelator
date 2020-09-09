source configIP.tcl
open_project -reset "project"

set_top ${hlsTopFunc}

add_files src/phi_regionizer.cpp -cflags "-std=c++0x"
add_files -tb phi_regionizer_test.cpp -cflags "-std=c++0x"

open_solution -reset "solution"
set_part {xcvu9p-flga2104-2L-e}
create_clock -period 2.5

set_directive_dependence -class array -dependent false router_monolythic
set_directive_dependence -class pointer -dependent false router_monolythic

csim_design
csynth_design
#cosim_design -trace_level all
#export_design -format ip_catalog -vendor "cern-cms" -version ${hlsIPVersion} -description ${hlsTopFunc}
exit
