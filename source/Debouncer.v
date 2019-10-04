/*
 * Debounce an input signal by waiting for input to stabilize for parameterized amount of time
 * @see http://www.eecs.umich.edu/courses/eecs270/270lab/270_docs/debounce.html
 *
 * @author mlewis61@gatech.edu
 * @date 2019-10-03
 *
 * 
 * @tparam     COUNTER_WIDTH the bit width of the counter to fill at the input clock speed before changing output
 *                               defaults to 16, or approximately 655 ns at 100 MHz clock input
 *
 * @param[in]  clock         the clock used to increment the internal counter
 * 
 * @param[in]  in            the input signal to be debounced
 * 
 * @param[out] out           the output, debounced signal
 */
module Debouncer #(
	parameter COUNTER_WIDTH = 16
)(
	input  wire clock,
	
	input  wire in,
	
	output reg  out
);
	
	// Synchronize input to clock through shift register
	reg [1:0] history;
	always @(posedge clock)
	begin
		history = {history[0], in};
	end
	
	// Debounce input by waiting for a counter to fill with stable input before propagating to output
	reg [COUNTER_WIDTH-1 : 0] counter;
	always @(posedge clock)
	begin
		// No need to debounce if the output and the older of the history bits are the same, so reset counter
		if (out == history[1])
		begin
			counter <= 0;
		end
		
		// Otherwise, the input and output signals are different, so count up
		else
		begin
			counter <= counter + 1;
			
			// If the counter if maxed out, propagate input to output
			if (counter == {COUNTER_WIDTH{1'b1}})
			begin
				out <= history[1];
			end
		end
	end
endmodule
