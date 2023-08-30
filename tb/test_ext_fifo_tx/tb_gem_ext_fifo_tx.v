//////////////////////////////////////////////////////////////////////////////////
// Company: Transbit Sp. z o.o.
// Engineer: GM
//
// Create Date: 08/28/2023 09:44:09 AM
// Design Name: Xilinx MPSoC GEM External FIFO Interface - Tx
// Module Name: tb_gem_ext_fifo_tx
// Project Name: 
// Target Devices: Xilinx/AMD ZymqMP
// Tool Versions:
// Description: The transmitter module of External FIFO IP.
//
// Dependencies:
//
// Revision:
// 1.01 [GM] - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_gem_ext_fifo_tx (
    input           clk,
    input           rstn,
    
    // axi stream slave
    input   [ 7:0]  s_axis_tdata,
    input           s_axis_tvalid,
    input           s_axis_tlast,
    input           s_axis_tuser,
    output          s_axis_tready,

    // gem interface
    output  [ 7:0]  gem_data,
    output          gem_data_ready,
    output          gem_data_valid,
    input           gem_data_rd_request,
    output          gem_sop,
    output          gem_eop,
    output          gem_err,
    output          gem_underflow,
    output          gem_control,
    output          gem_dma_tx_status_tog,
    output          gem_dma_tx_end_tog,
    input   [ 3:0]  gem_status,
);
    wire            rst;
    wire [ 7:0]     int_axis_tdata;
    wire            int_axis_tkeep;
    wire            int_axis_tvalid;
    wire            int_axis_tready;
    wire            int_axis_tlast;
    wire            int_axis_tid;
    wire            int_axis_tdest;
    wire            int_axis_tuser;  

    assign rst = ~rstn;

    gem_ext_fifo_tx UUT (
        .clk (clk),
        .rstn (rstn),
        .gem_data(gem_data),
        .gem_data_ready,
        .gem_data_valid,
        .gem_data_rd_request,
        .gem_sop,
        .gem_eop,
        .gem_err,
        .gem_underflow,
        .gem_control,
        .gem_dma_tx_status_tog,
        .gem_dma_tx_end_tog(gem_dma_tx_end_tog),
        .gem_status(gem_status),
        .s_axis_tdata(int_axis_tdata),
        .s_axis_tkeep(int_axis_tkeep),
        .s_axis_tvalid(int_axis_tvalid),
        .s_axis_tready(int_axis_tready),
        .s_axis_tlast(int_axis_tlast),
        .s_axis_tid(int_axis_tid),
        .s_axis_tdest(int_axis_tdest),
        .s_axis_tuser(int_axis_tuser)
    );

    axis_fifo #(
    .DEPTH(2048),
    .DATA_WIDTH(8),
    .KEEP_ENABLE(0),
    .KEEP_WIDTH(1),
    .LAST_ENABLE(1),
    .ID_ENABLE(0),
    .ID_WIDTH(1),
    .DEST_ENABLE(0),
    .DEST_WIDTH(1),
    .USER_ENABLE(1),
    .USER_WIDTH(1),
    .PIPELINE_OUTPUT(0),
    .FRAME_FIFO(1),
    .USER_BAD_FRAME_VALUE(1),
    .USER_BAD_FRAME_MASK(0),
    .DROP_BAD_FRAME(0),
    .DROP_WHEN_FULL(1)
)
i_data_fifo (
    .clk(clk),
    .rst(rst),
    // AXI input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(1'b0),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tid(1'b0),
    .s_axis_tdest(1'b0),
    .s_axis_tuser(s_axis_tuser),
    // AXI output
    .m_axis_tdata(int_axis_tdata),
    .m_axis_tkeep(int_axis_tkeep),
    .m_axis_tvalid(int_axis_tvalid),
    .m_axis_tready(int_axis_tready),
    .m_axis_tlast(int_axis_tlast),
    .m_axis_tid(int_axis_tid),
    .m_axis_tdest(int_axis_tdest),
    .m_axis_tuser(int_axis_tuser),
    // Status
    .status_overflow(),
    .status_bad_frame(),
    .status_good_frame()
);

    // Dump waves 
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, tb_gem_ext_fifo_tx);
    end

endmodule