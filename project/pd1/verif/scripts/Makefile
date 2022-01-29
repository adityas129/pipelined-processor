export TEST ?= test_null

export SCRIPTS_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export CL_ROOT     = $(realpath $(SCRIPTS_DIR)/../..)
export TEST_NAME   = $(CL_ROOT)/verif/tests/$(TEST)

export SIM_ROOT = $(CL_ROOT)/verif/sim/$(SIMULATOR)
export SIM_DIR  = $(SIM_ROOT)/$(TEST)

all: make_sim_dir compile run

# surround path with quotes
MEM_PATH ?= $(CL_ROOT)/verif/data/test.x
MEM_PATH_STR ?= \"$(MEM_PATH)\"
MEM_DEPTH ?= 1048576
TEST_VECTOR ?= $(CL_ROOT)/verif/data/test_vector.x
TEST_VECTOR_STR ?= \"$(TEST_VECTOR)\"

WARN ?= 1

ifeq ($(WARN), 1)
WARN_OUTPUT = 2>&1 | tee output.log
WARN_CHECK  = cat $(SIM_DIR)/output.log | bash $(CL_ROOT)/verif/scripts/check_warnings.sh
else
WARN_OUTPUT = 
WARN_CHECK  = 
endif

EXTRA_PACKAGE_FILES := ./verif/tests/test_pd.v

include ${PROJECT_ROOT}/common/verif/tb/scripts/Makefile.common.inc

