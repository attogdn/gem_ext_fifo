import os
import random
from pathlib import Path
from re import X

import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


# ****************** ENABLE TESTS BY SETTING THESE ******************** #
real_packet_test = 0
constant_data_test = 0
tx_datapath_test = 1

pytestmark = pytest.mark.simulator_required


@cocotb.test()
async def gem_fifo_if_transceiver_test(dut):
    # Create a 10ns period clock on clk ports
    rx_clock = Clock(dut.rx.clk, 10, units="ns")
    tx_clock = Clock(dut.tx.clk, 10, units="ns")
    m_axis_clock = Clock(dut.axis_out.clk, 10, units="ns")
    s_axis_clock = Clock(dut.axis_in.clk, 10, units="ns")

    # Start the clocks
    cocotb.start_soon(rx_clock.start())
    cocotb.start_soon(tx_clock.start())
    cocotb.start_soon(s_axis_clock.start())
    cocotb.start_soon(m_axis_clock.start())

    # Initial values
    dut.rx_w_err = 0
    dut.rx_w_wr = 0
    dut.tx_r_data_rdy = 0
    dut.m_axis_tvalid = 0
    dut.dma_tx_end_tog = 0
    dut.dma_tx_status_tog = 0
    dut.tx_r_eop = 0
    dut.s_axis_tvalid = 0
    dut.s_axis_tready = 0
    readset = 0
    writeset = 0
    data_rdy = 0
    dataset = 0

    await RisingEdge(dut.rx.clk)  # Synchronize with the clock
    for i in range(300):
        # ****************** REAL PACKET RX TEST ******************** #
        if real_packet_test == 1:
            # Reset
            if i == 0:
                dut.rx_rstn.value = 0
                dut.tx_rstn.value = 0
            else:
                dut.rx_rstn.value = 1
                dut.tx_rstn.value = 1

            # Generate random variables, enable data
            read_val = random.randint(0, 1)

            if dataset == 1:
                data = random.randint(0, 254)
                val = random.randint(0, 1)
            else:
                data = 0
                val = 0

            # Latch necessary signals
            dut.rx_w_data.value = data
            dut.rx_w_wr.value = writeset

            # Set the external AXIS receiving block ready
            if dut.m_axis_tvalid == 1:
                dut.m_axis_tready = 1

            # Start packet and end packet

            if i == 11:
                dut.rx_w_sop.value = 1
            else:
                dut.rx_w_sop.value = 0

            if i == 50:
                dut.rx_w_eop.value = 1
            else:
                dut.rx_w_eop.value = 0

            # Set write and data signal
            if i == 10:
                dataset = 1
                writeset = 1

            if i == 35:
                writeset = 0

            if i == 40:
                writeset = 1

            if i == 50:
                dataset = 0
                writeset = 0

        # ****************** CONSTANT DATA TEST  ******************** #
        if constant_data_test == 1:
            # Reset
            if i == 0:
                dut.rx_rstn.value = 1
                dut.tx_rstn.value = 1
            else:
                dut.rx_rstn.value = 0
                dut.tx_rstn.value = 0

            # Generate random variables
            read_val = random.randint(0, 1)
            val = random.randint(0, 1)
            data = random.randint(0, 254)

            # Latch necessary signals
            data_rdy = dut.tx_r_data_rdy.value
            dut.rx_w_wr.value = writeset
            dut.rx_w_data.value = data
            dut.s_axis_tvalid = val
            dut.s_axis_tdata = data
            dut.s_axis_tuser = 0

            # Set data ready and valid
            if i == 0:
                dut.tx_r_data_rdy.value = 0
                dut.s_axis_tvalid.value = 0

            # Enable random read sigal
            if i == 0:
                readset = 1

            if readset == 1:
                dut.tx_r_rd.value = read_val
            else:
                dut.tx_r_rd.value = 0

            # Set the external AXIS receiving block ready
            if dut.m_axis_tvalid == 1:
                dut.m_axis_tready = 1

            # Set sop, eop and tlast
            if i == 10:
                dut.rx_w_sop.value = 1
            else:
                dut.rx_w_sop.value = 0

            if i == 100:
                dut.rx_w_eop.value = 1
                writeset = 0
                dut.s_axis_tlast = 1
                readset = 0
            else:
                dut.rx_w_eop.value = 0
                dut.s_axis_tlast = 0

            # Disable write for a while
            if i == 50:
                writeset = 0

            if i == 70:
                writeset = 1

            # Same cycle SOP and EOP test
            if i == 150:
                dut.rx_w_wr.value = 1
                dut.rx_w_sop.value = 1
                dut.rx_w_eop.value = 1
                readset = 0

            if i == 151:
                dut.s_axis_tlast = 1
                readset = 0

            if i == 162:
                dut.s_axis_tlast = 1
                readset = 0

        # ****************** TX DATAPATH TEST******************** #

        if tx_datapath_test == 1:
            data = random.randint(0, 254)

            if i == 0:
                dut.rx_rstn.value = 0
                dut.tx_rstn.value = 0
            else:
                dut.rx_rstn.value = 1
                dut.tx_rstn.value = 1

            if i == 1:
                dut.s_axis_tdata = data

            if i == 10 or i == 100:
                dut.s_axis_tvalid = 1
            else:
                if i == 75 or i == 165:
                    dut.s_axis_tvalid = 0

            if i == 30 or i == 111:
                dut.data_ready = 1
            if i == 64 or i == 136:
                dut.data_ready = 0

            if i == 74 or i == 164:
                dut.s_axis_tlast = 1
            else:
                dut.s_axis_tlast = 0

            if dut.s_axis_tvalid and dut.s_axis_tready == 1:
                dut.s_axis_tdata = data

            if dut.tx_r_eop == 1:
                dut.dma_tx_end_tog = 1

            if dut.dma_tx_status_tog == 1:
                dut.dma_tx_end_tog = 0

            if dut.tx_r_data_rdy == 1:
                dut.tx_r_rd = 1
            else:
                dut.tx_r_rd = 0

        await RisingEdge(dut.rx.clk)
        assert dut.rx_w_wr.value == 1 or dut.rx_w_wr.value == 0


def test_gem_fifo_if_transceiver_runner():
    toplevel_lang = os.getenv("TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")

    proj_path = Path("/media/kreatywni/git/Work/Verilog/external_fifo_transceiver/src/")

    print("Project path: ", proj_path)

    verilog_sources = []
    vhdl_sources = []

    if toplevel_lang == "verilog":
        verilog_sources = [proj_path / "ext_fifo_transceiver.v"]
    else:
        vhdl_sources = [proj_path / "ext_fifo_transceiver.vhdl"]

    runner = get_runner(sim)()
    runner.build(
        verilog_sources=verilog_sources,
        vhdl_sources=vhdl_sources,
        toplevel="ext_fifo_transceiver",
    )

    runner.test(toplevel="ext_fifo_transceiver", py_module="test_gem_fifo_if")


if __name__ == "__main__":
    test_gem_fifo_if_transceiver_runner()
