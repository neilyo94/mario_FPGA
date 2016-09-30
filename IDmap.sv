module IDmap (
				// input clk50,    // Clock
				// //input clk_en, // Clock Enable
				// input reset,  
				// input [9:0] hc, vc, 	// line counter input. Need them for EndofField checking condition 
				// input [9:0] xcoor,
				// 			ycoor,
				// input [23:0] to_hw_data,
				// input  to_hw_sig,
				// output to_sw_read_sig, 	//1 means finish reading the data, move to the next one
				// output logic [1:0] to_sw_sig, // 1 means module is working, pause software
				// output logic [7:0] VGA_R, VGA_G, VGA_B

				//testing 
				input clk50,    // Clock
				input reset,  
				input [9:0] hc, vc, 	// line counter input. Need them for EndofField checking condition 
				input [9:0] xcoor,
							ycoor,
				input [7:0] to_hw_data,
				input [1:0] to_hw_sig,
				//output logic to_sw_read_sig, 	//1 means finish reading the data, move to the next one
				output logic [1:0] to_sw_sig, // 1 means read, two 2module is working, pause software
				output logic [7:0] VGA_R, VGA_G, VGA_B

				//new added port
);

	//State Machine initialization
//	enum logic [2:0] {sw_reset, sw_read, sw_ack_read, sw_drawing, sw_loop} sw_state, sw_next_state;

	//Variable
	logic [5:0] sw_counter;			//Counts the current index of object_info, set to 5. 
	logic [4:0] id_ram_address;  	//address that stores the current object_info
	logic [23:0] id_ram_in;			//Data goes into id_ram
	logic [23:0] id_ram_out;		//Data comes out from id_ram
	logic [4:0] update_counter;  	//Counter for update state machine
	logic id_ram_we;				//idram write-enable
	logic finish_read, finish_draw; 	//signal indicating read and draw are finished
	logic [1:0] addr_select;			//  
	logic [2:0] buffer_update_select;
	id_ram id1(.clk(clk50), .we(id_ram_we), .data_in(id_ram_in), .data_out(id_ram_out), .address(id_ram_address));
	addr_mux addrmux(.select(addr_select), .swAddr(sw_counter), .updateAddr(update_counter), .in3(), .in4(), .out(id_ram_address));
	//sw_state: state logic
	
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
				hw_read_1: begin
					to_sw_data	<= temp[23:16];
				end
				hw_read_2: begin
					to_sw_data	<=	temp[15:8];
				end 
				hw_read_3: begin
					to_sw_data	<=	temp[7:0];
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
		id_ram_out = 24'd0;	//ram to sw
		id_ram_in=24'd0;
		to_sw_sig = 2'd0;
		unique case (sw_state)
			sw_reset: begin
				finish_read = 0;
				to_sw_sig = 2'd0;
			end
			//h2s
			hw_read_1: begin
				to_sw_sig = 2'd1;
			end
			hw_read_2: begin
				to_sw_sig = 2'd1;
			end
			hw_read_3: begin
				to_sw_sig = 2'd1;
				temp = id_ram_out;//id_ram_in = temp;
				id_ram_we = 1;
			end
			hw_ack_read_1: begin
				to_sw_sig = 2'd0;
			end
			hw_ack_read_2: begin
				to_sw_sig = 2'd0;
			end
			hw_ack_read_3: begin
				to_sw_sig = 2'd0;
			end
			hw_ack_read_3: begin	//hold or loop back or sw_calc_begin
				to_sw_sig = 2'd0;
			end
			//s2h
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
			sw_loop: begin 			//hold or loop back or draw
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
					sw_next_state = hw_read_1;
			end
			//=======================	HW_TO_SW
			hw_read_1: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = hw_ack_read_1;
			end 
			hw_ack_read_1: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = hw_read_2;
			end 
			hw_read_2: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = hw_ack_read_2;
			end 
			hw_ack_read_2: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = hw_read_3;
			hw_read_3: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = hw_ack_read_3;		//read 24 bits done
			end
			hw_ack_read_3: begin				
				if(to_hw_sig == 2'd1)			//go back loop 32 times 
					sw_next_state = hw_read_1;
				if(to_hw_sig == 2'd0) 		//go to sw processing and wait for output
					sw_next_state = sw_read_1; 	
			end 
			//=======================
			sw_read_1: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = sw_ack_read_1;
			end 
			sw_ack_read_1: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_read_2;
			end 
			sw_read_2: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = sw_ack_read_2;
			end 
			sw_ack_read_2: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_read_3;
			end
			sw_read_3: begin
				if(to_hw_sig == 2'd2)
					sw_next_state = sw_loop;//combine loop and ack3
			end
/*			sw_ack_read_3: begin	
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_loop;  //Finish reading here
			end
				*/
			sw_loop: begin
				//if(sw_counter == 6'd31) begin //Check counter. Counter range is 1 to 32
				if(to_hw_sig == 2'd0)	begin
					sw_next_state = sw_drawing;
				end
				else if(to_hw_sig == 2'd1) begin
					sw_next_state = sw_read_1;
				end
			end
			sw_drawing: begin
				if(finish_draw == 1'd1 || to_hw_sig == 2'd2)// && to_hw_sig == 2'd2) //finish drawing the frame
					sw_next_state = sw_reset;
			end
		endcase
	end 
/*	
	always_ff @ (posedge clk50 or posedge reset) begin
		if(reset) begin
			sw_state <= sw_reset;
		end
		else begin
			sw_state <= sw_next_state;
			case (sw_state)
				sw_reset: begin
					sw_counter <= 0;
				end
				sw_read: begin
					sw_counter <= sw_counter + 1;
					//id_ram_address <= sw_counter;			///bug 1
				end
				sw_ack_read: begin
				end 
				sw_loop: ;
				sw_drawing: begin
				end
			endcase // sw_state
		end
	end 
	always_comb begin
		to_sw_sig = 2'b0;
		// to_sw_read_sig = 1'd0;
		finish_read = 1'd0;
		id_ram_we=1'd0;
		id_ram_in=24'd0;
		unique case (sw_state)
			sw_reset: begin
				to_sw_sig =2'b0;
				// to_sw_read_sig =0;
				finish_read = 0;
			end
			sw_read: begin
				
				id_ram_in = to_hw_data;
				id_ram_we = 1;
				// to_sw_read_sig = 0;
			end
			sw_ack_read: begin
				id_ram_we = 0; 
				// to_sw_read_sig = 1;
			end
			sw_loop: ;
			sw_drawing: begin
				id_ram_we = 0;
				finish_read = 1'd1;
				to_sw_sig = 2'b1;
			end
		endcase
	end
	//sw_state: next-state logic
	always_comb begin
		sw_next_state = sw_state;
		unique case (sw_state)
			sw_reset: begin
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_read;
			end
			sw_read: begin
				sw_next_state = sw_ack_read;
			end
			sw_ack_read: begin				//Read-akg state 
				if(to_hw_sig == 2'd1)
					sw_next_state = sw_loop;
			end
			sw_loop: begin
				if(sw_counter == 6'd32) begin //Check counter. Counter range is 1 to 32
					sw_next_state = sw_drawing;
				end
				else	sw_next_state = sw_read;
			end
			sw_drawing: begin
				if(finish_draw == 1'd1) //finish drawing the frame
					sw_next_state = sw_reset;
			end
		endcase
	end
*/

	/************************************
		VGA line buffer implementation 
	************************************/
	//Setting for line buffer
	logic we;
	logic A_we;
	logic B_we;
	logic update_we;
	logic [9:0] buffer_A_address;
  	logic [9:0] buffer_B_address;
  	logic [9:0] buffer_update_address;
  	logic [9:0] buffer_draw_address;
  	logic [23:0] A_out;		//output of buffer A. (pixel)
  	logic [23:0] B_out;		//output of buffer B. (pixel)
  	logic [23:0] mem_in_A;	//Data_in into buffer A
  	logic [23:0] mem_in_B;	//Data_in into buffer B
  	logic [23:0] update_in; //the pixel info we want to push into buffer 
  	logic [23:0] mem_out;	//Output pixel from the drawing buffer 
  	//state of choosing line buffer
  	enum logic [2:0] {uA_dB, uB_dA} line_buffer_select;  
  	//line_buffer module
  	line_buffer line_buffer_A(.clk(clk50),.we(A_we),.data_in(mem_in_A),.data_out(A_out),.address(buffer_A_address));
  	line_buffer line_buffer_B(.clk(clk50),.we(B_we),.data_in(mem_in_B),.data_out(B_out),.address(buffer_B_address));

  	//Line buffer select logic
  	always_comb begin
	  	A_we = 0;
	    B_we = 0;
	    mem_in_A = 24'd0;
      	mem_in_B = 24'd0;
	    buffer_A_address = 10'd0;
	    buffer_B_address = 10'd0;
	    mem_out = 24'd0;
	    if(line_buffer_select == uA_dB) begin
	    	A_we = update_we;
	    	mem_in_A = update_in;
	    	mem_out = B_out;
	    	buffer_A_address = buffer_update_address;
	    	buffer_B_address = buffer_draw_address;
	    end
	    else if (line_buffer_select == uB_dA) begin
	    	B_we = update_we;
	    	mem_in_B = update_in;
	    	mem_out = A_out; 
	    	buffer_A_address = buffer_draw_address;
	    	buffer_B_address = buffer_update_address;
	    end
	end 
	//////////////////////////////////////////////////////////////////////////////////
	//All VGA State machines 
  
  	logic [23:0] object_info;			//Current working object_info
  	logic [23:0] sprite_pixel; 			//Pixel from sprite
  	logic [23:0] background_pixel;		//Pixel for background
  	logic [9:0] background_counter; 	//Counter for updating the background pixel
  	logic [9:0] sprite_addr; 			//Pixel address for sprite
  	logic print_sprite_start; 			//Singal to control print_sprint module
  	logic print_ready; 					//Signal to show print_sprint finish the job
  	logic update_start; 				//Signal indicating we can start update.
  	logic draw_start;					//Signal indicating drawing can start.
  	logic EndofField;					//Signal indicating all the pixel are draw. 
  	logic EndofLine;					//Signal indicating current line pixels are draw. 
  	logic ctr_reset;					//Signal given by control_st to update_st and draw_st 
  	
  	logic [4:0] sprite_counter; 

  	assign background_pixel = 24'h005fff; 	//Background pixel value (pick a blue color)
  	assign object_info = id_ram_out;

  	//line buffer top level control state machine
  	enum logic [2:0] {control_reset, control_process, control_wait_1, control_wait_2} control_st, control_next_st;
	//state of drawing
	enum logic [2:0] {drawing_reset, drawing_process, drawing_wait} draw_st, draw_next_st;
	//state of updating 
	enum logic [2:0] {lb_reset, lb_ready, lb_process1, lb_process2, lb_process3, lb_process_loop, lb_update_end} update_st, update_next_st;
	//helper function: print_sprite
	print_sprite ps(.clk50(clk50), .reset(reset), .ycoor(ycoor), .object_info(object_info), .start(print_sprite_start),
					.sprite_counter(sprite_counter), .ready(print_ready), .sprite_addr(sprite_addr));  											//.buffer_update_address(buffer_update_address), .update_we(update_we), .xcoor(xcoor), 
	//Sprite MUX: provide the correct sprite_pixel 
	sprite_mux sm(.clk50(clk50), .object_id(object_info[23:19]), .addr(sprite_addr), .sprite_pixel(sprite_pixel));
	
	//Control State Machine
	always_ff @ (posedge clk50 or posedge reset) begin
		if(reset) begin
			control_st <= control_reset;
			finish_draw <= 0; 
			line_buffer_select <= uA_dB;
		end
		else begin
			control_st <= control_next_st;
			case (control_st)
				control_reset: begin
					finish_draw <= 1'd0;				//reset finish_draw signal
					line_buffer_select <= uA_dB; 		//reset line_buffer_select
				end
				control_process: begin
					finish_draw <= 1'd0;
				end 
				control_wait_1: begin
					if(EndofField == 1)		//If we reach the End of Field, we are done. Send finish_draw signal and go to control_reset state
						finish_draw <= 1'd1;
					else if(update_st == lb_update_end && draw_st == drawing_wait) begin
						if (line_buffer_select == uA_dB) 	//flipping the line_buffer_select signal
							line_buffer_select <= uB_dA;
						else begin 
							line_buffer_select <= uA_dB;
						end
					end 
				end
				control_wait_2: ;
			endcase // control_st
		end
	end
	always_comb begin
		control_next_st = control_st;
		update_start = 0;
		draw_start = 0;
		ctr_reset = 0; 
		unique case (control_st)
			control_reset: begin
				if(finish_read == 1)
					control_next_st = control_process;
			end
			control_process: begin
				if(update_st == lb_update_end || draw_st == drawing_wait)
					control_next_st = control_wait_1; 
				update_start = 1;					//Update state machine start working
				draw_start = 1;						//Draw state machine start working
			end
			control_wait_1: begin
				if(update_st == lb_update_end && draw_st == drawing_wait) begin //If both update and drawing are finish, go back to process
					control_next_st = control_wait_2;
				end 
				update_start = 1;					//keep the signal high in case the sub state-machine doesn't finish
				draw_start = 1;
			end
			control_wait_2: begin
				if(EndofField == 1)	begin			//This state is wait for EndofField signal
					control_next_st = control_reset;					 
				end
				else if(EndofLine) begin			//This state is wait for EndofLine signal
					control_next_st = control_process;
					ctr_reset = 1;
				end 
			end 
		endcase // control_st
	end

	//========================================================
	//Update state machine logic
	always_ff @(posedge clk50 or posedge reset) begin
		if(reset) begin
			update_st <= lb_reset;
		end
		else begin
			update_st <= update_next_st;
			case(update_st)
				lb_reset: begin
				end
				lb_ready: begin
					background_counter <= 0;
					update_counter <= 0;		
				end
				lb_process1: begin
					//First draw the backgound
					if(background_counter <= 10'd639) begin			//Loop 640 times in oder to push backgound pixel into buffer
						update_in <= background_pixel;
						buffer_update_address <= background_counter;
						background_counter <= background_counter + 1; 
					end 
					//Second draw the sprite
					//Check if current sprite need to be draw into line buffer
					else if(ycoor - object_info[8:0] >= 0 && ycoor - object_info[8:0] <= 10'd31) begin
						update_in <= sprite_pixel; 			//update_in always come from sprite_pixel
						buffer_update_address <= sprite_counter + object_info[18:9];			//I have to put this line here because if put this line inside the print_sprit module, we get error: Multi wired buffer_update_address 			
					end
					
				end
				lb_process2: begin
					update_counter <= update_counter+1;
				end
				lb_process3: begin 
					if(ycoor - object_info[8:0] >= 0 && ycoor - object_info[8:0] <= 10'd31) begin
						update_in <= sprite_pixel; 			//update_in always come from sprite_pixel
						buffer_update_address <= sprite_counter + object_info[18:9];			//I have to put this line here because if put this line inside the print_sprit module, we get error: Multi wired buffer_update_address 			
					end
				end 
				lb_update_end: begin
				end
			endcase // update_st
		end
	end
	always_comb begin
		update_next_st = update_st;
		print_sprite_start = 0;
		update_we = 0;
		unique case (update_st)
			lb_reset: begin
				if(update_start == 1)
					update_next_st = lb_ready;
			end
			lb_ready: update_next_st = lb_process1;
			lb_process1: begin							//This process will wait the sprite module finish print all the pixels 
				if(background_counter > 10'd639) begin 	//When finish printing background, print sprite. If not, stay in lb_process1
					//Two cases we may go to lb_process2: finish printing sprite, or sprite does not need to be printed
					if(ycoor - object_info[8:0] >= 0 && ycoor - object_info[8:0] <= 10'd31) begin 	 
						print_sprite_start = 1;
						update_we = 1;
						if (print_ready == 1) 
							update_next_st = lb_process2;	 
					end
					else 
						update_next_st = lb_process2;
				end
				else begin // case: if(background_counter <= 10'd639)
					update_we = 1;
				end
			end
			lb_process2: begin
				update_next_st = lb_process_loop;
			end
			lb_process_loop: begin			//This state is for checking the counter
				if(update_counter == 5'd31) // Will miss the last sprite here 
					update_next_st = lb_process3;
				else
					update_next_st = lb_process1; 
			end
			lb_process3: begin				//For printing the last sprite 						
				if(ycoor - object_info[8:0] >= 0 && ycoor - object_info[8:0] <= 10'd31) begin 	 
					print_sprite_start = 1;
					update_we = 1;
					if (print_ready == 1) 
						update_next_st = lb_update_end;	
				end
				else 
					update_next_st = lb_update_end;
			end 
			lb_update_end: begin
				 if(ctr_reset == 1)
				 	update_next_st = lb_reset;
			end
		endcase
	end		
	//========================================================
	//Drawing state machine
	assign buffer_draw_address = xcoor; //WHEN TESTING, comment it out  
	always_ff @ (posedge clk50 or posedge reset) // We should use frame clk here
	begin
		if(reset)
			draw_st <= drawing_reset;
		else
			draw_st <= draw_next_st; 
			case (draw_st)
				drawing_reset: begin
					//buffer_draw_address <= 0;			//should be comment out when run on board
				end
				drawing_process: begin
					{VGA_R, VGA_G, VGA_B} <= {mem_out[23:16], mem_out[15:8], mem_out[7:0]};
					//buffer_draw_address <= buffer_draw_address + 1;		//should be comment out when run on board
				end
			endcase 
	end 
	always_comb begin
		draw_next_st = draw_st;
		unique case (draw_st)
			drawing_reset: begin
				if(draw_start == 1'd1)
					draw_next_st = drawing_process; 
			end 
			drawing_process: begin
				if(buffer_draw_address > 10'd639) 
					draw_next_st = drawing_wait;
			end
			drawing_wait: begin
				if(ctr_reset == 1'd1)
					draw_next_st = drawing_reset;
			end 
		endcase // draw_st
	end
	//========================================================
	//EndofField combinational logic
	 parameter HACTIVE      = 11'd 1280,
            HFRONT_PORCH = 11'd 32,
            HSYNC        = 11'd 192,
            HBACK_PORCH  = 11'd 96,
            HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH; //1600

			parameter VACTIVE      = 10'd 480,
            VFRONT_PORCH = 10'd 10,
            VSYNC        = 10'd 2,
            VBACK_PORCH  = 10'd 33,
            VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH; //525

   //  assign endOfLine = hcount == HTOTAL - 1;
  	// assign endOfField = vcount == VTOTAL - 1;
	always_comb begin
		if(hc == 10'd799 && vc == 10'd524)
			EndofField = 1;
		else 
			EndofField = 0;
		if(hc == 10'd799)			//Should change to 798?
			EndofLine = 1;
		else
			EndofLine = 0; 
	end
	//========================================================
	//addr_select logic
	always_comb begin
		addr_select = 2'b00;			//By default, connect to sw_state machine 
//		if (sw_state == sw_read) begin		//Writing
//			addr_select = 2'b00;
//		end
		if(finish_read == 1'd1) begin	//Reading
			addr_select = 2'b01;
		end
	end

endmodule