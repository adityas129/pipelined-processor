
export SCRIPTS_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export CL_ROOT     = $(realpath $(SCRIPTS_DIR)/../..)

design.dcp:: # force run
	vivado -mode batch -nojournal -nolog -source synth-test.tcl -tclargs $(CL_ROOT)

synthesis-test: design.dcp
