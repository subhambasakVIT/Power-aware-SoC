`timescale 1ns/1ps
`include "forwarding_unit.v"
`include "operand_select_mux.v"
`include "alu_16_bit.v"
`include "branch_condition_checker.v"

module execute_top #(
    parameter DATA_WIDTH = 16,
    parameter REGISTER_WIDTH = 4,
    parameter PC_WIDTH = 16
) (
    input wire [PC_WIDTH-1:0] pc_in,
    input wire [DATA_WIDTH-1:0] rs1_data,
    input wire [DATA_WIDTH-1:0] rs2_data,
    input wire [DATA_WIDTH-1:0] imm_data,
    input wire [REGISTER_WIDTH-1:0] rd,
    input wire [REGISTER_WIDTH-1:0] rs1,
    input wire [REGISTER_WIDTH-1:0] rs2,
    input wire [3:0] alu_op,
    input wire alu_src_imm,
    input wire [3:0] shamt,
    input wire is_branch,
    input wire is_jump,
    input wire [1:0] branch_type,
    input wire [REGISTER_WIDTH-1:0] prev_rd,
    input wire prev_reg_write,
    input wire [DATA_WIDTH-1:0] forward_data,
    input wire mem_read,
    input wire mem_write,
    input wire reg_write,
    input wire [1:0] wb_sel,

    output [PC_WIDTH-1:0] pc_out,
    output [DATA_WIDTH-1:0] alu_result,
    output [DATA_WIDTH-1:0] store_data_out,
    output [REGISTER_WIDTH-1:0] rd_out,
    output branch_taken,
    output [PC_WIDTH-1:0] branch_target,
    output mem_read_out,
    output mem_write_out,
    output reg_write_out,
    output [1:0] wb_sel_out
);

    // Internal Signals
    wire forwardA;
    wire forwardB;
    wire [DATA_WIDTH-1:0] operand_A;
    wire [DATA_WIDTH-1:0] operand_B;
    wire [31:0] alu_result_int;
    wire carry_out;
    wire [DATA_WIDTH-1:0] remainder;
    wire branch_taken_int;
    wire [PC_WIDTH-1:0] branch_target_int;
    wire cin;

    assign cin = (alu_op == 4'b0001);

    //--------------------
    // Forwarding Unit
    //--------------------
    forwarding_unit #(
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) forward_unit (
        .rs1(rs1),
        .rs2(rs2),
        .prev_rd(prev_rd),
        .prev_reg_write(prev_reg_write),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    //----------------------
    // Operand Select Mux
    //----------------------
    operand_select_mux #(
        .DATA_WIDTH(DATA_WIDTH)
    ) osm (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_data(imm_data),
        .forward_data(forward_data),
        .alu_src_imm(alu_src_imm),
        .forwardA(forwardA),
        .forwardB(forwardB),
        .operand_A(operand_A),
        .operand_B(operand_B)
    );

    //--------------------
    // ALU
    //--------------------
    alu_16_bit ALU (
        .A(operand_A),
        .B(operand_B),
        .shamt(shamt),
        .sel(alu_op),
        .cin(cin),
        .result(alu_result_int),
        .remainder(remainder),
        .carry_out(carry_out)
    );

    //----------------------------
    // Branch Condition Checker
    //----------------------------
    branch_condition_checker #(
        .DATA_WIDTH(DATA_WIDTH)
    ) BCC (
        .operand_A(operand_A),
        .operand_B(operand_B),
        .is_branch(is_branch),
        .is_jump(is_jump),
        .branch_type(branch_type),
        .branch_taken(branch_taken_int)
    );

    assign branch_target_int = pc_in + imm_data; 
    assign alu_result = alu_result_int[15:0];
    assign store_data_out = operand_B;
    assign pc_out = pc_in;
    assign rd_out = rd;
    assign mem_read_out = mem_read;
    assign mem_write_out = mem_write;
    assign reg_write_out = reg_write;
    assign wb_sel_out = wb_sel;
    assign branch_taken = branch_taken_int;
    assign branch_target = branch_target_int;
    
endmodule