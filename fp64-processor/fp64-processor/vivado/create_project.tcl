# Usage (from repo root):  vivado -mode batch -source vivado/create_project.tcl
# Creates a Vivado project, adds RTL + testbenches, and runs behavioural simulation.
set proj_dir ./vivado/fp64_proj
create_project fp64_proc $proj_dir -part xc7a100tcsg324-1 -force   ;# any 7-series part works

add_files [glob ./rtl/*.v]
add_files ./rtl/fp64_defs.vh
set_property file_type {Verilog Header} [get_files fp64_defs.vh]
set_property is_global_include true [get_files fp64_defs.vh]
add_files -fileset sim_1 [list ./tb/tb_fp64_processor.v ./tb/tb_fp64_alu.v ./sim/vector_count.vh]
set_property file_type {Verilog Header} [get_files vector_count.vh]
set_property is_global_include true [get_files vector_count.vh]
add_files -fileset sim_1 -norecurse [list ./programs/program.hex ./programs/data.hex ./sim/vectors.mem]

set_property top fp64_processor_top [current_fileset]
set_property top tb_fp64_processor  [get_filesets sim_1]
# $readmemh paths in the RTL are relative; run the simulator from the repo root
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg dummy} -objects [get_filesets sim_1]

launch_simulation
run all
