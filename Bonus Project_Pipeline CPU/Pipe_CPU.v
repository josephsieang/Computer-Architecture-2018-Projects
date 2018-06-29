`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/03
 * Design Name: 	Pipeline CPU
 * Module Name:		Pipe_CPU 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 
 * Please DO NOT change the module name, or your'll get ZERO point.
 * You should add your code here to complete the project 3.
 ******************************************************************/
module Pipe_CPU(
        clk_i,
		rst_i
		);
    
/****************************************
*            I/O ports                  *
****************************************/
input clk_i;
input rst_i;

/****************************************
*          Internal signal              *
****************************************/

/**** IF stage ****/
wire [31:0] mux_pc_result_w;
wire [31:0] pc_addr_w;
wire [31:0] instr_w;
wire [31:0] MEM_PCSrc;
wire [31:0] add1_result_w;
wire PCSrc;//mux select signal

wire [31:0] IF_ID_instr_w;
wire [31:0] IF_ID_add1_result_w;
wire [31:0] add1_source_w;

assign add1_source_w = 32'd4;
 

/**** ID stage ****/
//EX
wire ctrl_write_mux_w; //RegDst
wire [2:0]  ctrl_alu_op_w; //ALUop
wire ctrl_alu_mux_w; //ALUsrc

wire ID_EX_RegDst;
wire [2:0] ID_EX_ALUop;
wire ID_EX_ALUsrc;

//M
wire ctrl_branch_w; //Branch
wire ctrl_mem_read_w; //MemRead
wire ctrl_mem_write_w; //MemWrite

wire ID_EX_branch;
wire ID_EX_MemRead;
wire ID_EX_MemWrite;

//WB
wire ctrl_register_write_w; //RegWrite
wire ctrl_mem_mux_w;  //MemToReg

wire ID_EX_RegWrite;
wire ID_EX_MemToReg;


wire [31:0] rf_rs_data_w;
wire [31:0] ID_EX_rf_rs_data_w;
wire [31:0] rf_rt_data_w;
wire [31:0] ID_EX_rf_rt_data_w;
wire [31:0] sign_extend_w;
wire [31:0] ID_EX_sign_extend_w;
wire [4:0] ID_EX_RegRs_w;
wire [4:0] ID_EX_RegRt_w;
wire [4:0] ID_EX_RegRd_w;
wire [31:0] ID_EX_add1_result_w;

//handling branch hazard
wire [31:0] ALU_branch_Mux_1_w;
wire [31:0] ALU_branch_Mux_2_w;
wire [31:0] ALU_branch_result_w;
wire ALU_branch_zero_w;


/**** EX stage ****/
//M
wire EX_MEM_branch;
wire EX_MEM_MemRead;
wire EX_MEM_MemWrite;

//WB
wire EX_MEM_RegWrite;
wire EX_MEM_MemToReg;


wire [31:0] add2_sum_w;
wire [31:0] EX_MEM_add2_sum_w;
wire [3:0]  alu_control_w;
wire alu_zero_w;
wire EX_MEM_alu_zero_w;
wire [31:0] alu_result_w;
wire [31:0] EX_MEM_alu_result_w;
wire [4:0] MUX_RegDst_w;
wire [4:0] EX_MEM_MUX_RegDst_w;
wire [31:0] MUX_ALU_src1_w;
wire [31:0] MUX_ALU_src2_w1;
wire [31:0] MUX_ALU_src2_w2;
wire [31:0] EX_MEM_Data_Write;

/**** MEM stage ****/
//WB
wire MEM_WB_RegWrite;
wire MEM_WB_MemToReg;


wire [31:0] dataMem_read_w;
wire [31:0] MEM_WB_dataMem_read_w;
wire [31:0] MEM_WB_alu_result_w;
wire [4:0] MEM_WB_RegRd;

assign PCSrc = ALU_branch_zero_w & ctrl_branch_w;

/**** WB stage ****/
wire [31:0] MUX_WB_w;


/**** Data hazard ****/
wire [1:0] forwardA;
wire [1:0] forwardB;
wire [1:0] forwardA_branch;
wire [1:0] forwardB_branch;



/****************************************
*       Instantiate modules             *
****************************************/
//Instantiate the components in IF stage
ProgramCounter PC(
	.clk_i(clk_i),      
	.rst_i(rst_i),     
	.pc_in_i(mux_pc_result_w),   
	.pc_out_o(pc_addr_w)
);

Instr_Memory IM(
	.pc_addr_i(pc_addr_w),  
	.instr_o(instr_w)  
);
			
Adder Add_pc(
	.src1_i(pc_addr_w),     
	.src2_i(add1_source_w),     
	.sum_o(add1_result_w)  
);

MUX_2to1 #(.size(32)) Mux_PC(
    .data0_i(add1_result_w),
    .data1_i(MEM_PCSrc),
    .select_i(PCSrc),
    .data_o(mux_pc_result_w)
);

		
Pipe_Reg #(.size(32)) IF_ID_PC(       
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(add1_result_w),
    .data_o(IF_ID_add1_result_w)
);

Pipe_Reg #(.size(32)) IF_ID_Instr(       
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(instr_w),
    .data_o(IF_ID_instr_w)
);
		
//Instantiate the components in ID stage
Reg_File RF(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.RSaddr_i(IF_ID_instr_w[25:21]) ,
	.RTaddr_i(IF_ID_instr_w[20:16]) ,
	.RDaddr_i(MEM_WB_RegRd) ,
	.RDdata_i(MUX_WB_w),
	.RegWrite_i(MEM_WB_RegWrite),
	.RSdata_o(rf_rs_data_w) ,
	.RTdata_o(rf_rt_data_w)
);

Decoder Control(
	.instr_op_i(IF_ID_instr_w[31:26]), 
	.RegWrite_o(ctrl_register_write_w), 
	.ALU_op_o(ctrl_alu_op_w),   
	.ALUSrc_o(ctrl_alu_mux_w),   
	.RegDst_o(ctrl_write_mux_w),   
	.Branch_o(ctrl_branch_w), 
	.MemWrite_o(ctrl_mem_write_w),
	.MemRead_o(ctrl_mem_read_w),
	.MemtoReg_o(ctrl_mem_mux_w)
);

Sign_Extend Sign_Extend(
	.data_i(IF_ID_instr_w[15:0]),
    .data_o(sign_extend_w)
);	

Pipe_Reg #(.size(1)) ID_EX_REG_DST(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_write_mux_w),
    .data_o(ID_EX_RegDst)

);

Pipe_Reg #(.size(3)) ID_EX_ALU_OP(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_alu_op_w),
    .data_o(ID_EX_ALUop)
);

Pipe_Reg #(.size(1)) ID_EX_ALU_SRC(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_alu_mux_w),
    .data_o(ID_EX_ALUsrc)
);

Pipe_Reg #(.size(1)) ID_EX_BRANCH(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_branch_w),
    .data_o(ID_EX_branch)
);

Pipe_Reg #(.size(1)) ID_EX_MEMREAD(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_mem_read_w),
    .data_o(ID_EX_MemRead)
);

Pipe_Reg #(.size(1)) ID_EX_MEMWRITE(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_mem_write_w),
    .data_o(ID_EX_MemWrite)
);

Pipe_Reg #(.size(1)) ID_EX_REGWRITE(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_register_write_w),
    .data_o(ID_EX_RegWrite)
);

Pipe_Reg #(.size(1)) ID_EX_MEM_TO_REG(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ctrl_mem_mux_w),
    .data_o(ID_EX_MemToReg)
);

Pipe_Reg #(.size(32)) ID_EX_RF_data1(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(rf_rs_data_w),
    .data_o(ID_EX_rf_rs_data_w)
);

Pipe_Reg #(.size(32)) ID_EX_RF_data2(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(rf_rt_data_w),
    .data_o(ID_EX_rf_rt_data_w)
);

Pipe_Reg #(.size(5)) ID_EX_RegRs(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.data_i(IF_ID_instr_w[25:21]),
	.data_o(ID_EX_RegRs_w)
);

Pipe_Reg #(.size(5)) ID_EX_RegRt(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(IF_ID_instr_w[20:16]),
    .data_o(ID_EX_RegRt_w)
);

Pipe_Reg #(.size(5)) ID_EX_REG_RD(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(IF_ID_instr_w[15:11]),
    .data_o(ID_EX_RegRd_w)
);

Pipe_Reg #(.size(32)) ID_EX_SE(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(sign_extend_w),
    .data_o(ID_EX_sign_extend_w)
);

//handling branch hazard
MUX_3to1 #(.size(32)) ALU_BRANCH_MUX_1(
    .data0_i(rf_rs_data_w),
    .data1_i(MUX_WB_w),
    .data2_i(EX_MEM_alu_result_w),
    .select_i(forwardA_branch),
    .data_o(ALU_branch_Mux_1_w)
);

MUX_3to1 #(.size(32)) ALU_BRANCH_MUX_2(
    .data0_i(rf_rt_data_w),
    .data1_i(MUX_WB_w),
    .data2_i(EX_MEM_alu_result_w),
    .select_i(forwardB_branch),
    .data_o(ALU_branch_Mux_2_w)
);

ALU ALU_branch(
    .src1_i(ALU_branch_Mux_1_w),
    .src2_i(ALU_branch_Mux_2_w),
    .ctrl_i(4'b1001),
    .result_o(ALU_branch_result_w),
    .zero_o(ALU_branch_zero_w)
);
		
//Instantiate the components in EX stage	   
ALU ALU(
	.src1_i(MUX_ALU_src1_w),
	.src2_i(MUX_ALU_src2_w2),
	.ctrl_i(alu_control_w),
	.result_o(alu_result_w),
	.zero_o(alu_zero_w)
);
		
ALU_Ctrl ALU_Control(
	.funct_i(ID_EX_sign_extend_w[5:0]),   
    .ALUOp_i(ID_EX_ALUop),   
    .ALUCtrl_o(alu_control_w) 
);

MUX_3to1 #(.size(32)) Mux_ALU_src1(
    .data0_i(ID_EX_rf_rs_data_w),
    .data1_i(MUX_WB_w),
    .data2_i(EX_MEM_alu_result_w),
    .select_i(forwardA),
    .data_o(MUX_ALU_src1_w)
);
        
MUX_3to1 #(.size(32)) Mux_ALU_src2_A(
    .data0_i(ID_EX_rf_rt_data_w),
    .data1_i(MUX_WB_w),
    .data2_i(EX_MEM_alu_result_w),
    .select_i(forwardB),
    .data_o(MUX_ALU_src2_w1)
);

MUX_2to1 #(.size(32)) Mux_ALU_src2_B(
    .data0_i(MUX_ALU_src2_w1),
    .data1_i(ID_EX_sign_extend_w),
    .select_i(ID_EX_ALUsrc),
    .data_o(MUX_ALU_src2_w2)
); 

MUX_2to1 #(.size(5)) Mux_RegDst(
	.data0_i(ID_EX_RegRt_w),
    .data1_i(ID_EX_RegRd_w),
    .select_i(ID_EX_RegDst),
    .data_o(MUX_RegDst_w)
);
		

Pipe_Reg #(.size(1)) EX_MEM_BRANCH(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ID_EX_branch),
    .data_o(EX_MEM_branch)
);

Pipe_Reg #(.size(1)) EX_MEM_MEMREAD(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ID_EX_MemRead),
    .data_o(EX_MEM_MemRead)
);

Pipe_Reg #(.size(1)) EX_MEM_MEMWRITE(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ID_EX_MemWrite),
    .data_o(EX_MEM_MemWrite)
);

Pipe_Reg #(.size(1)) EX_MEM_REGWRITE(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ID_EX_RegWrite),
    .data_o(EX_MEM_RegWrite)
);

Pipe_Reg #(.size(1)) EX_MEM_MEM_TO_REG(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(ID_EX_MemToReg),
    .data_o(EX_MEM_MemToReg)
);

Pipe_Reg #(.size(32)) EX_MEM_ALU_Result(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(alu_result_w),
    .data_o(EX_MEM_alu_result_w)
);
Pipe_Reg #(.size(1)) EX_MEM_ALU_zero(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(alu_zero_w),
    .data_o(EX_MEM_alu_zero_w)
);

Pipe_Reg #(.size(32)) EX_MEM_DATA_WRITE(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(MUX_ALU_src2_w1),
    .data_o(EX_MEM_Data_Write)
);

Pipe_Reg #(.size(5)) EX_MEM_REG_RD(
	.rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(MUX_RegDst_w),
    .data_o(EX_MEM_MUX_RegDst_w)
);
			   
//Instantiate the components in MEM stage
Data_Memory DM(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.addr_i(EX_MEM_alu_result_w),
	.data_i(EX_MEM_Data_Write),
	.MemRead_i(EX_MEM_MemRead),
	.MemWrite_i(EX_MEM_MemWrite),
	.data_o(dataMem_read_w)
);

Pipe_Reg #(.size(1)) MEM_WB_REG_WRITE(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(EX_MEM_RegWrite),
    .data_o(MEM_WB_RegWrite)
);

Pipe_Reg #(.size(1)) MEM_WB_MEM_TO_REG(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(EX_MEM_MemToReg),
    .data_o(MEM_WB_MemToReg)
);

Pipe_Reg #(.size(32)) MEM_WB_DM_readData(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(dataMem_read_w),
    .data_o(MEM_WB_dataMem_read_w)    
);

Pipe_Reg #(.size(32)) MEM_WB_ALU_Result(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(EX_MEM_alu_result_w),
    .data_o(MEM_WB_alu_result_w)   
);

Pipe_Reg #(.size(5)) MEM_WB_ALU_REG_RD(
    .rst_i(rst_i),
    .clk_i(clk_i),
    .data_i(EX_MEM_MUX_RegDst_w),
    .data_o(MEM_WB_RegRd)
);

//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux3(
	.data0_i(MEM_WB_alu_result_w),
    .data1_i(MEM_WB_dataMem_read_w),
    .select_i(MEM_WB_MemToReg),
    .data_o(MUX_WB_w)
);

//Forwarding Unit
ForwardinUnit ForwardingUnit(
    .EX_MEMRegWrite(EX_MEM_RegWrite),
    .MEM_WBRegWrite(MEM_WB_RegWrite),
    .EX_MEMRegisterRd(EX_MEM_MUX_RegDst_w),
    .MEM_WBRegisterRd(MEM_WB_RegRd),
    .ID_EXRegisterRs(ID_EX_RegRs_w),
    .ID_EXRegisterRt(ID_EX_RegRt_w),
    .ForwardA(forwardA),
    .ForwardB(forwardB)
);

//Forwarding Unit for handling branch hazard
ForwardinUnit ForwardingUnit_Branch(
    .EX_MEMRegWrite(EX_MEM_RegWrite),
    .MEM_WBRegWrite(MEM_WB_RegWrite),
    .EX_MEMRegisterRd(EX_MEM_MUX_RegDst_w),
    .MEM_WBRegisterRd(MEM_WB_RegRd),
    .ID_EXRegisterRs(IF_ID_instr_w[25:21]),
    .ID_EXRegisterRt(IF_ID_instr_w[20:16]),
    .ForwardA(forwardA_branch),
    .ForwardB(forwardB_branch)
);

/****************************************
*         Signal assignment             *
****************************************/
	
endmodule

