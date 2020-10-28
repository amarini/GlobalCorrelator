source configIP.tcl

set slices { "input" "fifo" "merge2" "merge4" "merge" "output" }
set funcs  { "input" "fifo" "merge2" "merge4" "merge" "full_output" }

foreach slice ${slices} funcname ${funcs} {
    set hlsTopFunc calo_router_${funcname}_slice
    open_project -reset "project_MC_calo_${slice}"
    set_top ${hlsTopFunc}

    add_files src/phi_regionizer.cpp -cflags "-std=c++0x"
    add_files -tb phi_regionizer_ref.cpp -cflags "-std=c++0x"
    add_files -tb readMC.cpp -cflags "-std=c++0x"
    add_files -tb phi_regionizer_testMC_calo.cpp -cflags "-std=c++0x"
    add_files -tb data/caloDump_hgcal.TTbar_PU200.txt

    open_solution -reset "solution"
    set_part {xcvu9p-flga2104-2L-e}
    create_clock -period 2.5

    csim_design
    csynth_design
    cosim_design -trace_level all
    #export_design -format ip_catalog -vendor "cern-cms" -version ${hlsIPVersion} -description ${hlsTopFunc}
}

exit
