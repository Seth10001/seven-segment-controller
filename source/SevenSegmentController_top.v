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
	
	
	// Debounce input buttons
	wire leftButton;
	wire rightButton;
	wire toggleButton;
	Debouncer leftDebouncer(
		.clock(clock),
		.in(buttons[`BUTTON_LEFT]),
		.out(leftButton)
	);
	Debouncer rightDebouncer(
		.clock(clock),
		.in(buttons[`BUTTON_RIGHT]),
		.out(rightButton)
	);
	Debouncer toggleDebouncer(
		.clock(clock),
		.in(buttons[`BUTTON_CENTER]),
		.out(toggleButton)
	);
	
	
	// Detect rising edges of buttons by storing value from previous clock cycle
	reg previousLeftButton   = 0;
	reg previousRightButton  = 0;
	reg previousToggleButton = 0;
	always @(posedge reset, posedge clock)
	begin
		if (reset)
		begin
			previousLeftButton   <= 0;
			previousRightButton  <= 0;
			previousToggleButton <= 0;
		end
		
		else
		begin
			previousLeftButton   <= leftButton;
			previousRightButton  <= rightButton;
			previousToggleButton <= toggleButton;
		end
	end
	
	// Raise edge signals when previous value was low and new value is high
	wire leftEdgeRising   = ~previousLeftButton   & leftButton;
	wire rightEdgeRising  = ~previousRightButton  & rightButton;
	wire toggleEdgeRising = ~previousToggleButton & toggleButton;
	
	
	// Change the current digit for decimal-point-enabling based on button inputs
	reg [1:0] currentPoint = 0;
	always @(posedge reset, posedge clock)
	begin
		if (reset)
		begin
			currentPoint <= 0;
		end
		
		else
		begin
			// Increment point index (move point left) when left button has a rising edge
			if (leftEdgeRising)
			begin
				currentPoint <= currentPoint + 1;
			end
			
			// Decrement point index (move point right) when right button has a rising edge (and left does not)
			else if (rightEdgeRising)
			begin
				currentPoint <= currentPoint - 1;
			end
		end
	end
	
	
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
		.clock(clock),
		.data(switches), .pointEnable(pointEnable),
		.segmentEnableN(segmentEnableN), .digitEnableN(digitEnableN[3:0])
	);
	
	// Disable upper unused digits
	assign digitEnableN[7:4] = 4'b1111;
	
	// Display currently-selected decimal point on LEDs
	assign leds = 1 << currentPoint;
	
endmodule
