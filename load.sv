/*
* Load module for drawing RAM data onto VGA Display
*
* Inputs: load_sw, CLOCK_50, q
*
* Outputs: load_x, load_y, color, read_addr
*/
module load (load_sw, CLOCK_50, load_x, load_y, color, read_addr, q);

    // Port Definitions
	input logic load_sw, CLOCK_50;
	output logic [10:0] load_x, load_y;
	output logic color;
	output logic [8:0] read_addr;
	input logic [639:0] q;

	// Placeholder for output data bus
	logic [8:0] y_count;
	logic [9:0] x_count;
	logic [639:0] data;

	// Placeholder for output data bus
	assign data = q;

	// Logic to iterate through entire VGA display, one pixel every clock cycle
	always_ff @(posedge CLOCK_50) begin
		if (~load_sw) begin
			y_count <= 9'd0;
			x_count <= 10'd0;
			read_addr <= 8'd0;
		end
		else begin
		    // if statment to iterate through all addresses in RAM
			if (y_count != 9'd479) begin
			    // if statement to iterate through every bit in 640 bit word present at each address
				if (x_count != 10'd639) begin
					load_x <= x_count;
					load_y <= y_count;
					read_addr <= y_count;
					color <= data[x_count];
					x_count <= x_count + 10'd1;
				end
				// resetting x_count and incrementing y_count if all bits at specific address are done
				if (x_count == 10'd639) begin
					y_count <= y_count + 10'd1;
					x_count <= 10'd0;
				end
			end
		end
	end

endmodule // load
