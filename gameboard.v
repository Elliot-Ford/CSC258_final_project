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

module tile_position(
  input [5:0] tile,
  output [7:0] x,
  output [6:0] y
  );

  // based on the tile number, x and y should give the screen location of that timescale
  assign x = (tile[2:0] << 2) + (tile[2:0] << 4);
  assign y = (tile[5:3] << 3) + (tile[5:3] << 2) + (tile[5:3] << 1) + tile[5:3];

endmodule

module tile_report(
  input [5:0] tile_n,
  input reg [63:0] mineMap,
  input reg [63:0] flagMap,
  input reg [63:0] stepMap,

  output reg [2:0] status // status[2] mined, status[1] flagged, status[1] stepped
  );
  integer tile_int;
  always @(*) begin: ini_status
  status = 3'b0; //initialize status to be 000
    case (tile_n)
      000000, 000001, 000010, 000011, 000100, 000101, 000110, 000111, 001000, 001001, 001010, 001011, 001100, 001101, 001110, 001111, 010000, 010001, 010010, 010011, 010100, 010101, 010110, 010111, 011000, 011001, 011010, 011011, 011100, 011101, 011110, 011111, 100000, 100001, 100010, 100011, 100100, 100101, 100110, 100111, 101000, 101001, 101010, 101011, 101100, 101101, 101110, 101111, 110000, 110001, 110010, 110011, 110100, 110101, 110110, 110111, 111000, 111001, 111010, 111011, 111100, 111101, 111110, 111111:
      begin
        tile_int = tile_n;
        status[2] = mineMap[tile_int];
        status[1] = flagMap[tile_int];
        status[0] = stepMap[tile_int];
      end
    endcase
  end
endmodule

module gameboard_shape(
  input clk,
  input load_x, load_y, reset, load_c, en_c, shape_drawn,
  input [7:0] x_in,
  input [6:0] y_in,
  output [7:0] x_out,
  output [6:0] y_out
  );

  wire en_y;
  wire reset_count;
  wire [7:0] x_origin;
  wire [6:0] y_origin;
  wire [4:0] x_count_out;
  wire [3:0] y_count_out;
  wire [5:0] tile_count_out;
  assign en_y = ~x_count_out[0] & // should increment y when x = 18
                 x_count_out[1] &
                ~x_count_out[2] &
                ~x_count_out[3] &
                 x_count_out[4];
  assign reset_count =  ~y_count_out[0] & // should reset itself when y = 13
                       ~y_count_out[1] &
                        y_count_out[2] &
                        y_count_out[3] &
                        ~x_count_out[0] & // should increment y when x = 18
                         x_count_out[1] &
                        ~x_count_out[2] &
                        ~x_count_out[3] &
                         x_count_out[4];

  assign shape_drawn = reset_count;

  assign x_out = x_origin + {2'b00, x_count_out};
  assign y_out = y_origin + {3'b00, y_count_out};

tile_position tp(
  .tile(tile_count_out),
  .x(x_origin),
  .y(y_origin)
  );

// x and y counters  19 x 14
  x_counter xc(
    .clk(clk),
    .load_x(load_x),
    .reset(reset & ~ en_y),
    .en(en_c),
    .x_in(5'b00000),
    .x_out(x_count_out)
    );

  y_counter yc(
    .clk(clk),
    .load_y(load_y),
    .reset(reset & ~ reset_count),
    .en(en_y),
    .y_in(4'b000),
    .y_out(y_count_out)
    );

  tile_counter tilec(
    .clk(clk),
    .load_tile(load_tile),
    .reset(reset),
    .en(reset_count),
    .tile_out(tile_count_out)
    );
endmodule

module x_counter(
	input clk,
	input load_x, reset, en,
	input [4:0] x_in,
	output reg [4:0] x_out
	);
	always @(posedge clk) begin
		if (!reset) begin
			x_out <= 5'b0;
      end
		else if (load_x) begin
			x_out <= x_in;
      end
		else if (en) begin
				x_out <= x_out + 1;
		end
	end
endmodule

module y_counter(
	input clk,
	input load_y, reset, en,
	input [3:0] y_in,
	output reg [3:0] y_out
	);
	always @(posedge clk) begin
		if (!reset) begin
			y_out <= 4'b0;
      end
		else if (load_y) begin
			y_out <= 0;
      end
		else if (en) begin
				y_out <= y_out + 1;
		end
	end
endmodule

module tile_counter(
	input clk,
	input load_tile, reset, en,
	output reg [5:0] tile_out
	);
	always @(posedge clk) begin
		if (!reset) begin
			tile_out <= 6'b0;
      end
		else if (en) begin
				tile_out <= tile_out + 1;
		end
    else
      tile_out <= tile_out;
	end
endmodule
