# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

ifneq ($(TOPLEVEL_LANG),verilog)
all:
	@echo "Skipping; this example does not support VHDL at the top-level"
clean::

else

SIM ?= icarus 

DUT = ext_fifo_tx

ROOT_DIR ?= $(shell pwd)/../../..

VERILOG_SOURCES = $(ROOT_DIR)/ip/gem_ext_fifo/src/$(DUT).v
VERILOG_SOURCES += $(ROOT_DIR)/alexforencich/verilog-ethernet/lib/axis/rtl/axis_fifo.v
VERILOG_SOURCES += $(ROOT_DIR)/ip/gem_ext_fifo/tb/tb_gem_ext_fifo_tx.v

MODULE = test_$(DUT)
TOPLEVEL = tb_$(DUT)

include $(shell cocotb-config --makefiles)/Makefile.sim

endif 