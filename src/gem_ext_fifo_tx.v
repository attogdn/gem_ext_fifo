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

    output wire [ 7:0]  gem_data,
    output reg        gem_data_ready,
    output reg      gem_data_valid,
    input wire      gem_data_rd_request,
    output reg      gem_sop,
    output reg      gem_eop,
    output reg      gem_err,
    output reg      gem_flushed,
    output reg      gem_underflow,
    output reg      gem_control,
    output reg      gem_dma_tx_status_tog,
    input wire      gem_dma_tx_end_tog,
    input wire [ 3:0  ]  gem_status,

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

  assign s_axis_tready = gem_data_rd_request;
  assign gem_data = s_axis_tdata;

  always @(posedge clk) begin

    // Reset
    if (rstn == 1'b0) begin
      gem_err <= 1'b0;
      gem_control <= 1'b0;
      gem_underflow <= 1'b0;
      gem_flushed <= 1'b0;
      gem_data_valid <= 1'b0;
      gem_data_ready <= 1'b0;
      gem_dma_tx_status_tog <= 1'b0;
      packet <= 1'b0;
      gem_sop <= 1'b0;
      gem_eop <= 1'b0;
    end else begin 

      // Signal MAC that data is ready to send
      if (packet == 1'b0)
        gem_data_ready <= s_axis_tvalid;
      else 
        gem_data_ready <= 1'b0;

      gem_data_valid = gem_data_rd_request & s_axis_tvalid;

      // If the FIFO is empty, and a read signal has been asserted, set underflow
      if (status_i[3] == 1'b1) gem_underflow <= 1'b1;
      else gem_underflow <= 1'b0;


      // On setting o_underflow, or receiving status, assert o_flushed
      if (gem_underflow == 1'b1 || gem_status != 4'b0) gem_flushed <= 1'b1;
      else gem_flushed <= 1'b0;

      // o_dma_status_tog has to be asserted after i_dma_end_tog is received
      if (gem_dma_tx_end_tog == 1'b1 || gem_status[2] == 1'b1) gem_dma_tx_status_tog <= 1'b1;
      else gem_dma_tx_status_tog <= 1'b0;

      if ((s_axis_tvalid == 1'b1) && (s_axis_tready == 1'b1) && (packet == 1'b0))
        packet <= 1'b1;
      else if ((s_axis_tvalid == 1'b1) && (s_axis_tlast == 1'b1) && (packet == 1'b1))
        packet <= 1'b0;
      else  
        packet <= packet;

      if ((s_axis_tvalid == 1'b1) && (s_axis_tready == 1'b1) && (packet != 1'b1))
        gem_sop <= 1'b1;
      else 
        gem_sop <= 1'b0;
      
      if ((s_axis_tlast == 1'b1) && (s_axis_tvalid == 1'b1) && (packet == 1'b1))
        gem_eop <= 1'b1;
      else
        gem_eop <= 1'b0; 

      // Set other signals (UNUSED FOR NOW)
      gem_control <= 1'b0;
      gem_err <= 1'b0;
    end 
  end

  // Dump waves
  /* initial begin */
  /*   $dumpfile("dump.vcd"); */
  /*   $dumpvars(1, ext_fifo_tx); */
  /* end */


endmodule
