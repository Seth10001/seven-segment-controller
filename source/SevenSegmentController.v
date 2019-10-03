/**
 * Drive a multiplexed seven-segment display system like on Digilent's Nexys A7 board
 * All of the same segments across all digits are tied to one pin, with an enable pin for each digit
 *   - In order to display different data on each digit, the controller must iteratively refresh each digit, continuously pulse-width modulating each one
 *
 * @author mlewis61@gatech.edu
 * @date 2019-10-02
 *
 * 
 * @param[in]  clock           the input clock signal, assumed to be 100 MHz for default parameters
 * @param[in]  data            the data to encode and display
 * @param[in]  pointEnable     the active-high enable mask for the decimal point in each digit
 * 
 * @param[out] segmentEnableN  the active-low enable mask for the segments on every digit
 * @param[out] digitEnableN    the active-low enable mask for which digits should display the output segments
 */
module SevenSegmentController #(
	parameter CLOCK_DIVISIONS = 17
)(
	input  wire        clock,
	
	input  wire [31:0] data,
	input  wire [ 7:0] pointEnable,
	
	output wire [ 7:0] segmentEnableN,
	output wire [ 7:0] digitEnableN
);
	
	// Initialize the current digit to 0
	reg [2:0] digit = 3'b0;
	
	// Select the data corresponding to the current digit from the total data
	wire [3:0] currentData = data[digit * 4 +: 4];
	
	// Select the decimal-point enable bit corresponding to the current digit
	wire currentPointEnable = pointEnable[digit];
	
	
	// For default parameters, divide the 100 MHz input clock by 2^17, for an output of roughly 763 Hz
	// Note that each clock cycle changes which digit (of 8) is active, so the refresh rate for a single digit is roughly 95 Hz
	wire refreshClock;
	ClockDivider #(.DIVISIONS(CLOCK_DIVISIONS)) divider(
		.inClock(clock),
		.outClock(refreshClock)
	);
	
	// Increment the digit on a clock edge, relying on overflow to reset
	always @(posedge refreshClock)
	begin
		digit <= digit + 1;
	end
	
	
	// Encode the selected data into a seven-segment enable mask
	SevenSegmentEncoder encoder(
		.data(currentData), .pointEnable(currentPointEnable),
		.segmentEnableN(segmentEnableN)
	);
	
	// Create an active-low enable mask for which digit is active
	assign digitEnableN = ~(1 << digit);
	
endmodule
