module SevenSegmentController_top (
	input  wire        clock,
	input  wire [15:0] switches,
	
	output wire [ 7:0] segmentEnableN,
	output wire [ 7:0] digitEnableN
);
	
	// Extend data provided by switches to 32 bits
	wire [31:0] data = {16'b0, switches};
	
	// Don't display decimal points
	wire [7:0] pointEnable = 8'b0;
	
	
	// Encode input switch data into segment and digit enable masks
	SevenSegmentController controller(
		.clock(clock), .data(data), .pointEnable(pointEnable),
		.segmentEnableN(segmentEnableN), .digitEnableN(digitEnableN)
	);
	
endmodule
