////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: bits_encoder
//
// Description:
// This module is a n-bit encoder.
//
// Dependencies:
// clog2.vh
//
// Revision: 1.0
//
// Parameters:
//                BITS - original data(input data) bit width.
// INVALID_VALUE_CHECK - if this signal is 1, out_valid = 1 only when one and
//                       only one "1" in input data, otherwise, out_valid = 1
//						 when input data isn't equal to zero.
//
// Inputs:
//       din - data input.
//
// Outputs:
// 		dout - data output.
// out_valid - this signal indicates whether dout is valid.
//           - depending the value of parameter invalid_value_check.
////////////////////////////////////////////////////////////////////////////////

module bits_encoder #(
		parameter BITS = 1,
		parameter INVALID_VALUE_CHECK = 1
	)(
		input [BITS - 1:0] din,
		output [$clog2(BITS) - 1:0] dout,
		output out_valid
	);

	`include "clog2.vh"

	localparam OUTPUT_WIDTH = clog2(BITS);

	wire [BITS - 1:0] valid; //whether i-th bit is 1 or one "1" in previous bits
							 //of din. 
	wire [BITS - 1:0] invalid; //whether "1" has one more times in previous bits 
							   //of din.
	wire [OUTPUT_WIDTH - 1:0] result [BITS - 1:0]; //intermediate result of 
												   //previous bits of din.

	genvar i;

	assign valid[0] = din[0];
	assign invalid[0] = 1'b0;
	assign result[0] = 0;

	generate
		for(i = 1;i < BITS;i = i + 1) begin : encode_generate
			assign valid[i] = ((valid[i - 1] == 1'b1) || 
				              (din[i] == 1'b1)) ? 1'b1 : 1'b0;
			assign invalid[i] = INVALID_VALUE_CHECK ? ((((valid[i - 1] == 1'b1)
			                    && (din[i] == 1'b1)) || 
			                    (invalid[i - 1] == 1'b1)) ? 1'b1 : 1'b0) : 
			                    1'b0;
			assign result[i] = valid[i - 1] ? result[i - 1] : 
			                   i[OUTPUT_WIDTH - 1:0];
		end
	endgenerate

	assign out_valid = valid[BITS - 1] & (~invalid[BITS - 1]);
	assign dout = out_valid ? result[BITS - 1] : {OUTPUT_WIDTH{1'b0}};

endmodule // bits_encoder