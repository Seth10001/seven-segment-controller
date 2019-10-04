/**
 * Drive a multiplexed seven-segment display system like on Digilent's Nexys A7 board
 * All of the same segments across all digits are tied to one pin, with an enable pin for each digit
 *   - In order to display different data on each digit, the controller must iteratively refresh each digit, continuously pulse-width modulating each one
 *
 * @author mlewis61@gatech.edu
 * @date 2019-10-02
 *
 *
 * @tparam     CLOCK_DIVISIONS the number of times to divide the input clock frequency by 2
 *                                 defaults to 17, or roughly 763 Hz overall and 95 Hz refresh rate per digit for a 100 MHz input clock and default 8 digits
 * @tparam     NUM_DIGITS      the number of seven-segment digits to control, defaults to 8
 * 
 * @param[in]  clock           the input clock signal, assumed to be 100 MHz for default parameters
 * @param[in]  data            the data to encode and display, with 4 bits per configured digit
 * @param[in]  pointEnable     the active-high enable mask for the decimal point in each digit
 * 
 * @param[out] segmentEnableN  the active-low enable mask for the segments on every digit
 * @param[out] digitEnableN    the active-low enable mask for which digits should display the output segments
 */
module SevenSegmentController #(
	parameter CLOCK_DIVISIONS = 17,
	parameter NUM_DIGITS      =  8
)(
	input  wire                        clock,
	input  wire                        reset,
	
	input  wire [NUM_DIGITS*4 - 1 : 0] data,
	input  wire [    NUM_DIGITS-1 : 0] pointEnable,
	
	output wire [               7 : 0] segmentEnableN,
	output wire [    NUM_DIGITS-1 : 0] digitEnableN
);
	
	// Initialize the current digit to 0
	// This doesn't really have to be this long, but no good way of getting log2 of a parameter
	reg [NUM_DIGITS-1 : 0] digit = 0;
	
	// Select the data corresponding to the current digit from the total data
	wire [3:0] currentData = data[digit * 4 +: 4];
	
	// Select the decimal-point enable bit corresponding to the current digit
	wire currentPointEnable = pointEnable[digit];
	
	
	// Divide the input clock to the configured frequency
	wire refreshClock;
	ClockDivider #(.COUNTER_WIDTH(CLOCK_DIVISIONS)) divider(
		.clock(clock), .reset(reset), .enable(~reset),
		.out(refreshClock)
	);
	
	always @(posedge reset, posedge refreshClock)
	begin
		// Reset digit to 0 if at max digit number or if module is being reset
		if (reset || digit == NUM_DIGITS-1)
		begin
			digit <= 0;
		end
		
		// Otherwise, increment the digit
		else
		begin
			digit <= digit + 1;
		end
	end
	
	
	// Encode the selected data into a seven-segment enable mask
	SevenSegmentEncoder encoder(
		.data(currentData), .pointEnable(currentPointEnable),
		.segmentEnableN(segmentEnableN)
	);
	
	
	// Create a mask representing which digits should be enabled
	reg [NUM_DIGITS-1 : 0] digitEnable;
	always @(*)
	begin
		// Turn off all digits during reset
		if (reset)
		begin
			digitEnable = 0;
		end
		
		// Otherwise, output a 1 in the bit location corresponding to the current digit
		else
		begin
			digitEnable = (1 << digit);
		end
	end
	
	// Output expected active-low version of enable mask
	assign digitEnableN = ~digitEnable;
	
endmodule
