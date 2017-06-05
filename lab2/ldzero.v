`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:31 04/21/2017 
// Design Name: 
// Module Name:    ldzero 
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
module ldzero(
	//inputs
	mag,
	//outputs
	exp,
	sfcand,
	fifthb
 );
	 
	 
input [11:0] mag;
output [2:0] exp;
output [3:0] sfcand;
output fifthb;

integer i;
integer t_exp;
reg [3:0] t_s;
reg t_fb;
reg [11:0] t_data;


always @(*)
begin
	t_data[11:0] = mag[11:0] ;
	i=0;
	while (!t_data[11] && (i < 8))
	begin
		i = i+1;
		t_data = t_data << 1;
	end
		
	if (i >= 8) 
		t_exp = 0;
	else if (i == 0)
	begin
		t_exp = 3'b111;
		t_data[11:0] = 12'hfff;
	end
	else
		t_exp = 8-i;	
end

assign sfcand = t_data[11:8];
assign fifthb = t_data[7];	
assign exp = t_exp;

endmodule
