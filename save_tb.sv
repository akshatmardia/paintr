`timescale 1 ps / 1 ps
 /*
 * Testbench for save module
 */
module save_tb();

	logic[10:0] x, y;
	logic save_sw, CLOCK_50;
	logic [8:0] write_addr;
	logic [639:0] data, read;

	save dut(.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the CLOCK_50
	end

	initial begin
		save_sw <= 0; 	@(posedge CLOCK_50);
		save_sw <= 1; 	@(posedge CLOCK_50);

		x <= 11'd1; y <= 11'd1; repeat(2) @(posedge CLOCK_50);
		x <= 11'd2; y <= 11'd2; repeat(2) @(posedge CLOCK_50);
		x <= 11'd3; y <= 11'd3; repeat(2) @(posedge CLOCK_50);
		x <= 11'd4; y <= 11'd4; repeat(2) @(posedge CLOCK_50);
		x <= 11'd5; y <= 11'd5; repeat(2) @(posedge CLOCK_50);

		save_sw <= 0; 	@(posedge CLOCK_50);
		x <= 11'd6; y <= 11'd6; repeat(2) @(posedge CLOCK_50);
		x <= 11'd7; y <= 11'd7; repeat(2) @(posedge CLOCK_50);
		x <= 11'd8; y <= 11'd8; repeat(2) @(posedge CLOCK_50);

		$stop;
	end

endmodule // save_tb
