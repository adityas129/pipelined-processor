set cl_root [lindex $argv 0]
create_project -in_memory -part xc7z020-clg400-1
read_verilog [ glob ../../design/code/* ] "$cl_root/design/design_wrapper.v" 
remove_files ../../design/code/imemory.v ../../design/code/dmemory.v
read_verilog  "$cl_root/build/design/top.v" 

synth_design -flatten none -mode out_of_context -top top

write_checkpoint -force design.dcp
