`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:50 05/03/2017 
// Design Name: 
// Module Name:    display 
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
module display(
	//input 
	fst_clk, blk_clk, sel, adj, bs, bp,
	//output
	seg0, seg1, seg2, seg3, seg4, seg5, seg6, d0, d1, d2, d3
    );


input fst_clk;
input blk_clk;
input sel, adj, bs, bp;
output seg0, seg1, seg2, seg3, seg4, seg5, seg6, d0, d1, d2, d3;
// Switch: left->sel, right->adj
// Button: left->pause, right->reset
//with the pause signal comes in, what we do is to restore the clock value into the display
//but not simply stop the whole function

//for the implementation of display, notice that all the four digits can only show the same digit at 
//a specific time tick
//2 counters, one for the min, one for the sec
//the display: 0 is on, 1 is off

//if pause, ff, restore original value
//if reset, whole zeros, pause on, stop at the original value; pause off, reset and then increment
//if adj, if sel 

reg [3:0] dig = 4'b1110;
reg [3:0] show = 4'b0000;

reg [3:0] min1 = 4'b0; 
reg [3:0] min0 = 4'b0;
reg [3:0] sec1 = 4'b0; 
reg [3:0] sec0 = 4'b0;
reg p_flag = 0;
wire s_flag;
wire p_f;// flag for pause, 0: no pause, 1: pause
reg [3:0] temp = 4'b0;
reg [6:0] seg = {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};

wire t_bp;
wire t_bs;

reg [1:0] bp_ff = 2'b0;
reg [1:0] bs_ff = 2'b0;

reg adj_c = 0;
reg inc_c = 1;

assign t_bp = bp;
assign t_bs = bs;
assign p_f = bp_ff[0];
assign s_flag = bs_ff[0];

assign d0 = (show[0] | dig[0]);
assign d1 = (show[1] | dig[1]);
assign d2 = (show[2] | dig[2]);
assign d3 = (show[3] | dig[3]);


assign seg0 = seg[0];
assign seg1 = seg[1];
assign seg2 = seg[2];
assign seg3 = seg[3];
assign seg4 = seg[4];
assign seg5 = seg[5];
assign seg6 = seg[6];



always @(posedge blk_clk or posedge t_bp)
   if (t_bp)
       bp_ff <= 2'b11;
   else
       bp_ff <= {1'b0, bp_ff[1]};

always @(posedge blk_clk or posedge t_bs)
   if (t_bs)
       bs_ff <= 2'b11;
   else
       bs_ff <= {1'b0, bs_ff[1]};

always @ (posedge p_f)
begin
		p_flag <= ~p_flag;
end


always @(posedge fst_clk)
begin
	dig[3:0] = {dig[2:0], dig[3]};
	if (!dig[0])
		temp = sec0;	
	else if (!dig[1])
		temp = sec1;
	else if (!dig[2])
		temp = min0;
	else 
		temp = min1;
		
	case (temp)
	4'h0: seg[6:0] = {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	4'h1: seg[6:0] = {1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};
	4'h2: seg[6:0] = {1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};
	4'h3: seg[6:0] = {1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
	4'h4: seg[6:0] = {1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1};
	4'h5: seg[6:0] = {1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0};
	4'h6: seg[6:0] = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
	4'h7: seg[6:0] = {1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0};
	4'h8: seg[6:0] = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
	4'h9: seg[6:0] = {1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
	endcase
	
end

always @(posedge blk_clk)
begin	

	if (adj_c)
		inc_c = ~inc_c;
	adj_c = ~adj_c;
	if (p_flag)
	begin
			show[3:0] = {1'b0, 1'b0, 1'b0, 1'b0};
	end
	else if (s_flag)
	begin
		show[3:0] = {1'b0, 1'b0, 1'b0, 1'b0};
		sec1 = 4'b0;
		sec0 = 4'b0;
		min1 = 4'b0;
		min0 = 4'b0;
	end
	else if (adj)
		begin
			if (sel)
			begin
			show[3:2] = {1'b0, 1'b0};
			show[1] = ~show[1];
			show[0] = ~show[0];
			end
			else
			begin
			show[1:0] = {1'b0, 1'b0};
			show[3] = ~show[3];
			show[2] = ~show[2];
			end
		if (adj_c)
			begin
			if (sel) // adjust sec
			begin
				if (sec0 == 4'b1001)
				begin
					if (sec1 == 4'b101)
					begin
						sec1 = 4'b0;
						sec0 = 4'b0;
					end
					else
					begin
						sec1 = sec1 + 1;
						sec0 = 4'b0;
					end
				end
				else
					sec0 = sec0 + 1;			
			end
			else		// adjust min
			begin
				if (min0 == 4'b1001)
				begin
					if (min1 == 4'b101)
					begin
						min1 = 4'b0;
						min0 = 4'b0;
					end
					else
					begin
						min1 = min1 + 1;
						min0 = 4'b0;
					end
				end
				else
					min0 = min0 + 1;
			end
		end
	end


	else if (adj_c == 0 && inc_c == 1)   // increment
	begin
		show[3:0] = {1'b0, 1'b0, 1'b0, 1'b0};
		
		
		if(sec0 == 4'b1001)
			begin
				if (sec1 == 4'b0101)
				begin
					if (min0 == 4'b1001)
					begin
						if (min1 == 4'b0101)
						begin
							min1 = 4'b0;
							min0 = 4'b0;
							sec1 = 4'b0;
							sec0 = 4'b0;
						end
						else
						begin
							min1 = min1 + 1;
							min0 = 4'b0;
							sec1 = 4'b0;
							sec0 = 4'b0;
						end
					end
					else
					begin
						min0 = min0 + 1;
						sec1 = 4'b0;
						sec0 = 4'b0;
					end
				end
				else
				begin
					sec1 = sec1 + 1;
					sec0 = 4'b0;
				end
			end
		else
		begin
			sec0 = sec0 + 1;
		end
		
	end


	// adjust which part to display



	
end


endmodule


