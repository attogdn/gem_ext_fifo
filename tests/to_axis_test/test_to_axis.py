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
async def gem_fifo_if_to_axis_test(dut):
    # Create a 10ns period clock on port clk
    prev_val = 0
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())  # Start the clock

    await RisingEdge(dut.clk)  # Synchronize with the clock
    for i in range(300):
        val = random.randint(0, 1)
        i_data = random.randint(0, 254)

        if i == 0:
            dut.rst.value = 1
        else:
            dut.rst.value = 0

        dut.i_wr.value = val
        dut.axis_tready.value = 1

        if i == 10:
            dut.axis_tready.value = 1
            dut.i_data_start.value = 1
        else:
            dut.i_data_start.value = 0

        if i == 100:
            dut.axis_tready.value = 1
            dut.i_data_end.value = 1
        else:
            dut.i_data_end.value = 0

        if i == 150:
            dut.axis_tready.value = 1
            dut.i_data_start.value = 1
            dut.i_data_end.value = 1

        dut.i_data.value = i_data

        if i == 60:
            dut.axis_tready.value = 1
            dut.i_data.value = 0

        await RisingEdge(dut.clk)
        assert dut.axis_tready.value == 1 or dut.axis_tready.value == 0


def test_gem_fifo_if_to_axis_runner():
    toplevel_lang = os.getenv("TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")

    proj_path = Path("/media/kreatywni/git/Work/Verilog/external_fifo_transceiver/src/")

    print("Project path: ", proj_path)

    verilog_sources = []
    vhdl_sources = []

    if toplevel_lang == "verilog":
        verilog_sources = [proj_path / "to_axis_converter.v"]
    else:
        vhdl_sources = [proj_path / "to_axis_converter.vhdl"]

    runner = get_runner(sim)()
    runner.build(
        verilog_sources=verilog_sources,
        vhdl_sources=vhdl_sources,
        toplevel="to_axis_converter",
    )

    runner.test(toplevel="to_axis_converter", py_module="test_gem_fifo_if")


if __name__ == "__main__":
    test_gem_fifo_if_to_axis_runner()
