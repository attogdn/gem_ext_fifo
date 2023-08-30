# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

ifneq ($(TOPLEVEL_LANG),verilog)
all:
	@echo "Skipping; this example does not support VHDL at the top-level"
clean::

else

SIM ?= icarus 

DUT = gem_ext_fifo_tx

ROOT_DIR ?= $(shell pwd)/../..

VERILOG_SOURCES = $(ROOT_DIR)/src/$(DUT).v
VERILOG_SOURCES += $(ROOT_DIR)/tb/test_ext_fifo_tx/axis_fifo.v
VERILOG_SOURCES += $(ROOT_DIR)/tb/test_ext_fifo_tx/tb_gem_ext_fifo_tx.v

MODULE = tb_$(DUT)
TOPLEVEL = tb_$(DUT)

include $(shell cocotb-config --makefiles)/Makefile.sim

endif 