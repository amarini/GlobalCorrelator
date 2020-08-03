# note: all paths have to be relative to the ipbb vivado project directory
source ../../../dummy-hls-algo-240MHz/hls/configIP.tcl
source ../../../scrips/tcl/importHLSIP.tcl
emp_import_HLS_IP ${empProjName} ${hlsTopFunc} ${hlsIPVersion} ../../../${empProjName}/hls/project/solution/impl/ip
