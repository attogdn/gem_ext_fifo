# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

ifeq ($(TOPLEVEL_LANG),verilog)
  VERILOG_SOURCES = ../../src/ext_fifo_rx.v
else ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES = ../../src/ext_fifo_rx.vhdl
endif

MODULE = test_ext_fifo_rx
TOPLEVEL = ext_fifo_rx

include $(shell cocotb-config --makefiles)/Makefile.sim
