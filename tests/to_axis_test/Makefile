# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

ifeq ($(TOPLEVEL_LANG),verilog)
  VERILOG_SOURCES = ../../src/to_axis_converter.v
else ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES = ../../src/to_axis_converter.vhdl
endif

MODULE = test_to_axis
TOPLEVEL = to_axis_converter

include $(shell cocotb-config --makefiles)/Makefile.sim
