module gameboard_top(
    input CLOCK_50,         // On Board 50 MHz
    // Board inputs
    input [9:0] KEY,
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

    wire resetn;
    assign resetn = KEY[0];

    /*
     * Create an instance of a VGA controller
     * Define the number of colors as well as the initial background
     * image file (.MIF) for the controller
     */
    vga_adapter VGA(
      .reset(resetn),
      .clock(CLOCK_50),
      .color(color),
      .x(x),
      .y(y),
      .plot(writeEn),
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
    defparam VGA.RESOLUTION = "160X120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "gameboard.mif";






endmodule

module gameboard(
  input clk,
  input [63:0] mineMap,
  input [63:0] flagMap,
  input [63:0] stepMap
  );

endmodule

module gameboard_control(

  );
endmodule

module gameboard_datapath(
  input clk,
  input load_x, load_y, load_c, reset,
  input [7:0] x_in,
  input [6:0] y_in,
  input [2:0] color_in,
  output [7:0] x_out,
  output [6:0] y_out,
  output reg [2:0] color_out
  );
  wire [7:0] x_target;
  wire [6:0] y_target;
  assign x_target = x_in + 5'b10011; //this gives the x coordinate of right endpoints
  assign y_target = y_in + 4'b1110; //this gives the y coordinate of left endpoints
// x and y counters  19 x 14
  always @(posedge clk) begin
    if (!reset)
      color_out <= 0;
    else if (load_c)
      color_out <= color_in;
  end
  x_counter xc(
    .clk(clk),
    .load_x(load_x),
    .reset(reset),
    .x_in(x_in),
    .x_out(x_out)
    );
  y_counter yc(
    .clk(clk),
    .load_y(load_y),
    .reset(reset),
    .y_in(y_in),
    .color_in(color_in),
    .y_out(y_out),
    .color_out(color_out)
    );
endmodule

module x_counter(
	input clk,
	input load_x, reset,
	input [7:0] x_in,
	output reg [7:0] x_out
	);
	wire [7:0] x_target;
	assign x_target = x_in + 5'b10011;
	always @(posedge clk) begin
		if (!reset)
			x_out <= 0;
		else if (load_x)
			x_out <= x_in;
		else if (en == 1) begin
			if (x == x_target)
				x <= 0;
			else
				x <= x + 1;
		end
	end
endmodule
module y_counter(
	input clk,
	input load_y, reset,
	input [6:0] y_in,
	output reg [6:0] y_out
	);
	wire [6:0] y_target;
	assign y_target = y_in + 4'b1110;
	always @(posedge clk) begin
		if (!reset)
			y_out <= 0;
		else if (load_y)
			y_out <= 0;
		else if (en == 1) begin
		 	if (y == y_target)
				y <= 0;
			else
				y <= y + 1;
		end
	end
endmodule
