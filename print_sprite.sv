module print_sprite(input clk50, reset,
					//input [9:0] xcoor,	//consider delete it
					input [9:0] ycoor,
					input [23:0] object_info,
					input start,
					//output logic[9:0] buffer_update_address,
					output logic [4:0] sprite_counter,
					output logic ready, 
					output logic [9:0] sprite_addr 	//Pixel address for sprite
					);


//state of single sprite drawing
enum logic [2:0] {sprite_wait, sprite_process1, sprite_ready} sprite_st, sprite_next_st;
//logic [4:0] sprite_counter ; 		//Counter for updating the sprite pixel

always_ff @ (posedge clk50) begin
		if(reset) begin
			sprite_st <= sprite_wait;
			sprite_counter <= 0;
			// update_we <= 0; 
		end
		else begin
			sprite_st <= sprite_next_st;
			case (sprite_st)
				sprite_wait: begin
					sprite_counter <= 0;
					// update_we <= 0;
				end
				sprite_process1: begin
					//Only update buffer when counter + object_info[18:9] is in [0, 639]                  
					if(sprite_counter + object_info[18:9] >= 10'd0 && sprite_counter + object_info[18:9] <= 10'd639) begin
						// update_we <= 1;
						//buffer_update_address <= sprite_counter + object_info[18:9];
						sprite_addr <= sprite_counter + (ycoor-object_info[8:0])*32;
						sprite_counter <= sprite_counter+1;
					end
					else //skip current pixel, go to next one
						sprite_counter <= sprite_counter+1;
						// update_we <= 0; 
				end
				sprite_ready: begin
					// update_we <= 0; 	//Close update_we
				end 
			endcase
		end
end 


always_comb begin 
	sprite_next_st = sprite_st;
	ready = 0;
	unique case (sprite_st)
		sprite_wait: begin
			if(start == 1'd1)
				sprite_next_st = sprite_process1;  
		end
		sprite_process1: begin
			if(sprite_counter == 5'd31)				//Does it skip the last bit?
				sprite_next_st = sprite_ready;
		end
		sprite_ready: begin
			ready = 1;
			if(start == 1'd0)
				sprite_next_st = sprite_wait;
		end 
	endcase // sprite_st
end
endmodule // print_sprite