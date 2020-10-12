source configIP.tcl
set slices { "input" "fifo" "merge2" "output" }

foreach slice ${slices} {
    set hlsTopFunc router_m2_${slice}_slice
    open_project -reset "project_m2_${slice}"
    set_top ${hlsTopFunc}

    add_files src/phi_regionizer.cpp -cflags "-std=c++0x -DROUTER_M2"
    add_files -tb phi_regionizer_test.cpp -cflags "-std=c++0x -DROUTER_M2"

    open_solution -reset "solution"
    set_part {xcvu9p-flga2104-2L-e}
    create_clock -period 2.5


    csim_design
    csynth_design
    #cosim_design -trace_level all
    #export_design -format ip_catalog -vendor "cern-cms" -version ${hlsIPVersion} -description ${hlsTopFunc}
}

exit
