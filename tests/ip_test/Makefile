# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

ifeq ($(TOPLEVEL_LANG),verilog)
  VERILOG_SOURCES = ../../src/ext_fifo_transceiver.v
else ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES = ../../src/ext_fifo_transceiver.vhdl
endif

MODULE = test_ext_fifo_ip
TOPLEVEL = ext_fifo_transceiver

include $(shell cocotb-config --makefiles)/Makefile.sim
