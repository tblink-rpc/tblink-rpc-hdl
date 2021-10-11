MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= questa

MKDV_VL_SRCS += $(TEST_DIR)/../../../src/hvl/tblink_rpc.sv

MKDV_VL_INCDIRS += $(TEST_DIR)/../../../src/hvl
MKDV_VL_INCDIRS += $(TEST_DIR)

MKDV_VL_SRCS += $(TEST_DIR)/loopback_smoke_pkg.sv
MKDV_VL_SRCS += $(TEST_DIR)/loopback_smoke_bfm.sv
MKDV_VL_SRCS += $(TEST_DIR)/smoke.sv

TOP_MODULE = smoke
VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal --timescale 1ns/1ns

GTEST_FILTER ?= TblinkRpcHdlTestBase.smoke
export GTEST_FILTER

MKDV_PYTHONPATH += $(TEST_DIR)
#MKDV_RUN_ARGS += +python3=$(PACKAGES_DIR)/python/bin/python3
MKDV_RUN_ARGS += +tblink.launch=sv.loopback
MKDV_RUN_ARGS += +UVM_TESTNAME=loopback_smoke_test

#VLOG_OPTIONS += -sv

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk
