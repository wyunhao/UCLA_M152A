`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:13:47 06/04/2017 
// Design Name: 
// Module Name:    vga 
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
module vga(
	input wire dclk,			//pixel clock: 25MHz
	input wire[3:0] cur_pos, // position of the figure
   input [19:0] out_cur_conv,
	input [19:0] max_easy,
	input [19:0] max_hard,
	input wire show_menu,
	input wire show_game,
	input wire [1:0] life,

   input sw_level,
   input [1:0] cur_figure,

	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
    
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

integer x = hbp;
integer y = vbp;


reg [3:0] cur_conv [4:0];
reg [3:0] hard [4:0];
reg [3:0] easy [4:0];

integer fig_r;
integer fig_c;

always @(*)
begin
case (cur_pos)
4'b0000: //0
begin
	fig_r = 460;
	fig_c = 140;
end

4'b0001: //1
begin
	fig_r = 460;
	fig_c = 380;
end

4'b0010:  //2
begin
	fig_r = 340;
	fig_c = 380;
end

4'b0011:  //3
begin
	fig_r = 220;
	fig_c = 380;
end

4'b0100:  //4
begin
	fig_r = 460;
	fig_c = 300;
end

4'b0101:  //5
begin
	fig_r = 340;
	fig_c = 300;
end

4'b0110:  //6
begin
	fig_r = 220;
	fig_c = 300;
end

4'b0111:  //7
begin
	fig_r = 460;
	fig_c = 220;
end

4'b1000:  //8
begin
	fig_r = 340;
	fig_c = 220;
end

4'b1001:  //9
begin
	fig_r = 220;
	fig_c = 220;
end

4'b1010:  //A
begin
	fig_r = 100;
	fig_c = 380;
end

4'b1011:  //B
begin
	fig_r = 100;
	fig_c = 300;
end

4'b1100:  //C
begin
	fig_r = 100;
	fig_c = 220;
end

4'b1101:  //D
begin
	fig_r = 100;
	fig_c = 140;
end

4'b1110:  //E
begin
	fig_r = 220;
	fig_c = 140;
end

4'b1111:  //F
begin
	fig_r = 340;
	fig_c = 140;
end
endcase

fig_r = fig_r + hbp;
fig_c = fig_c + vbp;
end

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk)
begin	
		cur_conv[4] = out_cur_conv[3:0];
		cur_conv[3] = out_cur_conv[7:4];
		cur_conv[2] = out_cur_conv[11:8];
		cur_conv[1] = out_cur_conv[15:12];
		cur_conv[0] = out_cur_conv[19:16];
	
		hard[4] = max_hard[3:0];
		hard[3] = max_hard[7:4];
		hard[2] = max_hard[11:8];
		hard[1] = max_hard[15:12];
		hard[0] = max_hard[19:16];

		easy[4] = max_easy[3:0];
		easy[3] = max_easy[7:4];
		easy[2] = max_easy[11:8];
		easy[1] = max_easy[15:12];
		easy[0] = max_easy[19:16];

		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =


always @(*)
begin
	// first check if we're within vertical active video range
	if (show_menu)
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		// display white bar



		// draw game_name
		if (hc >= hbp && hc < (hbp + 640) && vc >= (vbp + 0) && vc < (vbp + 65))
		begin
			red = 000;
			green = 110;
			blue = 01;
            // draw "w"
            if(hc >= hbp && hbp < (hbp + 52))
            begin
                if(hc >= hbp && hc < (hbp + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 39) && hc < (hbp + 52))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= hbp && hc < (hbp + 52) && vc >= (vbp + 39) && vc < (vbp + 52))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 20) && hc < (hbp + 33) && vc >= (vbp + 26) && vc < (vbp + 39))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
            end
            // draw "H"
            if(hc >= (hbp + 60) && hc < (hbp + 112))
            begin
                if(hc >= (hbp + 60 ) && hc < (hbp + 60 + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 60 + 39) && hc < (hbp + 60 + 52))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 60) && hc < (hbp + 60 + 52) && vc >= (vbp + 26) && vc < (vbp + 39))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
            end
            // draw "A"
            if(hc >= (hbp + 120) && hc < (hbp + 172))
            begin
                if(hc >= (hbp + 120 + 18) && hc < (hbp+ 120+ 31) && vc >= (vbp) && vc < (vbp + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp + 120+ 6) && hc < (hbp + 120+ 20) && vc >= (vbp + 13) && vc < (vbp + 26 ))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp + 120+ 31) && hc < (hbp+ 120+ 46) && vc >= (vbp + 13) && vc < (vbp + 26))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp+ 120) && hc < (hbp + 120+ 13) && vc >= (vbp + 26) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp + 120+ 39) && hc < (hbp+ 120 + 52) && vc >= (vbp + 26) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;  
                end
                else if(hc >= (hbp + 120) && hc < (hbp+ 120+ 52) && vc >= (vbp + 39) && vc < (vbp + 52))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;  
                end
            end
            // draw "C"
            if(hc >= (hbp + 180) && hc < (hbp + 232))
            begin
                if(hc >= (hbp + 180 + 13) && hc < (hbp + 180 + 52) && vc >= (vbp) && vc < (vbp + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 180 + 13) && hc < (hbp + 180 + 52) && vc >= (vbp + 52) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 180) && hc < (hbp + 180 + 13) && vc >= (vbp) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
            end
            // draw "K"
            if(hc >= (hbp + 240) && hc < (hbp + 292))
            begin
                if(hc >= (hbp + 240) && hc < (hbp + 240 + 13) && vc >= (vbp) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end

                if(hc >= (hbp + 240 + 13) && hc < (hbp + 240 + 26) && vc >= (vbp + 26) && vc < (vbp + 39))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 240 + 26) && hc < (hbp + 240 + 39) && vc >= (vbp + 13) && vc < (vbp + 26))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 240 + 26) && hc < (hbp + 240 + 39) && vc >= (vbp + 39) && vc < (vbp +65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 240 + 39) && hc < (hbp + 240 + 52) && vc >= (vbp + 0) && vc < (vbp + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 240 + 39) && hc < (hbp + 240 + 52) && vc >= (vbp + 52) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
            end
            // draw "   "
            if(hc >= (hbp + 292) && hc < (hbp + 300))
            begin
            end
            // draw "A"
            if(hc >= (hbp +50 + 250) && hc < (hbp +50 + 250 + 52))
            begin
                if(hc >= (hbp +50 + 250 + 18) && hc < (hbp +50+ 250+ 31) && vc >= (vbp) && vc < (vbp + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp +50 + 250+ 6) && hc < (hbp +50 + 250+ 20) && vc >= (vbp + 13) && vc < (vbp + 26 ))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp +50 + 250+ 31) && hc < (hbp +50+ 250+ 46) && vc >= (vbp + 13) && vc < (vbp + 26))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp +50+ 250) && hc < (hbp + 250 +50+ 13) && vc >= (vbp + 26) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
                else if(hc >= (hbp + 250 +50+ 39) && hc < (hbp+ 250 +50 + 52) && vc >= (vbp + 26) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;  
                end
                else if(hc >= (hbp+50 + 250) && hc < (hbp+50+ 250+ 52) && vc >= (vbp + 39) && vc < (vbp + 52))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;  
                end
            end

            // draw " "
            if(hc >= (hbp+50 + 310) && hc < (hbp+50 + 320))
            begin
            end


            // draw "M"
            if(hc >= (hbp+50 + 10 + 310) && hbp < (hbp+50 + 310 + 52))
            begin
                if(hc >= (hbp+50 + 10  + 310) && hc < (hbp +50+ 10  + 310 + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp +50+ 10  + 310 + 39) && hc < (hbp+50 + 10  + 310 + 52))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp+50 + 10  + 310) && hc < (hbp+50 + 10  + 310 + 52) && vc >= (vbp + 13) && vc < (vbp + 26))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp+50 + 10  + 310 + 20) && hc < (hbp+50 + 310 + 10  + 33) && vc >= (vbp + 26) && vc < (vbp + 39))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end

            end

            // draw "O"
            if(hc >= (hbp+50 + 10  + 370) && hbp < (hbp+50 + 10  + 370 + 52))
            begin
                if(hc >= (hbp+50 + 10  + 370) && hc< (hbp+50 + 10  + 370 + 52) && vc >= (vbp) && vc < (vbp + 13))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp+50 + 10  + 370) && hc < (hbp+50 + 10  + 370 + 52) && vc >= (vbp + 52) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp+50 + 10  + 370) && hc < (hbp+50 + 10  + 370 + 13) && vc >= (vbp) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp+50 + 10  + 370 + 39 ) && hc < (hbp+50 + 10  + 370 + 52) && vc >= (vbp) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
            end
            // draw "L"
            if(hc >= (hbp+50 + 10  + 430) && hbp < (hbp+50 + 10  + 430 + 52))
            begin
                if(hc >= (hbp + 50 + 10  + 430 + 13) && hc < (hbp+50 + 10  + 430 + 52)&& vc >= (vbp + 52) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
                if(hc >= (hbp + 50 + 10  + 430 ) && hc < (hbp+50 + 10  + 430 + 13)&& vc >= (vbp) && vc < (vbp + 65))
                begin
                    red = 111;
                    green = 111;
                    blue = 11;
                end
            end
            // draw "E"
			if(hc >= (hbp + 20 + 530) && hc < (hbp + 20 + 52+ 530))
            begin
            	if(hc >= (hbp + 20 + 530) && hc < (hbp + 20 + 52 + 530) && vc >= (vbp) && vc < (vbp  + 13))
            	begin
                    red = 111;
                    green = 111;
                    blue = 11; 
            	end
            	if(hc >= (hbp + 20+ 530) && hc < (hbp + 20 +39 + 530) && vc >= (vbp  + 26) && vc < (vbp  + 39))
            		begin
                    red = 111;
                    green = 111;
                    blue = 11;
            	end
            	if(hc >= (hbp + 20+ 530) && hc < (hbp + 20 + 52 + 530) && vc >= (vbp  + 52) && vc < (vbp  + 65))
            		begin
                    red = 111;
                    green = 111;
                    blue = 11; 
            	end
            	if(hc >= (hbp + 20+ 530) && hc < (hbp +  20 + 520 + 20)&& vc >= (vbp ) && vc < (vbp  + 65))
            		begin
                    red = 111;
                    green = 111;
                    blue = 11; 
                end
            end
		end

        
		else if (hc >= (hbp) && hc < (hbp + 640) && vc >= (vbp + 200) && vc < (vbp + 265))  
		begin 
		    if(hc >= hbp && hc < (hbp + 20))
			begin
               red = 0;
               green = 0;
               blue = 0; 
			end
			// easy mode
            if(hc >= (hbp + 20) && hc < (hbp + 350))
            begin
                if(hc >= (hbp + 20) && hc < (hbp + 320))
                begin
            		// draw "E"
            		if(hc >= (hbp + 20) && hc < (hbp + 20 + 52))
            		begin
                        	red = 0;
                        	green = 0;
                       		blue =0;
            			if(hc >= (hbp + 20) && hc < (hbp + 20 + 52) && vc >= (vbp+ 200) && vc < (vbp + 200 + 13))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			if(hc >= (hbp + 20) && hc < (hbp + 20 + 39) && vc >= (vbp + 200 + 26) && vc < (vbp + 200 + 39))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01;
            			end
            			if(hc >= (hbp + 20) && hc < (hbp + 20 + 52) && vc >= (vbp + 200 + 52) && vc < (vbp + 200 + 65))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			if(hc >= (hbp + 20) && hc < (hbp + 20 + 13))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
                     end
            		end
            		// draw "A"
            		else if (hc >= (hbp + 60 + 20) && hc < (hbp + 112 + 20))
            		begin
            			if(hc > (hbp + 60 + 20 + 18) && hc < (hbp + 20 + 60 + 31) && vc >= (vbp + 200) && vc < (vbp + 13 + 200))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			else if(hc > (hbp + 20 + 60 + 6) && hc < (hbp + 20 + 60 + 20) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			else if(hc > (hbp + 20 + 60 + 31) && hc < (hbp + 20 + 60 + 46) && vc >= (vbp + 13+ 200) && vc < (vbp + 26+ 200))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			else if(hc > (hbp + 20 + 60) && hc < (hbp + 20 + 60 + 13) && vc >= (vbp + 26 + 200) && vc < (vbp + 65 + 200))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
                       	end
            			else if(hc > (hbp + 20 + 60 + 39) && hc < (hbp + 20 + 60 + 52) && vc >= (vbp + 26+ 200) && vc < (vbp + 65 + 200))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
                       	end
                       	else if(hc > (hbp + 20 + 60) && hc < (hbp + 20 + 60 + 52) && vc >= (vbp + 39 + 200) && vc < (vbp + 52+ 200))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
                       	end
                       	else             			
                       	begin
                        	red = 0;
                        	green = 0;
                       		blue = 0; 
                       	end
            		end
            		// draw "S"
            		else if (hc >= (hbp + 20 + 120) && hc < (hbp + 20 + 172))
            		begin
            			if(hc >= (hbp + 20 + 120) && hc < (hbp + 20 + 172) && vc >= (vbp + 200) && vc < (vbp + 200 + 13))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			else if(hc >= (hbp + 20 + 120) && hc < (hbp + 20 + 120 + 13) && vc >= (vbp + 200 + 13) && vc < (vbp + 200 + 26))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01;
            			end
            			else if(hc >= (hbp + 20 + 120 ) && hc < (hbp+ 20 + 172) && vc >= (vbp + 200 + 26) && vc < (vbp + 200 + 39))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			else if(hc >= (hbp + 20 + 120 + 39) && hc < (hbp + 20 + 120 + 52) && vc >= (vbp + 200 + 26) && vc < (vbp + 200 + 52))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01;
            			end
            			else if(hc >= (hbp + 20 + 120 ) && hc < (hbp + 20 + 172) && vc >= (vbp + 200 + 52) && vc < (vbp + 200 + 65))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
                        else 
                        begin
                            red = 0;
                            green = 0;
                            blue = 0;
                        end
            		end
            		// draw "Y"
            		else if (hc >= (hbp + 20 + 180) && hc < (hbp + 20 + 180 + 52))
            		begin
            			if(hc >= (hbp + 20 + 180) && hc < (hbp + 20 + 180 + 13) && vc >= (vbp  + 200 ) && vc < (vbp + 200  + 13))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			
            			else if(hc >= (hbp+ 20  + 180 + 39) && hc < (hbp+ 20 + 180 + 52) && vc >= (vbp + 200 ) && vc < (vbp  + 200 + 13))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end

            			else if(hc >= (hbp+ 20  + 180 + 7) && hc < (hbp + 20 + 180 + 20) && vc >= (vbp  + 200 + 13) && vc < (vbp  + 200 + 26))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end

            			else if(hc >= (hbp+ 20  + 180 + 33) && hc < (hbp+ 20  + 180 + 46) && vc >= (vbp  + 200 + 13) && vc < (vbp  + 200 + 26))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			else if(hc >= (hbp+ 20  + 180 + 20) && hc < (hbp+ 20  + 180 + 33) && vc >= (vbp  + 200 + 26) && vc < (vbp+ 200 + 65))
            			begin
                        	red = 100;
                        	green = 111;
                       		blue = 01; 
            			end
            			else 
            			begin
                        	red = 0;
                        	green = 0;
                       		blue = 0; 
            			end
            		end
                    else 
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end
                else 
                begin
                    red = 0;
                    green = 0;
                    blue = 0;
                end
            end
            // draw score
            else if(hc >= (hbp + 350) && hc < (hbp + 640))
            begin
                 // draw digit[0]
                if(hc >= (hbp + 350) && hc < (hbp + 350 + 39))
                begin
                    if(easy[0] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 53 + 200))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                    else if (easy[0] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 350 + 26) && hc < (hbp + 350 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                            red = 100;
                            green = 111;
                            blue = 01; 
                        end
                        else if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                        begin
                            red = 100;
                            green = 111;
                            blue = 01; 
                        end
                        else
                        begin
                            red = 0;
                            green = 0;
                            blue = 0;
                        end
                    end
                    else if (easy[0] == 4'b0010) // if the digit is 2
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                           red = 100;
                           green = 111;
                           blue = 01; 
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 39) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       else 
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end
                    else if (easy[0] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc>= (vbp + 200) && vc< (vbp + 65 + 200))
                       begin
                          red = 100;
                          green = 111;
                          blue = 01; 
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc>= (vbp + 13 + 200) && vc< (vbp + 52 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) &&vc >= (vbp + 26 + 200) && vc< (vbp + 39 + 200))
                       begin
                          red = 100;
                          green = 111;
                          blue = 01; 
                       end 
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                        end
                    end
                    else if (easy[0] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                          red = 100;
                          green = 111;
                          blue = 01; 
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >=(vbp + 200) && vc < (vbp + 26 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 65 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end

                    else if (easy[0] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                          red = 100;
                          green = 111;
                          blue = 01; 
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 39) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       else 
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end
                    else if (easy[0] == 4'b0110) // if the digit is 6
                    begin
                          
                            red = 0;
                            green = 0;
                            blue = 0;
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) &&vc >= (vbp + 200) &&vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 39) && vc>= (vbp + 13 + 200) && vc< (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc>= (vbp + 39 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                    else if (easy[0] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else if (easy[0] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                        end
                    end
                    else if (easy[0] == 4'b1001) // if the digit is 9
                        begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 200 ) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                    blue = 0;
                    end
                end 
                // draw digit[1]
                else if(hc >= (hbp + 400) && hc < (hbp + 400 + 39))
                begin
                    if(easy[1] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 53 + 200))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (easy[1] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 400 + 26) && hc < (hbp + 400 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (easy[1] == 4'b0010) // if the digit is 2
                    begin
                        if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                        if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 39) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end
                
                    else if (easy[1] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc>= (vbp + 200) && vc< (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc>= (vbp + 13 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) &&vc >= (vbp + 26 + 200) && vc< (vbp + 39 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end 
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end

                    else if (easy[1] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >=(vbp + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;

                       end
                    end

                    else if (easy[1] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 39) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       else 
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end

                    else if (easy[1] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) &&vc >= (vbp + 200) &&vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 39) && vc>= (vbp + 13 + 200) && vc< (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc>= (vbp + 39 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[1] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[1] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[1] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 200 ) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end
                // draw digit[2]
                else if(hc >= (hbp + 450) && hc < (hbp + 450 + 39))
                begin
                    if(easy[2] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 53 + 200))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (easy[2] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 450 + 26) && hc < (hbp + 450 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (easy[2] == 4'b0010) // if the digit is 2
                    begin
                      if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 39) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                
                    else if (easy[2] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc>= (vbp + 200) && vc< (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc>= (vbp + 13 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) &&vc >= (vbp + 26 + 200) && vc< (vbp + 39 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end 
                    end

                    else if (easy[2] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >=(vbp + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[2] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 39) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                    end

                    else if (easy[2] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) &&vc >= (vbp + 200) &&vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 39) && vc>= (vbp + 13 + 200) && vc< (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc>= (vbp + 39 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[2] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[2] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[2] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 200 ) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else 
                    begin 
                        red = 100;
                        green = 111;
                        blue = 01;
                    end
                end
                // draw digit[3]
                else if(hc >= (hbp + 500) && hc < (hbp + 500 + 39))
                begin
                    if(easy[3] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 53 + 200))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (easy[3] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 500 + 26) && hc < (hbp + 500 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (easy[3] == 4'b0010) // if the digit is 2
                    begin
                      if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 39) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                
                    else if (easy[3] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc>= (vbp + 200) && vc< (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc>= (vbp + 13 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) &&vc >= (vbp + 26 + 200) && vc< (vbp + 39 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end 
                    end

                    else if (easy[3] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >=(vbp + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[3] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 39) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[3] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) &&vc >= (vbp + 200) &&vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 39) && vc>= (vbp + 13 + 200) && vc< (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc>= (vbp + 39 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[3] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[3] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[3] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 200 ) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                end
             // draw digit[4]
                else if(hc >= (hbp + 550) && hc < (hbp + 550 + 39))
                begin
                    if(easy[4] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 53 + 200))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (easy[4] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 550 + 26) && hc < (hbp + 550 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                        begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (easy[4] == 4'b0010) // if the digit is 2
                    begin
                    if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 39) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                
                    else if (easy[4] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc>= (vbp + 200) && vc< (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc>= (vbp + 13 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) &&vc >= (vbp + 26 + 200) && vc< (vbp + 39 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end 
                    end

                    else if (easy[4] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >=(vbp + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[4] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 39) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[4] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) &&vc >= (vbp + 200) &&vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 39) && vc>= (vbp + 13 + 200) && vc< (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc>= (vbp + 39 + 200) && vc< (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (easy[4] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 65 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[4] == 4'b1000) // if the digit is 8
                        begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 200) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (easy[4] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 200)  && vc < (vbp + 65 + 200))
                       begin
                        red = 100;
                        green = 111;
                        blue = 01; 
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 200) && vc < (vbp + 26 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 200 ) && vc < (vbp + 52 + 200))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else 
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end
                else 
                begin
                    red = 0;
                    green = 0;
                    blue = 0;
                end 
            end
            else 
            begin
                red = 100;
                green = 111;
                blue = 01;
            end
        end
    
           
        else if (hc >= (hbp) && hc < (hbp + 640) && vc >= (vbp + 300) && vc < (vbp + 365))
        begin
            // HARD MODE
            if(hc >= (hbp + 20) && hc < (hbp + 320) && vc >= (vbp + 300) && vc < (vbp + 365))
            begin
                    red = 0;
                    green = 0;
                    blue = 0; 
                    // draw "H"
                    if(hc >= (hbp + 20) && hc < (hbp + 72))
                    begin
                        if(hc >= (hbp + 20) && hc < (hbp + 20 + 13) && vc >= (vbp+ 300) && vc < (vbp+ 300 + 65))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                        end
                        else if(hc >= (hbp +20  + 39) && hc < (hbp + 20 + 52) && vc >= (vbp+ 300) && vc < (vbp+ 300 + 65))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(vc >= (vbp + 300+ 26) && vc < (vbp+ 300 + 39))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end 
                        else 
                        begin
                            red = 0;
                            green = 0;
                            blue = 0; 
                        end
                    end
                    // draw "A"
                    if (hc >= (hbp + 80) && hc < (hbp + 80 + 52))
                    begin
                        if(hc > (hbp + 80 + 18) && hc < (hbp + 80 + 31) && vc >= (vbp+ 300) && vc < (vbp+ 300 + 13))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc > (hbp + 80 + 6) && hc < (hbp + 80 + 20) && vc >= (vbp+ 300 + 13) && vc < (vbp+ 300 + 26))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc > (hbp + 80 + 31) && hc < (hbp + 80 + 46) && vc >= (vbp+ 300 + 13) && vc < (vbp+ 300 + 26))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc > (hbp + 80) && hc < (hbp + 80 + 13) && vc >= (vbp+ 300 + 26) && vc < (vbp+ 300 + 65))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                        end
                        else if(hc > (hbp + 80 + 39) && hc < (hbp + 80 + 52) && vc >= (vbp+ 300 + 26) && vc < (vbp+ 300 + 65))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc > (hbp + 80) && hc < (hbp + 80 + 52) && vc >= (vbp+ 300 + 39) && vc < (vbp+ 300 + 52))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                        end
                        else                        
                        begin
                            red = 0;
                            green = 0;
                            blue = 0; 
                        end
                    end
                    // draw "R"
                    if (hc >= (hbp + 140) && hc < (hbp + 192))
                    begin
                        if(hc >= (hbp + 140) && hc < (hbp + 140 + 39) && vc >= (vbp+ 300) && vc < (vbp + 300+ 13))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 140) && hc < (hbp + 140 + 13) && vc >= (vbp+ 300) && vc < (vbp + 300+ 65))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 140 + 33) && hc < (hbp + 140 + 46) && vc >= (vbp+ 300 + 13) && vc < (vbp+ 300 + 26))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                        end
                        if(hc >= (hbp + 140) && hc < (hbp + 140 + 39) && vc >= (vbp+ 300 + 26) && vc < (vbp+ 300 + 39))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 140 + 26) && hc < (hbp + 140 + 39) && vc >= (vbp + 300+ 39) && vc < (vbp+ 300 + 52))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 140 + 39) && hc < (hbp + 140 + 52) && vc >= (vbp+ 300 + 52) && vc < (vbp+ 300 + 65))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                    end

                    // draw "D"
                    if (hc >= (hbp + 200) && hc < (hbp + 252))
                    begin
                        red = 000;
                        green = 100;
                        blue = 01;
                        if(hc >= (hbp + 200 + 13) && hc < (hbp + 200 + 39) && vc >= (vbp+ 300 + 13) && vc < (vbp+ 300 + 52))
                        begin
                            red = 0;
                            green = 0;
                            blue = 0; 
                        end
                        
                        if(hc >= (hbp + 200 + 39) && hc < (hbp + 200 + 52) && vc >= (vbp + 300+ 52) && vc < (vbp+ 300 + 65))
                        begin
                            red = 0;
                            green = 0;
                            blue = 0;  
                        end
                        
                        if(hc >= (hbp + 200 + 39) && hc < (hbp + 200 + 52) && vc >= (vbp+ 300 ) && vc < (vbp+ 300 + 13))
                        begin
                            red = 0;
                            green = 0;
                            blue = 0;  
                        end
                    end
            end

            // draw score
            else if(hc >= (hbp + 350) && hc < (hbp + 640))
            begin
                 // draw digit[0]
                if(hc >= (hbp + 350) && hc < (hbp + 350 + 39))
                begin
                    if(hard[0] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 53 + 300))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                    else if (hard[0] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 350 + 26) && hc < (hbp + 350 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else
                        begin
                            red = 0;
                            green = 0;
                            blue = 0;
                        end
                    end
                    else if (hard[0] == 4'b0010) // if the digit is 2
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 39) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       else 
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end
                    else if (hard[0] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc>= (vbp + 300) && vc< (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc>= (vbp + 13 + 300) && vc< (vbp + 52 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) &&vc >= (vbp + 26 + 300) && vc< (vbp + 39 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end 
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                        end
                    end
                    else if (hard[0] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >=(vbp + 300) && vc < (vbp + 26 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 65 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end

                    else if (hard[0] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 39) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                       else 
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end
                    else if (hard[0] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) &&vc >= (vbp + 300) &&vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 39) && vc>= (vbp + 13 + 300) && vc< (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc>= (vbp + 39 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                    else if (hard[0] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else if (hard[0] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else if (hard[0] == 4'b1001) // if the digit is 9
                        begin
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 350 + 13) && hc < (hbp + 350 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 350) && hc < (hbp + 350 + 26) && vc >= (vbp + 39 + 300 ) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                    blue = 0;
                    end
                end 
                // draw digit[1]
                else if(hc >= (hbp + 400) && hc < (hbp + 400 + 39))
                begin
                    if(hard[1] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 53 + 300))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (hard[1] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 400 + 26) && hc < (hbp + 400 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (hard[1] == 4'b0010) // if the digit is 2
                    begin
                        if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                        if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 39) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end
                
                    else if (hard[1] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc>= (vbp + 300) && vc< (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc>= (vbp + 13 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) &&vc >= (vbp + 26 + 300) && vc< (vbp + 39 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end 
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end

                    else if (hard[1] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >=(vbp + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       else
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;

                       end
                    end

                    else if (hard[1] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 39) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       else 
                       begin
                            red = 0;
                            green = 0;
                            blue = 0;
                       end
                    end

                    else if (hard[1] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) &&vc >= (vbp + 300) &&vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 39) && vc>= (vbp + 13 + 300) && vc< (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc>= (vbp + 39 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[1] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[1] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[1] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 400 + 13) && hc < (hbp + 400 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 400) && hc < (hbp + 400 + 26) && vc >= (vbp + 39 + 300 ) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                end
                // draw digit[2]
                else if(hc >= (hbp + 450) && hc < (hbp + 450 + 39))
                begin
                    if(hard[2] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 53 + 300))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (hard[2] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 450 + 26) && hc < (hbp + 450 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (hard[2] == 4'b0010) // if the digit is 2
                    begin
                      if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 39) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                
                    else if (hard[2] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc>= (vbp + 300) && vc< (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc>= (vbp + 13 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) &&vc >= (vbp + 26 + 300) && vc< (vbp + 39 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end 
                    end

                    else if (hard[2] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >=(vbp + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[2] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 39) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                          red = 0;
                          green = 0;
                          blue = 0;
                       end
                    end

                    else if (hard[2] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) &&vc >= (vbp + 300) &&vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 39) && vc>= (vbp + 13 + 300) && vc< (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc>= (vbp + 39 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[2] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[2] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[2] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 450 + 13) && hc < (hbp + 450 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 450) && hc < (hbp + 450 + 26) && vc >= (vbp + 39 + 300 ) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else 
                    begin 
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                end
                // draw digit[3]
                else if(hc >= (hbp + 500) && hc < (hbp + 500 + 39))
                begin
                    if(hard[3] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 53 + 300))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (hard[3] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 500 + 26) && hc < (hbp + 500 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (hard[3] == 4'b0010) // if the digit is 2
                    begin
                      if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 39) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                
                    else if (hard[3] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc>= (vbp + 300) && vc< (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc>= (vbp + 13 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) &&vc >= (vbp + 26 + 300) && vc< (vbp + 39 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end 
                    end

                    else if (hard[3] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >=(vbp + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[3] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 39) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[3] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) &&vc >= (vbp + 300) &&vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 39) && vc>= (vbp + 13 + 300) && vc< (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc>= (vbp + 39 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[3] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[3] == 4'b1000) // if the digit is 8
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[3] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 500 + 13) && hc < (hbp + 500 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 500) && hc < (hbp + 500 + 26) && vc >= (vbp + 39 + 300 ) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                end
             // draw digit[4]
                else if(hc >= (hbp + 550) && hc < (hbp + 550 + 39))
                begin
                    if(hard[4] == 4'b0000) // if the digit is 0
                    begin
                        if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 53 + 300))
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end 
                    end
                
                    else if (hard[4] == 4'b0001) // if the digit is 1
                    begin
                        if(hc >= (hbp + 550 + 26) && hc < (hbp + 550 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01;
                        end
                        else
                        begin
                        red = 0;
                        green = 0;
                        blue = 0;
                        end
                    end

                    else if (hard[4] == 4'b0010) // if the digit is 2
                    begin
                    if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 39) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end
                
                    else if (hard[4] == 4'b0011) // if the digit is 3
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc>= (vbp + 300) && vc< (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc>= (vbp + 13 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) &&vc >= (vbp + 26 + 300) && vc< (vbp + 39 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end 
                    end

                    else if (hard[4] == 4'b0100) // if the digit is 4
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >=(vbp + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[4] == 4'b0101) // if the digit is 5
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 39) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[4] == 4'b0110) // if the digit is 6
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) &&vc >= (vbp + 300) &&vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 39) && vc>= (vbp + 13 + 300) && vc< (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc>= (vbp + 39 + 300) && vc< (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                    end

                    else if (hard[4] == 4'b0111) // if the digit is 7
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 300) && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 65 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[4] == 4'b1000) // if the digit is 8
                        begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 300) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end

                    else if (hard[4] == 4'b1001) // if the digit is 9
                    begin
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 39) && vc >= (vbp + 300)  && vc < (vbp + 65 + 300))
                       begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       end
                       if(hc >= (hbp + 550 + 13) && hc < (hbp + 550 + 26) && vc >= (vbp + 13 + 300) && vc < (vbp + 26 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end
                       if(hc >= (hbp + 550) && hc < (hbp + 550 + 26) && vc >= (vbp + 39 + 300 ) && vc < (vbp + 52 + 300))
                       begin
                        red = 0;
                        green = 0;
                        blue = 0;
                       end 
                    end
                    else 
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end
                else 
                begin
                    red = 0;
                    green = 0;
                    blue = 0;
                end 
            end


            else 
            begin
                red = 0;
                green = 0;
                blue = 0; 
            end
        end

		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
end


// show_game



	else 
	begin
	if (vc >= vbp && vc < vfp) 
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		// display white bar
		// draw score
		if (hc >= (hbp) && hc < (hbp + 640) && vc >= (vbp ) && vc < (vbp + 65))
		begin
			red = 0;
			green = 0;
			blue = 0; 
			// draw digit[0]
            if(hc >= hbp && hc < (hbp + 39))
            begin
                if(cur_conv[0] == 4'b0000) // if the digit is 0
                begin
                    if(hc >= (hbp) && hc < (hbp + 39) && vc >= (vbp) && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                    end
                    if(hc >= (hbp + 13) && hc < (hbp + 26) && vc >= (vbp + 13) && vc < (vbp + 53))
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end 
                end
                
                else if (cur_conv[0] == 4'b0001) // if the digit is 1
                begin
                    if(hc >= (hbp + 26) && hc < (hbp + 39) && vc >= vbp && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else if(hc >= (hbp + 13) && hc < (hbp + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end

                else if (cur_conv[0] == 4'b0010) // if the digit is 2
                begin
                 	if(hc >= hbp && hc < (hbp + 39) && vc >= (vbp) && vc < (vbp + 130))
						begin
                            red = 000;
                            green = 100;
                            blue = 01;
						end
					if(hc >= hbp && hc < (hbp + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
						begin
							red = 0;
							green = 0;
							blue = 0;
						end
					if(hc >= (hbp + 13) && hc < (hbp + 39) && vc >= (vbp + 39) && vc < (vbp + 52))
						begin
							red = 0;
							green = 0;
							blue = 0;
						end
				end
                
                else if (cur_conv[0] == 4'b0011) // if the digit is 3
                begin
					 if(hc >= hbp && hc < (hbp + 39) && vc>= (vbp) && vc< (vbp + 65 ))
					 begin
                            red = 000;
                            green = 100;
                            blue = 01;
					 end
					 if(hc >= hbp && hc < (hbp + 26) && vc>= (vbp + 13) && vc< (vbp + 52 ))
					 begin
						red = 0;
						green = 0;
						blue = 0;
					 end
					 if(hc >= (hbp + 13) && hc < (hbp + 26) &&vc >= (vbp + 26) && vc< (vbp + 39))
					 begin
                            red = 000;
                            green = 100;
                            blue = 01;
					 end 
                end

                else if (cur_conv[0] == 4'b0100) // if the digit is 4
                begin
					if(hc >= (hbp) && hc < (hbp + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 13) && hc < (hbp + 26) && vc >=(vbp) && vc < (vbp +26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= hbp && hc < (hbp + 26) && vc >= (vbp + 39) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[0] == 4'b0101) // if the digit is 5
                begin
					if(hc >= hbp && hc < (hbp + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 13) && hc < (hbp + 39) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= hbp && hc < (hbp + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[0] == 4'b0110) // if the digit is 6
                begin
					if(hc >= hbp && hc < (hbp + 39) &&vc >= (vbp) &&vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 13) && hc < (hbp + 39) && vc>= (vbp + 13) && vc< (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 13) && hc < (hbp + 26) && vc>= (vbp + 39) && vc< (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[0] == 4'b0111) // if the digit is 7
                begin
					if(hc >= (hbp + 0) && hc < (hbp + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp +0) && hc < (hbp + 26) && vc >= (vbp + 13) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[0] == 4'b1000) // if the digit is 8
                begin
					if(hc >= (hbp) && hc < (hbp + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 13) && hc < (hbp + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 13) && hc < (hbp + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[0] == 4'b1001) // if the digit is 9
                begin
					if(hc >= (hbp) && hc < (hbp + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 13) && hc < (hbp + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp) && hc < (hbp + 26) && vc >= (vbp + 39 ) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end
            end
            // draw digit[1]
            if(hc >= (hbp + 45) && hc < (hbp + 45 + 39))
            begin
                if(cur_conv[1] == 4'b0000) // if the digit is 0
                begin
                    if(hc >= (hbp + 45) && hc < (hbp  + 45 + 39) && vc >= (vbp) && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                    end
                    if(hc >= (hbp + 45 + 13) && hc < (hbp  + 45 + 26) && vc >= (vbp + 13) && vc < (vbp + 53))
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end 
                end
                
                else if (cur_conv[1] == 4'b0001) // if the digit is 1
                begin
                    if(hc >= (hbp + 45 + 26) && hc < (hbp + 45 + 39) && vc >= vbp && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end

                else if (cur_conv[1] == 4'b0010) // if the digit is 2
                begin
                 	if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) && vc >= (vbp) && vc < (vbp + 130))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 39) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end
                
                else if (cur_conv[1] == 4'b0011) // if the digit is 3
                begin
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) && vc>= (vbp) && vc< (vbp + 65 ))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 26) && vc>= (vbp + 13) && vc< (vbp + 52 ))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 26) &&vc >= (vbp + 26) && vc< (vbp + 39))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end 
                end

                else if (cur_conv[1] == 4'b0100) // if the digit is 4
                begin
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 26) && vc >=(vbp) && vc < (vbp +26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 26) && vc >= (vbp + 39) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[1] == 4'b0101) // if the digit is 5
                begin
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 39) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[1] == 4'b0110) // if the digit is 6
                begin
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) &&vc >= (vbp) &&vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 39) && vc>= (vbp + 13) && vc< (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 26) && vc>= (vbp + 39) && vc< (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[1] == 4'b0111) // if the digit is 7
                begin
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 26) && vc >= (vbp + 13) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[1] == 4'b1000) // if the digit is 8
                begin
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[1] == 4'b1001) // if the digit is 9
                begin
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 45 + 13) && hc < (hbp + 45 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 45) && hc < (hbp + 45 + 26) && vc >= (vbp + 39 ) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end
            end

            // draw digit[2]
            if(hc >= (hbp + 89) && hc < (hbp + 89 + 39))
            begin
                if(cur_conv[2] == 4'b0000) // if the digit is 0
                begin
                    if(hc >= (hbp + 89) && hc < (hbp  + 89 + 39) && vc >= (vbp) && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    if(hc >= (hbp + 89 + 13) && hc < (hbp  + 89 + 26) && vc >= (vbp + 13) && vc < (vbp + 53))
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end 
                end
                
                else if (cur_conv[2] == 4'b0001) // if the digit is 1
                begin
                    if(hc >= (hbp + 89 + 26) && hc < (hbp + 89 + 39) && vc >= vbp && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                    end
                    else if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end

                else if (cur_conv[2] == 4'b0010) // if the digit is 2
                begin
                 	if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) && vc >= (vbp) && vc < (vbp + 130))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 39) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end
                
                else if (cur_conv[2] == 4'b0011) // if the digit is 3
                begin
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) && vc>= (vbp) && vc< (vbp + 65 ))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 26) && vc>= (vbp + 13) && vc< (vbp + 52 ))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 26) &&vc >= (vbp + 26) && vc< (vbp + 39))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end 
                end

                else if (cur_conv[2] == 4'b0100) // if the digit is 4
                begin
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 26) && vc >=(vbp) && vc < (vbp +26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 26) && vc >= (vbp + 39) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[2] == 4'b0101) // if the digit is 5
                begin
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 39) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[2] == 4'b0110) // if the digit is 6
                begin
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) &&vc >= (vbp) &&vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 39) && vc>= (vbp + 13) && vc< (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 26) && vc>= (vbp + 39) && vc< (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[2] == 4'b0111) // if the digit is 7
                begin
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 26) && vc >= (vbp + 13) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[2] == 4'b1000) // if the digit is 8
                begin
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[2] == 4'b1001) // if the digit is 9
                begin
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 89 + 13) && hc < (hbp + 89 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 89) && hc < (hbp + 89 + 26) && vc >= (vbp + 39 ) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end
            end

            // draw digit[3]
            if(hc >= (hbp + 133) && hc < (hbp + 133 + 39))
            begin
                if(cur_conv[3] == 4'b0000) // if the digit is 0
                begin
                    if(hc >= (hbp + 133) && hc < (hbp  + 133 + 39) && vc >= (vbp) && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) && vc >= (vbp + 13) && vc < (vbp + 53))
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end 
                end
                
                else if (cur_conv[3] == 4'b0001) // if the digit is 1
                begin
                    if(hc >= (hbp + 133 + 26) && hc < (hbp + 133 + 39) && vc >= vbp && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end

                else if (cur_conv[3] == 4'b0010) // if the digit is 2
                begin
                 	if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) && vc >= (vbp) && vc < (vbp + 130))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 39) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end
                
                else if (cur_conv[3] == 4'b0011) // if the digit is 3
                begin
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) && vc>= (vbp) && vc< (vbp + 65 ))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 26) && vc>= (vbp + 13) && vc< (vbp + 52 ))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) &&vc >= (vbp + 26) && vc< (vbp + 39))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end 
                end

                else if (cur_conv[3] == 4'b0100) // if the digit is 4
                begin
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) && vc >=(vbp) && vc < (vbp +26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 26) && vc >= (vbp + 39) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[3] == 4'b0101) // if the digit is 5
                begin
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 39) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[3] == 4'b0110) // if the digit is 6
                begin
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) &&vc >= (vbp) &&vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 39) && vc>= (vbp + 13) && vc< (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) && vc>= (vbp + 39) && vc< (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[3] == 4'b0111) // if the digit is 7
                begin
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 26) && vc >= (vbp + 13) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[3] == 4'b1000) // if the digit is 8
                begin
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[3] == 4'b1001) // if the digit is 9
                begin
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 133 + 13) && hc < (hbp + 133 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 133) && hc < (hbp + 133 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end
            end

            // draw digit[4]
            if(hc >= (hbp + 178) && hc < (hbp + 178 + 39))
          	begin
                if(cur_conv[4] == 4'b0000) // if the digit is 0
                begin
                    if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc >= (vbp) && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) && vc >= (vbp + 13) && vc < (vbp + 53))
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end 
                end
                
                else if (cur_conv[4] == 4'b0001) // if the digit is 1
                begin
                    if(hc >= (hbp + 178 + 26) && hc < (hbp + 178 + 39) && vc >= vbp && vc < (vbp + 65))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
                    begin
                            red = 000;
                            green = 100;
                            blue = 01;
                    end
                    else
                    begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                end

                else if (cur_conv[4] == 4'b0010) // if the digit is 2
                begin
                 	if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc >= (vbp) && vc < (vbp + 130))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 39) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end
                
                else if (cur_conv[4] == 4'b0011) // if the digit is 3
                begin
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc>= (vbp) && vc< (vbp + 65 ))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 26) && vc>= (vbp + 13) && vc< (vbp + 52 ))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) &&vc >= (vbp + 26) && vc< (vbp + 39))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end 
                end

                else if (cur_conv[4] == 4'b0100) // if the digit is 4
                begin
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) && vc >=(vbp) && vc < (vbp +26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 26) && vc >= (vbp + 39) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[4] == 4'b0101) // if the digit is 5
                begin
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 39) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[4] == 4'b0110) // if the digit is 6
                begin
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) &&vc >= (vbp) &&vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 39) && vc>= (vbp + 13) && vc< (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) && vc>= (vbp + 39) && vc< (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
                end

                else if (cur_conv[4] == 4'b0111) // if the digit is 7
                begin
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc >= (vbp) && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01; 
					end
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 26) && vc >= (vbp + 13) && vc < (vbp + 65))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[4] == 4'b1000) // if the digit is 8
                begin
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end

                else if (cur_conv[4] == 4'b1001) // if the digit is 9
                begin
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 39) && vc >= (vbp)  && vc < (vbp + 65))
					begin
                            red = 000;
                            green = 100;
                            blue = 01;
					end
					if(hc >= (hbp + 178 + 13) && hc < (hbp + 178 + 26) && vc >= (vbp + 13) && vc < (vbp + 26))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end
					if(hc >= (hbp + 178) && hc < (hbp + 178 + 26) && vc >= (vbp + 39) && vc < (vbp + 52))
					begin
						red = 0;
						green = 0;
						blue = 0;
					end 
                end
            end

            // draw difficult mode
            if(hc >= (hbp + 300) && hc < (hbp + 552))
            begin
            	if(sw_level == 0)
            	begin
            		// draw "E"
            		if(hc >= (hbp + 300) && hc < (hbp + 352))
            		begin
            			if(hc >= (hbp + 300) && hc < (hbp + 352) && vc >= (vbp) && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc >= (hbp + 300) && hc < (hbp + 326) && vc >= (vbp + 13) && vc < (hbp + 39))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc >= (hbp + 300) && hc < (hbp + 352) && vc >= (vbp + 52) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc >= (hbp + 300) && hc < (hbp + 339) && vc >= (vbp + 26) && vc < (vbp + 39))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
                       	else 
                       	begin
                        	red = 0;
                        	green = 0;
                       		blue = 0; 
                       	end
            		end
            		// draw "A"
            		if (hc >= (hbp + 360) && hc < (hbp + 412))
            		begin
            			if(hc > (hbp + 360 + 18) && hc < (hbp + 360 + 31) && vc >= (vbp) && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc > (hbp + 360 + 6) && hc < (hbp + 360 + 20) && vc >= (vbp + 13) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc > (hbp + 360 + 31) && hc < (hbp + 360 + 46) && vc >= (vbp + 13) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
            			end
            			else if(hc > (hbp + 360) && hc < (hbp + 360 + 13) && vc >= (vbp + 26) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                       	end
            			else if(hc > (hbp + 360 + 39) && hc < (hbp + 360 + 52) && vc >= (vbp + 26) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       	end
                       	else if(hc > (hbp + 360) && hc < (hbp + 360 + 52) && vc >= (vbp + 39) && vc < (vbp + 52))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       	end
                       	else             			
                       	begin
                        	red = 0;
                        	green = 0;
                       		blue = 0; 
                       	end
            		end
            		// draw "S"
            		if (hc >= (hbp + 420) && hc < (hbp + 472))
            		begin
            			if(hc >= (hbp + 420) && hc < (hbp + 472) && vc >= (vbp) && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
            			end
            			else if(hc >= (hbp + 420) && hc < (hbp + 420 + 13) && vc >= (vbp) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc >= (hbp + 420 ) && hc < (hbp + 472) && vc >= (vbp+26) && vc < (vbp + 39))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc >= (hbp + 420 + 39) && hc < (hbp + 420 + 52) && vc >= (vbp + 26) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc >= (hbp + 420 ) && hc < (hbp + 472) && vc >= (vbp + 52) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            		end

            		// draw "Y"
            		if (hc >= (hbp + 480) && hc < (hbp + 552))
            		begin
            			if(hc >= (hbp + 480) && hc < (hbp + 480 + 13) && vc >= vbp && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			
            			else if(hc >= (hbp + 480 + 39) && hc < (hbp + 480 + 52) && vc >= vbp && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end

            			else if(hc >= (hbp + 480 + 7) && hc < (hbp + 480 + 20) && vc >= (vbp + 13) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end

            			else if(hc >= (hbp + 480 + 33) && hc < (hbp + 480 + 46) && vc >= (vbp + 13) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
            			end
            			else if(hc >= (hbp + 480 + 20) && hc < (hbp + 480 + 33) && vc >= (vbp + 26) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else 
            			begin
                        	red = 0;
                        	green = 0;
                       		blue = 0; 
            			end
            		end
            	end
            	else 
            	begin
                            red = 0;
                            green = 0;
                            blue = 0; 
            		// draw "H"
            		if(hc >= (hbp + 300) && hc < (hbp + 352))
            		begin
            			if(hc >= (hbp + 300) && hc < (hbp + 300 + 13) && vc >= (vbp) && vc < (vbp + 65))
            			begin
                        	red = 000;
                        	green = 100;
                       		blue = 01; 
            			end
            			else if(hc >= (hbp + 300 + 39) && hc < (hbp + 352) && vc >= (vbp) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(vc >= (vbp + 26) && vc < (vbp + 39))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end 
                       	else 
                       	begin
                        	red = 0;
                        	green = 0;
                       		blue = 0; 
                       	end
            		end
            		// draw "A"
            		if (hc >= (hbp + 360) && hc < (hbp + 412))
            		begin
            			if(hc > (hbp + 360 + 18) && hc < (hbp + 360 + 31) && vc >= (vbp) && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc > (hbp + 360 + 6) && hc < (hbp + 360 + 20) && vc >= (vbp + 13) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc > (hbp + 360 + 31) && hc < (hbp + 360 + 46) && vc >= (vbp + 13) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			else if(hc > (hbp + 360) && hc < (hbp + 360 + 13) && vc >= (vbp + 26) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                       	end
            			else if(hc > (hbp + 360 + 39) && hc < (hbp + 360 + 52) && vc >= (vbp + 26) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
                       	end
                       	else if(hc > (hbp + 360) && hc < (hbp + 360 + 52) && vc >= (vbp + 39) && vc < (vbp + 52))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                       	end
                       	else             			
                       	begin
                        	red = 0;
                        	green = 0;
                       		blue = 0; 
                       	end
            		end
            		// draw "R"
            		if (hc >= (hbp + 420) && hc < (hbp + 472))
            		begin
            			if(hc >= (hbp + 420) && hc < (hbp + 420 + 39) && vc >= (vbp) && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			if(hc >= (hbp + 420) && hc < (hbp + 420 + 13) && vc >= (vbp) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			if(hc >= (hbp + 420 + 33) && hc < (hbp + 420 + 46) && vc >= (vbp + 13) && vc < (vbp + 26))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
            			end
            			if(hc >= (hbp + 420) && hc < (hbp + 420 + 39) && vc >= (vbp + 26) && vc < (vbp + 39))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			if(hc >= (hbp + 420 + 26) && hc < (hbp + 420 + 39) && vc >= (vbp + 39) && vc < (vbp + 52))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			if(hc >= (hbp + 420 + 39) && hc < (hbp + 420 + 52) && vc >= (vbp + 52) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            		end

            		// draw "D"
            		if (hc >= (hbp + 480) && hc < (hbp + 552))
            		begin 
            			if(hc >= (hbp + 480 ) && hc < (hbp + 480 + 13) && vc >= (vbp) && vc < (vbp + 65))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;
            			end
            			
            			if(hc >= (hbp + 480 + 39) && hc < (hbp + 480 + 52) && vc >= (vbp + 13) && vc < (vbp + 52))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01;  
            			end
            			
            		    if(hc >= (hbp + 480 ) && hc < (hbp + 480 + 39) && vc >= (vbp ) && vc < (vbp + 13))
            			begin
                            red = 000;
                            green = 100;
                            blue = 01; 
            			end
                        if(hc >= (hbp + 480 ) && hc < (hbp + 480 + 39) && vc >= (vbp  + 52) && vc < (vbp + 65))
                        begin
                            red = 000;
                            green = 100;
                            blue = 01; 
                        end


            		end
            	end
            end
        end

        // draw field
		else if (hc >= (hbp + 80) && hc < (hbp+560) && vc >= (vbp+120)) 
		begin
			red = 001;
			green = 101;
			blue = 00; 

			if(hc >= (hbp + 80) && hc < (hbp + 560) && vc >= (vbp + 140) && vc < (vbp + 180))
			begin

				//pos 1
				if (hc >= (hbp + 100) && hc < (hbp + 180))
				begin
					red = 0;
					green = 0;
					blue = 0; 
				end

				//pos 2
				if (hc >= (hbp + 220) && hc < (hbp + 300))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				//pos 3
				if (hc >= (hbp + 340) && hc < (hbp + 420))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				//pos 10
				if (hc >= (hbp + 460) && hc < (hbp + 540))
				begin
					red = 0;
					green = 0;
					blue = 0;
				end
			end
			if(hc >= (hbp + 80) && hc < (hbp + 560) && vc >= (vbp + 220) && vc < (vbp + 260))
			begin

				// pos 4
				if (hc >= (hbp + 100) && hc < (hbp + 180))
				begin
					red = 0;
					green = 0;
					blue = 0; 
				end

				// pos 5
				if (hc >= (hbp + 220) && hc < (hbp + 300))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				// pos 6
				if (hc >= (hbp + 340) && hc < (hbp + 420))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				// pos 11
				if (hc >= (hbp + 460) && hc < (hbp + 540))
				begin
					red = 0;
					green = 0;
					blue = 0;
				end
			end
			if(hc >= (hbp + 80) && hc < (hbp + 560) && vc >= (vbp + 300) && vc < (vbp + 340))
			begin
				// pos 7
				if (hc >= (hbp + 100) && hc < (hbp + 180))
				begin
					red = 0;
					green = 0;
					blue = 0; 
				end

				// pos 8
				if (hc >= (hbp + 220) && hc < (hbp + 300))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				// pos 9
				if (hc >= (hbp + 340) && hc < (hbp + 420))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				// pos 12
				if (hc >= (hbp + 460) && hc < (hbp + 540))
				begin
					red = 0;
					green = 0;
					blue = 0;
				end
			end
			if(hc >= (hbp + 80) && hc < (hbp + 560) && vc >= (vbp + 380) && vc < (vbp + 420))
			begin
				// pos 0
				if (hc >= (hbp + 100) && hc < (hbp + 180))
				begin
					red = 0;
					green = 0;
					blue = 0; 
                end

				// pos 15
				if (hc >= (hbp + 220) && hc < (hbp + 300))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				// pos 14
				if (hc >= (hbp + 340) && hc < (hbp + 420))
				begin
					red = 0;
					green = 0;
					blue = 0;

				end

				// 13
				if (hc >= (hbp + 460) && hc < (hbp + 540))
				begin
					red = 0;
					green = 0;
					blue = 0;
				end

			end
		end

		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
		
		
		if(hc >= (hbp) && hc < (hbp + 20) && vc >= (vbp + 80) && vc < (vbp + 120))
		begin
		// draw life
			if(life == 2'b11)
			begin
				red = 000;
				green = 110;
				blue = 00;
			end
			else if(life == 2'b01)
			begin
				red = 111;
				green = 0;
				blue = 0;
			end
			else if (life == 2'b10)
			begin
				red = 110;
				green = 111;
				blue = 00;
			end		
		end
		// draw figure
		if(cur_figure == 2'b00)  // rabbit
		begin
			if (hc >= (fig_r + 32) && hc < (fig_r + 38) && vc >= (fig_c) && vc < (fig_c + 16))  
			begin
				red = 111;
				green = 111;
				blue = 11;
				if (hc >= (fig_r + 34) && hc < (fig_r + 36) && vc >= (fig_c + 6) && vc < (fig_c + 16))
				begin
					red = 0;
					green = 0;
					blue = 0;
				end
			end
			else if (hc >= (fig_r + 42) && hc < (fig_r + 48) && vc >= (fig_c) && vc < (fig_c + 16))  
			begin
				red = 111;
				green = 111;
				blue = 11;			
				if (hc >= (fig_r +  44) && hc < (fig_r + 46) && vc >= (fig_c + 6) && vc < (fig_c + 16))
				begin
					red = 0;
					green = 0;
					blue = 0;
				end
			end

			else if (hc >= (fig_r  + 26) && hc < (fig_r + 54) && vc >= (fig_c + 16) && vc < (fig_c + 38))  
			begin
				red = 111;
				green = 111;
				blue = 11;
			end

			else if (hc >= (fig_r + 34) && hc < (fig_r + 46) && vc >= (fig_c + 28) && vc < (fig_c + 30))  
			begin
				red = 111;
				green = 111;
				blue = 11;
			end
		end
		else if (cur_figure == 2'b11) // big mole
		begin
			if (hc >= (fig_r + 20) && hc < (fig_r + 60) && vc >= (fig_c) && vc < (fig_c + 40))  
			begin
				red = 110;
				green = 010;
				blue = 10; 
			// left eye
			end
			if (hc >= (fig_r+ 28) && hc < (fig_r+ 32) && vc >= (fig_c + 8) && vc < (fig_c + 20))
			begin
				red = 0;
				green = 0;
				blue = 0;
			end
			// right eye
			else if (hc >= (fig_r + 48) && hc < (fig_r + 52) && vc >= (fig_c + 8) && vc < (fig_c + 20))
			begin
				red = 0;
				green = 0;
				blue = 0;
			end
			// left huxu...
			else if (hc >= (fig_r+ 24) && hc < (fig_r + 32) && vc >= (fig_c + 26) && vc < (fig_c + 28))
			begin
				red = 0;
				green = 0;
				blue = 0;
			end
			// right huxu...
			else if (hc >= (fig_r + 48) && hc < (fig_r+ 56) && vc >= (fig_c + 26) && vc < (fig_c + 28))
			begin
				red = 0;
				green = 0;
				blue = 0;
			end
			// mouth...
			else if (hc >= (fig_r+ 38) && hc < (fig_r +  42) && vc >= (fig_c +  28) && vc < (fig_c + 30))
			begin
				red = 0;
				green = 0;
				blue = 0;
			end
		end 
		else // normal mole
		begin
            if (hc >= (fig_r + 20) && hc < (fig_r + 60) && vc >= (fig_c) && vc < (fig_c + 40))  
            begin
                red = 010;
                green = 001;
                blue = 10; 
            // left eye
            end
            if (hc >= (fig_r+ 28) && hc < (fig_r+ 32) && vc >= (fig_c + 8) && vc < (fig_c + 20))
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
            // right eye
            else if (hc >= (fig_r + 48) && hc < (fig_r + 52) && vc >= (fig_c + 8) && vc < (fig_c + 20))
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
            // left huxu...
            else if (hc >= (fig_r+ 24) && hc < (fig_r + 32) && vc >= (fig_c + 26) && vc < (fig_c + 28))
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
            // right huxu...
            else if (hc >= (fig_r + 48) && hc < (fig_r+ 56) && vc >= (fig_c + 26) && vc < (fig_c + 28))
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
            // mouth...
            else if (hc >= (fig_r+ 38) && hc < (fig_r +  42) && vc >= (fig_c +  28) && vc < (fig_c + 30))
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
        end 

	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
	end
end


endmodule
