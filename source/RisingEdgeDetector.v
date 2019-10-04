/*
 * Optionally debounce and detect a rising edge on an input signal, such as a button
 *
 * @author mlewis61@gatech.edu
 * @date 2019-10-04
 *
 * 
 * @tparam     DEBOUNCE      if 1 (the default), debounces the input signal before edge-detection
 *
 * @param[in]  clock         the clock used to increment the internal counter
 * @param[in]  reset         active-high reset of edge-detection history
 * 
 * @param[in]  in            the input signal to check for edges
 * 
 * @param[out] detected      high when a rising edge is detected, low otherwise
 */
module RisingEdgeDetector #(
	parameter DEBOUNCE = 1
)(
	input  wire clock,
	input  wire reset,
	
	input  wire in,
	
	output wire detected
);
	
	// Declare an internal signal, which may be the input signal raw or after debouncing
	wire _in;
	
	generate
		// Debounce the input signal if requested
		if (DEBOUNCE == 1)
		begin
			Debouncer debouncer(
				.clock(clock),
				.in(in),
				.out(_in)
			);
		end
		
		// Otherwise, just use the input signal as-is
		else
		begin
			assign _in = in;
		end
	endgenerate
	
	
	// Detect rising edges of buttons by storing value from previous clock cycle
	reg previousIn = 0;
	always @(posedge reset, posedge clock)
	begin
		if (reset)
		begin
			previousIn <= 0;
		end
		
		else
		begin
			previousIn <= _in;
		end
	end
	
	// Raise edge signals when previous value was low and new value is high
	assign detected = ~previousIn & _in;
	
endmodule
