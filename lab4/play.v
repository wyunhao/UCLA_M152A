module play(
	input clk,
	// Debouncer
	input sw_level,
	input start,
	input pause,
	input Enable,
	input start_pulse,
	// Decoder
	input [3:0] DecodeOut,
	// rand_gen
	input [3:0] pos_dec,
	input [1:0] figure,
	// Output
	output reg show_menu,
	output reg [3:0] cur_pos,
	output reg [19:0] max_easy,
	output reg [19:0] max_hard,
	output reg [19:0] out_cur_conv,
 	output reg [1:0] life,
 	output reg [1:0] cur_figure
 );


reg [3:0] cur_conv [4:0];
	
reg [26:0] max_time;
reg [26:0] counter;
reg [16:0] cur_score;
reg boss_beaten = 0;

initial begin
	cur_figure = 2'b00;
	cur_pos = 4'b0000;
	life = 2'b11;
	max_time = 27'd100000000;
	counter = 27'd0;
	max_easy = 20'b0;
	max_hard = 20'b0;
	out_cur_conv = 20'b0;
	cur_conv[0] = 4'b0;
	cur_conv[1] = 4'b0;
	cur_conv[2] = 4'b0;
	cur_conv[3] = 4'b0;
	cur_conv[4] = 4'b0;
	cur_score = 17'b0;
end

reg play_flag = 1;

// compare: flatten score
// computation: cur_conv, 2D array
// compare for maxtime: integer binary representation 


