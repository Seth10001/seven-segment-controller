/*
 * Debounce an input signal by waiting for input to stabilize for parameterized amount of time
 * @see http://www.eecs.umich.edu/courses/eecs270/270lab/270_docs/debounce.html
 *
 * @author mlewis61@gatech.edu
 * @date 2019-10-03
 *
 * 
 * @tparam     COUNTER_WIDTH the bit width of the counter to fill at the input clock speed before changing output
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
	// At 100 MHz and default 16-bit counter, this takes approximately 655 ns
	reg [COUNTER_WIDTH-1 : 0] counter;
	always @(posedge clock)
	begin
		if (out == history[1])
		begin
			counter <= 0;
		end
		
		else
		begin
			counter <= counter + 1;
			
			if (counter == {COUNTER_WIDTH{1'b1}})
			begin
				out <= history[1];
			end
		end
	end
endmodule
