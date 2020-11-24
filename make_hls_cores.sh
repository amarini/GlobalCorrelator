#!/bin/bash

if [[ "$1" == "" ]]; then echo "Usage : $0 core"; exit 1; fi;
core=$1
test -d ip_cores_firmware || mkdir ip_cores_firmware

case $core in
    pfHGCal_3ns_ii4)
        test -d ip_cores_firmware/$core && rm -r ip_cores_firmware/$core 2> /dev/null;
        mkdir -p ip_cores_firmware/$core/firmware/{hdl,cfg} &&
        pushd l1pf_hls &&
            (test -d proj_pfHGCal_VCU118_3ns_II4 || vivado_hls -f run_hls_pfalgo2hgc_3ns_II4.tcl) &&
            popd &&
        cp -v l1pf_hls/proj_pfHGCal_VCU118_3ns_II4/solution/impl/vhdl/* ip_cores_firmware/$core/firmware/hdl/ &&
        (cd ip_cores_firmware/$core/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/$core/firmware/cfg/top.dep;
        ;;
    puppiHGCal_3ns_ii4)
        test -d ip_cores_firmware/${core}_charged && rm -r ip_cores_firmware/${core}_{charged,neutral} 2> /dev/null;
        mkdir -p ip_cores_firmware/${core}_{charged,neutral}/firmware/{hdl,cfg} &&
        pushd l1pf_hls/puppi &&
            (test -d proj_linpuppi_HGCal_VCU118_3ns_II4_charged || vivado_hls -f run_hls_linpuppi_hgcal_3ns_II4.tcl ) &&
            popd &&
        for X in charged neutral; do
            cp -v l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_3ns_II4_${X}/solution/impl/vhdl/* ip_cores_firmware/${core}_${X}/firmware/hdl/ &&
            (cd ip_cores_firmware/${core}_${X}/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/${core}_${X}/firmware/cfg/top.dep;
        done
        ;;
    puppiHGCal_3ns_ii4_stream)
        test -d ip_cores_firmware/${core}_prep && rm -r ip_cores_firmware/${core}_{prep,one,chs} 2> /dev/null;
        mkdir -p ip_cores_firmware/${core}_{prep,one,chs}/firmware/{hdl,cfg} &&
        pushd l1pf_hls/puppi &&
            (test -d proj_linpuppi_HGCal_VCU118_3ns_II4_stream_prep || vivado_hls -f run_hls_linpuppi_hgcal_3ns_II4_stream.tcl ) &&
            popd &&
        for X in prep one chs; do
            cp -v l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_3ns_II4_stream_${X}/solution/impl/vhdl/* ip_cores_firmware/${core}_${X}/firmware/hdl/ &&
            (cd ip_cores_firmware/${core}_${X}/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/${core}_${X}/firmware/cfg/top.dep;
        done
        ;;
    pfHGCal_2p2ns_ii6)
        test -d ip_cores_firmware/$core && rm -r ip_cores_firmware/$core 2> /dev/null;
        mkdir -p ip_cores_firmware/$core/firmware/{hdl,cfg} &&
        pushd l1pf_hls &&
            (test -d proj_pfHGCal_VCU118_2p2ns_II6 || vivado_hls -f run_hls_pfalgo2hgc_2p2ns_II6.tcl) &&
            popd &&
        cp -v l1pf_hls/proj_pfHGCal_VCU118_2p2ns_II6/solution/impl/vhdl/* ip_cores_firmware/$core/firmware/hdl/ &&
        (cd ip_cores_firmware/$core/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/$core/firmware/cfg/top.dep;
        ;;
    puppiHGCal_2p2ns_ii6)
        test -d ip_cores_firmware/${core}_charged && rm -r ip_cores_firmware/${core}_{charged,neutral} 2> /dev/null;
        mkdir -p ip_cores_firmware/${core}_{charged,neutral}/firmware/{hdl,cfg} &&
        pushd l1pf_hls/puppi &&
            (test -d l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_2p2ns_II6_charged || vivado_hls -f run_hls_linpuppi_hgcal_2p2ns_II6.tcl ) &&
            popd &&
        for X in charged neutral; do
            cp -v l1pf_hls/puppi/proj_linpuppi_HGCal_VCU118_2p2ns_II6_${X}/solution/impl/vhdl/* ip_cores_firmware/${core}_${X}/firmware/hdl/ &&
            (cd ip_cores_firmware/${core}_${X}/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/${core}_${X}/firmware/cfg/top.dep;
        done
        ;;
    tdemux)
        test -d ip_cores_firmware/$core && rm -r ip_cores_firmware/$core 2> /dev/null;
        mkdir -p ip_cores_firmware/$core/firmware/{hdl,cfg} &&
        pushd l1pf_hls/multififo_regionizer/tdemux &&
            (test -d project || vivado_hls -f run_hls.tcl) &&
            popd &&
        cp -v l1pf_hls/multififo_regionizer/tdemux/project/solution/impl/vhdl/* ip_cores_firmware/$core/firmware/hdl/ &&
        (cd ip_cores_firmware/$core/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/$core/firmware/cfg/top.dep;
        ;;
    unpackers)
        test -d ip_cores_firmware/$core && rm -r ip_cores_firmware/$core 2> /dev/null;
        mkdir -p ip_cores_firmware/$core/firmware/{hdl,cfg} &&
        pushd l1pf_hls/multififo_regionizer &&
            (test -d project_unpack_hgcal_3to1 && test -d project_unpack_mu_3to12 && test -d project_unpack_track_3to2 || vivado_hls -f run_hls_unpackers.tcl) &&
            popd &&
        cp -v l1pf_hls/multififo_regionizer/project_unpack_{hgcal_3to1,track_3to2,mu_3to12}/solution/impl/vhdl/* ip_cores_firmware/$core/firmware/hdl/ &&
        (cd ip_cores_firmware/$core/firmware/hdl && ls -1 ) | sed 's/^/src /' | tee ip_cores_firmware/$core/firmware/cfg/top.dep;
        ;;
esac;
