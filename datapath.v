module datapath(
	input clk,
	input resetn,
	input [63:0] MMin,
	input [63:0] FMin,
	input [63:0] SMin,
	input [63:0] PMin,
	input left,
	input right,
	input up,
	input down,
	output win,
	output lose,
	output [63:0] MMout,
	output [63:0] FMout,
	output [63:0] SMout,
	output [63:0] PMout
	);

	endmodule

	module posMap_register(
		input clk,
		input resetn,
		input d,
		input en,
    input dir,
    output [63:0] out
		);

	endmodule

	module map_register(
		input clk,
		input resetn,
		input ld,
		input en,
		input [63:0] map_in,
		output [63:0] map_out
		);

  endmodule
