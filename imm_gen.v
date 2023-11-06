module imm_gen (
    instr,    // input -> instruction
    imm  // output -> generated immediate
);

parameter XLEN = 32;

// -- Memory mapped IO ----------------------------------------
parameter IO_INPUT_BUS_LEN = 14;
parameter IO_OUTPUT_BUS_LEN = 52;
parameter IO_BASE_ADDR = 712;

// -- Module IO -----------------------------------------------
input [31:0] instr;
output reg [XLEN-1:0] imm;

// -- Internal signals ----------------------------------------
reg [2:0] instruction_format;

// -- Instruction format coding -------------------------------
parameter R = 3'b000;  // R-Type: Register operations
parameter I = 3'b001;  // I-Type: Immediates and Loads
parameter S = 3'b010;  // S-Type: Stores
parameter B = 3'b011;  // B-Type: Conditional branches
parameter U = 3'b100;  // U-Type: Upper immediates
parameter J = 3'b101;  // J-Type: Unconditional jumps
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
always @(*) begin
    case (instr[6:0])
        lui_gr: instruction_format = U;
        aui_gr: instruction_format = U;
        jal_gr: instruction_format = J;
        jlr_gr: instruction_format = I;
        bra_gr: instruction_format = B;
        loa_gr: instruction_format = I;
        sto_gr: instruction_format = S;
        rim_gr: instruction_format = I;
        reg_gr: instruction_format = R;
    endcase  
end
always @(*) begin
    case (instruction_format)
        I: imm = {{(XLEN - 11){instr[31]}}, instr[30:20]};
        S: imm = {{(XLEN - 11){instr[31]}}, instr[30:25], instr[11:7]};
        B: imm = {{(XLEN - 12){instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        U: imm = {{(XLEN - 31){instr[31]}}, instr[30:20], instr[19:12], 12'b0};
        J: imm = {{(XLEN - 20){instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 1'b0};
        default: imm = {XLEN{1'b0}};  
    endcase
end    
endmodule