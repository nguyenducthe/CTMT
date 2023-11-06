module pc_register(
    pc_next,             
    pc,          
    clock_i,         
    reset_ni           
);

input [31:0] pc_next;
input  clock_i, reset_ni;
output reg [31:0] pc;

always @(posedge clock_i) begin
    if (reset_ni ==1)
        pc <= 0;
    else 
        pc <= pc_next;
end

endmodule