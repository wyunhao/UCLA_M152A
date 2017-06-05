`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:03:03 05/01/2017 
// Design Name: 
// Module Name:    stopwatch 
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
module stopwatch(
	//input
	clk,
	adj, sel, 
	bp, bs, 
	//output
	seg0, seg1, seg2, seg3, seg4, seg5, seg6,
	d0, d1, d2, d3
);

input sel, adj, bs, bp, clk;	 
output seg0, seg1, seg2, seg3, seg4, seg5, seg6, d0, d1, d2, d3;
	 
wire fst_clk;
wire blk_clk;

clock clock__ (
	//input
	.clk (clk),
	//output
	.fst_clk (fst_clk),
	.blk_clk (blk_clk)
);

display display__ (
	//input 
	.fst_clk (fst_clk),
	.blk_clk (blk_clk),

	//output
	.adj		(adj),
	.sel		(sel),
	.bp   	(bp),
	.bs		(bs),
	.seg0   	(seg0),
	.seg1 	(seg1), 
	.seg2 	(seg2), 
	.seg3 	(seg3),
	.seg4 	(seg4),
	.seg5 	(seg5),
	.seg6 	(seg6),
	.d0		(d0),
	.d1		(d1),
	.d2		(d2),
	.d3		(d3)
);

endmodule

