/*
* Save module for writing pixel data from joystick to RAM simultaneously as its drawn to VGA Display
*
* Inputs: x, y, CLOCK_50, save_sw
*
* Outputs: write_addr, data
*/
module save (CLOCK_50, x, y, save_sw, write_addr, data);

    // Port definitions
	input logic [10:0] x, y;
	input logic save_sw, CLOCK_50;
	output logic [8:0] write_addr;
	output logic [639:0] data;

	// Logic to write data to the proper indexes within the RAM module after recieving data from joystick
	// and when save_sw is set to high
	always_ff @(posedge CLOCK_50) begin
	    // Stay in init state while save_sw is off
		if (~save_sw) begin
			write_addr <= 9'd0;
			data <= 640'd0;
		end else begin
		    // Sets data output to zero for proper indexing
			if (data != 640'd0) begin
				data <= 640'd0;
			end
			// If correct address then send color value to properly indexed bit in word
			if (write_addr == y) begin
				data <= data | (1'b1 << x);
			end
			write_addr <= y;
		end
	end

endmodule // save
