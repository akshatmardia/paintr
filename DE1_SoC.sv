 /*
 * Top level module for the FPGA that takes the onboard resources
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 			- On board switches of the FPGA
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 */
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50,
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, V_GPIO);

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	inout [35:23] V_GPIO;

	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	wire latch;
	wire pulse;

	assign V_GPIO[27] = pulse;
	assign V_GPIO[26] = latch;

	// Clock divider code block
	logic [31:0] div_clk;
	parameter whichClock = 20;
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
	logic clkSelect;
    // assign clkSelect = CLOCK_50; // 50Hz Clock for simulation
	assign clkSelect = div_clk[whichClock]; // for board

	// Local Signals
	logic [10:0] x, y, pointX, pointY;
	logic [7:0] positionX;
	logic [7:0] positionY;
	logic reset, pixel_color;

	logic [8:0] write_addr, read_addr, addr;
	logic [639:0] data, saved_data;
	logic [10:0] load_x, load_y;
	logic color;

	// VGA buffer instantiation
	VGA_framebuffer fb (
		.clk50			(CLOCK_50),
		.reset			(1'b0),
		.x,
		.y,
		.pixel_color,
		.pixel_write	(1'b1),
		.VGA_R,
		.VGA_G,
		.VGA_B,
		.VGA_CLK,
		.VGA_HS,
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N),
		.VGA_SYNC_n		(VGA_SYNC_N));

	// Joystick driver instantiation
	joystick_driver jdriver(
    .clk(CLOCK_50),
    .data_in(V_GPIO[28]),
    .latch(latch),
    .pulse(pulse),
    .positionX(positionX),
    .positionY(positionY));

	// assigning x and y coordinates to draw depending on draw or load
	assign x = SW[9] ? load_x : pointX;
	assign y = SW[9] ? load_y : pointY;

	// JS_to_VGA instantiation
	JS_to_VGA coord (
		.clk			(clkSelect),
		.positionX,
		.positionY,
		.vga_x		(pointX),
		.vga_y		(pointY));

	// Local assignments
	assign addr = SW[9] ? read_addr : (SW[0] ? write_addr : 8'd500); // arbitrary address (after 479)
	assign pixel_color = SW[9] ? color : 1'b1;

	// RAM module instantiation
	RAM_save ram (
		.address	(addr),
		.clock		(CLOCK_50),
		.data		(data),
		.wren		(SW[0]),
		.q			(saved_data));

	// Save module instantiation
	save s (
		.CLOCK_50,
		.x,
		.y,
		.save_sw(SW[0]),
		.write_addr,
		.data);

	// Load module instantiation
	load l (
		.load_sw(SW[9]),
		.CLOCK_50,
		.load_x,
		.load_y,
		.color,
		.read_addr,
		.q(saved_data));

endmodule  // DE1_SoC
