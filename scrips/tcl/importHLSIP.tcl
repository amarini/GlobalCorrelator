proc emp_import_HLS_IP { empProjName hlsTopFunc hlsIPVersion hlsPath } {
    open_project ${empProjName}/${empProjName}.xpr

    set vendor "cern-cms"
    set hlsIpName ${hlsTopFunc}
    set hlsIpModuleName ${hlsIpName}_0

    set ipRepoDir user_ip_repo
    file mkdir $ipRepoDir
    set_property  ip_repo_paths  $ipRepoDir [current_project]
    # Rebuild user ip_repo's index before adding any source files
    update_ip_catalog -rebuild
    update_ip_catalog -add_ip "${hlsPath}/${vendor}_hls_${hlsTopFunc}_[string map { . _ } ${hlsIPVersion}].zip" -repo_path $ipRepoDir

    create_ip -name ${hlsIpName} -vendor cern-cms -library hls -version ${hlsIPVersion} -module_name ${hlsIpModuleName}
    generate_target {instantiation_template} [get_files ${empProjName}/${empProjName}.srcs/sources_1/ip/${hlsIpModuleName}/${hlsIpModuleName}.xci]
    generate_target all [get_files ${empProjName}/${empProjName}.srcs/sources_1/ip/${hlsIpModuleName}/${hlsIpModuleName}.xci]
    export_ip_user_files -of_objects [get_files ${empProjName}/${empProjName}.srcs/sources_1/ip/${hlsIpModuleName}/${hlsIpModuleName}.xci] -no_script -force -quiet
    create_ip_run [get_files -of_objects [get_fileset sources_1] ${empProjName}/${empProjName}.srcs/sources_1/ip/${hlsIpModuleName}/${hlsIpModuleName}.xci]
    launch_run -jobs 4 ${hlsIpModuleName}_synth_1
    wait_on_run ${hlsIpModuleName}_synth_1
}
