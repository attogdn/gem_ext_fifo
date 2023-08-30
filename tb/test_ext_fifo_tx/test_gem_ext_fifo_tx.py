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

import socket 

pytestmark = pytest.mark.simulator_required

CLK_PERIOD_NS = 10

@cocotb.test()
async def gem_ext_fifo_tx_test(dut):
    """Test full functionality of Xilinx GEM External FIFO Interface (TX)"""
    
    reset_n = dut.rstn

    sys_clk = Clock(dut.clk, CLK_PERIOD_NS, units="ns") # Create a 100 MHz clock on port s_axi_aclk
    cocotb.start_soon(sys_clk.start())  # Start the AXI clock 

    # Reset DUT
    await reset_dut(reset_n, 500)

    # assign values to unused inputs
    dut.gem_status.value = 0
    dut.s_axis_tuser.value = 0
    dut.gem_data_rd_request.value = 0

    await RisingEdge(dut.s_axi_aclk)  # Synchronize with the axi clock

    

        
# A reset coroutine
async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset_n._log.debug("Reset complete")

def setup_dut(dut):
    cocotb.fork(Clock(dut.clk, CLK_PERIOD_NS, units='ns').start())

# This function is used to fill FIFO with frame
async def fill_fifo(dut):
    for i in range(256):
        await RisingEdge(dut.clk)
        val = random.randint(0, 255)
        dut.s_axis_tdata.value = val 
        if dut.tready == 1:
            dut.tvalid.value = 1
        if i == 255:
            dut.tlast.value = 1
        else:
            dut.tlast.value = 0


# Transmit packet
@cocotb.test()
async def transmit_packet(dut):
    """Write data to FIFO in packet mode and transmit packet to MAC through external FIFO interface

    Test ID: 0

    Expected Results:
        TBA
    """

    # Reset
    dut.rstn <= 1
    dut.test_id <= 0
    setup_dut(dut)
    await Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.rstn <= 0

    await Timer(CLK_PERIOD_NS * 10, units='ns')


    #value = dut.dut.r_temp_0
    #assert value == DATA, ("Register at address 0x%08X should have been "
    #                       "0x%08X but was 0x%08X" % (ADDRESS, DATA, int(value)))
    #dut._log.info("Write 0x%08X to address 0x%08X" % (int(value), ADDRESS))





def test_gem_ext_fifo_tx_runner():

    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    verilog_sources = []

    verilog_sources = [proj_path / "tb" / "test_ext_fifo_tx" / "tb_gem_ext_fifo_tx.v",
                       proj_path / "tb" / "test_ext_fifo_tx" / "axis_fifo.v",
                       proj_path / "src" / "gem_ext_fifo_tx.v",
                       ]

    runner = get_runner(sim)()
    runner.build(
        verilog_sources=verilog_sources, hdl_toplevel="tb_gem_ext_fifo_tx"
    )

    runner.test(hdl_toplevel="tb_gem_ext_fifo_tx", test_module="test_gem_ext_fifo_tx")


if __name__ == "__main__":
    test_gem_ext_fifo_tx_runner()