`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:31:53 04/21/2017 
// Design Name: 
// Module Name:    sgnmag 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sgnmag(
	//inputs
	D,
	//outputs
	S,
	mag
);

input [11:0] D;
output S;
output [11:0] mag;

reg [11:0] t_mag;

always @(*)
begin
	t_mag =( D[11:0] ^ ({12{D[11]}})) + D[11];
end

assign mag = t_mag;
assign S = D[11];

endmodule
