////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: bits_encoder
//
// Description:
// This module is a reset signal synchronizer.
//
// Dependencies:
// <None>
//
// Revision: 1.0
//
// Parameters:
//  RESET_IN_ACTIVE_LEVEL - rst_in active level, must start with "1'b".
// RESET_OUT_ACTIVE_LEVEL - rst_out active level, must start with "1'b".
// 	     RESET_SYNC_STAGE - stages of synchronizer.
//
// Inputs:
//     clk - system clock.
//  rst_in - reset signal input.
//
// Outputs:
// rst_out - reset signal output.
////////////////////////////////////////////////////////////////////////////////

module reset_sync #(
		parameter RESET_IN_ACTIVE_LEVEL = 1'b0,
		parameter RESET_OUT_ACTIVE_LEVEL = 1'b1,
		parameter RESET_SYNC_STAGE = 3
	)(
		input clk,
		input rst_in,
		output rst_out
	);

	reg [RESET_SYNC_STAGE - 1:0] rst_sync;

    always @(posedge clk) begin
        rst_sync <= {(~RESET_IN_ACTIVE_LEVEL) ^ rst_in, rst_sync[RESET_SYNC_STAGE - 1:1]};
    end

    assign rst_out = (~RESET_OUT_ACTIVE_LEVEL) ^ rst_sync[0];

endmodule // reset_sync