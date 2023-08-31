# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import random
from pathlib import Path

import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer

pytestmark = pytest.mark.simulator_required


@cocotb.test()
async def gem_fifo_if_tx_test(dut):
    # Create a 10ns period clock on port clk
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())  # Start the clock
    dut.s_axis_tvalid = 0
    dut.s_axis_tready = 0
    dut.s_axis_tdata = 0
    dut.data_ready_o = 0

    await RisingEdge(dut.clk)  # Synchronize with the clock
    for i in range(300):
        val = random.randint(0, 255)
        if i == 0:
            dut.rstn = 0
            dut.dma_tx_end_tog_i = 1
        else:
            dut.rstn = 1

        # Set valid on data
        if i == 10 or i == 100:
            dut.s_axis_tvalid = 1
        elif i == 74 or i == 164:
            dut.s_axis_tvalid = 0

        # Set last
        if i == 74 or i == 164:
            dut.dma_tx_end_tog_i = 0

        if i == 73 or i == 163:
            dut.s_axis_tlast = 1
        else:
            dut.s_axis_tlast = 0

        # Latch data on AXIS handshake
        if dut.s_axis_tvalid == 1 and dut.s_axis_tready == 1:
            dut.s_axis_tdata = val

        # Status
        if i == 85:
            dut.status_i = 8
        else:
            dut.status_i = 0

        # Send read request from GEM
        if dut.data_ready_o == 1:
            dut.rd_i = 1
        else:
            dut.rd_i = 0

        await RisingEdge(dut.clk)
        assert dut.s_axis_tvalid == 1 or dut.s_axis_tvalid == 0


def test_gem_fifo_if_tx_runner():
    toplevel_lang = os.getenv("TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    print("Project path: ", proj_path)

    verilog_sources = []
    vhdl_sources = []

    verilog_sources = [proj_path /src/ "ext_fifo_tx.v"]
    
    runner = get_runner(sim)()
    runner.build(
        verilog_sources=verilog_sources,
        vhdl_sources=vhdl_sources,
        toplevel="ext_fifo_tx",
    )

    runner.test(toplevel="ext_fifo_tx", py_module="test_gem_fifo_if")


if __name__ == "__main__":
    test_gem_fifo_if_tx_runner()
