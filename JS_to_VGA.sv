 /*
 * Module to translate joystick coordinates to VGA coordinates
 */

module JS_to_VGA (clk, positionX, positionY, vga_x, vga_y);

	input logic clk;
	input logic [7:0] positionX, positionY;
    output logic [10:0] vga_x, vga_y;

	// Update VGA coordinates based on joystick position
	always_ff @(posedge clk) begin
		if (positionX <= 8'b00110000) begin
			vga_x <= vga_x;
		end else if (positionX[7] == 1) begin
			// Negative X direction (left)
			vga_x <= vga_x - 1'b1;
		end else begin
			// Positive X direction (right)
			vga_x <= vga_x + 1'b1;
		end

		if (positionY <= 8'b00110000) begin
			vga_y <= vga_y;
		end else if (positionY[7] == 1) begin
			// Negative Y direction (down)
			vga_y <= vga_y + 1'b1;
		end else begin
			// Positive Y direction (up)
			vga_y <= vga_y - 1'b1;
		end
	end

endmodule
