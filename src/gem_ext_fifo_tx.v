`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Transbit Sp. z o.o.
// Engineer: MB, GM
//
// Create Date: 07/12/2022 09:44:09 AM
// Design Name: Xilinx MPSoC GEM External FIFO Interface - Tx
// Module Name: ext_fifo_tx
// Project Name:
// Target Devices:
// Tool Versions:
// Description: The transmitter module of External FIFO IP.
//
// Dependencies:
//
// Revision:
// 1.01 [MB] - File Created
// 1.02 [GM] - Changed signal names to standard; chenged handshaking
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module gem_ext_fifo_tx (

    output wire [7:0] data_o,
    output reg data_ready_o,
    output reg data_valid_o,
    output reg sop_o,
    output reg eop_o,
    output reg err_o,
    output reg underflow_o,
    output reg flushed_o,
    output reg control_o,
    output reg dma_tx_status_tog_o,
    input wire dma_tx_end_tog_i,
    input wire rd_i,
    input wire [3:0] status_i,

    // AXI4-Stream 
    input wire [7:0] s_axis_tdata,
    input wire [7:0] s_axis_tid,
    input wire [7:0] s_axis_tdest,
    output wire s_axis_tready,
    input wire s_axis_tkeep,
    input wire s_axis_tvalid,
    input wire s_axis_tlast,
    input wire s_axis_tuser,
    input wire rstn,
    input wire clk
);

  reg packet;
  /* reg dma_end_tog_prev; */

  /* GM patch */
  /* incorrect handshaking */

  assign s_axis_tready = rd_i;
  assign data_o = s_axis_tdata;

  always @(posedge clk) begin

    // Reset
    if (rstn == 1'b0) begin
      err_o <= 1'b0;
      control_o <= 1'b0;
      underflow_o <= 1'b0;
      flushed_o <= 1'b0;
      dma_tx_status_tog_o <= 1'b0;
      packet <= 1'b0;
      sop_o <= 1'b0;
      eop_o <= 1'b0;
    end else begin 

      // Signal MAC that data is ready to send
      if (packet == 1'b0)
        data_ready_o <= s_axis_tvalid;
      else 
        data_ready_o <= 1'b0;

      data_valid_o = rd_i & s_axis_tvalid;

      // If the FIFO is empty, and a read signal has been asserted, set underflow
      if (status_i[3] == 1'b1) underflow_o <= 1'b1;
      else underflow_o <= 1'b0;


      // On setting o_underflow, or receiving status, assert o_flushed
      if (underflow_o == 1'b1 || status_i != 4'b0) flushed_o <= 1'b1;
      else flushed_o <= 1'b0;

      // o_dma_status_tog has to be asserted after i_dma_end_tog is received
      if (dma_tx_end_tog_i == 1'b1 || status_i[2] == 1'b1) dma_tx_status_tog_o <= 1'b1;
      else dma_tx_status_tog_o <= 1'b0;

      if ((s_axis_tvalid == 1'b1) && (s_axis_tready == 1'b1) && (packet == 1'b0))
        packet <= 1'b1;
      else if ((s_axis_tvalid == 1'b1) && (s_axis_tlast == 1'b1) && (packet == 1'b1))
        packet <= 1'b0;
      else  
        packet <= packet;

      if ((s_axis_tvalid == 1'b1) && (s_axis_tready == 1'b1) && (packet != 1'b1))
        sop_o <= 1'b1;
      else 
        sop_o <= 1'b0;
      
      if ((s_axis_tlast == 1'b1) && (s_axis_tvalid == 1'b1) && (packet == 1'b1))
        eop_o <= 1'b1;
      else
        eop_o <= 1'b0; 

      // Set other signals (UNUSED FOR NOW)
      control_o <= 1'b0;
      err_o <= 1'b0;
    end 
  end

  // Dump waves
  /* initial begin */
  /*   $dumpfile("dump.vcd"); */
  /*   $dumpvars(1, ext_fifo_tx); */
  /* end */


endmodule
