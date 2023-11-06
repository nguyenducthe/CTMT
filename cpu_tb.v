`include "cpu.v"

module cpu_tb;
reg clock_i = 1'b1;
reg reset_ni = 1'b0;
reg [13:0] io_in = 14'd10;
wire [51:0] io_out;


cpu cputest(
     .clock_i(clock_i),
     .reset_ni(reset_ni),
     .io_input_bus(io_in),
     .io_output_bus(io_out)
);

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0);
    


end
always 
    begin
        clock_i = ~ clock_i;
        #5;  
        
    end
    
    initial
    begin
        reset_ni <= 1'b1;
        #100;

        reset_ni <=1'b0;
        #400;
        $finish;
    end




endmodule