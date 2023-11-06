`include "alu.v"
`include "brcomp.v"
`include "Imem.v"
`include "imm_gen.v"
`include "lsu.v"
`include "register_file.v"
`include "pc_register.v"
`include "ctrl_unit.v"
`include "adder.v"
//`include "datamemory"



module cpu(
    clock_i,
    reset_ni,
    io_input_bus,
    io_output_bus
);
parameter XLEN = 32;
parameter IO_INPUT_BUS_LEN = 14;
parameter IO_OUTPUT_BUS_LEN = 52;
parameter IO_BASE_ADDR = 712;

// -- Module IO -----------------------------------------------
input clock_i, reset_ni;
input [13:0] io_input_bus;      // |13 KEY 10|9 SW 0|
output [51:0] io_output_bus;    // |51 HEX5 45|44 HEX4 38|37 HEX3 31|30 HEX2 24|23 HEX1 17|16 HEX0 10|9 LED 0|

// khai bao
// control output
wire br_unsigned,
	  br_sel,
	  mem_wren,
	  rd_wren,
	  op_b_sel,
	  op_a_sel;
wire [3:0]alu_op;
wire [1:0]wb_sel;
wire [1:0]mem_mode;
wire mem_unsigned;
// branch output
wire br_less, br_equal;
 
reg [31:0] wb_data;

// pc register
wire [31:0] pc;
reg [31:0] nxt_pc;
wire [31:0] pc_four;

pc_register PC(
    .pc_next(nxt_pc),
    .pc(pc),
    .clock_i(clock_i),
    .reset_ni(reset_ni)
);
adder addpc(
    .a(pc),
    .b(32'd4),
    .out(pc_four)
);
always @(*) begin
	    //pc_four = pc + 32'd4;
        if(reset_ni)
            nxt_pc = 32'd0;
        else
            nxt_pc = (br_sel) ?   alu_data : pc_four ;
		end

// khoi imem

wire [31:0] instr;
Imem Imem(
   .pc(pc), 
	.clock_i(clock_i),
	.reset_ni(reset_ni),
	.instr(instr)       
);

// khoi register
wire [XLEN-1:0] rs1_data, rs2_data;
register_file REGISTER_FILE(
    .rs1_addr(instr[19:15]),
    .rs2_addr(instr[24:20]),
    .rd_addr(instr[11:7]),
    .rd_data(wb_data),
    .rd_wren(rd_wren),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .clock_i(clock_i),
    .reset_ni(reset_ni)
);

// khoi imm

wire [XLEN-1:0] imm;
imm_gen imm_gen(
    .instr(instr),
    .imm(imm)
);

// khoi control

ctrl_unit CONTROL(
    .instr(instr),
	 .br_less(br_less),
	 .br_equal(br_equal),
	 .br_unsigned(br_unsigned),
	 .br_sel(br_sel),
	 .mem_wren(mem_wren),
	 .rd_wren(rd_wren),
	 .wb_sel(wb_sel),
	 .alu_op(alu_op),
	 .op_b_sel(op_b_sel),
	 .op_a_sel(op_a_sel),
	 .mem_mode(mem_mode),
	 .mem_unsigned(mem_unsigned)
);

// khoi branch
brcomp brcomp(
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
	 .br_unsigned(br_unsigned),
    .br_less(br_less),
    .br_equal(br_equal)
);
// khoi alu
wire [31:0] alu_data;
reg [XLEN-1:0] operand_a, operand_b;
always @(*) begin
    if (op_a_sel)
        operand_a <= pc ;   
    else
        operand_a <= rs1_data;
    if (op_b_sel)
        operand_b <= imm;
    else
        operand_b <= rs2_data;
end
alu alu(
    .operand_a(operand_a),
    .operand_b(operand_b),
    .alu_op(alu_op),
    .alu_data(alu_data)
);


// khoi quyet dinh ghi data

always @(*)
	begin
		case(wb_sel)
		2'b00: wb_data <= pc_four;
		2'b01: wb_data <= alu_data;
		2'b10: wb_data <= ld_data;
		2'b11: wb_data <= ld_data;
		endcase
	end

// khoi load- store unit

wire [31:0] ld_data;

lsu lsu(
	 .addr(alu_data),        
    .mem_mode(mem_mode),      
    .mem_unsigned(mem_unsigned),
	 .clock_i(clock_i), 
	 .reset_ni(reset_ni),
	 .st_data(rs2_data),            
    .st_en(mem_wren),  
	 .ld_data(ld_data),
    .io_input_bus(io_input_bus),
    .io_output_bus(io_output_bus)
    
);



endmodule