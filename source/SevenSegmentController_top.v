module SevenSegmentController_top (
	input  wire        clock,
	input  wire        resetN,
	
	input  wire [15:0] switches,
	input  wire [ 2:0] buttons,
	
	output wire [ 7:0] segmentEnableN,
	output wire [ 7:0] digitEnableN,
	output wire [15:0] leds
);	
	
	// Define some constants for button indexes
	`define BUTTON_LEFT   0
	`define BUTTON_CENTER 1
	`define BUTTON_RIGHT  2
	
	// Debounce input buttons
	wire leftButton;
	wire rightButton;
	wire toggleButton;
	wire reset;
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
	Debouncer resetDebouncer(
		.clock(clock),
		.in(~resetN),
		.out(reset)
	);
	
	
	// Initialize decimal point selection to 0
	reg [7:0] pointEnable    = 0;
	reg [2:0] currentPoint   = 0;
	
	// Detect rising edges of buttons by storing value from previous clock cycle
	reg previousLeftButton   = 0;
	reg previousRightButton  = 0;
	reg previousToggleButton = 0;
	wire leftEdgeRising   = ~previousLeftButton   & leftButton;
	wire rightEdgeRising  = ~previousRightButton  & rightButton;
	wire toggleEdgeRising = ~previousToggleButton & toggleButton;
	
	always @(posedge reset, posedge clock)
	begin
		// Clear all registers back to initial values
		if (reset)
		begin
			pointEnable          <= 0;
			currentPoint         <= 0;
			
			previousLeftButton   <= 0;
			previousRightButton  <= 0;
			previousToggleButton <= 0;
		end
		
		else
		begin
			// Update button history values
			previousLeftButton   <= leftButton;
			previousRightButton  <= rightButton;
			previousToggleButton <= toggleButton;
			
			
			// Increment point index when left button has a rising edge
			if (leftEdgeRising)
			begin
				currentPoint <= currentPoint + 1;
			end
			
			// Decrement point index when right button has a rising edge (and left does not)
			else if (rightEdgeRising)
			begin
				currentPoint <= currentPoint - 1;
			end
			
			// Toggle enabled state of selected decimal point when toggle button has a rising edge (and the other buttons do not)
			else if (toggleEdgeRising)
			begin
				pointEnable[currentPoint] = ~pointEnable[currentPoint];
			end
		end
	end
	
	
	// Extend data provided by switches to 32 bits
	wire [31:0] data = {16'b0, switches};
	
	
	// Encode input switch data into segment and digit enable masks
	SevenSegmentController controller(
		.clock(clock), .data(data), .pointEnable(pointEnable),
		.segmentEnableN(segmentEnableN), .digitEnableN(digitEnableN)
	);
	
	
	// Display currently-selected decimal point on LEDs
	assign leds = 1 << currentPoint;
	
endmodule
