module Dmem (
	addr,    // input -> address to read/write
	clock_i,      // input -> clock
	reset_ni,
	st_data,       // input -> input data
	st_en,       // input -> high enables write
	ld_data          // output -> output data
);

input [9:0] addr; 
input clock_i ,reset_ni;
input [31:0] st_data;
input st_en;
output [31:0] ld_data;

// -- Internal signals ----------------------------------------
reg wren_reg;
reg [9:0] address_reg;
reg [31:0] data_reg;
reg [31:0] mem [1023:0];
always @(posedge clock_i) begin
    if (reset_ni == 1) begin
        wren_reg <= 0;
        address_reg <= 0;
        data_reg <= 0;
    end else begin
        wren_reg <= st_en;
        address_reg <= addr;
        data_reg <= st_data;
    end
end
assign ld_data = mem[address_reg];
always @(posedge clock_i) begin
    if (wren_reg)
        mem[address_reg] <= data_reg;
end

endmodule