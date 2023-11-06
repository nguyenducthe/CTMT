`include "alu.v"
`include "brcomp.v"
`include "Imem.v"
`include "imm_gen.v"
`include "lsu.v"
`include "register_file.v"
`include "pc_register.v"
`include "ctrl_unit.v"
`include "adder.v"


module cpu(
    clk_i,
    rst_ni,
     io_sw_i,  
     io_lcd_o, 
   io_ledg_o, 
   io_ledr_o,
   io_hex0_o,
   io_hex1_o,
   io_hex2_o,
   io_hex3_o,
   io_hex4_o,
   io_hex5_o,
   io_hex6_o,
   io_hex7_o,
   pc_debug_o
);
parameter XLEN = 32;


// -- Module IO -----------------------------------------------
input clk_i, rst_ni;
input [31:0] io_sw_i;
output  [31:0] io_lcd_o;
output  [31:0] io_ledg_o;
output  [31:0] io_ledr_o;
output  [31:0] io_hex0_o;
output  [31:0] io_hex1_o;
output  [31:0] io_hex2_o;
output  [31:0] io_hex3_o;
output  [31:0] io_hex4_o;
output  [31:0] io_hex5_o;
output  [31:0] io_hex6_o;
output  [31:0] io_hex7_o;
output  [31:0]      pc_debug_o;


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
    .clock_i(clk_i),
    .reset_ni(rst_ni)
);
adder addpc(
    .a(pc),
    .b(32'd4),
    .out(pc_four)
);
always @(*) begin
	    //pc_four = pc + 32'd4;
        if(rst_ni)
            nxt_pc = 32'd0;
        else
            nxt_pc = (br_sel) ?   alu_data : pc_four ;
		end

// khoi imem

wire [31:0] instr;
Imem Imem(
   .pc(pc), 
	.clock_i(clk_i),
	.reset_ni(rst_ni),
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
	.clock_i(clck_i), 
	.reset_ni(rst_ni),
	.st_data(rs2_data),            
    .st_en(mem_wren),  
	.ld_data(ld_data),
    .io_sw_i(io_sw_i),
    .io_lcd_o(io_lcd_o),
    .io_ledg_o(io_ledg_o),
    .io_ledr_o(io_ledr_o),
    .io_hex0_o(io_hex0_o),
    .io_hex1_o(io_hex1_o),
    .io_hex2_o(io_hex2_o),
    .io_hex3_o(io_hex3_o),
    .io_hex4_o(io_hex4_o),
    .io_hex5_o(io_hex5_o),
    .io_hex6_o(io_hex6_o),
    .io_hex7_o(io_hex7_o)
    
    
);



endmodule