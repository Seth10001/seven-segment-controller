/**
 * Encode a normal value to a segment enable mask for use in seven-segment displays
 *
 * Directly adapted from `hexTo7Segment` module written by Cameron Braun
 *
 * @author caustin43@gatech.edu
 * @author cameronbraun@gatech.edu
 * @author mlewis61@gatech.edu
 * @date 2019-10-02
 *
 *
 * @param[in]	value			the value to encode
 * @param[in]	pointEnable		display the decimal point on the "seven"-segment display
 * 
 * @param[out]	segmentEnableN	the "seven"-segment active-low enable mask corresponding to the input values
 */
module SevenSegmentEncoder
(
	input	wire	[3:0]	value,
	input	wire			pointEnable,
	
	output	wire	[7:0]	segmentEnableN
);
	
	`define SEGMENT_TOP				0
	`define SEGMENT_RIGHT_TOP		1
	`define SEGMENT_RIGHT_BOTTOM 	2
	`define SEGMENT_BOTTOM			3
	`define SEGMENT_LEFT_BOTTOM		4
	`define SEGMENT_LEFT_TOP		5
	`define SEGMENT_CENTER			6
	
	`define SEGMENT_MASK_TOP			(1 << `SEGMENT_TOP)
	`define SEGMENT_MASK_RIGHT_TOP		(1 << `SEGMENT_RIGHT_TOP)
	`define SEGMENT_MASK_RIGHT_BOTTOM 	(1 << `SEGMENT_RIGHT_BOTTOM)
	`define SEGMENT_MASK_BOTTOM			(1 << `SEGMENT_BOTTOM)
	`define SEGMENT_MASK_LEFT_BOTTOM	(1 << `SEGMENT_LEFT_BOTTOM)
	`define SEGMENT_MASK_LEFT_TOP		(1 << `SEGMENT_LEFT_TOP)
	`define SEGMENT_MASK_CENTER			(1 << `SEGMENT_CENTER)
	`define SEGMENT_MASK_ALL			7'b1111111
	
	reg [6:0] segmentEnable;
	
	assign segmentEnableN = ~{pointEnable, segmentEnable};
	
	
	//Set sensitivity list to all signals and all changes to allow combinational logic
	always @(*)
	begin
		//Since there's no real pattern to the seven-segment bitmaps for each value, use a case statement to select from the pre-computed literals corresponding to each value
		case (value)
			//Hexadecimal "0"
			4'h0:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_CENTER;
			
			//Hexadecimal "1"
			4'h1:
				segmentEnable = `SEGMENT_MASK_RIGHT_TOP | `SEGMENT_MASK_RIGHT_BOTTOM;
			
			//Hexadecimal "2"
			4'h2:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_LEFT_TOP & ~`SEGMENT_MASK_RIGHT_BOTTOM;
			
			//Hexadecimal "3"
			4'h3:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_LEFT_TOP & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			//Hexadecimal "4"
			4'h4:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_TOP & ~`SEGMENT_MASK_BOTTOM & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			//Hexadecimal "5"
			4'h5:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_RIGHT_TOP & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			//Hexadecimal "6"
			4'h6:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_RIGHT_TOP;
			
			//Hexadecimal "7"
			4'h7:
				segmentEnable = `SEGMENT_MASK_TOP | `SEGMENT_MASK_RIGHT_TOP | `SEGMENT_MASK_RIGHT_BOTTOM;
			
			//Hexadecimal "8"
			4'h8:
				segmentEnable = `SEGMENT_MASK_ALL;
			
			//Hexadecimal "9"
			4'h9:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			//Hexadecimal "A"
			4'ha:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_BOTTOM;
			
			//Hexadecimal "b"
			4'hb:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_TOP & ~`SEGMENT_MASK_RIGHT_TOP;
			
			//Hexadecimal "C"
			4'hc:
				segmentEnable = `SEGMENT_MASK_TOP | `SEGMENT_MASK_LEFT_TOP | `SEGMENT_MASK_LEFT_BOTTOM | `SEGMENT_MASK_BOTTOM;
			
			//Hexadecimal "d"
			4'hd:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_TOP & ~`SEGMENT_MASK_LEFT_TOP;
			
			//Hexadecimal "E"
			4'he:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_RIGHT_TOP & ~`SEGMENT_MASK_RIGHT_BOTTOM;
			
			//Hexadecimal "F"
			4'hf:
				segmentEnable = `SEGMENT_MASK_TOP | `SEGMENT_MASK_LEFT_TOP | `SEGMENT_MASK_CENTER | `SEGMENT_MASK_LEFT_BOTTOM;
		endcase
	end
endmodule
