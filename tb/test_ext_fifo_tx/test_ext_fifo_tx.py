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

from cocotb_bus.drivers.amba import AXI4LiteMaster, AXIProtocolError

pytestmark = pytest.mark.simulator_required

CLK_PERIOD_NS = 10

@cocotb.test()
async def gem_ext_fifo_tx_test(dut):
    """Test full functionality of Xilinx GEM External FIFO Interface (TX)"""
    
    reset_n = dut.s_axi_aresetn

    axi_clk = Clock(dut.s_axi_aclk, CLK_PERIOD_NS, units="ns") # Create a 100 MHz clock on port s_axi_aclk
    cocotb.start_soon(axi_clk.start())  # Start the AXI clock 

    # Reset DUT
    await reset_dut(reset_n, 500)

    # assign values to unused inputs - we use axi control
    dut.att_ch1_update.value = 0
    dut.att_ch2_update.value = 0
    dut.att_ch1_val = 0
    dut.att_ch2_val = 0

    await RisingEdge(dut.s_axi_aclk)  # Synchronize with the axi clock

    

        
# A coroutine
async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset_n._log.debug("Reset complete")

##### AXI Slave ######

def setup_dut(dut):
    cocotb.fork(Clock(dut.clk, CLK_PERIOD_NS, units='ns').start())


# Write to address 0 and verify that value got through
@cocotb.test()
async def write_address_0(dut):
    """Write to the register at address 0, verify the value has changed.

    Test ID: 0

    Expected Results:
        The value read directly from the register is the same as the
        value written.
    """

    # Reset
    dut.rst <= 1
    dut.test_id <= 0
    axim = AXI4LiteMaster(dut, "AXIML", dut.clk)
    setup_dut(dut)
    await Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.rst <= 0

    ADDRESS = 0x00
    DATA = 0xAB

    await axim.write(ADDRESS, DATA)
    await Timer(CLK_PERIOD_NS * 10, units='ns')

    value = dut.dut.r_temp_0
    assert value == DATA, ("Register at address 0x%08X should have been "
                           "0x%08X but was 0x%08X" % (ADDRESS, DATA, int(value)))
    dut._log.info("Write 0x%08X to address 0x%08X" % (int(value), ADDRESS))


# Read back a value at address 0x04
@cocotb.test()
async def read_address_4(dut):
    """Use cocotb to set the value of the register at address 0x04.
    Use AXIML to read the contents of that register and
    compare the values.

    Test ID: 1

    Expected Results:
        The value read from the register is the same as the value written.
    """
    # Reset
    dut.rst <= 1
    dut.test_id <= 1
    axim = AXI4LiteMaster(dut, "AXIML", dut.clk)
    setup_dut(dut)
    await Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.rst <= 0
    await Timer(CLK_PERIOD_NS, units='ns')
    ADDRESS = 0x04
    DATA = 0xCD

    dut.dut.r_temp_1 <= DATA
    await Timer(CLK_PERIOD_NS * 10, units='ns')

    value = await axim.read(ADDRESS)
    await Timer(CLK_PERIOD_NS * 10, units='ns')

    assert value == DATA, ("Register at address 0x%08X should have been "
                           "0x%08X but was 0x%08X" % (ADDRESS, DATA, int(value)))
    dut._log.info("Read: 0x%08X From Address: 0x%08X" % (int(value), ADDRESS))


@cocotb.test()
async def write_and_read(dut):
    """Write to the register at address 0.
    Read back from that register and verify the value is the same.

    Test ID: 2

    Expected Results:
        The contents of the register is the same as the value written.
    """

    # Reset
    dut.rst <= 1
    dut.test_id <= 2
    axim = AXI4LiteMaster(dut, "AXIML", dut.clk)
    setup_dut(dut)
    await Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.rst <= 0

    ADDRESS = 0x00
    DATA = 0xAB

    # Write to the register
    await axim.write(ADDRESS, DATA)
    await Timer(CLK_PERIOD_NS * 10, units='ns')

    # Read back the value
    value = await axim.read(ADDRESS)
    await Timer(CLK_PERIOD_NS * 10, units='ns')

    value = dut.dut.r_temp_0
    assert value == DATA, ("Register at address 0x%08X should have been "
                           "0x%08X but was 0x%08X" % (ADDRESS, DATA, int(value)))
    dut._log.info("Write 0x%08X to address 0x%08X" % (int(value), ADDRESS))


@cocotb.test()
async def write_fail(dut):
    """Attempt to write data to an address that doesn't exist.

    Test ID: 3

    Expected Results:
        The AXIML bus should throw an AXIProtocolError exception because
        the user attempted to write to an invalid address.
    """
    # Reset
    dut.rst <= 1
    dut.test_id <= 3
    axim = AXI4LiteMaster(dut, "AXIML", dut.clk)
    setup_dut(dut)
    await Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.rst <= 0

    ADDRESS = 0x08
    DATA = 0xAB

    try:
        await axim.write(ADDRESS, DATA)
        await Timer(CLK_PERIOD_NS * 10, units='ns')
    except AXIProtocolError as e:
        print("Exception: %s" % str(e))
        dut._log.info("Bus successfully raised an error")
    else:
        assert False, "AXI bus should have raised an error when writing to an invalid address"


@cocotb.test()
async def read_fail(dut):
    """Attempt to read data from an address that doesn't exist.

    Test ID: 4

    Expected Results:
        The AXIML bus should throw an AXIProtocolError exception because
        the user attempted to read from an invalid address.
    """
    # Reset
    dut.rst <= 1
    dut.test_id <= 4
    axim = AXI4LiteMaster(dut, "AXIML", dut.clk)
    setup_dut(dut)
    await Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.rst <= 0

    ADDRESS = 0x08
    DATA = 0xAB

    try:
        await axim.read(ADDRESS, DATA)
        await Timer(CLK_PERIOD_NS * 10, units='ns')
    except AXIProtocolError as e:
        print("Exception: %s" % str(e))
        dut._log.info("Bus Successfully Raised an Error")
    else:
        assert False, "AXI bus should have raised an error when reading from an invalid address"


def gem_ext_fifo_tx_test_runner():

    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent 

    verilog_sources = []

    verilog_sources = [proj_path / "axi_pe43704.v"]

    runner = get_runner(sim)()
    runner.build(
        verilog_sources=verilog_sources, hdl_toplevel="axi_pe43704"
    )

    runner.test(hdl_toplevel="tb_gem_ext_fifo_tx", test_module="test_axi_pe43704")


if __name__ == "__main__":
    gem_ext_fifo_tx_test_runner()