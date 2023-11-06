
module ctrl_unit(
    instr,        
	 br_less ,					
	 br_equal,					
	 br_unsigned,
    br_sel,     			
    mem_wren ,          
    rd_wren, 				  
    wb_sel,               
    alu_op,            
    op_b_sel,			
    op_a_sel,
	 mem_mode,	 
	 mem_unsigned
    );
// -- ALU operations encoding ---------------------------------
parameter ALU_ADD = 4'b0000;    // add
parameter ALU_SUB = 4'b0001;    // subtract
parameter ALU_XOR = 4'b0010;    // xor
parameter ALU_OR  = 4'b0101;    // or
parameter ALU_AND = 4'b0110;    // and
parameter ALU_LSR = 4'b0111;    // logical shift right
parameter ALU_LSL = 4'b1000;    // logical shift left
parameter ALU_PASS_0 = 4'b1101; // pass input 0 to output
parameter ALU_PASS_1 = 4'b1001; // pass input 1 to output
parameter ALU_ASR = 4'b1010;    // arithmetic shift right
parameter ALU_LT = 4'b1011;     // set if less than
parameter ALU_LTU = 4'b1100;    // set if less than unsigned
// -- Branch comparison encoding ------------------------------
parameter EQ = 'b001;   // Equal
parameter NE = 'b010;   // Not equal
parameter LT = 'b011;   // Less than
parameter GE = 'b100;   // Greater than or equal to
parameter LTU = 'b101;  // Less than unsigned
parameter GEU = 'b110;  // Greater than or equal to unsigned
// -- Instruction opcode groups -------------------------------
parameter lui_gr = 7'b0110111; // Lui
parameter aui_gr = 7'b0010111; // Auipc
parameter jal_gr = 7'b1101111; // Jal
parameter jlr_gr = 7'b1100111; // Jalr
parameter bra_gr = 7'b1100011; // Branch group
parameter loa_gr = 7'b0000011; // Load group
parameter sto_gr = 7'b0100011; // Store group
parameter rim_gr = 7'b0010011; // Arithmetic & logic immediate group
parameter reg_gr = 7'b0110011; // Arithmetic & logic R-type instructions

// -- Memory mode encoding ------------------------------------
parameter MEM_BYTE = 'b00;    // Store/read byte's (8-bit)
parameter MEM_HALF = 'b01;    // Store/read half words (16-bit)
parameter MEM_WORD = 'b10;    // Store/read words (32-bit)

// -- Module IO -------------------------------------------
input [31:0] instr;
input br_less, br_equal;
output reg br_sel, mem_wren, br_unsigned, rd_wren, op_b_sel, op_a_sel;
output reg [1:0] wb_sel;
output reg [3:0] alu_op;
output reg [1:0] mem_mode;
output reg mem_unsigned;

