module sprite_mux (input clk50,
				   input [4:0] object_id, 
				   input [9:0] addr,
				   output logic [23:0] sprite_pixel
					);

always_comb begin 
	case (object_id)
		5'd0: begin
			sprite_pixel = 24'hff0087; 	//test color: pink red
		end
		5'd1: begin
			sprite_pixel = 24'h87ff00;	//test color: vivid green
		end
		default: begin
			sprite_pixel = 24'h000000;
		end
	endcase // object_id
end


	// rom_starwarsword starwars (.address(startwarsword_address),.clock(clk50),.q(color_starwars));
	// rom_startgameword startword (.address(startword_address),.clock(clk50),.q(color_start));
	// rom_scoreword scoreword (.address(scoreword_address),.clock(clk50),.q(color_score));
	// rom_bombword bombword(.address(bombword_address),.clock(clk50),.q(color_bomb));

endmodule // sprite_mux