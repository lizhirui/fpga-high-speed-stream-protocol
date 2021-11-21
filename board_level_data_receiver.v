////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: board_level_data_receiver
//
// Description:
// This module implements transparent data reception and convert 6-bit data to
// 8-bit data.
//
// Dependencies:
// board_level_data_receiver_physical.v
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
//     rev_clk - receive clock from transmitter.
// serial_data - serial data from transmitter.
//
// Outputs:
// frame_start - indicates that this module received a frame start signal.
//   frame_end - indicates that this module received a frame end signal.
//        data - received data(when frame_start or frame_end is "1", 
//               this signal is meaningless).
//       valid - whether frame_start or frame_end or data is valid.
//       error - whether frame CRC is error.
////////////////////////////////////////////////////////////////////////////////

module board_level_data_receiver(
		input clk,
		input rst,
		input rev_clk,
		input serial_data,
		output frame_start,
		output frame_end,
		output [7:0] data,
		output valid,
		output error
	);

	localparam DATASTATE_FIRST = 2'b00;
	localparam DATASTATE_SECOND = 2'b01;
	localparam DATASTATE_THIRD = 2'b10;
	localparam DATASTATE_FOURTH = 2'b11;

	//signals from board_level_data_receiver_physical.
	wire [5:0] physical_data;
	wire physical_valid;
	wire physical_frame_end;

	//used for reception FSM
	reg [1:0] cur_datastate;
	reg [1:0] next_datastate;

	wire [7:0] mix_data; //combined 8-bit data.
	wire [5:0] backup_data; //data bits that need to be backup.
	reg [5:0] data_buffer; //data backup register.

	reg [7:0] confirmed_data; //data that is ready to output.

	//received CRC data.
	reg [7:0] crc_data;
	wire [7:0] new_crc_data;

	reg rev_status; //whether this module is receiving data.

	reg confirmed_valid; //confirmed valid signal.

	reg last_frame_end; //delayed frame_end signal.

	wire error_signal; //whether received CRC isn't equal to calculated CRC.
	reg error_result; //error signal output register.

	board_level_data_receiver_physical board_level_data_receiver_physical_inst(
		.clk(clk),
		.rst(rst),
		.rev_clk(rev_clk),
		.serial_data(serial_data),
		.frame_start(frame_start),
		.frame_end(physical_frame_end),
		.data(physical_data),
		.valid(physical_valid)
	);

	//-------------------------------Reception FSM------------------------------
	always @(posedge clk) begin
		if(rst) begin
			cur_datastate <= DATASTATE_FIRST;
		end
		else if(physical_valid) begin
			cur_datastate <= (frame_start == 1'b1) ? DATASTATE_FIRST : 
							 next_datastate;
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

	//-------------------------------Receive Data-------------------------------
	assign mix_data = (cur_datastate == DATASTATE_FIRST) ? 8'b0 :
					  (cur_datastate == DATASTATE_SECOND) ? 
					  {data_buffer, physical_data[5:4]} :
					  (cur_datastate == DATASTATE_THIRD) ? 
					  {data_buffer[3:0], physical_data[5:2]} : 
					  {data_buffer[1:0], physical_data};

	assign backup_data = (cur_datastate == DATASTATE_FIRST) ? physical_data : 
						 (cur_datastate == DATASTATE_SECOND) ? 
						 {2'b00, physical_data[3:0]} :
						 (cur_datastate == DATASTATE_THIRD) ? 
						 {2'b00, physical_data[1:0]} : 6'b0;

	always @(posedge clk) begin
		if(rst) begin
			data_buffer <= 8'b0;
		end
		else if(!rev_status) begin
			data_buffer <= 8'b0;
		end
		else if(physical_valid) begin
			data_buffer <= backup_data;
		end
	end
	//--------------------------------------------------------------------------

	crc8_maxim crc8_maxim_inst(
		.last_crc(crc_data),
		.data(confirmed_data),
		.crc(new_crc_data)
	);

	always @(posedge clk) begin
		if(rst) begin
			rev_status <= 1'b0;
		end
		else if(frame_start == 1'b1) begin
			rev_status <= 1'b1;
		end
		else if(frame_end == 1'b1) begin
			rev_status <= 1'b0;
		end
	end

	always @(posedge clk) begin
		if(rst) begin
			confirmed_data <= 8'b0;
		end
		else if(!rev_status) begin
			confirmed_data <= 8'b0;
		end
		else if(physical_valid) begin
			confirmed_data <= (frame_start == 1'b1) ? 8'b0 : mix_data;
		end
	end

	always @(posedge clk) begin
		if(rst) begin
			crc_data <= 8'b0;
		end
		else if(!rev_status) begin
			crc_data <= 8'b0;
		end
		else if(physical_valid & confirmed_valid) begin
			crc_data <= (frame_start == 1'b1) ? 8'b0 : new_crc_data;
		end
	end	

	always @(posedge clk) begin
		if(rst) begin
			confirmed_valid <= 1'b0;
		end
		else if(!rev_status) begin
			confirmed_valid <= 1'b0;
		end
		else if(frame_start == 1'b1) begin
			confirmed_valid <= 1'b0;
		end
		else if(physical_valid == 1'b1) begin
			confirmed_valid <= (cur_datastate == DATASTATE_FIRST) ? 
			                   1'b0 : 1'b1;
		end
	end

	//delay frame_end signal to remain one clock to determine whether
	//confirmed_data should be output(CRC shouldn't be output).
	always @(posedge clk) begin
		if(rst) begin
			last_frame_end <= 1'b0;
		end
		else if(physical_valid) begin
			last_frame_end <= physical_frame_end;
		end
		else begin
			last_frame_end <= 1'b0;
		end
	end

	//-------------------------------Result Output------------------------------
	assign frame_end = last_frame_end;
	assign valid = (rev_status & confirmed_valid & physical_valid & 
				   (~physical_frame_end)) | last_frame_end | 
	               (frame_start & physical_valid);
	assign data = valid ? confirmed_data : 8'b0;
	assign error_signal = |(crc_data ^ confirmed_data);

	always @(posedge clk) begin
		if(rst) begin
			error_result <= 1'b0;
		end
		else if(frame_start & physical_valid) begin
			error_result <= 1'b0;
		end
		else if(physical_frame_end & physical_valid) begin
			error_result <= error_signal;
		end
	end

	assign error = error_result;
	//--------------------------------------------------------------------------

endmodule // board_level_data_receiver