module datapath(
	input clk,
	input resetn,
	input ldMM,
  input ldMMtoSM,
  input ldFM,
  input ldSM,
	input [63:0] MMin,
	input [1:0] dir,
	output win,
	output lose,
	output [63:0] MMout,
	output [63:0] FMout,
	output [63:0] SMout,
	output [63:0] PMout
	);
	wire [24:0] RD;
	wire PM_EN;

	map_register FM(     // Flag Map
		.clk(~(win | lose) && ldFM),
		.resetn(resetn),
		.ld(1'b1),
		//.map_in(64'b10),
		.map_in(PMout ^ FMout),
		.map_out(FMout));
	map_register SM(     // Step Map
		.clk(~(win | lose) && ldSM && (((PMout | SMout) & FMout) == 64'b0)),
		.resetn(resetn),
		.ld(1'b1),
		//.map_in(64'b1),
		.map_in(~ldMMtoSM * (PMout | SMout) | ldMMtoSM * (MMout)),
		.map_out(SMout));
	map_register MM(      // Mine Map
		.clk(clk),
		.resetn(resetn),
		.ld(ldMM),
		.map_in(MMin),
		.map_out(MMout));

//	posMap_register PM(  // Postion Map
//		.clk(clk),
//		.resetn(resetn),
//		.dir(dir),
//		.out(PMout));

	posMap_register PM(  // Postion Map
		.clk(~(win | lose) && PM_EN),
		.resetn(resetn),
		.en(dir),
		.out(PMout));

//	map_shift_reg posMap_reg(
//	 	.d(dir[0]),
//	 	.en(1'b1),
//	 	.resetn(resetn),
//	 	.clk(dir[1]),
//	 	.out(PMout)
//	 	);

	rate_divider rd0(  // Rate divider for Postion Map
		.clk(clk),
		.resetn(resetn),
		.en(~(win | lose) && 1'b1),
		.clk_out(PM_EN));

  assign win = (MMout == FMout) ? 1'b1 : 1'b0;
  assign lose = ((MMout & SMout) != 64'b0) ? 1'b1 : 1'b0;
endmodule

module posMap_register(
	input clk,
	input resetn,
	input [1:0] en, // 1=up, 2=right, 4=down, 8=left
	output reg [63:0] out
	);
	always @ (posedge clk, negedge resetn)
		if(!resetn)
			out <= 64'b1;
		else begin
			if (en[0])	// right
				out <= {out[62:0],out[63]};
			else if (en[1]) // left
				out <= {out[0], out[63:1]};
			else
				out <= out;
		end
endmodule

module rate_divider(
	input clk, resetn, en,
	output reg clk_out);

	reg [23:0] divider;
	always @(posedge clk)
	begin
		if (!resetn || divider == 24'b0) begin
			divider <= 24'b101111101011110000011111;
			clk_out <= 1'b1;
			end
		else begin
			divider <= divider - 1'b1;
			clk_out <= 1'b0;
		end

	end
endmodule

module map_register(
	input clk,
	input resetn,
	input ld,
	input [63:0] map_in,
	output reg [63:0] map_out
	);
	always @(posedge clk) begin
		if (!resetn)
			map_out <= 64'b0;
		else if (ld)
			map_out <= map_in;
		else
			map_out <= map_out;
	end
endmodule
