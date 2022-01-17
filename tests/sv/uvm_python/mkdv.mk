MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= questa

include $(TEST_DIR)/../../common/prefix.mk

SV_SRC := $(shell $(PACKAGES_DIR)/python/bin/python -m mkdv files tblink-rpc-hdl::uvm-python-tb -t verilogSource -t systemVerilogSource -f sv,sv-uvm)
SV_INC := $(shell $(PACKAGES_DIR)/python/bin/python -m mkdv files tblink-rpc-hdl::uvm-python-tb -i -t verilogSource -t systemVerilogSource -f sv,sv-uvm)

MKDV_VL_SRCS += $(SV_SRC)
MKDV_VL_INCDIRS += $(SV_INC)

#MKDV_VL_SRCS += $(TEST_DIR)/../../../src/sv/tblink_rpc.sv
#MKDV_VL_SRCS += $(TEST_DIR)/../../../src/sv/tblink_rpc_uvm.sv

#MKDV_VL_INCDIRS += $(TEST_DIR)/../../../src/sv
#MKDV_VL_INCDIRS += $(TEST_DIR)

#MKDV_VL_INCDIRS += $(TEST_DIR)
#MKDV_VL_SRCS += $(TEST_DIR)/uvm_python_pkg.sv
#MKDV_VL_SRCS += $(TEST_DIR)/uvm_python_tb.sv

VPI_LIBS += $(BUILD_DIR)/libtblink_rpc_hdl_dpi.so

TOP_MODULE = uvm_python_tb
VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal --timescale 1ns/1ns
MODELSIM_UVM = 1
MKDV_PLUGINS += cocotb

MKDV_PYTHONPATH += $(TEST_DIR)/python
MKDV_COCOTB_MODULE ?= uvm_python_smoke
#MKDV_RUN_ARGS += +python3=$(PACKAGES_DIR)/python/bin/python3
MKDV_RUN_ARGS += +tblink.launch=sv.loopback
MKDV_RUN_ARGS += +UVM_TESTNAME=uvm_python_test

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk
