`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:08:21 05/01/2017 
// Design Name: 
// Module Name:    clock 
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
module clock(
	//input
	clk, // Master
	//output
	fst_clk, //381Hz, 1000000000000000000  // 256Hz 390625
	blk_clk  //2.98H, 2^25 // 4Hz
    );

input clk; // 100MHz
output fst_clk, blk_clk;

reg t_fst = 1'b0;
reg t_blk = 1'b0;

reg [18:0] fst_cnt = 19'b0;
reg [24:0] blk_cnt = 25'b0;

assign fst_clk = t_fst;
assign blk_clk = t_blk;

always @(posedge clk)
begin
	fst_cnt = fst_cnt + 1'b1;
	blk_cnt = blk_cnt + 1'b1;
	
	if (fst_cnt == 19'd390625) //fast clock divider
        begin
				t_fst = 1;
        end
	else if (fst_cnt == 19'd390626)
			begin
				fst_cnt = 19'b0;
				t_fst = 0;
			end
	if (blk_cnt == 25'd25000000) //fast clock divider
        begin
				t_blk = 1;				
        end
	else if (blk_cnt == 25'd25000001)
			begin
				blk_cnt = 25'b0;
				t_blk = 0;
			end			

end

endmodule
