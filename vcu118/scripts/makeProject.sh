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
BASE_DIR=`pwd`

test -d $BUILD_DIR || mkdir $BUILD_DIR
cd $BUILD_DIR

# Anonymous checkout of ipbb
if test -d ipbb; then
    echo "Will not re-download ipbb";
else
    curl -L https://github.com/ipbus/ipbb/archive/v0.2.8.tar.gz | tar xvz
    mv ipbb-0.2.8 ipbb;
fi;

source ipbb/env.sh

test -d ultratests && rm -rf ultratests
ipbb init ultratests

mkdir ultratests/src/ultratests
pushd ultratests/src/ultratests
ln -sf ../../../../ultrascale .
ln -sf ../../../../boards .
popd

pushd ultratests/src
## Get MP7 core firmware
#ipbb add git https://gitlab.cern.ch/thea/mp7.git -b standalone
# Get IPbus firmware
ipbb add git https://github.com/gpetruc/ipbus-firmware.git
popd


pushd ultratests
ipbb proj create vivado ultra_build ultratests:ultrascale -t top.dep
popd

pushd ultratests/proj/ultra_build/
ipbb vivado project reset
popd
