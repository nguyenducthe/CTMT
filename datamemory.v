

module datamemory(
    clock_i, 
    reset_ni, 
    mem_mode, 
    mem_unsigned, 
    st_data, 
    st_en,
    ld_data, 
    addr
);
input [31:0] addr;
input clock_i, reset_ni, st_en, mem_unsigned;
input [31:0] st_data;
input [1:0] mem_mode;
output reg [31:0] ld_data;

always @(posedge clock_i)
    begin
        if(reset_ni)
            ld_data <= 32'd0;
        else
            begin




            end

    end


endmodule