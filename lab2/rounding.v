`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:44 04/21/2017 
// Design Name: 
// Module Name:    rounding 
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
module rounding(
	//inputs
	exp,
	sfcand,
	fifthb,
	//outputs
	E,
	F
);

input [2:0] exp;
input [3:0] sfcand;
input fifthb;

output [2:0] E;
output [3:0] F;

reg [4:0] t_fcand;
reg [3:0] t_exp;

always @(*)
begin
if (fifthb)
	begin
		t_fcand = sfcand+1;
		if (t_fcand[4]) // sfcand overflow, in which case, originally, we have sfcand = 1111
		begin
			t_fcand = t_fcand >> 1;
			t_exp = exp+1;
			if (t_exp[3]) // exp overflow, in which case, originally, we have exp = 111
			begin
				t_exp = 4'b0111;
				t_fcand = 5'b01111;
			end
		end	
	end
else 
	begin
		t_fcand[3:0] = sfcand[3:0];
		t_exp[2:0] = exp[2:0];
	end
end

assign F = t_fcand[3:0];
assign E = t_exp[2:0];

endmodule
