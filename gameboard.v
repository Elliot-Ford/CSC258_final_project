module gameboard(
  input clk,
  input resetn,
  input [63:0] mineMap,
  input [63:0] flagMap,
  input [63:0] stepMap,
  input [63:0] posMap,
  output [7:0] x,
  output [6:0] y,
  output [2:0] color,
  output [0:0] en
  );

  wire [3:0] status;
  wire [5:0] tile_n;
  wire [4:0] x_count;
  wire [3:0] y_count;
  assign en = 1'b1;
  // assign color = status;
  tile_report tr(
    .tile_n(tile_n),
    .mineMap(mineMap),
    .flagMap(flagMap),
    .stepMap(stepMap),
    .posMap(posMap),
    .status(status)
    );

    pixel_color pc(
      .status(status),
      .x(x_count),
      .y(y_count),
      .color(color)
      );

    gameboard_shape gs(
      .clk(clk),
      .reset(resetn),
      .x_count(x_count),
      .y_count(y_count),
      .x_out(x),
      .y_out(y),
      .tile_n(tile_n),
      .en_c(1'b1)
      );
endmodule

module pixel_color(
  input [3:0] status,
  input [4:0] x,
  input [3:0] y,
  output reg[2:0] color
  );
  
  always @(*)
  begin
    if(status[3] == 1'b1 && ((x < 5 || x > 13) && (y == 0 || y == 13)) || ((x == 0 || x == 18)&& (y < 5 || y > 9)))
			color = 3'b011;
		else 
			color = 3'b000;
    else if (status[0] == 1'b1 && status[2] == 1'b1) // this isn't working yet
      if((x == 9 && (y == 2 || y == 12)) && 
			  ((x == 5 || x == 13 || (x > 6 && x < 12)) && (y == 3 || y == 11)) &&
			   (x > 5 && x < 13 && (y == 4 || y == 10)) &&
				(x > 4 && x < 7 && x > 9 && x < 14 && (y == 5 || y == 6)) &&
				(x > 4 && x < 14 && (y == 9 || y == 8)) &&
				(x > 3 && x < 15 && y == 7))
				color = 3'b000;
			else
				color = 3'b111;
    else if (status[0] == 1'b1)
      color = 3'b010;
    else if (status[1] == 1'b1)
		if((x > 7 && x < 11 && y == 3) || 
		   (x > 6 && x < 11 && y == 4) || 
			(x > 5 && x < 11 && y == 5) || 
			(x > 5 && x < 10 && y == 6) || 
			(x > 5 && x < 9 && y == 7))
			color = 3'b100;
		else if(x == 10 && y > 5 && y < 12)
			color = 3'b111;
		else
			color = 3'b000;
    else
      color = 3'b000;
  end

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
  input [63:0] mineMap,
  input [63:0] flagMap,
  input [63:0] stepMap,
  input [63:0] posMap,

  output [3:0] status // status[3] position, status[2] mined, status[1] flagged, status[1] stepped
  );

  
  assign status = {posMap[tile_n], mineMap[tile_n], flagMap[tile_n], stepMap[tile_n]};
endmodule

module gameboard_shape(
  input clk,
  input en_c, reset,
  output [4:0] x_count,
  output [3:0] y_count,
  output [7:0] x_out,
  output [6:0] y_out,
  output [5:0] tile_n
  );

  wire en_y;
  wire reset_count;
  wire [7:0] x_origin;
  wire [6:0] y_origin;
  assign en_y = ~x_count[0] & // should increment y when x = 18
                 x_count[1] &
                ~x_count[2] &
                ~x_count[3] &
                 x_count[4];
  assign reset_count =  y_count[0] & // should reset itself when y = 13
                       ~y_count[1] &
                        y_count[2] &
                        y_count[3] &
                        ~x_count[0] & // should increment y when x = 18
                         x_count[1] &
                        ~x_count[2] &
                        ~x_count[3] &
                         x_count[4];

  assign x_out = x_origin + {2'b00, x_count};
  assign y_out = y_origin + {3'b00, y_count};

tile_position tp(
  .tile(tile_n),
  .x(x_origin),
  .y(y_origin)
  );

// x and y counters  19 x 14
  x_counter xc(
    .clk(clk),
    .reset(reset & ~ en_y),
    .en(en_c),
    .x_in(5'b00000),
    .x_out(x_count)
    );

  y_counter yc(
    .clk(clk),
    .reset(reset & ~ reset_count),
    .en(en_y),
    .y_in(4'b000),
    .y_out(y_count)
    );

  tile_counter tilec(
    .clk(clk),
    .reset(reset),
    .en(reset_count),
    .tile_out(tile_n)
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
				x_out <= x_out + 1'b1;
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
				y_out <= y_out + 1'b1;;
		end
	end
endmodule

module tile_counter(
	input clk,
	input reset, en,
	output reg [5:0] tile_out
	);
	always @(posedge clk) begin
		if (!reset)
			tile_out <= 6'b0;
		else if (en)
				tile_out <= tile_out + 1'b1;
  end
endmodule
