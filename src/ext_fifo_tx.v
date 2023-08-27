`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/12/2022 09:44:09 AM
// Design Name:
// Module Name: ext_fifo_tx
// Project Name:
// Target Devices:
// Tool Versions:
// Description: The transmitter module of External FIFO IP.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ext_fifo_tx (

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
    output wire axis_tready_o,
    input wire dma_tx_end_tog_i,
    input wire rd_i,
    input wire [3:0] status_i,
    input wire [7:0] axis_tdata_i,
    input wire [7:0] axis_tid_i,
    input wire [7:0] axis_tdest_i,
    input wire axis_tkeep_i,
    input wire axis_tvalid_i,
    input wire axis_tlast_i,
    input wire axis_tuser_i,
    input wire rstn,
    input wire clk
);

  reg packet;
  /* reg dma_end_tog_prev; */

  /* GM patch */
  /* incorrect handshaking */

  assign axis_tready_o = rd_i;
  assign data_o = axis_tdata_i;

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
        data_ready_o <= axis_tvalid_i;
      else 
        data_ready_o <= 1'b0;

      data_valid_o = rd_i & axis_tvalid_i;

      // If the FIFO is empty, and a read signal has been asserted, set underflow
      if (status_i[3] == 1'b1) underflow_o <= 1'b1;
      else underflow_o <= 1'b0;


      // On setting o_underflow, or receiving status, assert o_flushed
      if (underflow_o == 1'b1 || status_i != 4'b0) flushed_o <= 1'b1;
      else flushed_o <= 1'b0;

      // o_dma_status_tog has to be asserted after i_dma_end_tog is received
      if (dma_tx_end_tog_i == 1'b1 || status_i[2] == 1'b1) dma_tx_status_tog_o <= 1'b1;
      else dma_tx_status_tog_o <= 1'b0;

      if ((axis_tvalid_i == 1'b1) && (axis_tready_o == 1'b1) && (packet == 1'b0))
        packet <= 1'b1;
      else if ((axis_tvalid_i == 1'b1) && (axis_tlast_i == 1'b1) && (packet == 1'b1))
        packet <= 1'b0;
      else  
        packet <= packet;

      if ((axis_tvalid_i == 1'b1) && (axis_tready_o == 1'b1) && (packet != 1'b1))
        sop_o <= 1'b1;
      else 
        sop_o <= 1'b0;
      
      if ((axis_tlast_i == 1'b1) && (axis_tvalid_i == 1'b1) && (packet == 1'b1))
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
