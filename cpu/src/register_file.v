module register_file (
    rs1_addr,     
    rs2_addr,     
    rd_addr,      
    rd_data,    
    rd_wren,   
    rs1_data,    
    rs2_data,    
    clock_i,         
    reset_ni           
);
parameter XLEN = 32;


//// -- Memory mapped IO ----------------------------------------
//parameter IO_INPUT_BUS_LEN = 14;
//parameter IO_OUTPUT_BUS_LEN = 52;
//parameter IO_BASE_ADDR = 712;
//// -- Module IO -----------------------------------------------


input [4:0] rs1_addr, rs2_addr, rd_addr;
input [XLEN-1:0] rd_data;
input rd_wren, clock_i, reset_ni;
output reg [XLEN-1:0] rs1_data, rs2_data;


reg [XLEN-1:0] reg_file [31:0];
always @ (*) begin
        if (rs1_addr == 0)
            rs1_data <= 0;
        else if (rs1_addr == rd_addr)
            rs1_data <= rd_data;
        else
            rs1_data <= reg_file [rs1_addr];
            
        if (rs2_addr == 0) 
            rs2_data <= 0;
        else if (rs2_addr == rd_addr)
            rs2_data <= rd_data;
        else
            rs2_data <= reg_file [rs2_addr];
end

integer i;
always @ (posedge clock_i) begin
    if(reset_ni)                   
        for (i=0; i < 32; i=i+1)
            reg_file [i] <= {XLEN{1'b0}};
    else 
        if (rd_wren == 1) begin
            if (rd_addr != 0) begin   
                reg_file [rd_addr] <= rd_data;
                end
    end
end

endmodule