// -- Extract opcode --------------------------------------
wire [6:0] opcode;
assign opcode = instr[6:0];
// -- Extract funct3 ---------------------------------------
wire [2:0] funct3;
assign funct3 = instr[14:12];
// -- Extract funct7 ---------------------------------------
wire [6:0] funct7;
assign funct7 = instr[31:25];
// -- Determine instruction -------------------------------
// Lui
wire lui_inst = (opcode == lui_gr);
// Auipc
wire auipc_inst = (opcode == aui_gr);
// Jal
wire jal_inst = (opcode == jal_gr);
// Jalr
wire jalr_inst = (opcode == jlr_gr) && (funct3 == 3'b000);
// Branch group
wire beq_inst = (opcode == bra_gr) && (funct3 == 3'b000);
wire bne_inst = (opcode == bra_gr) && (funct3 == 3'b001);
wire blt_inst = (opcode == bra_gr) && (funct3 == 3'b100);
wire bge_inst = (opcode == bra_gr) && (funct3 == 3'b101);
wire bltu_inst = (opcode == bra_gr) && (funct3 == 3'b110);
wire bgeu_inst = (opcode == bra_gr) && (funct3 == 3'b111);
// Load group
wire lb_inst = (opcode == loa_gr) && (funct3 == 3'b000);
wire lh_inst = (opcode == loa_gr) && (funct3 == 3'b001);
wire lw_inst = (opcode == loa_gr) && (funct3 == 3'b010);
wire lbu_inst = (opcode == loa_gr) && (funct3 == 3'b100);
wire lhu_inst = (opcode == loa_gr) && (funct3 == 3'b101);
wire lwu_inst = (opcode == loa_gr) && (funct3 == 3'b110);
// Store group
wire sb_inst = (opcode == sto_gr) && (funct3 == 3'b000);
wire sh_inst = (opcode == sto_gr) && (funct3 == 3'b001);
wire sw_inst = (opcode == sto_gr) && (funct3 == 3'b010);
// Arithmetic & logic immediate group
wire addi_inst = (opcode == rim_gr) && (funct3 == 3'b000);
wire slli_inst = (opcode == rim_gr) && (funct3 == 3'b001);
wire slti_inst = (opcode == rim_gr) && (funct3 == 3'b010);
wire sltiu_inst = (opcode == rim_gr) && (funct3 == 3'b011);
wire xori_inst = (opcode == rim_gr) && (funct3 == 3'b100);
wire srli_inst = (opcode == rim_gr) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
wire srai_inst = (opcode == rim_gr) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
wire ori_inst = (opcode == rim_gr) && (funct3 == 3'b110);
wire andi_inst = (opcode == rim_gr) && (funct3 == 3'b111);
// Arithmetic & logic R-type instructions
wire add_inst = (opcode == reg_gr) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
wire sub_inst = (opcode == reg_gr) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
wire sll_inst = (opcode == reg_gr) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
wire slt_inst = (opcode == reg_gr) && (funct3 == 3'b010) && (funct7 == 7'b0000000);
wire sltu_inst = (opcode == reg_gr) && (funct3 == 3'b011) && (funct7 == 7'b0000000);
wire xor_inst = (opcode == reg_gr) && (funct3 == 3'b100) && (funct7 == 7'b0000000);
wire srl_inst = (opcode == reg_gr) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
wire sra_inst = (opcode == reg_gr) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
wire or_inst = (opcode == reg_gr) && (funct3 == 3'b110) && (funct7 == 7'b0000000);
wire and_inst = (opcode == reg_gr) && (funct3 == 3'b111) && (funct7 == 7'b0000000);

// -- Set control signals ---------------------------------
always @(*) begin
    // Reset all signals
    mem_wren <= 0;
    rd_wren <= 0;
    wb_sel <= 0;
    op_b_sel <= 0;
    op_a_sel <= 0;
	 alu_op <= 'b0;
	 br_unsigned <= 0;
	 br_sel <= 0;
        case (1'b1)
            lui_inst:   begin alu_op <= ALU_PASS_1; op_a_sel <= 1; op_b_sel <= 1; rd_wren <= 1; end
            auipc_inst: begin alu_op <= ALU_ADD;    op_b_sel <= 1; op_b_sel <= 1; rd_wren <= 1; end 
            jal_inst:   begin alu_op <= ALU_PASS_0; rd_wren <= 1;  op_a_sel <= 1; wb_sel <= 2'b10 ; end
            jalr_inst:   begin alu_op <= ALU_PASS_0; rd_wren <= 1; op_a_sel <= 0;wb_sel <= 2'b01 ; end
            // Branch group
            beq_inst:  begin
							   if(br_equal) begin br_sel <= 1; alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1; end
							   else begin  alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1; end
							  end
            bne_inst:  begin 
								if(br_equal) begin br_sel <= 1; alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1; end
							   else begin  alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1; end
							  end
            blt_inst:  begin br_sel <= 1; alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1;   end  
            bge_inst:  begin br_sel <= 1; alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1;  end  
            bltu_inst: begin br_sel <= 1; alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1;   br_unsigned <= 1; end  
            bgeu_inst: begin br_sel <= 1; alu_op <= ALU_ADD; op_a_sel <= 1; op_b_sel <= 1;   br_unsigned <= 1; end 
            // Load group
            lb_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1; rd_wren <= 1; wb_sel <= 2'b01 ;mem_mode <= MEM_BYTE;  end
            lh_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1; rd_wren <= 1; wb_sel <= 2'b01;  mem_mode <= MEM_HALF; end
            lw_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1; rd_wren <= 1; wb_sel <= 2'b01; mem_mode <= MEM_WORD; end
            lbu_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1;rd_wren <= 1; wb_sel <= 2'b01;  mem_mode <= MEM_BYTE; mem_unsigned <= 1; end
            lhu_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1;rd_wren <= 1; wb_sel <= 2'b01; mem_mode <= MEM_HALF; mem_unsigned <= 1; end
            lwu_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1;rd_wren <= 1; wb_sel <= 2'b01; mem_mode <= MEM_WORD; mem_unsigned <= 1; end
            // Store group
            sb_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1;  mem_wren <= 1;  mem_mode <= MEM_BYTE;end
            sh_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1;  mem_wren <= 1;  mem_mode <= MEM_HALF;end
            sw_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1;  mem_wren <= 1;  mem_mode <= MEM_WORD;end
            // Arithmetic & logic immediate group
            addi_inst: begin alu_op <= ALU_ADD; op_b_sel <= 1; rd_wren <= 1; end
            slli_inst: begin alu_op <= ALU_LSL; op_b_sel <= 1; rd_wren <= 1; end
            slti_inst: begin alu_op <= ALU_LT; op_b_sel <= 1;  rd_wren <= 1; end
            sltiu_inst: begin alu_op <= ALU_LTU; op_b_sel <= 1;rd_wren <= 1;  end
            xori_inst: begin alu_op <= ALU_XOR; op_b_sel <= 1; rd_wren <= 1; end
            srli_inst: begin alu_op <= ALU_LSR; op_b_sel <= 1; rd_wren <= 1; end
            srai_inst: begin alu_op <= ALU_ASR; op_b_sel <= 1; rd_wren <= 1; end
            ori_inst: begin alu_op <= ALU_OR; op_b_sel <= 1;   rd_wren <= 1; end
            andi_inst: begin alu_op <= ALU_AND; op_b_sel <= 1; rd_wren <= 1; end
            // Arithmetic & logic R-type instructions
            add_inst: begin alu_op <= ALU_ADD; rd_wren <= 1; end
            sub_inst: begin alu_op <= ALU_SUB; rd_wren <= 1; end
            sll_inst: begin alu_op <= ALU_LSL; rd_wren <= 1; end
            slt_inst: begin alu_op <= ALU_LT;  rd_wren <= 1; end
            sltu_inst: begin alu_op <= ALU_LTU;rd_wren <= 1; end
            xor_inst: begin alu_op <= ALU_XOR; rd_wren <= 1; end
            srl_inst: begin alu_op <= ALU_LSR; rd_wren <= 1; end
            sra_inst: begin alu_op <= ALU_ASR; rd_wren <= 1; end
            or_inst: begin alu_op <= ALU_OR; ; rd_wren <= 1; end
            and_inst: begin alu_op <= ALU_AND; rd_wren <= 1; end
           
        endcase
    end	 
endmodule