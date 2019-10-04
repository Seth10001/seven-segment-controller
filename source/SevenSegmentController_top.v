module SevenSegmentController_top (
	input  wire        clock,
	input  wire        resetN,
	
	input  wire [15:0] switches,
	input  wire [ 2:0] buttons,
	
	output wire [ 7:0] segmentEnableN,
	output wire [ 7:0] digitEnableN,
	output wire [ 3:0] leds
);
	
	// Define some constants for button indexes
	`define BUTTON_LEFT   0
	`define BUTTON_CENTER 1
	`define BUTTON_RIGHT  2
	
	
	// Debounce and invert active-low reset button
	wire reset;
	Debouncer resetDebouncer(
		.clock(clock),
		.in(~resetN),
		.out(reset)
	);
	
	
	// Debounce and detect edges on input buttons for changing selected digit for decimal-point control
	wire leftEdgeRising;
	wire rightEdgeRising;
	RisingEdgeDetector leftDetector(
		.clock(clock), .reset(reset),
		.in(buttons[`BUTTON_LEFT]),
		.detected(leftEdgeRising)
	);
	RisingEdgeDetector rightDetector(
		.clock(clock), .reset(reset),
		.in(buttons[`BUTTON_RIGHT]),
		.detected(rightEdgeRising)
	);
	
	// Change the current digit for decimal-point-enabling based on button inputs
	reg [1:0] currentPoint = 0;
	always @(posedge reset, posedge clock)
	begin
		if (reset)
		begin
			currentPoint <= 0;
		end
		
		else if (leftEdgeRising)
		begin
			currentPoint <= currentPoint + 1;
		end
		
		// Decrement point index (move point right) when right button has a rising edge (and left does not)
		else if (rightEdgeRising)
		begin
			currentPoint <= currentPoint - 1;
		end
	end
	
	// Display currently-selected decimal point on LEDs
	assign leds = 1 << currentPoint;
	
	
	// Debounce and detect edges on button for toggling demical-point on selected digit
	wire toggleEdgeRising;
	RisingEdgeDetector toggleDetector(
		.clock(clock), .reset(reset),
		.in(buttons[`BUTTON_CENTER]),
		.detected(toggleEdgeRising)
	);
	
	// Initialize decimal point selection to 0
	reg [3:0] pointEnable = 0;
	always @(posedge reset, posedge clock)
	begin
		// Clear all registers back to initial values
		if (reset)
		begin
			pointEnable <= 0;
		end
		
		// Toggle enabled state of selected decimal point when toggle button has a rising edge
		else if (toggleEdgeRising)
		begin
			pointEnable[currentPoint] = ~pointEnable[currentPoint];
		end
	end
	
	
	// Encode input switch data into segment and digit enable masks
	SevenSegmentController #(.NUM_DIGITS(4), .CLOCK_DIVISIONS(18)) controller(
		.clock(clock), .reset(reset),
		.data(switches), .pointEnable(pointEnable),
		.segmentEnableN(segmentEnableN), .digitEnableN(digitEnableN[3:0])
	);
	
	// Disable upper unused digits
	assign digitEnableN[7:4] = 4'b1111;
	
endmodule
