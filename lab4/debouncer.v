
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:44:12 05/26/2017 
// Design Name: 
// Module Name:    debouncer 
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
module debouncer(
	input deb_clk,
	input bt_exit,
	input bt_start,
	input bt_pause,
	input Enable,
	output start,
	output pause,
	output enable,
	output start_pulse
 );

wire t_p;
wire t_s;
wire t_e;
wire t_en;

assign t_p = bt_pause;
assign t_s = bt_start;
assign t_e = bt_exit;
assign t_en = Enable;


reg [1:0] exit_ff = 2'b0;
reg [1:0] pause_ff = 2'b0;
reg [1:0] start_ff = 2'b0;
reg [1:0] enable_ff = 2'b0;

reg exit_prev = 1'b0;
reg start_prev = 1'b0;
reg pause_prev = 1'b0;
reg enable_prev = 1'b0;

reg t_exit = 1'b0;
reg t_start = 1'b0;
reg t_pause = 1'b0;
reg t_enable = 1'b0;

reg start_flag = 1'b0;
reg pause_flag = 1'b0;
reg start_pulse_t;

assign pause = pause_flag;
assign start = start_flag;
assign enable = t_enable;
assign start_pulse = start_pulse_t;

always @ (posedge deb_clk)
begin
	if (exit_ff[0] && exit_prev == 1'b0)
		start_flag = 1'b0;
	else if (start_ff[0] && start_prev == 1'b0)
		start_flag = 1'b1;	

	if (start_ff[0] && start_prev == 1'b0)
		start_pulse_t = 1'b1;
	else
		start_pulse_t = 1'b0;	

	exit_prev = exit_ff[0];
	start_prev = start_ff[0];	
end


always @ (posedge deb_clk )
begin
	if (enable_ff[0] && enable_prev == 1'b0)
		t_enable <= 1'b1;
	else
		t_enable <= 1'b0;
	enable_prev <= enable_ff[0];
end

always @ (posedge deb_clk or posedge t_en)
begin
	if (t_en)
		enable_ff <= 2'b11;
	else
		enable_ff <= {1'b0, enable_ff[1]};
end


always @ (posedge deb_clk or posedge t_e)
begin
	if (t_e)
		exit_ff <= 2'b11;
	else
		exit_ff <= {1'b0, exit_ff[1]};
end



always @ (posedge deb_clk or posedge t_s) 
begin
	if (t_s)
		start_ff <= 2'b11;
	else
		start_ff <= {1'b0, start_ff[1]};
end



always @ (posedge deb_clk)
begin
	if (pause_ff[0] && pause_prev == 1'b0)
		pause_flag <= ~pause_flag;
	pause_prev <= pause_ff[0];
end

always @ (posedge deb_clk or posedge t_p)
begin
	if (t_p)
		pause_ff <= 2'b11;
	else
		pause_ff <= {1'b0, pause_ff[1]};
end



endmodule
