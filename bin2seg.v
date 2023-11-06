module bin2seg(bin, seg);

input wire [3:0] bin;
output reg [6:0] seg;

always @(*)
  case (bin)
	 0 : seg = ~7'b0111111;
	 1 : seg = ~7'b0000110;
	 2 : seg = ~7'b1011011;
	 3 : seg = ~7'b1001111;
	 4 : seg = ~7'b1100110;
	 5 : seg = ~7'b1101101;
	 6 : seg = ~7'b1111101;
	 7 : seg = ~7'b0000111;
	 8 : seg = ~7'b1111111;
	 9 : seg = ~7'b1101111;
	 10: seg = ~7'b1110111;
	 11: seg = ~7'b1111100;
	 12: seg = ~7'b0111001;
	 13: seg = ~7'b1011110;
	 14: seg = ~7'b1111001;
	 15: seg = ~7'b1110001;
  endcase
endmodule