TBLINK_RPC_HDL_TESTS_COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TBLINK_RPC_HDL_DIR := $(abspath $(TBLINK_RPC_HDL_TESTS_COMMON_DIR)/../..)
PACKAGES_DIR := $(TBLINK_RPC_HDL_DIR)/packages
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)

BUILD_DIR ?=  $(abspath $(TBLINK_RPC_HDL_TESTS_COMMON_DIR)/../../build)
LAUNCHER_DIR = $(BUILD_DIR)/launcher

ifneq (1,$(RULES))

#VPI_LIBS += $(BUILD_DIR)/tests/libtblink_rpc_hdl_testlauncher.so
DPI_LIBS += $(BUILD_DIR)/libtblink_rpc_hdl.so
TBLINK_TEST_RUNNER = $(BUILD_DIR)/tests/tblink_rpc_hdl_testrunner
export TBLINK_TEST_RUNNER

LD_LIBRARY_PATH:=$(BUILD_DIR):$(LD_LIBRARY_PATH)
export LD_LIBRARY_PATH

MKDV_PYTHONPATH += $(PACKAGES_DIR)/tblink-rpc-core/python

include $(DV_MK)
else # Rules
include $(DV_MK)

endif

