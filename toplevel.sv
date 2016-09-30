module toplevel(  input			CLOCK_50, 
				  input  [3:0]  KEY,
				  output [7:0]  LEDG,
				  output [17:0] LEDR,
				  //output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,

				  // VGA Interface 
                  output [7:0]  VGA_R,					//VGA Red
				                VGA_G,					//VGA Green
								VGA_B,					//VGA Blue
				  output        VGA_CLK,				//VGA Clock
				                VGA_SYNC_N,				//VGA Sync signal
				  			    VGA_BLANK_N,			//VGA Blank signal
								VGA_VS,					//VGA virtical sync signal	
								VGA_HS,					//VGA horizontal sync signal
				  // CY7C67200 Interface
				  inout [15:0]  OTG_DATA,						//	CY7C67200 Data bus 16 Bits
				  output [1:0]  OTG_ADDR,						//	CY7C67200 Address 2 Bits
				  output        OTG_CS_N,						//	CY7C67200 Chip Select
								OTG_RD_N,						//	CY7C67200 Write
								OTG_WR_N,						//	CY7C67200 Read
								OTG_RST_N,						//	CY7C67200 Reset
				  input			OTG_INT,						//	CY7C67200 Interrupt
				  // SDRAM Interface for Nios II Software
				  output [12:0] DRAM_ADDR,
				  output [1:0]  DRAM_BA,
				  output        DRAM_CAS_N,
				  output		DRAM_CKE,
				  output		DRAM_CS_N,
				  inout  [31:0] DRAM_DQ,
				  output  [3:0] DRAM_DQM,
				  output		DRAM_RAS_N,
				  output		DRAM_WE_N,
				  output		DRAM_CLK
					);

				logic  [1:0] to_sw_sig;			// handshake
				logic  [1:0] to_hw_sig;
				logic  [7:0] to_hw_data;		// data
				
				logic  reset;
				assign reset = ~KEY[0];

				// For debugging purpose
				assign LEDR[7:0] = {to_hw_data[7:0]};
				assign LEDG[3:0] = {to_sw_sig, to_hw_sig};
				nios_system NiosII (.clk_clk(CLOCK_50), 
											.reset_reset_n(KEY[0]), 
											.to_sw_sig_export(to_sw_sig), 
											.to_hw_sig_export(to_hw_sig),
											.to_hw_data_export(to_hw_data),
											.sdram_wire_addr(DRAM_ADDR),    //  sdram_wire.addr
											.sdram_wire_ba(DRAM_BA),      	//  .ba
											.sdram_wire_cas_n(DRAM_CAS_N),    //  .cas_n
											.sdram_wire_cke(DRAM_CKE),     	//  .cke
											.sdram_wire_cs_n(DRAM_CS_N),      //  .cs_n
											.sdram_wire_dq(DRAM_DQ),      	//  .dq
											.sdram_wire_dqm(DRAM_DQM),     	//  .dqm
											.sdram_wire_ras_n(DRAM_RAS_N),    //  .ras_n
											.sdram_wire_we_n(DRAM_WE_N),      //  .we_n
											.sdram_clk_clk(DRAM_CLK)			//  clock out to SDRAM from other PLL port
											);
				logic [9:0] hcount, vcount; 	//line counter
				logic [9:0] xcoor, ycoor;		//DrawX, DrawY signal
				IDmap id (.clk50(CLOCK_50), 
							.reset(~KEY[0]), 
							.hc(hcount), 
							.vc(vcount), 
							.xcoor(xcoor), 
							.ycoor(ycoor), 
							.to_hw_data(to_hw_data),
							.to_hw_sig(to_hw_sig),
							.to_sw_sig(to_sw_sig),
							.VGA_R(VGA_R),
							.VGA_G(VGA_G),
							.VGA_B(VGA_B)
					);
				vga_controller vgasync_instance (.Clk(CLOCK_50),
												.hs(VGA_HS), .vs(VGA_VS),      //do not invert them!  
												.pixel_clk(VGA_CLK), 
												.blank(VGA_BLANK_N),  //Active low
												.sync(VGA_SYNC_N),	//Active low
												.hcount(hcount),
												.vcount(vcount),
												.DrawX(xcoor),
												.DrawY(ycoor)
												); 


endmodule
