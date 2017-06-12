`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc 2011
// Engineer: Michelle Yu  
//				 Josh Sackos
// Create Date:    07/23/2012 
//
// Module Name:    Decoder
// Project Name:   PmodKYPD_Demo
// Target Devices: Nexys3
// Tool versions:  Xilinx ISE 14.1 
// Description: This file defines a component Decoder for the demo project PmodKYPD. The Decoder scans
//					 each column by asserting a low to the pin corresponding to the column at 1KHz. After a
//					 column is asserted low, each row pin is checked. When a row pin is detected to be low,
//					 the key that was pressed could be determined.
//
// Revision History: 
// 						Revision 0.01 - File Created (Michelle Yu)
//							Revision 0.02 - Converted from VHDL to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================================
// 												Define Module
// ==============================================================================================
module Decoder(
    clk,
    Row,
    Col,
    DecodeOut,
	Enable
    );

// ==============================================================================================
// 											Port Declarations
// ==============================================================================================
    input clk;						// 100MHz onboard clock
    input [3:0] Row;				// Rows on KYPD
    output [3:0] Col;			// Columns on KYPD
    output [3:0] DecodeOut;	// Output data
	output Enable;

// ==============================================================================================
// 							  		Parameters, Regsiters, and Wires
// ==============================================================================================
	
	// Output wires and registers
	reg [3:0] Col;
	reg [3:0] DecodeOut;
	
	// Count register
	reg [25:0] sclk;
	
	// Enabler
	reg Enable = 1'b0;

// ==============================================================================================
// 												Implementation
// ==============================================================================================

	always @(posedge clk) begin

			// 1ms
			if (sclk == 26'b00011000011010100000000000) begin
				//C1
				Col <= 4'b0111;
				sclk <= sclk + 1'b1;
				Enable <= 1'b0;
			end
			
			// check row pins
			else if(sclk == 26'b00011000011010101000000000) begin
				//R1
				if (Row == 4'b0111) begin
					DecodeOut <= 4'b0001;		//1
					Enable <= 1'b1;
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b0100; 		//4
					Enable <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b0111; 		//7
					Enable <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b0000; 		//0
					Enable <= 1'b1;
				end
				else
					Enable <= 1'b0;
				sclk <= sclk + 1'b1;
			end

			// 2ms
			else if(sclk == 26'b00110000110101000000000000) begin
				//C2
				Col<= 4'b1011;
				sclk <= sclk + 1'b1;
				Enable <= 1'b0;
			end
			
			// check row pins
			else if(sclk == 26'b00110000110101001000000000) begin
				//R1
				if (Row == 4'b0111) begin
					DecodeOut <= 4'b0010; 		//2
					Enable <= 1'b1;
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b0101; 		//5
					Enable <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b1000; 		//8
					Enable <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b1111; 		//F
					Enable <= 1'b1;
				end
				else
					Enable <= 1'b0;
				sclk <= sclk + 1'b1;
			end

			//3ms
			else if(sclk == 26'b01001001001111100000000000) begin
				//C3
				Col<= 4'b1101;
				sclk <= sclk + 1'b1;
				Enable <= 1'b0;
			end
			
			// check row pins
			else if(sclk == 26'b01001001001111101000000000) begin
				//R1
				if(Row == 4'b0111) begin
					DecodeOut <= 4'b0011; 		//3
					Enable <= 1'b1;					
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b0110; 		//6
					Enable <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b1001; 		//9
					Enable <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b1110; 		//E
					Enable <= 1'b1;
				end
				else
					Enable <= 1'b0;
				sclk <= sclk + 1'b1;
			end

			//4ms
			else if(sclk == 26'b01100001101010000000000000) begin
				//C4
				Col<= 4'b1110;
				sclk <= sclk + 1'b1;
				Enable <= 1'b0;
			end

			// Check row pins
			else if(sclk == 26'b01100001101010001000000000) begin
				//R1
				if(Row == 4'b0111) begin
					DecodeOut <= 4'b1010; //A
					Enable <= 1'b1;
				end
				//R2
				else if(Row == 4'b1011) begin
					DecodeOut <= 4'b1011; //B
					Enable <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					DecodeOut <= 4'b1100; //C
					Enable <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					DecodeOut <= 4'b1101; //D
					Enable <= 1'b1;
				end
				else
					Enable <= 1'b0;
				sclk <= 26'b00000000000000000000000000;
			end

			// Otherwise increment
			else begin
				sclk <= sclk + 1'b1;
				Enable <= 1'b0;
			end
			
	end

endmodule
