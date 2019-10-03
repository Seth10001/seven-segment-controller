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
 * @param[in]  data           the data to encode
 * @param[in]  pointEnable    display the decimal point on the "seven"-segment display
 * 
 * @param[out] segmentEnableN the "seven"-segment active-low enable mask corresponding to the input values
 */
module SevenSegmentEncoder (
	input  wire [3:0] data,
	input  wire       pointEnable,
	
	output wire [7:0] segmentEnableN
);
	
	// Define some helpful mask macros
	`define SEGMENT_MASK_TOP          (1 << 0)
	`define SEGMENT_MASK_RIGHT_TOP    (1 << 1)
	`define SEGMENT_MASK_RIGHT_BOTTOM (1 << 2)
	`define SEGMENT_MASK_BOTTOM	      (1 << 3)
	`define SEGMENT_MASK_LEFT_BOTTOM  (1 << 4)
	`define SEGMENT_MASK_LEFT_TOP     (1 << 5)
	`define SEGMENT_MASK_CENTER       (1 << 6)
	
	`define SEGMENT_MASK_ALL          7'b1111111
	
	
	// Select the mask corresponding to the input data from hardcoded mask combinations
	reg [6:0] segmentEnable;
	always @(*)
	begin
		case (data)
			// Hexadecimal "0" (without slash)
			4'h0:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_CENTER;
			
			// Hexadecimal "1" (oriented right)
			4'h1:
				segmentEnable = `SEGMENT_MASK_RIGHT_TOP | `SEGMENT_MASK_RIGHT_BOTTOM;
			
			// Hexadecimal "2"
			4'h2:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_LEFT_TOP & ~`SEGMENT_MASK_RIGHT_BOTTOM;
			
			// Hexadecimal "3"
			4'h3:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_LEFT_TOP & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			// Hexadecimal "4"
			4'h4:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_TOP & ~`SEGMENT_MASK_BOTTOM & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			// Hexadecimal "5"
			4'h5:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_RIGHT_TOP & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			// Hexadecimal "6" (with top segment enabled)
			4'h6:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_RIGHT_TOP;
			
			// Hexadecimal "7"
			4'h7:
				segmentEnable = `SEGMENT_MASK_TOP | `SEGMENT_MASK_RIGHT_TOP | `SEGMENT_MASK_RIGHT_BOTTOM;
			
			// Hexadecimal "8"
			4'h8:
				segmentEnable = `SEGMENT_MASK_ALL;
			
			// Hexadecimal "9" (with bottom segment enabled)
			4'h9:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_LEFT_BOTTOM;
			
			// Hexadecimal "A" (uppercase)
			4'ha:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_BOTTOM;
			
			// Hexadecimal "b" (lowercase)
			4'hb:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_TOP & ~`SEGMENT_MASK_RIGHT_TOP;
			
			// Hexadecimal "C" (uppercase)
			4'hc:
				segmentEnable = `SEGMENT_MASK_TOP | `SEGMENT_MASK_LEFT_TOP | `SEGMENT_MASK_LEFT_BOTTOM | `SEGMENT_MASK_BOTTOM;
			
			// Hexadecimal "d" (lowercase)
			4'hd:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_TOP & ~`SEGMENT_MASK_LEFT_TOP;
			
			// Hexadecimal "E" (uppercase)
			4'he:
				segmentEnable = `SEGMENT_MASK_ALL & ~`SEGMENT_MASK_RIGHT_TOP & ~`SEGMENT_MASK_RIGHT_BOTTOM;
			
			// Hexadecimal "F" (uppercase)
			4'hf:
				segmentEnable = `SEGMENT_MASK_TOP | `SEGMENT_MASK_LEFT_TOP | `SEGMENT_MASK_CENTER | `SEGMENT_MASK_LEFT_BOTTOM;
		endcase
	end
	
	
	// Invert signals before output to create active-low enable mask
	// The decimal point bit is the highest bit in the mask, so prepend it to the other enable signals
	assign segmentEnableN = ~{pointEnable, segmentEnable};
	
endmodule
