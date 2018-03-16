// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire resetn;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	wire original_x;
	reg [7:0] x_in;

	// wires for controller output:
	wire ld_x, ld_y, ld_alu_x, ld_alu_y, select_alu_a;



	// register for X & wire for this register
	assign original_x = {1'b0, SW[6:0]};
	always @(posedge CLOCK_50) begin
	if (!resetn)
		x_in <= 8'b00000000;
	else
		x_in <= original_x;
	end
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.


    // Instansiate datapath
	// datapath d0(...);
	datapath d0(
		.clk(CLOCK_50),
		.load_x(ld_x),
		.load_y(ld_y),
		.ld_alu_x(ld_alu_x),
		.ld_alu_y(ld_alu_y),
		.select_alu_a(select_alu_a),
		.reset(resetn),
		.x_in(x_in),
		.y_in(SW[6:0]),
		.color_in(SW[9:7]),
		.x_out(x),
		.y_out(y),
		.color_out(colour));
    // Instansiate FSM control
    // control c0(...);
    	control c0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(~KEY[1]),
		.loadInX(~KEY[3]),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_alu_x(ld_alu_x),
		.ld_alu_y(ld_alu_y),
		.select_alu_a(select_alu_a),
		.plot(writeEn));
endmodule

module control(
	input clk, resetn, go, loadInX,
	output reg ld_x, ld_y,
	output reg ld_alu_x, ld_alu_y, select_alu_a,
	output reg plot
	);
	reg [4:0] current_state, next_state;

    	localparam	S_LOAD          = 5'd0,
		  	S_LOAD_WAIT     = 5'd1,
                  	S_CYCLE_0       = 5'd2,
			S_CYCLE_0_WAIT  = 5'd3,
                  	S_CYCLE_1       = 5'd4,
                  	S_CYCLE_2       = 5'd5,
                  	S_CYCLE_3       = 5'd6,
                  	S_CYCLE_4       = 5'd7,
		  	S_CYCLE_5	= 5'd8,
                  	S_CYCLE_6       = 5'd9,
                  	S_CYCLE_7       = 5'd10,
                  	S_CYCLE_8       = 5'd11,
                  	S_CYCLE_9       = 5'd12,
                  	S_CYCLE_10      = 5'd13,
			S_CYCLE_11	= 5'd14,
			S_CYCLE_12      = 5'd15,
			S_CYCLE_13	= 5'd16,
			S_CYCLE_14      = 5'd17,
			S_CYCLE_15      = 5'd18,
			S_CYCLE_16	= 5'd19,
			S_CYCLE_17      = 5'd20,
			S_CYCLE_18      = 5'd21;
			//S_CYCLE_19	= 5'd22;

	// Next state logic aka our state table
	always@(*)
	begin: state_table
		case (current_state)
		    S_LOAD: next_state = loadInX ? S_LOAD_WAIT : S_LOAD; // Loop in current state until value is input
		    S_LOAD_WAIT: next_state = loadInX ? S_LOAD_WAIT : S_CYCLE_0; // Loop in current state until loadInX signal goes low
		    S_CYCLE_0: next_state = go ? S_CYCLE_0_WAIT : S_CYCLE_0; // Loop in current state until go button is pressed
		    S_CYCLE_0_WAIT: next_state = go ? S_CYCLE_0_WAIT : S_CYCLE_1; // Loop in current state until go signal goes low
		    S_CYCLE_1: next_state = S_CYCLE_2;
		    S_CYCLE_2: next_state = S_CYCLE_3;
		    S_CYCLE_3: next_state = S_CYCLE_4;
		    S_CYCLE_4: next_state = S_CYCLE_5;
		    S_CYCLE_5: next_state = S_CYCLE_6;
		    S_CYCLE_6: next_state = S_CYCLE_7;
		    S_CYCLE_7: next_state = S_CYCLE_8;
		    S_CYCLE_8: next_state = S_CYCLE_9;
		    S_CYCLE_9: next_state = S_CYCLE_10;
		    S_CYCLE_10: next_state = S_CYCLE_11;
		    S_CYCLE_11: next_state = S_CYCLE_12;
		    S_CYCLE_12: next_state = S_CYCLE_13;
		    S_CYCLE_13: next_state = S_CYCLE_14;
		    S_CYCLE_14: next_state = S_CYCLE_15;
		    S_CYCLE_15: next_state = S_CYCLE_16;
		    S_CYCLE_16: next_state = S_CYCLE_17;
		    S_CYCLE_17: next_state = S_CYCLE_18;
		    S_CYCLE_18: next_state = S_LOAD; // After 16 plots, start over
		    //S_CYCLE_19: next_state = S_LOAD;
		    default: next_state = S_LOAD;
		endcase
	end // state_table

	//Oututput logic aka all of our datapath control signals
	always @(*)
	begin: enable_signals
        // By default make all our signals 0
	ld_x = 0;
	ld_y = 0;
	ld_alu_x = 0;
	ld_alu_y = 0;
	select_alu_a = 0;
	plot = 0;
		case (current_state)
			S_LOAD: begin
				ld_x = 1;
				ld_y = 1;
			end
			S_CYCLE_0, S_CYCLE_1, S_CYCLE_2,
			S_CYCLE_5, S_CYCLE_6, S_CYCLE_7,
			S_CYCLE_10, S_CYCLE_11, S_CYCLE_12,
			S_CYCLE_15, S_CYCLE_16, S_CYCLE_17: begin
				ld_alu_x = 1;
				ld_x = 1;
				select_alu_a = 0;
				plot = 1;
			end
			S_CYCLE_3, S_CYCLE_8, S_CYCLE_13, S_CYCLE_18: begin
				ld_alu_x = 0;
				ld_alu_y = 0;
				ld_x = 1;
				ld_y = 0;
				select_alu_a = 1;
				plot = 1;
			end
			S_CYCLE_4, S_CYCLE_9, S_CYCLE_14: begin
				ld_alu_x = 0;
				ld_alu_y = 1;
				ld_x = 0;
				ld_y = 1;
				select_alu_a = 0;
				plot = 1;
			end
		endcase
	end //enable signals
	//current state registers
	always @(posedge clk)
	begin: state_FFs
		if (!resetn)
			current_state <= S_LOAD;
		else
			current_state <= next_state;
	end //state_FFs
endmodule

module datapath_counter(
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
module datapath(
	input clk,
	input load_x, load_y, ld_alu_x, ld_alu_y, select_alu_a, reset,
	input [7:0] x_in,
	input [6:0] y_in,
	input [2:0] color_in,
	output reg [7:0] x_out,
	output reg [6:0] y_out,
	output reg [2:0] color_out);

	reg [6:0] alu_out;
	reg [6:0] alu_a;

	// loading
	always @(posedge clk) begin
		if (!reset) begin
			x_out <= 0;
			y_out <= 0;
			color_out <= 0;
		end
		else begin
		if (load_x)
			x_out[7] <= 0;
			x_out[6:0] <= ld_alu_x ? alu_out : x_in[6:0];
		if (load_y)
			y_out <= ld_alu_y ? alu_out : y_in;
			color_out <= color_in;
		end
	end

	// alu_a input multiplexer
	always @(*)
	begin
		case(select_alu_a)
			0: alu_a = x_out[6:0];
			1: alu_a = y_out;
		endcase
	end
	// The ALU
	always @(*)
	begin: ALU
		alu_out <= alu_a + 1;
	end
endmodule
