`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:26:07 04/21/2017 
// Design Name: 
// Module Name:    fpcvt 
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
module FPCVT(
	//input 
	D,
	//output
	E,
	F,
	S
);


    input [11:0] D;
    output S;
    output [2:0] E;
    output [3:0] F;
    
    wire [11:0] mag;
    wire [2:0] exp;
    wire [3:0] sfcand;
    wire       fifthb;
	
	
sgnmag sgnmag_ (
	//inputs
	.D     (D),
	//outputs
	.S     (S),
	.mag    		(mag)
);
               
ldzero ldzero_ (
	//inputs
	.mag  		(mag),
	//outputs
	.exp  		(exp),
	.sfcand  	(sfcand),
	.fifthb 		(fifthb)
);
                  
rounding rounding_ (
	//inputs
	.exp   			(exp), 
	.sfcand   		(sfcand), 
	.fifthb   		(fifthb),
	//outputs
	.E      	(E),
	.F      	(F)
);

endmodule
