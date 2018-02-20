#!/bin/bash
set -e # Exit on error.

if [ -f buildToolSetup.sh ] ; then
    source buildToolSetup.sh
fi

if [ -z ${XILINX_VIVADO:+x} ] ; then
    echo "Xilinx Vivado environment has not been sourced. Exiting."
    exit 1
else
    echo "Found Xilinx Vivado at" ${XILINX_VIVADO}
fi

BUILD_DIR="build/"
cd $BUILD_DIR

source myipbb/env.sh

cd ultratests/proj/ultra_build/

if [[ "$1" == "-p" ]]; then
    ipbb vivado reset synth impl bitfile package
elif [[ "$1" == "-a" ]]; then
    ipbb vivado doit package
else
    ipbb vivado reset synth impl
fi;
#python checkTiming.py
#ipbb vivado bitfile package
