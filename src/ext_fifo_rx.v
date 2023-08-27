`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Transbit SP.Z.O.O
// Engineer: Michał Bojke
//
// Create Date: 07/11/2022 12:01:20 PM
// Design Name:
// Module Name: ext_fifo_rx
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


module ext_fifo_rx (
    output reg [7:0] o_data,
    output reg o_data_start,
    output reg o_data_end,
    output reg o_overflow,
    input wire [7:0] i_data,
    input wire i_wr,
    input wire i_sop,
    input wire i_eop,
    input wire i_err,
    input wire i_flush,
    input wire [44:0] i_status,
    input wire rst,
    input wire clk
);


  always @(posedge clk) begin

    // Reset
    if (rst == 1'b0) begin
      o_data_start <= 1'b0;
      o_data_end <= 1'b0;
      o_overflow <= 1'b0;
      o_data <= 8'b0;
    end

    // Send data if:
    // - There is an incoming write signal
    // - AND no errors are detected
    if (i_wr == 1'b1 && i_err != 1'b1) o_data <= i_data;
    else o_data <= 8'h00;

    // Set other signals (UNUSED FOR NOW)
    o_data_start <= i_sop;
    o_data_end   <= i_eop;
    o_overflow   <= 1'b0;
  end

  // Dump waves
  /* initial begin */
  /*   $dumpfile("dump.vcd"); */
  /*   $dumpvars(1, ext_fifo_rx); */
  /* end */


endmodule
