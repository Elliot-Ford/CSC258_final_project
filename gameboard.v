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
  input load_x, load_y, reset, load_c, en_c, shape_drawn,
  input [7:0] x_in,
  input [6:0] y_in,
  output [7:0] x_out,
  output [6:0] y_out
  );

  wire en_y;
  wire reset_count;
  wire [4:0] x_count_out;
  wire [3:0] y_count_out;
  assign en_y = ~x_count_out[0] & // should increment y when x = 18
                 x_count_out[1] &
                ~x_count_out[2] &
                ~x_count_out[3] &
                 x_count_out[4];
  assign reset_count =  y_count_out[0] & // should reset itself when y = 13
                       ~y_count_out[1] &
                        y_count_out[2] &
                        y_count_out[3];

  assign shape_drawn = reset_count;

  assign x_out = x_in + {3'b00, x_count_out};
  assign y_out = y_in + {3'b00, y_count_out};
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

module tile_control(
  input clk,
  input resetn,
  input go,
  input [63:0] mineMap,
  input [63:0] flagMap,
  input [63:0] stepMap,

  output reg ld_x, ld_y, ld_color, // probably don't need these
  output reg en_c,
  output reg writeEn,
  output reg [7:0] x,
  output reg [6:0] y,
  output reg [2:0] color);

  reg [5:0] current_state, next_state;

  localparam  S_CYCLE_0   = 6'd0,  S_CYCLE_1   = 6'd1,
              S_CYCLE_2   = 6'd2,  S_CYCLE_3   = 6'd3,
              S_CYCLE_4   = 6'd4,  S_CYCLE_5   = 6'd5,
              S_CYCLE_6   = 6'd6,  S_CYCLE_7   = 6'd7,
              S_CYCLE_8   = 6'd8,  S_CYCLE_9   = 6'd9,
              S_CYCLE_10  = 6'd10, S_CYCLE_11  = 6'd11,
              S_CYCLE_12  = 6'd12, S_CYCLE_13  = 6'd13,
              S_CYCLE_14  = 6'd14, S_CYCLE_15  = 6'd15,
              S_CYCLE_16  = 6'd16, S_CYCLE_17  = 6'd17,
              S_CYCLE_18  = 6'd18, S_CYCLE_19  = 6'd19,
              S_CYCLE_20  = 6'd20, S_CYCLE_21  = 6'd21,
              S_CYCLE_22  = 6'd22, S_CYCLE_23  = 6'd23,
              S_CYCLE_24  = 6'd24, S_CYCLE_25  = 6'd25,
              S_CYCLE_26  = 6'd26, S_CYCLE_27  = 6'd27,
              S_CYCLE_28  = 6'd28, S_CYCLE_29  = 6'd29,
              S_CYCLE_30  = 6'd30, S_CYCLE_31  = 6'd31,
              S_CYCLE_32  = 6'd32, S_CYCLE_33  = 6'd33,
              S_CYCLE_34  = 6'd34, S_CYCLE_35  = 6'd35,
              S_CYCLE_36  = 6'd36, S_CYCLE_37  = 6'd37,
              S_CYCLE_38  = 6'd38, S_CYCLE_39  = 6'd39,
              S_CYCLE_40  = 6'd40, S_CYCLE_41  = 6'd41,
              S_CYCLE_42  = 6'd42, S_CYCLE_43  = 6'd43,
              S_CYCLE_44  = 6'd44, S_CYCLE_45  = 6'd45,
              S_CYCLE_46  = 6'd46, S_CYCLE_47  = 6'd47,
              S_CYCLE_48  = 6'd48, S_CYCLE_49  = 6'd49,
              S_CYCLE_50  = 6'd50, S_CYCLE_51  = 6'd51,
              S_CYCLE_52  = 6'd52, S_CYCLE_53  = 6'd53,
              S_CYCLE_54  = 6'd54, S_CYCLE_55  = 6'd55,
              S_CYCLE_56  = 6'd56, S_CYCLE_57  = 6'd57,
              S_CYCLE_58  = 6'd58, S_CYCLE_59  = 6'd59,
              S_CYCLE_60  = 6'd60, S_CYCLE_61  = 6'd61,
              S_CYCLE_62  = 6'd62, S_CYCLE_63  = 6'd63;

  // Next state logic aka our state table
  always@(*)
  begin: state_table
    case (current_state)
      S_CYCLE_0: next_state = go ? S_CYCLE_1  : S_CYCLE_0;
      S_CYCLE_1: next_state = go ? S_CYCLE_2  : S_CYCLE_1;
      S_CYCLE_2: next_state = go ? S_CYCLE_3  : S_CYCLE_2;
      S_CYCLE_3: next_state = go ? S_CYCLE_4  : S_CYCLE_3;
      S_CYCLE_4: next_state = go ? S_CYCLE_5  : S_CYCLE_4;
      S_CYCLE_5: next_state = go ? S_CYCLE_6  : S_CYCLE_5;
      S_CYCLE_6: next_state = go ? S_CYCLE_7  : S_CYCLE_6;
      S_CYCLE_7: next_state = go ? S_CYCLE_8  : S_CYCLE_7;
      S_CYCLE_8: next_state = go ? S_CYCLE_9  : S_CYCLE_8;
      S_CYCLE_9: next_state = go ? S_CYCLE_10 : S_CYCLE_9;
      S_CYCLE_10:next_state = go ? S_CYCLE_11 : S_CYCLE_10;
      S_CYCLE_11:next_state = go ? S_CYCLE_12 : S_CYCLE_11;
      S_CYCLE_12:next_state = go ? S_CYCLE_13 : S_CYCLE_12;
      S_CYCLE_13:next_state = go ? S_CYCLE_14 : S_CYCLE_13;
      S_CYCLE_14:next_state = go ? S_CYCLE_15 : S_CYCLE_14;
      S_CYCLE_15:next_state = go ? S_CYCLE_16 : S_CYCLE_15;
      S_CYCLE_16:next_state = go ? S_CYCLE_17 : S_CYCLE_16;
      S_CYCLE_17:next_state = go ? S_CYCLE_18 : S_CYCLE_17;
      S_CYCLE_18:next_state = go ? S_CYCLE_19 : S_CYCLE_18;
      S_CYCLE_19:next_state = go ? S_CYCLE_20 : S_CYCLE_19;
      S_CYCLE_20:next_state = go ? S_CYCLE_21 : S_CYCLE_20;
      S_CYCLE_21:next_state = go ? S_CYCLE_22 : S_CYCLE_21;
      S_CYCLE_22:next_state = go ? S_CYCLE_23 : S_CYCLE_22;
      S_CYCLE_23:next_state = go ? S_CYCLE_24 : S_CYCLE_23;
      S_CYCLE_24:next_state = go ? S_CYCLE_25 : S_CYCLE_24;
      S_CYCLE_25:next_state = go ? S_CYCLE_26 : S_CYCLE_25;
      S_CYCLE_26:next_state = go ? S_CYCLE_27 : S_CYCLE_26;
      S_CYCLE_27:next_state = go ? S_CYCLE_28 : S_CYCLE_27;
      S_CYCLE_28:next_state = go ? S_CYCLE_29 : S_CYCLE_28;
      S_CYCLE_29:next_state = go ? S_CYCLE_30 : S_CYCLE_29;
      S_CYCLE_30:next_state = go ? S_CYCLE_31 : S_CYCLE_30;
      S_CYCLE_31:next_state = go ? S_CYCLE_32 : S_CYCLE_31;
      S_CYCLE_32:next_state = go ? S_CYCLE_33 : S_CYCLE_32;
      S_CYCLE_33:next_state = go ? S_CYCLE_34 : S_CYCLE_33;
      S_CYCLE_34:next_state = go ? S_CYCLE_35 : S_CYCLE_34;
      S_CYCLE_35:next_state = go ? S_CYCLE_36 : S_CYCLE_35;
      S_CYCLE_36:next_state = go ? S_CYCLE_37 : S_CYCLE_36;
      S_CYCLE_37:next_state = go ? S_CYCLE_38 : S_CYCLE_37;
      S_CYCLE_38:next_state = go ? S_CYCLE_39 : S_CYCLE_38;
      S_CYCLE_39:next_state = go ? S_CYCLE_40 : S_CYCLE_39;
      S_CYCLE_40:next_state = go ? S_CYCLE_41 : S_CYCLE_40;
      S_CYCLE_41:next_state = go ? S_CYCLE_42 : S_CYCLE_41;
      S_CYCLE_42:next_state = go ? S_CYCLE_43 : S_CYCLE_42;
      S_CYCLE_43:next_state = go ? S_CYCLE_44 : S_CYCLE_43;
      S_CYCLE_44:next_state = go ? S_CYCLE_45 : S_CYCLE_44;
      S_CYCLE_45:next_state = go ? S_CYCLE_46 : S_CYCLE_45;
      S_CYCLE_46:next_state = go ? S_CYCLE_47 : S_CYCLE_46;
      S_CYCLE_47:next_state = go ? S_CYCLE_48 : S_CYCLE_47;
      S_CYCLE_48:next_state = go ? S_CYCLE_49 : S_CYCLE_48;
      S_CYCLE_49:next_state = go ? S_CYCLE_50 : S_CYCLE_49;
      S_CYCLE_50:next_state = go ? S_CYCLE_51 : S_CYCLE_50;
      S_CYCLE_51:next_state = go ? S_CYCLE_52 : S_CYCLE_51;
      S_CYCLE_52:next_state = go ? S_CYCLE_53 : S_CYCLE_52;
      S_CYCLE_53:next_state = go ? S_CYCLE_54 : S_CYCLE_53;
      S_CYCLE_54:next_state = go ? S_CYCLE_55 : S_CYCLE_54;
      S_CYCLE_55:next_state = go ? S_CYCLE_56 : S_CYCLE_55;
      S_CYCLE_56:next_state = go ? S_CYCLE_57 : S_CYCLE_56;
      S_CYCLE_57:next_state = go ? S_CYCLE_58 : S_CYCLE_57;
      S_CYCLE_58:next_state = go ? S_CYCLE_59 : S_CYCLE_58;
      S_CYCLE_59:next_state = go ? S_CYCLE_60 : S_CYCLE_59;
      S_CYCLE_60:next_state = go ? S_CYCLE_61 : S_CYCLE_60;
      S_CYCLE_61:next_state = go ? S_CYCLE_62 : S_CYCLE_61;
      S_CYCLE_62:next_state = go ? S_CYCLE_63 : S_CYCLE_62;
      S_CYCLE_63:next_state = go ? S_CYCLE_0 : S_CYCLE_63;

      default: next_state = S_CYCLE_0;
    endcase
  end

  // Output logic aka all of our datapath control signals
  always @(*)
  begin: enable_signals
    // By default make all our signals 0
    ld_x = 1'b0;
    ld_y = 1'b0;
    x = 8'b00000000;
    y = 7'b0000000;
    color = 3'b000;
		en_c = 1'b0;
    ld_color = 1'b0;
    writeEn = 1'b0;

    case (current_state)
      S_CYCLE_0: begin
        x = 8'b00000000;
        y = 7'b0000000;
        en_c = 1'b1;
        if(flagMap[0]) begin
          color = 3'b010;
        end
      end
      S_CYCLE_1: begin
      end
      S_CYCLE_2: begin
      end
      S_CYCLE_3: begin
      end
      S_CYCLE_4: begin
      end
      S_CYCLE_5: begin
      end
      S_CYCLE_6: begin
      end
      S_CYCLE_7: begin
      end
      S_CYCLE_8: begin
      end
      S_CYCLE_9: begin
      end
      S_CYCLE_10: begin
      end
      S_CYCLE_11: begin
      end
      S_CYCLE_12: begin
      end
      S_CYCLE_13: begin
      end
      S_CYCLE_14: begin
      end
      S_CYCLE_15: begin
      end
      S_CYCLE_16: begin
      end
      S_CYCLE_17: begin
      end
      S_CYCLE_18: begin
      end
      S_CYCLE_19: begin
      end
      S_CYCLE_20: begin
      end
      S_CYCLE_21: begin
      end
      S_CYCLE_22: begin
      end
      S_CYCLE_23: begin
      end
      S_CYCLE_24: begin
      end
      S_CYCLE_25: begin
      end
      S_CYCLE_26: begin
      end
      S_CYCLE_27: begin
      end
      S_CYCLE_28: begin
      end
      S_CYCLE_29: begin
      end
      S_CYCLE_30: begin
      end
      S_CYCLE_31: begin
      end
      S_CYCLE_32: begin
      end
      S_CYCLE_33: begin
      end
      S_CYCLE_34: begin
      end
      S_CYCLE_35: begin
      end
      S_CYCLE_36: begin
      end
      S_CYCLE_37: begin
      end
      S_CYCLE_38: begin
      end
      S_CYCLE_39: begin
      end
      S_CYCLE_40: begin
      end
      S_CYCLE_41: begin
      end
      S_CYCLE_42: begin
      end
      S_CYCLE_43: begin
      end
      S_CYCLE_44: begin
      end
      S_CYCLE_45: begin
      end
      S_CYCLE_46: begin
      end
      S_CYCLE_47: begin
      end
      S_CYCLE_48: begin
      end
      S_CYCLE_49: begin
      end
      S_CYCLE_50: begin
      end
      S_CYCLE_51: begin
      end
      S_CYCLE_52: begin
      end
      S_CYCLE_53: begin
      end
      S_CYCLE_54: begin
      end S_CYCLE_55: begin
      end
      S_CYCLE_56: begin
      end
      S_CYCLE_57: begin
      end
      S_CYCLE_58: begin
      end
      S_CYCLE_59: begin
      end
      S_CYCLE_60: begin
      end
      S_CYCLE_61: begin
      end
      S_CYCLE_62: begin
      end
      S_CYCLE_63: begin
      end
    endcase
  end

  always@(posedge clk)
  begin: state_FFs
    if(!resetn)
      current_state <= S_LOAD;
    else
      current_state <= next_state;
  end
  endmodule
