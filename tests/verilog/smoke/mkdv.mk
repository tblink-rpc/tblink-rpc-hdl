MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= icarus

MKDV_VL_SRCS += $(TEST_DIR)/smoke.v
TOP_MODULE = smoke

GTEST_FILTER ?= TblinkRpcHdlTestBase.smoke
export GTEST_FILTER

VLOG_OPTIONS += -sv

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk
