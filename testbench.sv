module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


logic Clk = 0;
logic Reset, Run, Continue;

logic  [1:0] to_sw_sig;			// handshake
logic  [1:0] to_hw_sig;
logic  [8:0] to_hw_data;		// data
logic [9:0] hcount, vcount; 	//line counter
logic [9:0] xcoor, ycoor;		//DrawX, DrawY signal
logic [7:0] VGA_R, VGA_G, VGA_B;

io_module iom(.clk50(Clk), .reset(Reset),
				.to_hw_data(to_hw_data),
				.to_hw_sig (to_hw_sig),
				.to_sw_sig (to_sw_sig));


// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 


// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Reset = 0;

#2 Reset = 1;
#2 Reset = 0;

#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd1;
#4 to_hw_sig = 2'd0;
#4 to_hw_sig = 2'd2;
#4 to_hw_sig = 2'd0;



end

endmodule


/*
assign ycoor = 10'd8;
IDmap id (.clk50(Clk), 
							.reset(Reset), 
							.hc(hcount), 
							.vc(vcount), 
							.xcoor(xcoor), 
							.ycoor(ycoor), 
							.to_hw_data(to_hw_data),
							.to_hw_sig(to_hw_sig),
							.to_sw_read_sig(to_sw_read_sig),
							.to_sw_sig(to_sw_sig),
							.VGA_R(VGA_R),
							.VGA_G(VGA_G),
							.VGA_B(VGA_B)
					);

*/