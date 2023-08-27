`timescale 1ns / 1ps
`include "ext_fifo_tx.v"
`include "ext_fifo_rx.v"
`include "to_axis_converter.v"
/* `include "/media/kreatywni/git/Work/Verilog/external_fifo_transceiver/src/ext_fifo_tx.v" */
/* `include "/media/kreatywni/git/Work/Verilog/external_fifo_transceiver/src/ext_fifo_rx.v" */
/* `include "/media/kreatywni/git/Work/Verilog/external_fifo_transceiver/src/to_axis_converter.v" */
//////////////////////////////////////////////////////////////////////////////////
// Company: Transbit SP.Z.O.O
// Engineer: Michał Bojke
//
// Create Date: 07/11/2022 12:01:20 PM
// Design Name: External FIFO Transceiver
// Module Name: ext_fifo_transceiver
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ext_fifo_transceiver (

    // Transmitter ports
    output wire tx_r_data_rdy,
    input wire tx_r_rd,
    output wire tx_r_valid,
    output wire [7:0] tx_r_data,
    output wire tx_r_sop,
    output wire tx_r_eop,
    output wire tx_r_err,
    output wire tx_r_underflow,
    output wire tx_r_flushed,
    output wire tx_r_control,
    input wire dma_tx_end_tog,
    output wire dma_tx_status_tog,
    input wire [3:0] tx_r_status,

    // Receiver ports
    input wire rx_w_wr,
    input wire [7:0] rx_w_data,
    input wire rx_w_sop,
    input wire rx_w_eop,
    input wire [44:0] rx_w_status,
    input wire rx_w_err,
    output wire rx_w_overflow,
    input wire rx_w_flush,

    // To-AXIS converter ports
    output wire [7:0] m_axis_tdata,
    output wire [7:0] m_axis_tid,
    output wire [7:0] m_axis_tdest,
    output wire m_axis_tkeep,
    output wire m_axis_tvalid,
    output wire m_axis_tlast,
    output wire m_axis_tuser,
    input wire m_axis_tready,

    // From-AXIS converter ports
    output wire s_axis_tready,
    input wire [7:0] s_axis_tdata,
    input wire [7:0] s_axis_tid,
    input wire [7:0] s_axis_tdest,
    input wire s_axis_tkeep,
    input wire s_axis_tvalid,
    input wire s_axis_tlast,
    input wire s_axis_tuser,

    // Clocks and reset
    input wire rx_clk,
    input wire tx_clk,
    input wire rx_rstn,
    input wire tx_rstn
);

  wire [7:0] w_in_data;
  wire w_rx_data_start, w_rx_data_end;


  ext_fifo_tx tx (
      .data_o(tx_r_data),
      .data_ready_o(tx_r_data_rdy),
      .data_valid_o(tx_r_valid),
      .sop_o(tx_r_sop),
      .eop_o(tx_r_eop),
      .err_o(tx_r_err),
      .underflow_o(tx_r_underflow),
      .flushed_o(tx_r_flushed),
      .control_o(tx_r_control),
      .dma_tx_status_tog_o(dma_tx_status_tog),
      .axis_tready_o(s_axis_tready),
      .dma_tx_end_tog_i(dma_tx_end_tog),
      .rd_i(tx_r_rd),
      .status_i(tx_r_status),
      .axis_tdata_i(s_axis_tdata),
      .axis_tid_i(s_axis_tid),
      .axis_tdest_i(s_axis_tdest),
      .axis_tkeep_i(s_axis_tkeep),
      .axis_tvalid_i(s_axis_tvalid),
      .axis_tlast_i(s_axis_tlast),
      .axis_tuser_i(s_axis_tuser),
      .rstn(tx_rstn),
      .clk(tx_clk)
  );

  ext_fifo_rx rx (
      .i_data(rx_w_data),
      .i_wr(rx_w_wr),
      .i_sop(rx_w_sop),
      .i_eop(rx_w_eop),
      .i_status(rx_w_status),
      .i_err(rx_w_err),
      .i_flush(rx_w_flush),
      .o_data(w_in_data),
      .o_data_start(w_rx_data_start),
      .o_data_end(w_rx_data_end),
      .o_overflow(rx_w_overflow),
      .rst(rx_rstn),
      .clk(rx_clk)
  );

  to_axis_converter axis_out (
      .axis_tdata(m_axis_tdata),
      .axis_tid(m_axis_tid),
      .axis_tdest(m_axis_tdest),
      .axis_tkeep(m_axis_tkeep),
      .axis_tvalid(m_axis_tvalid),
      .axis_tlast(m_axis_tlast),
      .axis_tuser(m_axis_tuser),
      .axis_tready(m_axis_tready),
      .i_data(w_in_data),
      .i_data_start(w_rx_data_start),
      .i_data_end(w_rx_data_end),
      .i_overflow(rx.o_overflow),
      .i_wr(rx_w_wr),
      .rst(rx_rstn),
      .clk(rx_clk)
  );

  // Dump waves
  /* initial begin */
  /*   $dumpfile("dump.vcd"); */
  /*   $dumpvars(1, ext_fifo_transceiver); */
  /* end */



endmodule
