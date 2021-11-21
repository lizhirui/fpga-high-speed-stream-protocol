////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_physical_encoder
//
// Description:
// This module implements conversation from control signals and raw data 
// to encoded_data that is 6b/8b code.
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
//          clk - system clock.
//          rst - reset.
//        empty - whether input fifo is empty.
//        valid - whether the output of input fifo is valid. 
//  frame_start - indicates that this module generates a frame start signal.
//    frame_end - indicates that this module generates a frame end signal.
//     raw_data - raw data.
//         full - whether output fifo is full.
//
// Outputs:
//           rd - control input fifo.
// encoded_data - encoded data output.
////////////////////////////////////////////////////////////////////////////////

module board_level_data_physical_encoder(
		input clk,
		input rst,
		input empty,
		output rd,
		input valid,
		input frame_start,
		input frame_end,
		input [5:0] raw_data,
		output reg [7:0] encoded_data,
		input full
	);

	reg [7:0] last_encoded_data;
    reg last_full;

    assign rd = ~full;

    always @(posedge clk) begin
        if(rst) begin
            last_full <= 1'b0;
        end
        else begin
            last_full <= full;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            last_encoded_data <= 8'b0;
        end
        else begin
            last_encoded_data <= encoded_data;
        end
    end

    always @(*) begin
        if(!valid) begin
            encoded_data = last_full ? last_encoded_data : 8'b0;
        end
        else if(frame_start) begin
            encoded_data = 8'b00000001;
        end
        else if(frame_end) begin
            encoded_data = 8'b00000010;
        end
        else begin
            encoded_data = {raw_data, 2'b11};
        end
    end
	
endmodule // board_level_data_physical_encoder