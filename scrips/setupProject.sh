#!/bin/bash
if [[ "$1" == "" ]]; then
    echo "Usage: $0 project";
    exit 1;
fi;

if [ -f buildToolSetup.sh ] ; then
    source buildToolSetup.sh
fi

if [ -z ${XILINX_VIVADO:+x} ] ; then
    echo "Xilinx Vivado environment has not been sourced. Exiting."
    exit 1
else
    echo "Found Xilinx Vivado at" ${XILINX_VIVADO}
fi

if [ -d ipbb-0.5.2 ]; then
    echo "Will not re-download ipbb"
else 
    curl -L https://github.com/ipbus/ipbb/archive/v0.5.2.tar.gz | tar xvz
fi
source ipbb-0.5.2/env.sh

if [ -d algo-work ]; then
    echo "Using existing algo-work directory"
else
    ipbb init algo-work
    pushd algo-work
        ipbb add git https://:@gitlab.cern.ch:8443/p2-xware/firmware/emp-fwk.git -b v0.3.4
        ipbb add git https://gitlab.cern.ch/ttc/legacy_ttc.git -b v2.1
        ipbb add git https://github.com/ipbus/ipbus-firmware -b v1.7
        (cd src && ln -sd ../.. ctl1-demos )
    popd
fi

PROJECT=$1
if test -f algo-work/src/ctl1-demos/$PROJECT/firmware/cfg/top.dep; then
    echo "Will create a project for $PROJECT";
else
    echo "Couldn't find algo-work/src/ctl1-demos/$PROJECT/firmware/cfg/top.dep --> exiting";
    exit 1;
fi;

if [[ "$2" != "--nohls" ]]; then
    HLS_COMPS=""
    pushd algo-work/src/ctl1-demos/$PROJECT
        for D in $(find . -maxdepth 1 -name 'hls*' -type d); do 
            test -f $D/run_hls.tcl || continue;
            echo "Processing HLS component $D";
            if test -d $D/project/solution/impl/ip; then
                echo " --> solution already existing and implemented up to IP core; nothing to do.";
            else
                echo " --> running vivado_hls for this project";
                ( cd $D && vivado_hls -f run_hls.tcl );
            fi;
            HLS_COMPS="${HLS_COMPS} $(basename $D)";
        done
    popd
fi;

pushd algo-work
    test -d proj/$PROJECT && rm -rf proj/$PROJECT 
    ipbb proj create vivado $PROJECT ctl1-demos:$PROJECT -t top.dep
    pushd proj/$PROJECT
        ipbb vivado project 
        for HLSIP in ${HLS_COMPS}; do
            vivado -mode batch -source ../../../$PROJECT/$HLSIP/importIP.tcl
        done;
    popd
popd


