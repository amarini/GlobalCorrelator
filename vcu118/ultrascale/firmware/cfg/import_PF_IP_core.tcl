open_project top/top.xpr

set l1pfAlgo "pfalgo3_full"
set l1pfTopFunc mp7wrapped_${l1pfAlgo}
set l1pfIPVersion 2.0

set pfIpName ${l1pfTopFunc}
set pfIpModuleName ${pfIpName}_0

set ipRepoDir user_ip_repo
file mkdir $ipRepoDir
set_property  ip_repo_paths  $ipRepoDir [current_project]
# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild
update_ip_catalog -add_ip /afs/cern.ch/user/g/gpetrucc/w/vivado/cern-cms_hls_mp7wrapped_pfalgo3_full_2_0.zip -repo_path $ipRepoDir

create_ip -name ${pfIpName} -vendor cern-cms -library hls -version ${l1pfIPVersion} -module_name ${pfIpModuleName}
generate_target {instantiation_template} [get_files top/top.srcs/sources_1/ip/${pfIpModuleName}/${pfIpModuleName}.xci]
generate_target all [get_files top/top.srcs/sources_1/ip/${pfIpModuleName}/${pfIpModuleName}.xci]
export_ip_user_files -of_objects [get_files top/top.srcs/sources_1/ip/${pfIpModuleName}/${pfIpModuleName}.xci] -no_script -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] top/top.srcs/sources_1/ip/${pfIpModuleName}/${pfIpModuleName}.xci]
launch_run -jobs 8 ${pfIpModuleName}_synth_1
