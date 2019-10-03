module SevenSegmentController
(
	input wire clock,
	
	input  wire [15:0] value,
	input  wire [ 7:0] pointEnable,
	
	output wire [7:0] segmentEnableN,
	output wire [7:0] digitEnableN
);
	
	
	SevenSegmentEncoder encoder(.value(value[3:0]), .pointEnable(0), .segmentEnableN(segmentEnableN));
	
	assign digitEnableN = ~switches[15:8];
	
endmodule