always @ (posedge clk)
begin
	
	if(!start || !play_flag) //not enter the game, stay on the menu page
	begin
		if(start_pulse)
			play_flag = 1;
		life = 2'b11;
		if (sw_level && out_cur_conv > max_hard)
		begin
			max_hard = out_cur_conv;
			out_cur_conv = 20'b0;
		end
		else if (!sw_level && out_cur_conv > max_easy)
		begin
			max_easy = out_cur_conv;
			out_cur_conv = 20'b0;
		end
		show_menu = 1'b1;
		cur_score = 17'b0;
		cur_conv[0] = 4'b0;
		cur_conv[1] = 4'b0;
		cur_conv[2] = 4'b0;
		cur_conv[3] = 4'b0;
		cur_conv[4] = 4'b0;
		max_time = 27'd100000000;
		counter = 0;
	end


	else if (pause) // pause the game when playing
	begin
		show_menu = 1'b0;
	end


	else // playing the game
	begin
		if (sw_level == 0)
			cur_figure = 2'b01;
		show_menu = 1'b0;
		if (cur_score >= 6000)  
			max_time = 27'd20000000;
		else if (cur_score >= 4500)
			max_time = 27'd40000000;
		else if (cur_score >= 3000)
			max_time = 27'd60000000;
		else if (cur_score >= 1500)
			max_time = 27'd80000000;

		if (cur_pos == DecodeOut && Enable) // hit on the figure
		begin
			if (cur_figure == 2'b00) // rabbit
			begin
				if(cur_score <= 17'b110010)
				begin
					cur_score = 17'b0;
					cur_conv[0] = 4'b0;
					cur_conv[1] = 4'b0;
					cur_conv[2] = 4'b0;
					cur_conv[3] = 4'b0;
					cur_conv[4] = 4'b0;
					out_cur_conv[3:0] = cur_conv[0];
					out_cur_conv[7:4] = cur_conv[1];
					out_cur_conv[11:8] = cur_conv[2];
					out_cur_conv[15:12] = cur_conv[3];
					out_cur_conv[19:16] = cur_conv[4];
				end
				else
				begin
					cur_score = cur_score - 17'b110010;
					if(cur_conv[1] >= 4'b0101)
					begin
						cur_conv[1] = cur_conv[1] - 4'b0101;
					end
					else if(cur_conv[2] >= 4'b1)
					begin
						cur_conv[2] = cur_conv[2] - 4'b1;
						cur_conv[1] = cur_conv[1] + 4'b0101;
					end
					else if(cur_conv[3] >= 4'b1)
					begin
						cur_conv[3] = cur_conv[3] - 4'b1;
						cur_conv[2] = 4'b1001;
						cur_conv[1] = cur_conv[1] + 4'b0101;
					end	
					else if(cur_conv[4] >= 4'b1)
					begin
						cur_conv[4] = cur_conv[4] - 4'b1;
						cur_conv[3] = 4'b1001;
						cur_conv[2] = 4'b1001;
						cur_conv[1] = cur_conv[1] + 4'b0101;
					end
					out_cur_conv[3:0] = cur_conv[0];
					out_cur_conv[7:4] = cur_conv[1];
					out_cur_conv[11:8] = cur_conv[2];
					out_cur_conv[15:12] = cur_conv[3];
					out_cur_conv[19:16] = cur_conv[4];
				end
				life = life - 1;
			end
			else // mole
			begin
				cur_score = cur_score + 17'b1100100;
				if(cur_conv[2] < 4'b1001)
				begin
					cur_conv[2] = cur_conv[2] + 4'b1;
				end
				else if(cur_conv[3] < 4'b1001)
				begin
					cur_conv[2] = 4'b0;
					cur_conv[3] = cur_conv[3] + 4'b1;
				end
				else if(cur_conv[4] < 4'b1001)
				begin
					cur_conv[2] = 4'b0;
					cur_conv[3] = 4'b0;
					cur_conv[4] = cur_conv[4] + 4'b1;
				end
				else
				begin
					cur_conv[0] = 4'b1001;
					cur_conv[1] = 4'b1001;
					cur_conv[2] = 4'b1001;
					cur_conv[3] = 4'b1001;
					cur_conv[4] = 4'b1001;
					cur_score = 17'b11000011010011111;
				end
				out_cur_conv[3:0] = cur_conv[0];
				out_cur_conv[7:4] = cur_conv[1];
				out_cur_conv[11:8] = cur_conv[2];
				out_cur_conv[15:12] = cur_conv[3];
				out_cur_conv[19:16] = cur_conv[4];
			end
		end

		else if (Enable && cur_pos != pos_dec) // does not hit the correct figure 
		begin
			if(cur_score <= 17'b10100)
			begin
				cur_score = 17'b0;
				cur_conv[0] = 4'b0;
				cur_conv[1] = 4'b0;
				cur_conv[2] = 4'b0;
				cur_conv[3] = 4'b0;
				cur_conv[4] = 4'b0;
				out_cur_conv[3:0] = cur_conv[0];
				out_cur_conv[7:4] = cur_conv[1];
				out_cur_conv[11:8] = cur_conv[2];
				out_cur_conv[15:12] = cur_conv[3];
				out_cur_conv[19:16] = cur_conv[4];
			end
			else
			begin
				cur_score = cur_score - 17'b10100;
				if(cur_conv[1] >= 4'b10)
				begin
					cur_conv[1] = cur_conv[1] - 4'b10;
				end
				else if(cur_conv[2] >= 4'b1)
				begin
					cur_conv[2] = cur_conv[2] - 4'b1;
					cur_conv[1] = cur_conv[1] + 4'b1000;
				end
				else if(cur_conv[3] >= 4'b1)
				begin
					cur_conv[3] = cur_conv[3] - 4'b1;
					cur_conv[2] = 4'b1001;
					cur_conv[1] = cur_conv[1] + 4'b1000;
				end	
				else if(cur_conv[4] >= 4'b1)
				begin
					cur_conv[4] = cur_conv[4] - 4'b1;
					cur_conv[3] = 4'b1001;
					cur_conv[2] = 4'b1001;
					cur_conv[1] = cur_conv[1] + 4'b1000;
				end
				out_cur_conv[3:0] = cur_conv[0];
				out_cur_conv[7:4] = cur_conv[1];
				out_cur_conv[11:8] = cur_conv[2];
				out_cur_conv[15:12] = cur_conv[3];
				out_cur_conv[19:16] = cur_conv[4];
			end
		end

		if (counter == max_time || cur_pos == DecodeOut && Enable)
		begin
			if (counter == max_time && cur_figure != 2'b00)
			begin
				life = life - 1;
			end

			if (counter != max_time && cur_figure == 2'b11)
			begin
				cur_figure = 2'b01;
				counter = counter + 1;
			end
			else
			begin
				counter = 27'b0;
				cur_pos = pos_dec;
				cur_figure = figure;
			end
		end

		else
			counter = counter + 1;
			
		if (life == 0)
			play_flag = 0;

		out_cur_conv[3:0] = cur_conv[0];
		out_cur_conv[7:4] = cur_conv[1];
		out_cur_conv[11:8] = cur_conv[2];
		out_cur_conv[15:12] = cur_conv[3];
		out_cur_conv[19:16] = cur_conv[4];
	end
	

end



endmodule
 