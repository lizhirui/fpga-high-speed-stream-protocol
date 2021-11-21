////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_physical_decoder
//
// Description:
// This module implements conversation to control signals and raw data 
// from encoded_data that is 6b/8b code.
// frame_start: 00000001
// frame_end: 00000010
// data: xxxxxx11
//
// Dependencies:
// <None>
//
// Revision: 1.0
//
// Parameters:
// <None>
//
// Inputs:
//                clk - system clock.
//                rst - reset.
//           raw_data - raw data.
//     raw_data_valid - whether raw data is valid.
//
// Outputs:
//        frame_start - whether signal indicates frame start signal.
//          frame_end - whether signal indicates frame end signal.
//       decoded_data - decoded data.
// decoded_data_valid - whether decoded data is valid.
////////////////////////////////////////////////////////////////////////////////

module board_level_data_physical_decoder(
		input clk,
		input rst,
		input[7:0] raw_data,
		input raw_data_valid,
		output reg frame_start,
		output reg frame_end,
		output reg[5:0] decoded_data,
		output reg decoded_data_valid
	);

	always @(posedge clk) begin
		if(rst) begin
			frame_start <= 1'b0;
		end
		else if(!raw_data_valid) begin
			frame_start <= 1'b0;
		end
		else if(raw_data == 8'b00000001) begin
			frame_start <= 1'b1;
		end
		else begin
			frame_start <= 1'b0;
		end
	end

	always @(posedge clk) begin
		if(rst) begin
			frame_end <= 1'b0;
		end
		else if(!raw_data_valid) begin
			frame_end <= 1'b0;
		end
		else if(raw_data == 8'b00000010) begin
			frame_end <= 1'b1;
		end
		else begin
			frame_end <= 1'b0;
		end
	end

	always @(posedge clk) begin
		if(rst) begin
			decoded_data <= 6'b0;
		end
		else if(!raw_data_valid) begin
			decoded_data <= 6'b0;
		end
		else begin
			decoded_data <= raw_data[7:2];
		end
	end

	always @(posedge clk) begin
		if(rst) begin
			decoded_data_valid <= 1'b0;
		end
		else if(!raw_data_valid) begin
			decoded_data_valid <= 1'b0;
		end
		else if(raw_data == 8'b0) begin
			decoded_data_valid <= 1'b0;
		end
		else begin
			decoded_data_valid <= raw_data_valid;
		end
	end

endmodule // board_level_data_physical_decoder