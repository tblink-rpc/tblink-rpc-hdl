TBLINK_RPC_HDL_TESTS_COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(TBLINK_RPC_HDL_TESTS_COMMON_DIR)/../../packages)
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)

BUILD_DIR ?=  $(abspath $(TBLINK_RPC_HDL_TESTS_COMMON_DIR)/../../build)
LAUNCHER_DIR = $(BUILD_DIR)/launcher

ifneq (1,$(RULES))

VPI_LIBS += $(BUILD_DIR)/tests/libtblink_rpc_hdl_testlauncher.so
TBLINK_TEST_RUNNER = $(BUILD_DIR)/tests/tblink_rpc_hdl_testrunner
export TBLINK_TEST_RUNNER

include $(DV_MK)
else # Rules
include $(DV_MK)

endif

