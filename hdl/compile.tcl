set script_path [file dirname [info script]]
set proj_path "${script_path}/Synthesis"
set proj_name "mcoi-xu5-design-complete"

if {![file exists ${proj_path}]} {
    puts "Project $proj_path does not exist. Call make vproject_update first"
} else {
    open_project ${script_path}/Synthesis/${proj_name}
    reset_run synth_1
    launch_runs synth_1
    wait_on_run synth_1
    launch_runs impl_1 -to_step write_bitstream
    wait_on_run impl_1
}
