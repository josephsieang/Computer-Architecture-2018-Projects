//Subject:     Architecture project 2 - ALU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
//I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;

//Internal signals
reg    [32-1:0]  result_o;
reg              zero_o;//zero flag is 1 if beq is true, otherwise 0

//Parameter
parameter ADD  = 4'b0000;
parameter SUB  = 4'b0001;
parameter AND  = 4'b0010;
parameter OR   = 4'b0011;
parameter SLT  = 4'b0100;
parameter ADDI = 4'b0101;
parameter LW   = 4'b0110;
parameter SW   = 4'b0111;
parameter SLTI = 4'b1000;
parameter BEQ  = 4'b1001;

//Main function
always@* begin
	//$display("src1:%d src2:%d", src1_i, src2_i);
	zero_o = 0;
	if(ctrl_i == ADD) begin
		result_o = src1_i + src2_i;
	end else if(ctrl_i == SUB) begin
		result_o = src1_i - src2_i;
	end else if(ctrl_i == AND) begin
		result_o = src1_i & src2_i;
	end else if(ctrl_i == OR) begin
		result_o = src1_i | src2_i;
	end else if(ctrl_i == SLT) begin
		if(src1_i < src2_i) begin
			result_o = 1;
		end else begin
			result_o = 0;
		end
	end else if(ctrl_i == ADDI) begin
		result_o = src1_i + src2_i;
	end else if(ctrl_i == SW) begin
		result_o = src1_i + src2_i;
	end else if(ctrl_i == LW) begin
		result_o = src1_i + src2_i;
	end else if(ctrl_i == SLTI) begin
		if(src1_i < src2_i) begin
			result_o = 1;
		end else begin
			result_o = 0;
		end
	end else if(ctrl_i == BEQ) begin
		result_o = 0;
		
		if(src1_i == src2_i) begin
			zero_o = 1;
		end else begin
			zero_o = 0;
		end
	end
end

endmodule