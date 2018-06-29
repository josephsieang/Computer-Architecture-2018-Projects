//Subject:     Architecture project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

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
//R-type op code
parameter ADD_op = 6'b100000;
parameter SUB_op = 6'b100010;
parameter AND_op = 6'b100100;
parameter OR_op  = 6'b100101;
parameter SLT_op = 6'b101010;



//Select exact operation, please finish the following code
always@(funct_i or ALUOp_i) begin
    if(ALUOp_i == 3'b000) begin//LW
        ALUCtrl_o = LW;
    end else if(ALUOp_i == 3'b001) begin//BEQ
        ALUCtrl_o = BEQ;
        //$display("ALUctrl beq");
    end else if(ALUOp_i == 3'b010) begin//R-type
        if(funct_i == ADD_op) begin
            ALUCtrl_o = ADD;
        end else if(funct_i == SUB_op) begin
            ALUCtrl_o = SUB;
        end else if(funct_i == AND_op) begin
            ALUCtrl_o = AND;
        end else if(funct_i == OR_op) begin
            ALUCtrl_o = OR;
        end else if(funct_i == SLT_op) begin
            ALUCtrl_o = SLT;
        end
    end else if(ALUOp_i == 3'b011) begin//ADDI
        ALUCtrl_o = ADDI;
    end else if(ALUOp_i == 3'b100) begin//SLTI
        ALUCtrl_o = SLTI;
    end else if(ALUOp_i == 3'b101) begin//SW
        ALUCtrl_o = SW;
    end
end

endmodule


// case(ALUOp_i)
//         3'b000: 
//             begin
//                 case(funct_i)
//                     6'b100100: ALUCtrl_o = 4'b0000; // AND
//                     default: ALUCtrl_o = 4'b1111;
//                 endcase
//             end
//         default:
//     endcase