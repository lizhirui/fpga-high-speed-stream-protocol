////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_block_transmitter
//
// Description:
// This module implements transparent data block transmission.
//
// Dependencies:
// clog2.vh
// board_level_data_transmitter.v
//
// Revision: 1.0
//
// Parameters:
// BYTE_N - bytes of data block.
//
// Inputs:
//          clk - system clock.
//          rst - reset.
//     send_clk - send clock.
//         data - send data.
//           we - write enable.
//
// Outputs:
//  serial_data - serial data to receiver.
//        ready - module is ready for receiving new data.
////////////////////////////////////////////////////////////////////////////////

module board_level_data_block_transmitter #(
        parameter BYTE_N = 8
    )(
        input clk,
        input rst,
        input send_clk,
        output serial_data,
        input [BYTE_N * 8 - 1:0] data,
        input we,
        output ready
    );

    `include "clog2.vh"

    localparam DATA_WIDTH = BYTE_N * 8;
    localparam CNT_BIT_WIDTH = clog2(BYTE_N);

    localparam SENDSTATE_INIT = 2'b00; 
    localparam SENDSTATE_SEND = 2'b01;
    localparam SENDSTATE_FINISH = 2'b10;

    //signals from and to board_level_data_transmitter
    reg send_frame_start;
    reg send_frame_end;
    reg [7:0] send_data;
    wire send_busy;
    reg send_we;

    //used for send FSM
    reg [2:0] cur_sendstate;
    reg [2:0] next_sendstate;

    reg [CNT_BIT_WIDTH - 1:0] cur_send_cnt; //bytes of send data.
    wire [CNT_BIT_WIDTH:0] temp_next_send_cnt; //this code style is to eliminate
                                               //warnings of ISE.
    wire [CNT_BIT_WIDTH - 1:0] next_send_cnt;

    reg [DATA_WIDTH - 1:0] stored_data; //used to split send data.

    board_level_data_transmitter board_level_data_transmitter_inst(
        .clk(clk),
        .rst(rst),
        .send_clk(send_clk),
        .frame_start(send_frame_start),
        .frame_end(send_frame_end),
        .data(send_data),
        .we(send_we),
        .busy(send_busy),
        .data_ready(),
        .serial_data(serial_data)
    );

    //---------------------------------Send FSM---------------------------------
    always @(posedge clk) begin
        if(rst) begin
            cur_sendstate <= SENDSTATE_INIT;
        end
        else begin
            cur_sendstate <= next_sendstate;
        end
    end

    always @(*) begin
        if(send_busy) begin
            next_sendstate = cur_sendstate;
        end
        else begin
            case(cur_sendstate)
                SENDSTATE_INIT: next_sendstate = (we == 1'b1) ? 
                                SENDSTATE_SEND : SENDSTATE_INIT;
                SENDSTATE_SEND: next_sendstate = 
                                (next_send_cnt == BYTE_N[CNT_BIT_WIDTH - 1:0]) ? 
                                SENDSTATE_FINISH : SENDSTATE_SEND;
                SENDSTATE_FINISH: next_sendstate = SENDSTATE_INIT;
                default: next_sendstate = SENDSTATE_INIT;
            endcase
        end
    end
    //--------------------------------------------------------------------------

    //-------------------------------Send Counter-------------------------------
    assign temp_next_send_cnt = cur_send_cnt + 
                                {{(CNT_BIT_WIDTH - 1){1'b0}}, 1'b1};
    assign next_send_cnt = temp_next_send_cnt[CNT_BIT_WIDTH - 1:0];

    always @(posedge clk) begin
        if(rst) begin
            cur_send_cnt <= {CNT_BIT_WIDTH{1'b0}};
        end
        else if(cur_sendstate == SENDSTATE_INIT) begin
            cur_send_cnt <= {CNT_BIT_WIDTH{1'b0}};
        end
        else if((cur_sendstate == SENDSTATE_SEND) && (!send_busy)) begin
            cur_send_cnt <= next_send_cnt;
        end
    end
    //--------------------------------------------------------------------------

    //---------------------------Send Signal Generate---------------------------
    always @(posedge clk) begin
        if(rst) begin
            stored_data <= {DATA_WIDTH{1'b0}};
        end
        else if(cur_sendstate == SENDSTATE_INIT) begin
            stored_data <= data;
        end
        else if((cur_sendstate == SENDSTATE_SEND) && (!send_busy)) begin
            stored_data <= stored_data >> 8;
        end
    end

    always @(*) begin
        case(cur_sendstate)
            SENDSTATE_INIT: begin
                if(next_sendstate == SENDSTATE_SEND) begin
                    send_frame_start = 1'b1;
                    send_frame_end = 1'b0;
                    send_data = 8'b0;
                    send_we = 1'b1;
                end
                else begin
                    send_frame_start = 1'b0;
                    send_frame_end = 1'b0;
                    send_data = 8'b0;
                    send_we = 1'b0;
                end
            end

            SENDSTATE_SEND: begin
                send_frame_start = 1'b0;
                send_frame_end = 1'b0;
                send_data = stored_data[7:0];
                send_we = 1'b1;
            end

            SENDSTATE_FINISH: begin
                send_frame_start = 1'b0;
                send_frame_end = 1'b1;
                send_data = 8'b0;
                send_we = 1'b1;
            end

            default: begin
                send_frame_start = 1'b0;
                send_frame_end = 1'b0;
                send_data = 8'b0;
                send_we = 1'b0;
            end
        endcase
    end
    //--------------------------------------------------------------------------

    assign ready = ((cur_sendstate == SENDSTATE_INIT) && (send_busy == 1'b0)) 
                   ? 1'b1 : 1'b0;

endmodule // board_level_data_block_transmitter