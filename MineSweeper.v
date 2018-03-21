module MineSweeper(
    input CLOCK_50,         // On Board 50 MHz
    // Board inputs
    input [9:0] KEY,
    input [9:0] SW,
	 output[9:0] LEDR,
    // The ports below are for the VGA output.
    output VGA_CLK,         // VGA Clock
    output VGA_HS,          // VGA H_SYNC
    output VGA_VS,          // VGA V_SYNC
    output VGA_BLANK_N,     // VGA BLANK
    output VGA_SYNC_N,      // VGA SYNC
    output [9:0] VGA_R,     // VGA Red[9:0]
    output [9:0] VGA_G,     // VGA Green[9:0]
    output [9:0] VGA_B     // VGA Blue[9:0]
  );

    wire en;
    wire [7:0] x;
 	  wire [6:0] y;
 	  wire [2:0] color;
    wire resetn;
    assign resetn = KEY[0];

    /*
     * Create an instance of a VGA controller
     * Define the number of colors as well as the initial background
     * image file (.MIF) for the controller
     */
    vga_adapter VGA(
      .resetn(resetn),
      .clock(CLOCK_50),
      .colour(color),
      .x(x),
      .y(y),
      .plot(en),
      // Signals for the DAC to drive the monitor
      .VGA_R(VGA_R),
      .VGA_G(VGA_G),
      .VGA_B(VGA_B),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_BLANK(VGA_BLANK_N),
      .VGA_SYNC(VGA_SYNC_N),
      .VGA_CLK(VGA_CLK)
    );
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "gameboard.mif";

    wire [63:0] mineMap;
	 wire clk_mineMap;
 	 assign LEDR[0] = clk_mineMap;
	 
    wire [63:0] flagMap;
	 wire clk_flagMap;
	 assign LEDR[1] = clk_flagMap;

	 
    wire [63:0] stepMap;
	 wire clk_stepMap;
	 assign LEDR[2] = clk_stepMap;

	 
    wire [63:0] posMap;
	 wire clk_posMap;
	 assign LEDR[3] = clk_posMap;

	 

	 //assign color = SW[9:7];
	 
    gameboard gm(
      .clk(CLOCK_50),
      .resetn(resetn),
      .mineMap(mineMap),
      .flagMap(flagMap),
      .stepMap(stepMap),
      .posMap(posMap),
      .x(x),
      .y(y),
      .color(color),
      .en(en)
      );
		
	select_map sm(
		.select(SW[1:0]),
		.in(~KEY[1]),
		.a(clk_mineMap),
		.b(clk_flagMap),
		.c(clk_stepMap),
		.d(clk_posMap)
		);
	
	map_shift_reg mineMap_reg(
		.d(SW[9]),
		.en(1'b1),
		.resetn(resetn),
		.clk(clk_mineMap),
		.out(mineMap)
		);
		
	map_shift_reg flagMap_reg(
		.d(SW[9]),
		.en(1'b1),
		.resetn(resetn),
		.clk(clk_flagMap),
		.out(flagMap)
		);
		
	map_shift_reg stepMap_reg(
		.d(SW[9]),
		.en(1'b1),
		.resetn(resetn),
		.clk(clk_stepMap),
		.out(stepMap)
		);
		
	map_shift_reg posMap_reg(
		.d(SW[9]),
		.en(1'b1),
		.resetn(resetn),
		.clk(clk_posMap),
		.out(posMap)
		);
		
	
		



endmodule

module select_map(
		input [1:0]select,
		input in,
		output reg a, b, c, d
		);
	
	always @(*)
		begin 
			
			case(select)
				3'b00 : begin
						a = in;
						b = 1'b0;
						c = 1'b0;
						d = 1'b0;
					end
				3'b01 : begin
						a = 1'b0;
						b = in;
						c = 1'b0;
						d = 1'b0;
					end
				3'b10 : begin
						a = 1'b0;
						b = 1'b0;
						c = in;
						d = 1'b0;
					end	
				3'b11 : begin
						a = 1'b0;
						b = 1'b0;
						c = 1'b0;
						d = in;	
					end
			endcase
		end
		
endmodule

module map_shift_reg(
		input d,
		input en,
		input resetn,
		input clk,
		output reg [63:0] out
);

	always @ (posedge clk, negedge resetn)
		if(!resetn)
			out <= 64'b0;
		else begin
			if (en)
				out <= {out[62:0],d};
			else
				out <= out;
		end

endmodule
