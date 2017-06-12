`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:38:39 05/24/2017 
// Design Name: 
// Module Name:    rand_gen 
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
module rand_gen(
	input clk,
	output [3:0] pos_dec,
	output [1:0] figure
);

reg [11:0] rand = 12'h345;
wire feedback;
assign feedback = !(rand[10]^rand[7]);
assign pos_dec = rand[5:2];
assign figure = rand[1:0];

always @ (posedge clk)	
begin
	rand = {rand[10:0], feedback};
end	

endmodule
