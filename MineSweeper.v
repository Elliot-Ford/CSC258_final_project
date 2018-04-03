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
    assign resetn = SW[9];

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
    wire [63:0] flagMap;
    wire [63:0] stepMap;
    wire [63:0] posMap;

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

    datapath dp(
      .clk(CLOCK_50),
      .resetn(resetn),
      .ldMM(SW[0]),
      .ldFM(~KEY[3]),
      .ldSM(~KEY[2]),
      .MMin(64'b100000000000000000000000010101000000110000100100000000000000001),
      .dir(~KEY[1:0]),
      .win(LEDR[0]),
      .lose(LEDR[1]),
      .MMout(mineMap),
      .FMout(flagMap),
      .SMout(stepMap),
      .PMout(posMap)
      );






endmodule

module generate_mine(
  input clk, resetn, en,
  output reg [63:0] mineOut
  );
  wire [5:0] index0, index1, index2, index3, index4, index5, index6, index7;
  lfsr r0(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000000),
    .out(index0)
    );
  lfsr r1(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000001),
    .out(index1)
    );
  lfsr r2(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000010),
    .out(index2)
    );
  lfsr r3(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000011),
    .out(index3)
    );
  lfsr r4(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000100),
    .out(index4)
    );
  lfsr r5(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000101),
    .out(index5)
    );
  lfsr r6(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000110),
    .out(index6)
    );
  lfsr r7(
    .clk(clk),
    .resetn(resetn),
    .en(en),
    .init(6'b000111),
    .out(index7)
    );
  always @(posedge clk, negedge resetn)
  begin
    if (!resetn)
      mineOut <= 64'b0;
    else
      mineOut <= 64'b0;
      mineOut[index0] <= 1;
      mineOut[index1] <= 1;
      mineOut[index2] <= 1;
      mineOut[index3] <= 1;
      mineOut[index4] <= 1;
      mineOut[index5] <= 1;
      mineOut[index6] <= 1;
      mineOut[index7] <= 1;
  end
endmodule

module lfsr(
  input clk, resetn, en,
  input [5:0] init,
  output reg [5:0] out
  );
  wire feedback;
  assign feedback = ~(out[5] ^ out[4]);

  always @(posedge clk, negedge resetn)
  begin
    if (!resetn)
      out <= init;
    else if (en)
      out <= {out[4:0], feedback};
    else
      out <= out;
  end
endmodule
