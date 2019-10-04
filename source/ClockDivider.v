/**
 * Divide an input clock frequency by a parameterized power of 2
 * This divider does not attempt to preserve the duty cycle of the input clock; the output will have a 50% duty cycle regardless of input
 *
 * @author mlewis61@gatech.edu
 * @date 2019-10-02
 *
 *
 * @tparam     DIVISIONS the number of times to divide the input clock by 2, defaulting to 1
 * 
 * @param[in]  inClock   the clock signal to divide
 * 
 * @param[out] outClock  the divided clock signal
 */
module ClockDivider #(
	parameter DIVISIONS = 1
)(
	input wire inClock,
	
	output wire outClock
);
	
	// Zero out all clocks initially
	reg [DIVISIONS : 0] clocks = {(DIVISIONS + 1){1'b0}};
	
	// Ease generation by tying the lowest clock bit to the input signal
	always @(*)
	begin
		clocks[0] = inClock;
	end
	
	// For each clock division requested, use one clock's positive edge to flip the next clock
	// This results in a division in frequency by 2 for each division requested
	genvar index;
	generate
		for (index = 0; index < DIVISIONS; index = index+1)
		begin
			always @(posedge clocks[index])
			begin
				clocks[index+1] <= ~clocks[index+1];
			end
		end
	endgenerate
	
	// Output the highest-bit (lowest-frequency) clock
	assign outClock = clocks[DIVISIONS];
	
endmodule
