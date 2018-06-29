`timescale 1ns / 1ps
// Subject:     Architecture Project1 - Simulator
//--------------------------------------------------------------------------------
// Version:     1.2
//--------------------------------------------------------------------------------
// Writer:      伍瀚翔 105062361
//----------------------------------------------
// Date:        2018/2/24
//----------------------------------------------
// Description: 
//--------------------------------------------------------------------------------

// Parameter
`define INSTR_NUM 256
`define DATA_NUM 256
// Parameter of R-type instruction
`define ADD 6'h20
`define SUB 6'h22
`define AND 6'h24
`define OR 6'h25
`define SLT 6'h2A
// Parameter of I-type instruction
`define ADDI 6'h8
`define LW 6'h23
`define SW 6'h2B
`define SLTI 6'hA
`define BEQ 6'h4

module Simulator(
  // I/O ports
  input clk_i,
  input rst_i
);

  // DO NOT CHANGE SIZE, NAME
  reg [32 - 1:0] Instr_Mem [0:`INSTR_NUM - 1];
  reg [32 - 1:0] Data_Mem  [0:`DATA_NUM - 1];
  reg signed [32 - 1:0] Reg_File [0:32 - 1];

  // Register
  reg [32 - 1:0] instr;
  reg [32 - 1:0] pc_addr;
  // Register for R-type
  reg [6 - 1:0]  op;
  reg [5 - 1:0]  rs;
  reg [5 - 1:0]  rt;
  reg [5 - 1:0]  rd;
  reg [5 - 1:0]  shamt;
  reg [6 - 1:0]  func;
  // Register for I-type
  reg [6 - 1:0]  op_i;
  reg [5 - 1:0]  rs_i;
  reg [5 - 1:0]  rt_i;
  reg signed [16 - 1:0] immediate;

  integer i;
  integer j;
  

  // Task
  //decode for R-type
  task decode;
    begin
      op    = instr[31:26];
      rs    = instr[25:21];
      rt    = instr[20:16];
      rd    = instr[15:11];
      shamt = instr[10:6];
      func  = instr[5:0];
    end
  endtask

  //decode for I-type
  task decode_i;
    begin
      op_i    = instr[31:26];
      rs_i    = instr[25:21];
      rt_i    = instr[20:16];
      immediate  = instr[15:0];
    end
  endtask
  
  // Main function
  always @(posedge clk_i or negedge rst_i) begin
	if(rst_i == 0) begin
	  for(i = 0; i < 32; i = i + 1) begin
		  Reg_File[i] = 32'd0;	
	    pc_addr = 32'd0;
    end
    for(j = 0; j < 256; j = j + 1) begin
      Data_Mem[j] = 32'd0;
    end
	end
	else begin
	  instr = Instr_Mem[pc_addr / 4];
	  decode;
    decode_i;
	  if(op == 6'd0)begin // R-type
      //$display("imme: %d s: %d t: %d", immediate, Reg_File[rs_i],  Reg_File[rt_i]);
      //$display("d: %d s: %d t: %d", Reg_File[rd], Reg_File[rs],  Reg_File[rt]);
	    case(func)
          `ADD: begin
            Reg_File[rd] = Reg_File[rs] + Reg_File[rt];
            //$display("add d: %d s: %d t: %d", Reg_File[rd], Reg_File[rs],  Reg_File[rt]);
          end
          `SUB: begin
            Reg_File[rd] = Reg_File[rs] - Reg_File[rt];
            //$display("sub d: %d s: %d t: %d rs: %d rt: %d", Reg_File[rd], Reg_File[rs],  Reg_File[rt], rs, rt);
          end
          `AND: begin
            Reg_File[rd] = Reg_File[rs] & Reg_File[rt];
           // $display("and d: %d s: %d t: %d", Reg_File[rd], Reg_File[rs],  Reg_File[rt]);
          end
          `OR: begin
            Reg_File[rd] = Reg_File[rs] | Reg_File[rt];
            //$display("or d: %d s: %d t: %d", Reg_File[rd], Reg_File[rs],  Reg_File[rt]);
          end
          `SLT: begin
            if(Reg_File[rs] < Reg_File[rt]) begin
              Reg_File[rd] = 32'd1;
            end else begin
              Reg_File[rd] = 32'd0;
            end
            //$display("slt d: %d s: %d t: %d", Reg_File[rd], Reg_File[rs],  Reg_File[rt]);
          end
        endcase
      end
      else begin // I-type
        case(op_i)
          `ADDI: begin
            Reg_File[rt_i] = Reg_File[rs_i] + immediate;
            //$display("addi imme: %d s: %d t: %d", immediate, Reg_File[rs_i],  Reg_File[rt_i]);
          end
          `LW: begin
            Reg_File[rt_i] = Data_Mem[rs_i + immediate]; 
            //$display("lw imme: %d s: %d t: %d", immediate, Reg_File[rs_i],  Reg_File[rt_i]);
          end
          `SW: begin
            Data_Mem[rs_i + immediate] = Reg_File[rt_i];
            //$display("sw imme: %d s: %d t: %d", immediate, Reg_File[rs_i],  Reg_File[rt_i]);
          end
          `SLTI: begin
            if(Reg_File[rs_i] < immediate) begin
              Reg_File[rt_i] = 32'd1;
            end else begin
              Reg_File[rt_i] = 32'd0;
            end
            //$display("slti imme: %d s: %d t: %d", immediate, Reg_File[rs_i],  Reg_File[rt_i]);
          end
          `BEQ: begin
            if(Reg_File[rs_i] == Reg_File[rt_i]) begin
              pc_addr = (pc_addr + 32'd4) + (immediate * 3'd4);
              pc_addr = pc_addr - 32'd4;//fix bug because the 161 line code, in c just use continue to avoid this bug
            end else begin
              pc_addr = pc_addr;
            end
            //$display("beq pc_addr: %d s: %d t: %d", pc_addr, Reg_File[rs_i],  Reg_File[rt_i]);
          end
        endcase
      end
      pc_addr = pc_addr + 32'd4;
    end
  end
endmodule
