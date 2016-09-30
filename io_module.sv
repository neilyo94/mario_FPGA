module io_module (input clk50,
				  input reset,
				  input [7:0] to_hw_data,
				  input [1:0] to_hw_sig,
				  output logic [1:0] to_sw_sig

					);

	logic [5:0] sw_counter;
	logic id_ram_we;
	logic [23:0] id_ram_in;
	logic finish_read, finish_draw;

	//State Machine initialization
	enum logic [3:0] {sw_reset, sw_read_1, sw_read_2, sw_read_3, 
					  sw_ack_read_1, sw_ack_read_2, sw_ack_read_3, sw_loop, sw_drawing} sw_state, sw_next_state;

	logic [23:0] temp;
	
	always_ff @ (posedge clk50 or posedge reset) begin
		if (reset) begin
			sw_state <= sw_reset;
		end
		else begin 
			sw_state <= sw_next_state;
			case (sw_state)
				sw_reset: begin
					sw_counter <= 0;
				end
				sw_read_1: begin
					temp[23:16] <= to_hw_data;
				end
				sw_read_2: begin
					temp[15:8] <= to_hw_data;
				end 
				sw_read_3: begin
					temp[7:0] <= to_hw_data;
				end
				sw_loop: begin 
					sw_counter <= sw_counter + 1;
				end 
			endcase 
		end 
	end 
	always_comb begin
		finish_read = 1'd0;
		id_ram_we=1'd0;
		id_ram_in=24'd0;
		to_sw_sig = 2'd0;
		unique case (sw_state)
			sw_reset: begin
				finish_read = 0;
				to_sw_sig = 2'd0;
			end
			sw_read_1: begin
				to_sw_sig = 2'd1;
			end
			sw_read_2: begin
				to_sw_sig = 2'd1;
			end
			sw_read_3: begin
				to_sw_sig = 2'd1;
				id_ram_in = temp;
				id_ram_we = 1;
			end
			sw_ack_read_1: begin
				to_sw_sig = 2'd0;
			end
			sw_ack_read_2: begin
				to_sw_sig = 2'd0;
			end
			sw_ack_read_3: begin
				to_sw_sig = 2'd0;
			end
			sw_loop: begin 
				to_sw_sig = 2'd0;
			end
			sw_drawing: begin
				id_ram_we = 0;
				finish_read = 1'd1;
				to_sw_sig = 2'd2;
			end
		endcase
	end
	//next state logic
	always_comb begin
		sw_next_state = sw_state;
		unique case (sw_state)
			sw_reset: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_read_1;
			end
			sw_read_1: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = sw_ack_read_1;
			end 
			sw_read_2: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = sw_ack_read_2;
			end 
			sw_read_3: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = sw_ack_read_3;
			end 
			sw_ack_read_1: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_read_2;
			end
			sw_ack_read_2: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_read_3;
			end
			sw_ack_read_3: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_loop;  //Finish reading here
			end
			sw_loop: begin
				if(sw_counter == 6'd32) begin //Check counter. Counter range is 1 to 32
					sw_next_state = sw_drawing;
				end
				else if(to_hw_sig == 2'd1) begin
					sw_next_state = sw_read_1;
				end
			end
			sw_drawing: begin
				if(finish_draw == 1'd1) //finish drawing the frame
					sw_next_state = sw_reset;
			end
		endcase
	end 

endmodule // io_module

	