module alu (
    operand_a,           
    operand_b,          
    alu_op,      
    alu_data          
);


// -- Data length ---------------------------------------------
parameter XLEN = 32;

// -- Memory mapped IO ----------------------------------------
parameter IO_INPUT_BUS_LEN = 14;
parameter IO_OUTPUT_BUS_LEN = 52;
parameter IO_BASE_ADDR = 712;

// -- Module IO -----------------------------------------------
input [XLEN-1:0] operand_a, operand_b;
input [3:0] alu_op;
output reg [XLEN-1:0] alu_data;
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

// -- Internal signals ----------------------------------------
wire [2*XLEN-1:0] in_0_extended = {{XLEN{operand_a[XLEN-1]}},operand_a};

// -- Calculate output based on operation code ----------------
always @(*) begin
    case (alu_op)
        ALU_ADD: alu_data <= operand_a + operand_b;
        ALU_SUB: alu_data <= operand_a - operand_b;
        ALU_XOR: alu_data <= operand_a ^ operand_b;
        ALU_OR: alu_data <= operand_a | operand_b;
        ALU_AND: alu_data <= operand_a & operand_b;
        ALU_LSR: alu_data <= operand_a >> operand_b;
        ALU_LSL: alu_data <= operand_a << operand_b;
        ALU_ASR: begin
            if (operand_b > XLEN)
                alu_data <= {XLEN{operand_a[XLEN-1]}};
            else
                alu_data <= in_0_extended >> operand_b;
        end
        ALU_PASS_1: alu_data <= operand_b;
        ALU_PASS_0: alu_data <= operand_a;
        ALU_LT: begin
            if (operand_a[XLEN-1] && operand_b[XLEN-1])           
                alu_data <= (operand_a < operand_b);
            else if (!operand_a[XLEN-1] && operand_b[XLEN-1])    
                alu_data <= 0;
            else if (operand_a[XLEN-1] && !operand_b[XLEN-1])    
                alu_data <= 1;
            else                                        
                alu_data <= (operand_a < operand_b);
        end
        ALU_LTU: alu_data <= (operand_a < operand_b) ? 1 : 0;
        default: alu_data <= {XLEN{1'b0}};  
    endcase
end

endmodule