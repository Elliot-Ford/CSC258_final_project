module datapath(
	input clk,
	input resetn,
	input ld,
	input [63:0] MMin,
	input [63:0] FMin,
	input [63:0] SMin,
	input [63:0] PMin,
	input [3:0] dir,
	output win,
	output lose,
	output [63:0] MMout,
	output [63:0] FMout,
	output [63:0] SMout,
	output [63:0] PMout
	);
	wire [24:0] RD;
	wire PM_EN;
	
	map_register FM(
		.clk(clk),
		.resetn(resetn),
		.ld(ld),
		.map_in(FMin),
		.map_out(FMout));
	map_register SM(
		.clk(clk),
		.resetn(resetn),
		.ld(ld),
		.map_in(SMin),
		.map_out(SMout));
	ma_register MM(
		.clk(clk),
		.resetn(resetn),
		.ld(ld),
		.map_in(MMin),
		.map_out(MMout);

	posMap_register PM(
		.clk(clk),
		.resetn(resetn),
		.en(PM_EN),
		.dir(dir),
		.out(PMout));

	rate_divider rd0(
		.clk(clk),
		.resetn(resetn),
		.en(1'b1),
		.divider(RD));
	assign PM_EN = (RD == 25'b0) ? 1 : 0;

	endmodule

	module posMap_register(
		input clk,
		input resetn,
		input en,
    		input [3:0] dir, // 1=up, 2=right, 4=down, 8=left 
    		output [63:0] out
		);
		wire [24:0] RD;
		always @(posedge clk) begin
			if (!resetn)
				out <= 64'b1;
			else if (en) begin
				if (dir == 4'd1)
					out <= {out[7:0], out[63:8]};
				else if (dir == 4'd2) 
					out <= {out[0], out[63:1]};
				else if (dir == 4'd4)
					out <= {out[55:0], out[63:56]};
				else if (dir == 4'd8)
					out <= {out[62:0], out[63]};
			end
		end
	endmodule

	module rate_divider(
		input clk, resetn, en;
		output divider;
		always @(posedge clk)
		begin 
			if (!resetn || divider == 25'b0)
				divider <= 25'b1011111010111100000111111;
			else if (en)
				divider <= divider - 1;
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
		end 
  endmodule
