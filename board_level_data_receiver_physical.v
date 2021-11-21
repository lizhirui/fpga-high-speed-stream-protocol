////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_receiver_physical
//
// Description:
// This module implements data reception physical level.
//
// Dependencies:
// reset_sync.v
// bits_synchronizer.v
// board_level_data_receiver_physical_buffer(8-bit async fifo with 16-depth)
// board_level_data_physical_decoder.v
//
// Revision: 1.0
//
// Parameters:
// <None>
//
// Inputs:
//         clk - system clock.
//         rst - reset.
//     rev_clk - receive clock from transmitter.
// serial_data - serial data from transmitter.
//
// Outputs:
// frame_start - indicates that this module received a frame start signal.
//   frame_end - indicates that this module received a frame end signal.
//        data - received data(when frame_start or frame_end is "1", 
//               this signal is meaningless)
//       valid - whether frame_start or frame_end or data is valid.
////////////////////////////////////////////////////////////////////////////////

module board_level_data_receiver_physical(
		input clk,
		input rst,
		input rev_clk,
		input serial_data,
		output frame_start,
		output frame_end,
		output [5:0] data,
		output valid
	);

	wire rev_clk_rst; //reset signal which is synchronized to rev_clk domain.

	(* IOB = "TRUE" *)reg serial_data_iob_sync; //this must be in IOB to ensure
	                                            //the phase relation between 
	                                            //rev_clk and serial_data.
	wire serial_data_sync; //synchronized serial_data signal by 3-stage
	                       //bits synchronizer.

	reg [7:0] rev_buffer; //stream reception buffer.
	wire rev_frame_start; //found a frame start signal.

	reg [2:0] rev_cnt; //counter of received bits
	wire [3:0] next_rev_cnt; //this code style is to eliminate warnings of ISE.

	wire [7:0] raw_data; //decoded raw data.
	wire raw_valid; //whether raw data is valid.

	reset_sync #(
        .RESET_IN_ACTIVE_LEVEL(1'b1),
        .RESET_OUT_ACTIVE_LEVEL(1'b1),
        .RESET_SYNC_STAGE(3)
    )reset_sync_inst(
        .clk(rev_clk),
        .rst_in(rst),
        .rst_out(rev_clk_rst)
    );

    always @(posedge rev_clk) begin
        serial_data_iob_sync <= serial_data;
    end

	bits_synchronizer #(
		.STAGE(3), 
		.BITS(1), 
		.DEFAULT_LEVEL(1'b0)
	)serial_data_sync_inst(
		.clk(rev_clk), 
		.rst(rst), 
		.din(serial_data_iob_sync), 
		.dout(serial_data_sync)
	);

	//receive bit stream.
	always @(posedge rev_clk) begin
		if(rev_clk_rst) begin
			rev_buffer <= 8'b0;
		end
		else begin
			rev_buffer <= {rev_buffer[6:0], serial_data_sync};
		end
	end

	//rev_frame_start = 1 only when rev_buffer == 8'b00000001.
	assign rev_frame_start = (~(|rev_buffer[7:1])) & rev_buffer[0];

	//-----------------------------Reception Counter----------------------------
	assign next_rev_cnt = rev_cnt + 3'b1;

	always @(posedge rev_clk) begin
		if(rev_clk_rst) begin
			rev_cnt <= 3'b0;
		end
		else if(rev_frame_start) begin
			rev_cnt <= 3'b0;
		end
		else if(rev_cnt == 3'd7) begin
			rev_cnt <= 3'b0;
		end
		else begin
			rev_cnt <= next_rev_cnt[2:0];
		end
	end
	//--------------------------------------------------------------------------

	board_level_data_receiver_physical_buffer board_level_data_receiver_physical_buffer_inst(
		.rst(rst),
		.wr_clk(rev_clk),
		.rd_clk(clk),
		.din(rev_buffer),
		.wr_en((rev_cnt == 3'd7) | rev_frame_start),
		.rd_en(1'b1),
		.dout(raw_data),
		.full(),
		.empty(),
		.valid(raw_valid)
	);

	board_level_data_physical_decoder board_level_data_physical_decoder_inst(
		.clk(clk),
		.rst(rst),
		.raw_data(raw_data),
		.raw_data_valid(raw_valid),
		.frame_start(frame_start),
		.frame_end(frame_end),
		.decoded_data(data),
		.decoded_data_valid(valid)
	);


endmodule // board_level_data_receiver_physical