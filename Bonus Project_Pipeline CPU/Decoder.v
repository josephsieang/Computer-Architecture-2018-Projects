//Subject:     Architecture project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	MemWrite_o,
	MemRead_o,
	MemtoReg_o
	);
     
//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output         RegDst_o;
output         Branch_o;
output		   MemWrite_o;
output		   MemRead_o;
output		   MemtoReg_o;
 
//Internal Signals
reg    [3-1:0] ALU_op_o;//3bit but 2 bit in notes
reg            ALUSrc_o;
reg            RegWrite_o;
reg            RegDst_o;
reg            Branch_o;
reg			   MemWrite_o;
reg			   MemRead_o;
reg			   MemtoReg_o;

//Parameter
parameter ADDI = 6'b001000;
parameter LW   = 6'b100011;
parameter SW   = 6'b101011;
parameter SLTI = 6'b001010;
parameter BEQ  = 6'b000100;

//Main function
always@* begin
  if(instr_op_i == 6'b0) begin
	RegDst_o = 1;
  end else begin
	RegDst_o = 0;
  end
end

always@* begin
	if(instr_op_i == BEQ) begin
		Branch_o = 1;
		//$display("%b BEQ decoder", instr_op_i);
	end else begin
		Branch_o = 0;
		//$display("%b not beq by decoder", instr_op_i);
	end
end

always@* begin
	if(instr_op_i == LW) begin
		MemRead_o = 1;
	end else begin
		MemRead_o = 0;
	end
end

always@* begin
	if(instr_op_i == LW) begin
		MemtoReg_o = 1;
	end else begin
		MemtoReg_o = 0;
	end
end

always@* begin
	if(instr_op_i == LW) begin
		ALU_op_o = 3'b000;//LW
	end else if(instr_op_i == BEQ) begin
		ALU_op_o = 3'b001;//BEQ
	end else if(instr_op_i == 6'b0) begin
		ALU_op_o = 3'b010;//R-type
	end else if(instr_op_i == ADDI) begin
		ALU_op_o = 3'b011;//ADDI
	end else if(instr_op_i == SLTI) begin
		ALU_op_o = 3'b100;//SLTI
	end else begin
		ALU_op_o = 3'b101;//SW
	end
end

always@* begin
	if(instr_op_i == SW) begin
		MemWrite_o = 1;
	end else begin
		MemWrite_o = 0;
	end
end

always@* begin
	if(instr_op_i == 6'b0 || instr_op_i == BEQ) begin
		ALUSrc_o = 0;
	end else begin
		ALUSrc_o = 1;
	end
end

always@* begin
	if(instr_op_i == SW || instr_op_i == BEQ) begin
		RegWrite_o = 0;
	end else begin
		RegWrite_o = 1;
	end
end

endmodule