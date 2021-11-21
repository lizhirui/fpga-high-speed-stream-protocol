////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_block_receiver
//
// Description:
// This module implements transparent data block reception.
//
// Dependencies:
// clog2.vh
// board_level_data_receiver.v
//
// Revision: 1.0
//
// Parameters:
// BYTE_N - bytes of data block.
//
// Inputs:
//          clk - system clock.
//          rst - reset.
//      rev_clk - receive clock from transmitter.
//  serial_data - serial data from transmitter.
//
// Outputs:
//         data - received data.
//        valid - whether "data" signal is valid.
//   data_error - whether CRC is error.
// length_error - whether frame length isn't equal to parameter BYTE_N.
//        error - the result of "data_error | length_error".
////////////////////////////////////////////////////////////////////////////////

module board_level_data_block_receiver #(
        parameter BYTE_N = 8
    )(
        input clk,
        input rst,
        input rev_clk,
        input serial_data,
        output [BYTE_N * 8 - 1:0] data,
        output valid,
        output data_error,
        output length_error,
        output error
    );

    `include "clog2.vh"

    localparam DATA_WIDTH = BYTE_N * 8;
    localparam CNT_BIT_WIDTH = clog2(BYTE_N + 1);

    localparam REVSTATE_INIT = 1'b0;
    localparam REVSTATE_REV = 1'b1;

    //signals from board_level_data_receiver
    wire rev_frame_start;
    wire rev_frame_end;
    wire [7:0] rev_data;
    wire rev_valid;
    wire rev_error;

    //used for reception FSM
    reg cur_revstate;
    reg next_revstate;

    reg [CNT_BIT_WIDTH - 1:0] cur_rev_cnt; //bytes of received data.
    wire [CNT_BIT_WIDTH:0] temp_next_rev_cnt; //this code style is to eliminate
                                              //warnings of ISE.
    wire [CNT_BIT_WIDTH - 1:0] next_rev_cnt;

    reg [DATA_WIDTH - 1:0] stored_data; //used to combine received data.

    wire rev_start; //whether reception starts.
    wire rev_finish; //whether reception finishes.

    //output result registers
    reg [DATA_WIDTH - 1:0] result_data;
    reg [CNT_BIT_WIDTH - 1:0] result_length;
    reg result_valid;
    reg result_data_error;

    board_level_data_receiver board_level_data_receiver_inst(
        .clk(clk),
        .rst(rst),
        .rev_clk(rev_clk),
        .serial_data(serial_data),
        .frame_start(rev_frame_start),
        .frame_end(rev_frame_end),
        .data(rev_data),
        .valid(rev_valid),
        .error(rev_error)
    );

    //-------------------------------Reception FSM------------------------------
    always @(posedge clk) begin
        if(rst) begin
            cur_revstate <= REVSTATE_INIT;
        end
        else begin
            cur_revstate <= next_revstate;
        end
    end

    always @(*) begin
        if(!rev_valid) begin
            next_revstate = cur_revstate;
        end
        else if(rev_frame_start == 1'b1) begin
            next_revstate = REVSTATE_REV;
        end
        else begin
            case(cur_revstate)
                REVSTATE_INIT: next_revstate = (rev_frame_start == 1'b1) ? 
                                               REVSTATE_REV : REVSTATE_INIT;
                REVSTATE_REV: next_revstate = (rev_frame_end == 1'b1) ? 
                                               REVSTATE_INIT : REVSTATE_REV;
                default: next_revstate = REVSTATE_INIT;
            endcase
        end
    end
    //--------------------------------------------------------------------------

    assign rev_start = (((cur_revstate == REVSTATE_INIT) && 
                       (next_revstate == REVSTATE_REV)) || 
                       (rev_valid && rev_frame_start)) ? 1'b1 : 1'b0;

    assign rev_finish = ((cur_revstate == REVSTATE_REV) && 
                        (next_revstate == REVSTATE_INIT)) ? 1'b1 : 1'b0;

    //-----------------------------Reception Counter----------------------------
    assign temp_next_rev_cnt = cur_rev_cnt + 
                               {{(CNT_BIT_WIDTH - 1){1'b0}}, 1'b1};
    assign next_rev_cnt = temp_next_rev_cnt[CNT_BIT_WIDTH - 1:0];

    always @(posedge clk) begin
        if(rst) begin
            cur_rev_cnt <= {CNT_BIT_WIDTH{1'b0}};
        end
        else if(rev_start) begin
            cur_rev_cnt <= {CNT_BIT_WIDTH{1'b0}};
        end
        else if((cur_revstate == REVSTATE_REV) && (rev_valid == 1'b1)) begin
            cur_rev_cnt <= next_rev_cnt;
        end
    end
    //--------------------------------------------------------------------------

    //receive data.
    always @(posedge clk) begin
        if(rst) begin
            stored_data <= {DATA_WIDTH{1'b0}};
        end
        else if(rev_start) begin
            stored_data <= {DATA_WIDTH{1'b0}};
        end
        else if((cur_revstate == REVSTATE_REV) && 
                (next_revstate == REVSTATE_REV) && 
                (rev_valid == 1'b1) && (cur_rev_cnt < BYTE_N)) begin
            stored_data[(cur_rev_cnt * 8) + 7 -: 8] <= rev_data;
        end
    end

    //-------------------------------Result Output------------------------------
    always @(posedge clk) begin
        if(rst) begin
            result_data <= {DATA_WIDTH{1'b0}};
        end
        else if(rev_finish) begin
            result_data <= stored_data;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            result_length <= {CNT_BIT_WIDTH{1'b0}};
        end
        else if(rev_finish) begin
            result_length <= cur_rev_cnt;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            result_valid <= 1'b0;
        end
        else if(rev_finish) begin
            result_valid <= 1'b1;
        end
        else begin
            result_valid <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            result_data_error <= 1'b0;
        end
        else if(rev_finish) begin
            result_data_error <= rev_error;
        end
    end

    assign data = result_data;
    assign valid = result_valid;
    assign length_error = (result_length == BYTE_N) ? 1'b0 : 1'b1;
    assign data_error = result_data_error;
    assign error = length_error | data_error;
    //--------------------------------------------------------------------------

endmodule // board_level_data_block_receiver