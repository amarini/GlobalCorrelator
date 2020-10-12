#!/bin/bash


#VHDLS="<IMPL>/route_link2fifo.vhd <IMPL>/router_monolythic_fifos_data_V_0.vhd <IMPL>/router_monolythic.vhd phi_regionizer_tb.vhd"
FW="../firmware/hdl"
if [[ "$1" == "hls_nomerge" ]]; then
    VHDLS="<IMPL>/route_link2fifo.vhd <IMPL>/router_nomerge_fifos_data_V_0.vhd <IMPL>/router_nomerge.vhd phi_regionizer_nomerge_tb.vhd"
    HLSPROJ="project_nomerge"
elif [[ "$1" == "vhdl_nomerge" ]]; then
    VHDLS="${FW}/regionizer_data.vhd ${FW}/rolling_fifo.vhd ${FW}/phi_regionizer_nomerge.vhd phi_regionizer_nomerge_vhdl_tb.vhd"
    HLSPROJ="project_nomerge"
elif [[ "$1" == "vhdl_m2" ]]; then
    VHDLS="${FW}/regionizer_data.vhd ${FW}/rolling_fifo.vhd ${FW}/fifo_merge2.vhd ${FW}/phi_regionizer_m2.vhd phi_regionizer_m2_vhdl_tb.vhd"
    HLSPROJ="project_m2_input"
elif [[ "$1" == "hls_m2_slices" ]]; then
    VHDLS="$VHDLS project_m2_input/solution/syn/vhdl/route_link2fifo.vhd  project_m2_input/solution/syn/vhdl/router_m2_input_slice.vhd"
    VHDLS="$VHDLS project_m2_fifo/solution/syn/vhdl/router_m2_fifo_slice_fifos_data_V_0.vhd  project_m2_fifo/solution/syn/vhdl/router_m2_fifo_slice.vhd"
    VHDLS="$VHDLS project_m2_merge2/solution/syn/vhdl/router_m2_merge2_slice.vhd"
    VHDLS="$VHDLS project_m2_output/solution/syn/vhdl/router_m2_output_slice.vhd"
    VHDLS="$VHDLS ${FW}/regionizer_data_stdlogic.vhd ${FW}/phi_regionizer_m2_hls_slices.vhd phi_regionizer_m2_vhdl_tb.vhd"
    HLSPROJ="project_m2_input"
elif [[ "$1" == "vhdl" ]]; then
    VHDLS="${FW}/regionizer_data.vhd ${FW}/rolling_fifo.vhd ${FW}/fifo_merge2_full.vhd ${FW}/fifo_merge3.vhd ${FW}/phi_regionizer.vhd phi_regionizer_vhdl_tb.vhd"
    HLSPROJ="project"
fi


CSIM=$HLSPROJ/solution/csim/build
if test -f $CSIM/input.txt; then
    echo " ## Getting C simulation inputs from $CSIM";
    cp -v $CSIM/*.txt .
else
    echo "Couldn't find C simulation inputs in $CSIM.";
    echo "Run vivado_hls in the parent directory before.";
    exit 1;
fi;
IMPL=$HLSPROJ/solution/impl/vhdl

# cleanup
rm -r xsim* xelab* webtalk* vivado* xvhdl* test.wdb 2> /dev/null || true;



echo " ## Compiling VHDL files: $VHDLS";
for V in $VHDLS; do
    xvhdl ${V/<IMPL>/$IMPL} || exit 2;
    grep -q ERROR xvhdl.log && exit 2;
done;

echo " ## Elaborating: ";
xelab testbench -s test -debug all || exit 3;
grep -q ERROR xelab.log && exit 3;

if [[ "$1" == "--gui" ]]; then
    echo " ## Running simulation in the GUI: ";
    xsim test --gui
else
    echo " ## Running simulation in batch mode: ";
    xsim test -R || exit 4;
    grep -q ERROR xsim.log && exit 4;

    test -f output_vhdl_tb.txt && echo " ## Output produced in output_vhdl_tb.txt ";
fi
