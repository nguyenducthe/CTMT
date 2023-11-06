`include "bin2seg.v"
`include "Dmem.v"

module lsu (
	addr,        
    mem_mode,		
	mem_unsigned,	
	clock_i,          
	reset_ni,
	st_data,           
	st_en,           
	ld_data,              
   io_input_bus,   
   io_output_bus 
);

// -- Memory mode encoding ------------------------------------
parameter MEM_BYTE = 'b00;    
parameter MEM_HALF = 'b01;    
parameter MEM_WORD = 'b10;   

// -- Module IO -----------------------------------------------
input [31:0] addr;        
input [1:0] mem_mode;
input clock_i, mem_unsigned, st_en, reset_ni;
input [31:0] st_data;
output reg [31:0] ld_data;
input [13:0] io_input_bus;
output reg [51:0] io_output_bus;

// -- Internal signals ----------------------------------------
wire[31:0] mem_out;
reg [3:0] byte_enable;
reg [31:0] io_out;
reg [31:0] io_in;
always @(*) begin
	if (st_en)
		case (mem_mode)
			MEM_BYTE: byte_enable <= ('b0001 << addr[1:0]);
			MEM_HALF: byte_enable <= ('b0011 << addr[1:0]); 
			MEM_WORD: byte_enable <= 'b1111;
			default: byte_enable <= 'b1111; 
		endcase
	else byte_enable <= 'b0000;
end

// -- Select output source ------------------------------------
reg [31:0] unmasked_q;
always @(*) begin
	case (addr[13:12])
		'b00: begin	
			unmasked_q <= mem_out >> (addr[1:0]*8); 
		end
		'b01: begin	
			unmasked_q <= io_out >> (addr[1:0]*8); 
		end
		'b10: begin	
			unmasked_q <= io_in >> (addr[1:0]*8); 
		end
		default: unmasked_q <= 0;
	endcase
	case (mem_mode)	// Shift and mask result based on mode
		MEM_BYTE: ld_data <= {(mem_unsigned)? {24{1'b0}} : {24{unmasked_q[7]}}, unmasked_q[7:0]};
		MEM_HALF: ld_data <= {(mem_unsigned)? {16{1'b0}} : {16{unmasked_q[15]}}, unmasked_q[15:0]};
		MEM_WORD: ld_data <= unmasked_q;
		default:  ld_data <= unmasked_q;
	endcase
end

// -- Memory block --------------------------------------------
Dmem Dmem(
	 .addr(addr[11:2]),         
	 .clock_i(clock_i), 
	 .reset_ni(reset_ni),
	 .st_data(st_data << (addr[1:0]*8)),  
     .st_en(st_en),     	
	 .ld_data(mem_out)
);
      

reg [31:0] io_registers [1:0];
always @(posedge clock_i)
begin
	if (reset_ni)
	begin
        io_registers[0] <= 0;
		io_registers[1] <= 0;
	end
	else if (st_en)
	begin
		case (addr[2]) 
			'b0: 
				case (mem_mode)
				MEM_BYTE: 	
							case (byte_enable)
								'b0001 : io_registers[0][7:0]  <= st_data[7:0];
								'b0010 : io_registers[0][15:8] <= st_data[7:0];
								'b0100 : io_registers[0][23:16] <= st_data[7:0];
								'b1000 : io_registers[0][31:24] <= st_data[7:0];
							endcase
				MEM_HALF: 	
							case (byte_enable)
								'b0011 : io_registers[0][15:0] <= st_data[15:0];
								'b0110 : io_registers[0][23:8] <= st_data[15:0];
								'b1100 : io_registers[0][31:16] <= st_data[15:0];
							endcase
				MEM_WORD: io_registers[0] <= st_data;
				endcase
			'b1: 
				case (mem_mode)
				MEM_BYTE: 	
							case (byte_enable)
								'b0001 : io_registers[1][7:0]  <= st_data[7:0];
								'b0010 : io_registers[1][15:8] <= st_data[7:0];
								'b0100 : io_registers[1][23:16] <= st_data[7:0];
								'b1000 : io_registers[1][31:24] <= st_data[7:0];
							endcase
				MEM_HALF: 	
							case (byte_enable)
								'b0011 : io_registers[1][15:0] <= st_data[15:0];
								'b0110 : io_registers[1][23:8] <= st_data[15:0];
								'b1100 : io_registers[1][31:16] <= st_data[15:0];
							endcase
				MEM_WORD: io_registers[1] <= st_data;
				endcase
		endcase
	end
end
always @(posedge clock_i)
begin
	case (addr[3:2])
		'b00: io_in <= io_registers[0];
		'b01: io_in <= io_registers[1];
		default: io_in <= {32{1'b0}};
	endcase
end

wire [6:0] digit_0, digit_1, digit_2, digit_3, digit_4, digit_5;
bin2seg convert_digit_0 (io_registers[1][3:0], digit_0);
bin2seg convert_digit_1 (io_registers[1][7:4], digit_1);
bin2seg convert_digit_2 (io_registers[1][11:8], digit_2);
bin2seg convert_digit_3 (io_registers[1][15:12], digit_3);
bin2seg convert_digit_4 (io_registers[1][19:16], digit_4);
bin2seg convert_digit_5 (io_registers[1][23:20], digit_5);
always @(*) begin
	io_output_bus[9:0]   <= io_registers[0][9:0];	  
	io_output_bus[16:10] <= digit_0; 			
	io_output_bus[23:17] <= digit_1; 			
	io_output_bus[30:24] <= digit_2; 			
	io_output_bus[37:31] <= digit_3; 			
	io_output_bus[44:38] <= digit_4; 			
	io_output_bus[51:45] <= digit_5; 			
	//end
end
always @(posedge clock_i)
begin
	case (addr[4:2]) 
		3'b000: io_out <= {{22{1'b0}}, io_input_bus[9:0]};
		3'b001: io_out <= {{31{1'b0}}, io_input_bus[10]};
		3'b010: io_out <= {{31{1'b0}}, io_input_bus[11]};
		3'b011: io_out <= {{31{1'b0}}, io_input_bus[12]};
		3'b100: io_out <= {{31{1'b0}}, io_input_bus[13]};
		default: io_out <= {32{1'b0}};
	endcase
end

endmodule