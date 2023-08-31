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
    output reg          gem_data_ready,
    output reg          gem_data_valid,
    input wire          gem_data_rd_request,
    output reg          gem_sop,
    output wire         gem_eop,
    output wire         gem_err,
    output wire         gem_flushed,
    output wire         gem_underflow,
    output wire         gem_control,
    output reg          gem_dma_tx_status_tog,
    input wire          gem_dma_tx_end_tog,
    input wire  [ 3:0]  gem_status,

    // AXI4-Stream 
    input wire  [7:0]   s_axis_tdata,
    input wire  [7:0]   s_axis_tid,
    input wire  [7:0]   s_axis_tdest,
    output reg          s_axis_tready,
    input wire          s_axis_tkeep,
    input wire          s_axis_tvalid,
    input wire          s_axis_tlast,
    input wire          s_axis_tuser,
    output reg  [2:0]   current_state,
    input wire          resetn,
    input wire          clk
);

  reg packet_valid;
  reg packet_finish;
  reg [2:0] state;

  // state definition
  localparam [2:0] 
    STATE_S0 = 3'b000,
    STATE_S1 = 3'b001,
    STATE_S2 = 3'b010,
    STATE_S3 = 3'b011,
    STATE_S4 = 3'b100;

  assign gem_data = s_axis_tdata;
  assign gem_eop = s_axis_tlast;
  assign gem_err = 1'b0;
  assign gem_underflow = 1'b0;
  assign gem_control = 1'b0;
  assign gem_flushed = 1'b0;


// synchronous logic to advance state machine to next state
always @(posedge clk) begin
  if (resetn == 1'b0) begin 
    state <= STATE_S0;
  end else begin
    case (state)
      STATE_S0: begin
        if (s_axis_tvalid == 1'b1) begin
          state <= STATE_S1;
        end else begin 
          state <= STATE_S0;
        end 
      end
      STATE_S1: begin
        if (gem_data_rd_request == 1'b1) begin 
          state <= STATE_S2;
        end else begin
          state <= STATE_S1;
        end 
      end
      STATE_S2: begin
        if ((gem_data_rd_request == 1'b1) && (s_axis_tvalid == 1'b1)) begin
          state <= STATE_S3;
        end else begin
          state <= STATE_S2;
        end
      end
      STATE_S3: begin
        if (s_axis_tlast == 1'b1) begin
          state <= STATE_S0;
        end else if (gem_data_rd_request == 1'b0) begin
          state <= STATE_S4;
        end else begin
          state <= STATE_S3;
        end
      end
      STATE_S4: begin
        if (s_axis_tlast == 1'b1) begin
          state <= STATE_S0;
        end else if (gem_data_rd_request == 1'b1) begin
          state <= STATE_S3;
        end else begin 
          state <= STATE_S4;
        end
      end
      default: begin
        state <= STATE_S0;
      end
    endcase
  end
end


// outputs depend only on the current state
always @(*) begin
  case (state)
    STATE_S0: begin
      current_state <= STATE_S0;
      s_axis_tready <= 1'b0;
      gem_data_ready <= 1'b0;
      gem_data_valid <= 1'b0;
      packet_valid <= 1'b0;
    end
    STATE_S1: begin
      current_state <= STATE_S1;
      s_axis_tready <= 1'b0;
      gem_data_ready <= 1'b1;
      gem_data_valid <= 1'b0;
      packet_valid <= 1'b0;
    end
    STATE_S2: begin
      current_state <= STATE_S2;
      s_axis_tready <= 1'b0;
      gem_data_ready <= 1'b1;
      gem_data_valid <= 1'b0;
      packet_valid <= 1'b0;
    end
    STATE_S3: begin
      current_state <= STATE_S3;
      gem_data_ready <= 1'b0;
      packet_valid <= s_axis_tvalid;
      if ((packet_finish == 1'b1) && (gem_data_rd_request == 1'b1)) begin
        gem_sop <= 1'b1;
      end else begin
        gem_sop <= 1'b0;
      end
      if (s_axis_tvalid == 1'b1) begin
        gem_data_valid <= 1'b1;
        s_axis_tready <= 1'b1;
      end else begin
        gem_data_valid <= 1'b0;
        s_axis_tready <= 1'b0;
      end
    end
    STATE_S4: begin
      current_state <= STATE_S4;
      s_axis_tready <= 1'b0;
      gem_data_ready <= 1'b0;
    end
    default: begin
      current_state <= STATE_S0;
      s_axis_tready <= 1'b0;
      gem_data_ready <= 1'b0;
      gem_data_valid <= 1'b0;
    end
  endcase
end


always @(posedge clk) begin
  if (resetn == 1'b0) begin
    gem_dma_tx_status_tog <= 1'b0;
    packet_finish <= 1'b0;
  end else begin
    if (gem_dma_tx_end_tog == 1'b1) begin
      gem_dma_tx_status_tog <= 1'b1;
    end else begin
      gem_dma_tx_status_tog <= 1'b0;
    end
    if (s_axis_tlast == 1'b1) begin
      packet_finish <= 1'b1;
    end
    if ((packet_finish == 1'b1) && (packet_valid == 1'b1)) begin
      packet_finish <= 1'b0;
    end
  end
end

  // Dump waves
  /* initial begin */
  /*   $dumpfile("dump.vcd"); */
  /*   $dumpvars(1, ext_fifo_tx); */
  /* end */


endmodule