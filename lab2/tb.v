`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:18:04 02/02/2017
// Design Name:   convertor
// Module Name:   C:/Users/152/Downloads/lab2/convertor_TB.v
// Project Name:  lab2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: convertor
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module convertor_TB;

	// Inputs
	reg [11:0] D;

	// Outputs
	wire S;
	wire [2:0] E;
	wire [3:0] F;

	// Instantiate the Unit Under Test (UUT)
	FPCVT uut (
		.D(D), 
		.S(S), 
		.E(E), 
		.F(F)
	);

	initial begin
		// Initialize Inputs
		D = 1;
		
		// Wait 100 ns for global reset to finish
		#1000;
	
		// Add stimulus here
		//$display
		D = 12'b000000000000;
		#100
		$display("FP: %b %b %b, original: 0 000 0000\n", S,E,F);
		#100
		D = 12'b000000101100;
		#100
		$display("FP: %b %b %b, original: 0 010 1011\n", S,E,F);
		#100
		D = 12'b000000101101;
		#100
		$display("FP: %b %b %b, original: 0 010 1011\n", S,E,F);
		#100
		D = 12'b000000101110;
		#100
		$display("FP: %b %b %b, original: 0 010 1100\n", S,E,F);
		#100
		D = 12'b000000101111;
		#100
		$display("FP: %b %b %b, original: 0 010 1100\n", S,E,F);
		#100
		D = 12'b000000000100;
		#100
		$display("FP: %b %b %b, original: 0 000 0100\n", S,E,F);
		#100
		D = 12'b011111111111;
		#100
		$display("FP: %b %b %b, original: 0 111 1111\n", S,E,F);
		#100
		D = 12'b111111111111;
		#100
		$display("FP: %b %b %b, original: 1 000 0001\n", S,E,F);
		#100
		D = 12'b011111100000;
		#100
		$display("FP: %b %b %b, original: 0 111 1111\n", S,E,F);
		#100
		D = 12'b000000011111;
		#100
		$display("FP: %b %b %b, original: 0 010 1000\n", S,E,F);
		#100
		D = 12'b011110000000; // test for the max overflow 2^7 * (2^4-1)
		#100
		$display("FP: %b %b %b, original: 0 111 1111\n", S,E,F);
		#100
		D = 12'b011110000001; // test for the max overflow + 1
		#100
		$display("FP: %b %b %b, original: 0 111 1111\n", S,E,F);
		#100
		D = 12'b011100000000; // test for the max overflow: 2^11 - 2^8
		#100
		$display("FP: %b %b %b, original: 0 111 1110\n", S,E,F);
		#100
		D = 12'b100010000000; // test for the min overflow
		#100
		$display("FP: %b %b %b, original: 1 111 1111\n", S,E,F);
		#100
		D = 12'b100100000000; // test for the min overflow: -(2^7 * 14 = 2^7 *(2^4-2) = 2^11 - 2^8)
		#100
		$display("FP: %b %b %b, original: 1 111 1110\n", S,E,F);
		#100
		D = 12'b111001011010;
		#100
		$display("FP: %b %b %b, original: 1 101 1101\n", S,E,F);
		#100
		D = 12'b111000000001;
		#100
		$display("FP: %b %b %b, original: 1 110 1000\n", S,E,F);
		#100
		D = 12'b100000000000;
		#100
		$display("FP: %b %b %b, original: 1 111 1111\n", S,E,F);
		#100
		D = 12'b100000000001;
		#100
		$display("FP: %b %b %b, original: 1 111 1111\n", S,E,F);

		
	end
      
endmodule
