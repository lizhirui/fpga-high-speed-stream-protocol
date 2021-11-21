////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_transmitter_physical
//
// Description:
// This module implements data transmission physical level.
//
// Dependencies:
// board_level_data_transmitter_physical_buffer(8-bit sync fifo with 16-depth)
// board_level_data_physical_encoder.v
// board_level_data_parallel_to_serial_fifo(8-bit to 1-bit async fifo with 
// 16-depth)
//
// Revision: 1.0
//
// Parameters:
// <None>
//
// Inputs:
//         clk - system clock.
//         rst - reset.
//    send_clk - send clock.
// frame_start - indicates that this module generates a frame start signal.
//   frame_end - indicates that this module generates a frame end signal.
//        data - send data(when frame_start or frame_end is "1", 
//               this signal is meaningless).
//          we - write enable.
//
// Outputs:
//        full - whether this module can't receive data because fifo is full.
// serial_data - serial data to receiver.
////////////////////////////////////////////////////////////////////////////////

module board_level_data_transmitter_physical(
        input clk,
        input rst,
        input send_clk,
        input frame_start,
        input frame_end,
        input [5:0] data,
        input we,
        output full,
        output serial_data
    );
    
    //signals from board_level_data_transmitter_physical_buffer
    wire [7:0] data_buffer_out;
    wire data_buffer_empty;
    wire data_buffer_rd;
    wire data_buffer_valid;

    //signals from board_level_data_physical_encoder
    wire [7:0] encoded_data;

    //signals from board_level_data_parallel_to_serial_fifo
    wire async_fifo_full;

    board_level_data_transmitter_physical_buffer board_level_data_transmitter_physical_buffer_inst(
        .clk(clk),
        .srst(rst),
        .din({frame_start, frame_end, data}),
        .wr_en(we),
        .rd_en(data_buffer_rd),
        .full(full),
        .empty(data_buffer_empty),
        .valid(data_buffer_valid),
        .dout(data_buffer_out)
    );

    board_level_data_physical_encoder board_level_data_physical_encoder_inst(
        .clk(clk),
        .rst(rst),
        .empty(data_buffer_empty),
        .rd(data_buffer_rd),
        .valid(data_buffer_valid),
        .frame_start(data_buffer_out[7]),
        .frame_end(data_buffer_out[6]),
        .raw_data(data_buffer_out[5:0]),
        .encoded_data(encoded_data),
        .full(async_fifo_full)
    );

    board_level_data_parallel_to_serial_fifo board_level_data_parallel_to_serial_fifo_inst(
        .rst(rst),
        .wr_clk(clk),
        .rd_clk(send_clk),
        .din(encoded_data),
        .wr_en(1'b1),
        .rd_en(1'b1),
        .dout(serial_data),
        .full(async_fifo_full),
        .empty()
    );

endmodule // board_level_data_transmitter_physical