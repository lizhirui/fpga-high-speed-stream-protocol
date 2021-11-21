////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Module Name: crc8_maxim
//
// Description:
// This module implements CRC8/Maxim by look-up table.
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
// last_crc - last CRC value.
//     data - new data.
//
// Outputs:
//      crc - new CRC value.
////////////////////////////////////////////////////////////////////////////////

module crc8_maxim(
		input [7:0] last_crc,
		input [7:0] data,
		output reg [7:0] crc
	);

	always @(*) begin
		case(last_crc ^ data)
			8'h00: crc = 8'h00;
			8'h01: crc = 8'h5e;
			8'h02: crc = 8'hbc;
			8'h03: crc = 8'he2;
			8'h04: crc = 8'h61;
			8'h05: crc = 8'h3f;
			8'h06: crc = 8'hdd;
			8'h07: crc = 8'h83;
			8'h08: crc = 8'hc2;
			8'h09: crc = 8'h9c;
			8'h0a: crc = 8'h7e;
			8'h0b: crc = 8'h20;
			8'h0c: crc = 8'ha3;
			8'h0d: crc = 8'hfd;
			8'h0e: crc = 8'h1f;
			8'h0f: crc = 8'h41;
			8'h10: crc = 8'h9d;
			8'h11: crc = 8'hc3;
			8'h12: crc = 8'h21;
			8'h13: crc = 8'h7f;
			8'h14: crc = 8'hfc;
			8'h15: crc = 8'ha2;
			8'h16: crc = 8'h40;
			8'h17: crc = 8'h1e;
			8'h18: crc = 8'h5f;
			8'h19: crc = 8'h01;
			8'h1a: crc = 8'he3;
			8'h1b: crc = 8'hbd;
			8'h1c: crc = 8'h3e;
			8'h1d: crc = 8'h60;
			8'h1e: crc = 8'h82;
			8'h1f: crc = 8'hdc;
			8'h20: crc = 8'h23;
			8'h21: crc = 8'h7d;
			8'h22: crc = 8'h9f;
			8'h23: crc = 8'hc1;
			8'h24: crc = 8'h42;
			8'h25: crc = 8'h1c;
			8'h26: crc = 8'hfe;
			8'h27: crc = 8'ha0;
			8'h28: crc = 8'he1;
			8'h29: crc = 8'hbf;
			8'h2a: crc = 8'h5d;
			8'h2b: crc = 8'h03;
			8'h2c: crc = 8'h80;
			8'h2d: crc = 8'hde;
			8'h2e: crc = 8'h3c;
			8'h2f: crc = 8'h62;
			8'h30: crc = 8'hbe;
			8'h31: crc = 8'he0;
			8'h32: crc = 8'h02;
			8'h33: crc = 8'h5c;
			8'h34: crc = 8'hdf;
			8'h35: crc = 8'h81;
			8'h36: crc = 8'h63;
			8'h37: crc = 8'h3d;
			8'h38: crc = 8'h7c;
			8'h39: crc = 8'h22;
			8'h3a: crc = 8'hc0;
			8'h3b: crc = 8'h9e;
			8'h3c: crc = 8'h1d;
			8'h3d: crc = 8'h43;
			8'h3e: crc = 8'ha1;
			8'h3f: crc = 8'hff;
			8'h40: crc = 8'h46;
			8'h41: crc = 8'h18;
			8'h42: crc = 8'hfa;
			8'h43: crc = 8'ha4;
			8'h44: crc = 8'h27;
			8'h45: crc = 8'h79;
			8'h46: crc = 8'h9b;
			8'h47: crc = 8'hc5;
			8'h48: crc = 8'h84;
			8'h49: crc = 8'hda;
			8'h4a: crc = 8'h38;
			8'h4b: crc = 8'h66;
			8'h4c: crc = 8'he5;
			8'h4d: crc = 8'hbb;
			8'h4e: crc = 8'h59;
			8'h4f: crc = 8'h07;
			8'h50: crc = 8'hdb;
			8'h51: crc = 8'h85;
			8'h52: crc = 8'h67;
			8'h53: crc = 8'h39;
			8'h54: crc = 8'hba;
			8'h55: crc = 8'he4;
			8'h56: crc = 8'h06;
			8'h57: crc = 8'h58;
			8'h58: crc = 8'h19;
			8'h59: crc = 8'h47;
			8'h5a: crc = 8'ha5;
			8'h5b: crc = 8'hfb;
			8'h5c: crc = 8'h78;
			8'h5d: crc = 8'h26;
			8'h5e: crc = 8'hc4;
			8'h5f: crc = 8'h9a;
			8'h60: crc = 8'h65;
			8'h61: crc = 8'h3b;
			8'h62: crc = 8'hd9;
			8'h63: crc = 8'h87;
			8'h64: crc = 8'h04;
			8'h65: crc = 8'h5a;
			8'h66: crc = 8'hb8;
			8'h67: crc = 8'he6;
			8'h68: crc = 8'ha7;
			8'h69: crc = 8'hf9;
			8'h6a: crc = 8'h1b;
			8'h6b: crc = 8'h45;
			8'h6c: crc = 8'hc6;
			8'h6d: crc = 8'h98;
			8'h6e: crc = 8'h7a;
			8'h6f: crc = 8'h24;
			8'h70: crc = 8'hf8;
			8'h71: crc = 8'ha6;
			8'h72: crc = 8'h44;
			8'h73: crc = 8'h1a;
			8'h74: crc = 8'h99;
			8'h75: crc = 8'hc7;
			8'h76: crc = 8'h25;
			8'h77: crc = 8'h7b;
			8'h78: crc = 8'h3a;
			8'h79: crc = 8'h64;
			8'h7a: crc = 8'h86;
			8'h7b: crc = 8'hd8;
			8'h7c: crc = 8'h5b;
			8'h7d: crc = 8'h05;
			8'h7e: crc = 8'he7;
			8'h7f: crc = 8'hb9;
			8'h80: crc = 8'h8c;
			8'h81: crc = 8'hd2;
			8'h82: crc = 8'h30;
			8'h83: crc = 8'h6e;
			8'h84: crc = 8'hed;
			8'h85: crc = 8'hb3;
			8'h86: crc = 8'h51;
			8'h87: crc = 8'h0f;
			8'h88: crc = 8'h4e;
			8'h89: crc = 8'h10;
			8'h8a: crc = 8'hf2;
			8'h8b: crc = 8'hac;
			8'h8c: crc = 8'h2f;
			8'h8d: crc = 8'h71;
			8'h8e: crc = 8'h93;
			8'h8f: crc = 8'hcd;
			8'h90: crc = 8'h11;
			8'h91: crc = 8'h4f;
			8'h92: crc = 8'had;
			8'h93: crc = 8'hf3;
			8'h94: crc = 8'h70;
			8'h95: crc = 8'h2e;
			8'h96: crc = 8'hcc;
			8'h97: crc = 8'h92;
			8'h98: crc = 8'hd3;
			8'h99: crc = 8'h8d;
			8'h9a: crc = 8'h6f;
			8'h9b: crc = 8'h31;
			8'h9c: crc = 8'hb2;
			8'h9d: crc = 8'hec;
			8'h9e: crc = 8'h0e;
			8'h9f: crc = 8'h50;
			8'ha0: crc = 8'haf;
			8'ha1: crc = 8'hf1;
			8'ha2: crc = 8'h13;
			8'ha3: crc = 8'h4d;
			8'ha4: crc = 8'hce;
			8'ha5: crc = 8'h90;
			8'ha6: crc = 8'h72;
			8'ha7: crc = 8'h2c;
			8'ha8: crc = 8'h6d;
			8'ha9: crc = 8'h33;
			8'haa: crc = 8'hd1;
			8'hab: crc = 8'h8f;
			8'hac: crc = 8'h0c;
			8'had: crc = 8'h52;
			8'hae: crc = 8'hb0;
			8'haf: crc = 8'hee;
			8'hb0: crc = 8'h32;
			8'hb1: crc = 8'h6c;
			8'hb2: crc = 8'h8e;
			8'hb3: crc = 8'hd0;
			8'hb4: crc = 8'h53;
			8'hb5: crc = 8'h0d;
			8'hb6: crc = 8'hef;
			8'hb7: crc = 8'hb1;
			8'hb8: crc = 8'hf0;
			8'hb9: crc = 8'hae;
			8'hba: crc = 8'h4c;
			8'hbb: crc = 8'h12;
			8'hbc: crc = 8'h91;
			8'hbd: crc = 8'hcf;
			8'hbe: crc = 8'h2d;
			8'hbf: crc = 8'h73;
			8'hc0: crc = 8'hca;
			8'hc1: crc = 8'h94;
			8'hc2: crc = 8'h76;
			8'hc3: crc = 8'h28;
			8'hc4: crc = 8'hab;
			8'hc5: crc = 8'hf5;
			8'hc6: crc = 8'h17;
			8'hc7: crc = 8'h49;
			8'hc8: crc = 8'h08;
			8'hc9: crc = 8'h56;
			8'hca: crc = 8'hb4;
			8'hcb: crc = 8'hea;
			8'hcc: crc = 8'h69;
			8'hcd: crc = 8'h37;
			8'hce: crc = 8'hd5;
			8'hcf: crc = 8'h8b;
			8'hd0: crc = 8'h57;
			8'hd1: crc = 8'h09;
			8'hd2: crc = 8'heb;
			8'hd3: crc = 8'hb5;
			8'hd4: crc = 8'h36;
			8'hd5: crc = 8'h68;
			8'hd6: crc = 8'h8a;
			8'hd7: crc = 8'hd4;
			8'hd8: crc = 8'h95;
			8'hd9: crc = 8'hcb;
			8'hda: crc = 8'h29;
			8'hdb: crc = 8'h77;
			8'hdc: crc = 8'hf4;
			8'hdd: crc = 8'haa;
			8'hde: crc = 8'h48;
			8'hdf: crc = 8'h16;
			8'he0: crc = 8'he9;
			8'he1: crc = 8'hb7;
			8'he2: crc = 8'h55;
			8'he3: crc = 8'h0b;
			8'he4: crc = 8'h88;
			8'he5: crc = 8'hd6;
			8'he6: crc = 8'h34;
			8'he7: crc = 8'h6a;
			8'he8: crc = 8'h2b;
			8'he9: crc = 8'h75;
			8'hea: crc = 8'h97;
			8'heb: crc = 8'hc9;
			8'hec: crc = 8'h4a;
			8'hed: crc = 8'h14;
			8'hee: crc = 8'hf6;
			8'hef: crc = 8'ha8;
			8'hf0: crc = 8'h74;
			8'hf1: crc = 8'h2a;
			8'hf2: crc = 8'hc8;
			8'hf3: crc = 8'h96;
			8'hf4: crc = 8'h15;
			8'hf5: crc = 8'h4b;
			8'hf6: crc = 8'ha9;
			8'hf7: crc = 8'hf7;
			8'hf8: crc = 8'hb6;
			8'hf9: crc = 8'he8;
			8'hfa: crc = 8'h0a;
			8'hfb: crc = 8'h54;
			8'hfc: crc = 8'hd7;
			8'hfd: crc = 8'h89;
			8'hfe: crc = 8'h6b;
			8'hff: crc = 8'h35;
			default: crc = 8'h00;
		endcase
	end

endmodule // crc8_maxim