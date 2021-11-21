////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: bits_synchronizer
//
// Description:
// This module is a n-level bits synchronizer.
//
// Dependencies:
// <None>
//
// Revision: 1.0
//
// Parameters:
//         STAGE - stages of synchronizer.
//          BITS - bit width of original data(input data).
// DEFAULT_LEVEL - reset level, must start with "1'b".
//
// Inputs:
//  clk - system clock.
//  rst - reset.
//  din - data input.
//
// Outputs:
// dout - data output.
////////////////////////////////////////////////////////////////////////////////

module bits_synchronizer #(
        parameter STAGE = 3,
        parameter BITS = 1,
        parameter DEFAULT_LEVEL = 1'b1
    )(
        input clk,
        input rst,
        input [BITS - 1:0] din,
        output [BITS - 1:0] dout
    );

    reg [BITS - 1:0] sync_reg [STAGE - 1:0];

    genvar i;

    always @(posedge clk) begin
        if(rst) begin
            sync_reg[0] <= {BITS{DEFAULT_LEVEL}};
        end
        else begin
            sync_reg[0] <= din;
        end
    end

    generate
        for(i = 0;i < STAGE - 1;i = i + 1) begin : sync_reg_generate
            always @(posedge clk) begin
                if(rst) begin
                    sync_reg[i + 1] <= {BITS{DEFAULT_LEVEL}};
                end
                else begin
                    sync_reg[i + 1] <= sync_reg[i];
                end
            end
        end

    endgenerate

    assign dout = sync_reg[STAGE - 1];

endmodule // bits_synchronizer