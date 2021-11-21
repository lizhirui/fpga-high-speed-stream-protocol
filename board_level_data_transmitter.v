////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_transmitter
//
// Description:
// This module implements transparent data transmisstion and convert 8-bit data 
// to 6-bit data.
//
// Dependencies:
// board_level_data_transmitter_physical.v
// crc8_maxim.v
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
//		    we - write enable.
//
// Outputs:
//        busy - whether this module is busy.
//  data_ready - whether this module can receive data.
// serial_data - serial data to receiver.
////////////////////////////////////////////////////////////////////////////////

module board_level_data_transmitter(
		input clk,
		input rst,
		input send_clk,
		input frame_start,
		input frame_end,
		input [7:0] data,
		input we,
		output busy,
		output data_ready,
		output serial_data
	);

	localparam STATE_IDLE = 2'b00; //used to send frame start signal.
	localparam STATE_DATA = 2'b01; //used to send data.
	localparam STATE_PADDING = 2'b10; //used to send last data(maybe some data 
									  //with CRC with some padding zero).
	localparam STATE_FINISH = 2'b11; //used to send frame end signal.

	localparam DATASTATE_FIRST = 2'b00;
	localparam DATASTATE_SECOND = 2'b01;
	localparam DATASTATE_THIRD = 2'b10;
	localparam DATASTATE_FOURTH = 2'b11;

	//used for send FSM
	reg [1:0] cur_state;
	reg [1:0] next_state;
	reg [1:0] cur_datastate;
	reg [1:0] next_datastate;

	wire full;
	wire physical_full;

	wire [7:0] origin_data; //data source(user input data or CRC).
	wire [5:0] out_data; //output data in this clock.
	wire [5:0] backup_data; //backup data in this clock.
	reg [5:0] data_buffer; //need to store backup data.

	reg [7:0] crc_data; //current CRC.
	wire [7:0] new_crc_data; //new CRC.

	//---------------------------------Send FSM---------------------------------
	always @(posedge clk) begin
		if(rst) begin
			cur_state <= STATE_IDLE;
		end
		else if(!full) begin
			cur_state <= next_state;
		end
	end

	always @(*) begin
		case(cur_state)
			STATE_IDLE: next_state = (frame_start & we) ? 
									 STATE_DATA : STATE_IDLE;
			STATE_DATA: next_state = (frame_end & we) ?
									 STATE_PADDING : STATE_DATA;
			STATE_PADDING: next_state = STATE_FINISH;
			STATE_FINISH: next_state = STATE_IDLE;
			default: next_state = STATE_IDLE;
		endcase
	end

	always @(posedge clk) begin
		if(rst) begin
			cur_datastate <= DATASTATE_FIRST;
		end
		else if(cur_state == STATE_IDLE) begin
			cur_datastate <= DATASTATE_FIRST;
		end
		else if((cur_state == STATE_DATA) && (!physical_full)) begin
			cur_datastate <= next_datastate;
		end
	end

	always @(*) begin
		case(cur_datastate)
			DATASTATE_FIRST: next_datastate = DATASTATE_SECOND;
			DATASTATE_SECOND: next_datastate = DATASTATE_THIRD;
			DATASTATE_THIRD: next_datastate = DATASTATE_FOURTH;
			DATASTATE_FOURTH: next_datastate = DATASTATE_FIRST;
			default: next_datastate = DATASTATE_FIRST;
		endcase
	end
	//--------------------------------------------------------------------------

	//----------------------------Send Data Generate----------------------------
	assign origin_data = (cur_state != STATE_DATA) ? 8'b00 :
						 frame_end ? crc_data : data;

	assign out_data = (cur_datastate == DATASTATE_FIRST) ? origin_data[7:2] :
					  (cur_datastate == DATASTATE_SECOND) ? 
					  {data_buffer[1:0], origin_data[7:4]} :
					  (cur_datastate == DATASTATE_THIRD) ? 
					  {data_buffer[3:0], origin_data[7:6]} : data_buffer;

	assign backup_data = (cur_datastate == DATASTATE_FIRST) ? 
						 {4'b00, origin_data[1:0]} : 
						 (cur_datastate == DATASTATE_SECOND) ? 
						 {2'b00, origin_data[3:0]} :
						 (cur_datastate == DATASTATE_THIRD) ? 
						 origin_data[5:0] : 6'b0;

	always @(posedge clk) begin
		if(rst) begin
			data_buffer <= 6'b0;
		end
		else if(!physical_full) begin
			data_buffer <= backup_data;
		end
	end
	//--------------------------------------------------------------------------

	//-------------------------------CRC Generate-------------------------------
	always @(posedge clk) begin
		if(rst) begin
			crc_data <= 8'b0;
		end
		else if(cur_state == STATE_IDLE) begin
			crc_data <= 8'b0;
		end
		else if((cur_state == STATE_DATA) && (!full)) begin
			crc_data <= new_crc_data;
		end
	end

	crc8_maxim crc8_maxim_inst(
		.last_crc(crc_data),
		.data(data),
		.crc(new_crc_data)
	);
	//--------------------------------------------------------------------------

	board_level_data_transmitter_physical 
	board_level_data_transmitter_physical_inst(
		.clk(clk),
		.rst(rst),
		.send_clk(send_clk),
		.frame_start(((cur_state == STATE_IDLE) && (next_state == STATE_DATA)) ? 
					 1'b1 : 1'b0),
		.frame_end((cur_state == STATE_FINISH) ? 1'b1 : 1'b0),
		.data(out_data),
		.we(we | (((cur_state == STATE_PADDING) || (cur_state == STATE_FINISH)) ? 
			1'b1 : 1'b0)),
		.full(physical_full),
		.serial_data(serial_data)
	);

	//-------------------------------Result Output------------------------------
	//in datastate_fourth, this module need to stop data reception for one clock
	//because the data bit length of data_buffer is 6-bit.
	assign full = physical_full | (((cur_datastate == DATASTATE_FOURTH) && 
				  (cur_state == STATE_DATA)) ? 1'b1 : 1'b0);

	assign busy = full | (((cur_state == STATE_PADDING) || 
				  (cur_state == STATE_FINISH)) ? 1'b1 : 1'b0);
	assign data_ready = ((cur_state == STATE_DATA) ? 1'b1 : 1'b0) & (~full);
	//--------------------------------------------------------------------------

endmodule