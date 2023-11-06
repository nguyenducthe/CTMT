module brcomp (
    rs1_data,    
    rs2_data,
	br_unsigned, 
	br_less,     
	br_equal	 
);
parameter XLEN = 32;
input wire [XLEN-1:0] rs1_data, rs2_data;
input br_unsigned;
output reg br_less;
output reg br_equal;
always @(*) begin
	 if(br_unsigned)
	 begin
	 if (rs1_data < rs2_data) begin br_equal = 0; br_less = 1; end
	 else if (rs1_data == rs2_data) begin br_equal = 1; br_less = 0; end
	 else  begin br_equal = 0; br_less = 0; end
	 end
	 else
	 begin
	 if (rs1_data < rs2_data) begin br_equal = 0; br_less = 1; end
	 else if (rs1_data == rs2_data) begin br_equal = 1; br_less = 0; end
	 else  begin br_equal = 0; br_less = 0; end
	 end
    end
endmodule