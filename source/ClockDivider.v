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
	parameter COUNTER_WIDTH        = 1,
	parameter PULSE_WIDTH_MODULATE = 0
)(
	input  wire                       clock,
	input  wire                       reset,
	input  wire                       enable,
	
	input  wire [COUNTER_WIDTH-1 : 0] activeCycles,
	
	output reg                        out
);
	
	wire [COUNTER_WIDTH-1 : 0] _activeCycles;
	generate
		// If pulse-width modulation is enabled, use input as the counter target for duty-cycle control
		if (PULSE_WIDTH_MODULATE == 1)
		begin
			assign _activeCycles = activeCycles;
		end
		
		// Otherwise, use 50% duty cycle (count to half the counter total)
		else
		begin
			assign _activeCycles = {1'b1, {(COUNTER_WIDTH-1){1'b0}}};
		end
	endgenerate
	
	
	reg [COUNTER_WIDTH-1 : 0] counter = 0;
	always @(posedge reset, posedge clock)
	begin
		// Reset counter and output to 0 on reset or when disabled
		if (reset || !enable)
		begin
			counter <= 0;
			out     <= 0;
		end
		
		// When enabled, increment the counter each cycle and output high when it is less than the configured `_activeCycles`
		else if (enable)
		begin
			// Until `_activeCycles`, the output should be high
			// This provides configuration over the length of the positive duty cycle
			if (counter < _activeCycles)
			begin
				out <= 1;
			end
			
			// After, the outupt should be low
			else
			begin
				out <= 0;
			end
			
			// Increment the counter, relying on overflow for resetting
			counter <= counter + 1;
		end
	end
endmodule
