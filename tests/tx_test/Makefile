# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

ifeq ($(TOPLEVEL_LANG),verilog)
  VERILOG_SOURCES = ../../src/ext_fifo_tx.v
else ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES = ../../src/ext_fifo_tx.vhdl
endif

MODULE = test_ext_fifo_tx
TOPLEVEL = ext_fifo_tx

include $(shell cocotb-config --makefiles)/Makefile.sim
