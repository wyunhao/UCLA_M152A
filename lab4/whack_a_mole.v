`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:25:03 05/24/2017 
// Design Name: 
// Module Name:    whack_a_mole 
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
module whack_a_mole(
	input clk,
	input sw_level, // 1: hard, 0: easy
	input bt_pause,
	input bt_exit,
	input bt_start,
	inout [7:0] JA,

	output [2:0] red,	//red vga output - 3 bits
	output [2:0] green,//green vga output - 3 bits
	output [1:0] blue,	//blue vga output - 2 bits
	output hsync,		//horizontal sync out
	output vsync	
);

wire dclk;
wire deb_clk;


//////////////////////////////////////////////
/////////Get the useful clock signals/////////
//////////////////////////////////////////////
clockdiv clockdiv (
	.clk 			(clk),
	.dclk 		(dclk),
	.deb_clk  	(deb_clk)
);


//////////////////////////////////////////////
//////Read into the Input from Number Pad/////
//////////////////////////////////////////////
wire [3:0] Col;
wire [3:0] DecodeOut;
wire Enable;

Decoder Decoder (
	.clk			(clk), //100MHz
	.Row 			(JA[7:4]),
	.Col			(JA[3:0]),
	.DecodeOut 	(DecodeOut),
	.Enable 		(Enable)
);

//////////////////////////////////////////////
///////Filter the valid input signals/////////
//////////////////////////////////////////////
wire enable, pause, start;

debouncer debouncer (
	.deb_clk 		(deb_clk),
	.bt_exit			(bt_exit),
	.bt_start		(bt_start),
	.bt_pause		(bt_pause),
	.Enable 			(Enable),
	.enable			(enable),
	.start			(start),
	.pause			(pause),
	.start_pulse (start_pulse)
);

//////////////////////////////////////////////
///Generate the Position of Mole and Figure///
//////////////////////////////////////////////
wire [1:0] figure; // 1: rabbit, 0: mole
wire [3:0] pos_dec;
wire sw_level;

rand_gen rand_gen (
	.clk			(clk),
	.pos_dec		(pos_dec),
	.figure		(figure)
);

wire 	show_menu;
wire [3:0] cur_pos;
wire [19:0] max_easy;
wire [19:0] max_hard;
wire [19:0] out_cur_conv;
wire [1:0] life;
wire [1:0] cur_figure;

play play(
	.clk (clk),
	// Debouncer
	.sw_level (sw_level),
	.start (start),
	.pause (pause),
	.Enable (Enable),
	.start_pulse (start_pulse),
	// Decoder
	.DecodeOut (DecodeOut),
	// rand_gen
	.pos_dec (pos_dec),
	.figure (figure),
	// Output
	.show_menu (show_menu),
	.cur_pos (cur_pos),
	.max_easy (max_easy),
	.max_hard (max_hard),
	.out_cur_conv (out_cur_conv),
 	.life (life),
 	.cur_figure (cur_figure)
);

vga vga(
	  .dclk (dclk),
	  .show_menu (show_menu),
	  .max_easy (max_easy),
	  .max_hard (max_hard),	  
	  .cur_pos (cur_pos),
	  .out_cur_conv (out_cur_conv),
 	  .life (life),

	  .sw_level (sw_level),
      .cur_figure (cur_figure),

	  .hsync (hsync),		
	  .vsync (vsync),		
	  .red (red),
	  .green (green),
	  .blue (blue)
);


endmodule
