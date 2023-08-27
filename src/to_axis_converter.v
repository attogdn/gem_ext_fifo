`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/26/2022 09:30:39 AM
// Design Name:
// Module Name: to_AXI_converter
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


module to_axis_converter (
    output reg [7:0] axis_tdata,
    output reg [7:0] axis_tid,
    output reg [7:0] axis_tdest,
    output reg axis_tkeep,
    output reg axis_tvalid,
    output reg axis_tlast,
    output reg axis_tuser,
    input wire axis_tready,
    input wire [7:0] i_data,
    input wire i_data_start,
    input wire i_data_end,
    input wire i_overflow,
    input wire i_wr,
    input wire rst,
    input wire clk
);
  // Helper registers:
  // Synchronizes the incoming write signal with the outgoing data
  reg r_wr;

  always @(posedge clk) begin

    // Reset
    if (rst == 1'b0) begin
      axis_tkeep <= 1'b0;
      axis_tvalid <= 1'b0;
      axis_tuser <= 1'b0;
      axis_tdata <= 8'b0;
      axis_tid <= 8'b0;
      axis_tid <= 8'b0;
      r_wr <= 1'b0;
    end

    // Latch the incoming write signal to sync it with the outgoing data
    r_wr <= i_wr;

    // Latch the incoming data to the outgoing data
    axis_tdata <= i_data;

    // Toggle axis_tlast
    axis_tlast <= i_data_end;
    if (axis_tlast == 1'b1) axis_tlast <= 1'b0;

    // Set data valid, on conditions:
    // - packet is active OR data_start/end received
    // - AND the MAC wants to write the data (incoming write signal)
    if (i_data_start == 1'b1 || i_data_end == 1'b1 || r_wr == 1'b1) axis_tvalid <= 1'b1;
    else axis_tvalid <= 1'b0;



    // Set other signals (UNUSED FOR NOW)
    axis_tdest <= 8'b0;
    axis_tid   <= 8'b0;
    axis_tuser <= 1'b0;
    axis_tkeep <= 1'b1;

  end

  // Dump waves
  /* initial begin */
  /*   $dumpfile("dump.vcd"); */
  /*   $dumpvars(1, to_axis_converter); */
  /* end */

endmodule
