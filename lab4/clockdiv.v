
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:59 05/24/2017 
// Design Name: 
// Module Name:    clockdiv 
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
module clockdiv(
	input clk,		//master clock: 100MHz
	output dclk,		//pixel clock: 25MHz
	output deb_clk  //debouncer clock: 381Hz
);

reg [2:0] q = 3'b0;
reg [18:0] deb_cnt = 19'b0;

// 100Mhz ÷ 2^2 = 25MHz
assign dclk = q[1];
// 100MHz ÷ 2^18 = 381Hz
assign deb_clk = deb_cnt[18];

always @(posedge clk)
begin
	q <= q + 1;
	deb_cnt <= deb_cnt + 1;
	if (deb_cnt == 19'h40001)
		deb_cnt <= 19'b0;
end

endmodule
