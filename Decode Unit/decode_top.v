`timescale 1ns/1ps
`include "instr_dec.v"
`include "reg_file.v"
`include "immediate_generator.v"
`include "hazard_detection.v"
`include "de_mw_reg.v"

module decode_top #(
    parameter PC_WIDTH       = 16,
    parameter DATA_WIDTH     = 16,
    parameter INSTR_WIDTH    = 16,
    parameter IMM_WIDTH      = 12,
    parameter REGISTER_WIDTH = 4
) (
    input wire                      clk,
    input wire                      rst_n,
    input wire [INSTR_WIDTH-1:0]    instr_in,
    input wire [PC_WIDTH-1:0]       pc_in,
    input wire [DATA_WIDTH-1:0]     wb_data,
    input wire [REGISTER_WIDTH-1:0] wb_rd,
    input wire                      wb_reg_write,
    input wire [REGISTER_WIDTH-1:0] prev_rd,
    input wire                      prev_mem_read,
    input wire                      flush,

    output [PC_WIDTH-1:0]       pc_out,
    output [DATA_WIDTH-1:0]     rs1_data_out,
    output [DATA_WIDTH-1:0]     rs2_data_out,
    output [INSTR_WIDTH-1:0]    imm_out,
    output [REGISTER_WIDTH-1:0] rd_out,
    output [REGISTER_WIDTH-1:0] rs1_out,
    output [REGISTER_WIDTH-1:0] rs2_out,
    output [REGISTER_WIDTH-1:0] alu_op_out,
    output                      alu_src_imm_out,
    output [REGISTER_WIDTH-1:0] shamt_out,
    output                      mem_read_out,
    output                      mem_write_out,
    output                      reg_write_out,
    output [1:0]                wb_sel_out,
    output                      is_branch_out,
    output                      is_jump_out,
    output [1:0]                branch_type_out,
    output                      pc_en,
    output                      if_de_en,
    output                      bubble
);

    // Internal Signals
    wire [REGISTER_WIDTH-1:0] opcode;
    wire [REGISTER_WIDTH-1:0] rd_dec;
    wire [REGISTER_WIDTH-1:0] rs1_dec;
    wire [REGISTER_WIDTH-1:0] rs2_dec;
    wire [DATA_WIDTH-1:0]     rs1_data;
    wire [DATA_WIDTH-1:0]     rs2_data;
    wire [IMM_WIDTH-1:0]      imm_raw;
    wire [1:0] imm_type;
    wire [INSTR_WIDTH-1:0]    imm_internal;
    wire [REGISTER_WIDTH-1:0] alu_op;
    wire                      alu_src_imm;
    wire                      mem_read;
    wire                      mem_write;
    wire                      reg_write;
    wire [1:0]                wb_sel;
    wire                      is_branch;
    wire                      is_jump;
    wire [1:0]                branch_type;
    wire [REGISTER_WIDTH-1:0] shamt;
    wire                      stall;
    wire                      pipeline_bubble;
    wire                      bubble_hdu;

    // Signal assignment
    assign bubble = bubble_hdu;
    assign pipeline_bubble = bubble_hdu | flush;
    assign shamt = instr_in[3:0];

    //------------------------
    // Instruction Decoder
    //------------------------
    instr_dec  #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .REGISTER_WIDTH(REGISTER_WIDTH),
        .IMME_WIDTH(IMM_WIDTH)
    ) decoder (
        .instr(instr_in),
        .opcode(opcode),
        .rd(rd_dec),
        .rs1(rs1_dec),
        .rs2(rs2_dec),
        .imm_raw(imm_raw),
        .imm_type(imm_type),
        .alu_op(alu_op),
        .alu_src_imm(alu_src_imm),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .wb_sel(wb_sel),
        .is_branch(is_branch),
        .is_jump(is_jump),
        .branch_type(branch_type)
    );

    //------------------------
    // Register File
    //------------------------
    reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(REGISTER_WIDTH)
    ) register_file (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_dec),
        .rs2_addr(rs2_dec),
        .rd_addr(wb_rd),
        .write_data(wb_data),
        .reg_write(wb_reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    //------------------------
    // Immediate Generator
    //------------------------
    immediate_generator #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .IMME_WIDTH(IMM_WIDTH)
    ) imm_gen (
        .imm_raw(imm_raw),
        .imm_type(imm_type),
        .imm_out(imm_internal)
    );

    //------------------------
    // Hazard Detection Unit
    //------------------------
    hazard_detection #(
        .REG_WIDTH(REGISTER_WIDTH)
    ) hdu (
        .rs1(rs1_dec),
        .rs2(rs2_dec),
        .prev_rd(prev_rd),
        .prev_mem_read(prev_mem_read),
        .stall(stall),
        .pc_en(pc_en),
        .if_de_en(if_de_en),
        .bubble(bubble_hdu)
    );

    //-----------------------------------
    // Decode-MemoryWriteback Register
    //-----------------------------------
    de_mw_reg #(
        .PC_WIDTH(PC_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH),
        .REGISTER_WIDTH(REGISTER_WIDTH)
    ) de_mw_reg_dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(if_de_en),
        .bubble(pipeline_bubble),
        .pc_in(pc_in),
        .rs1_data_in(rs1_data),
        .rs2_data_in(rs2_data),
        .imm_in(imm_internal),
        .rd_in(rd_dec),
        .rs1_in(rs1_dec),
        .rs2_in(rs2_dec),
        .alu_op_in(alu_op),
        .alu_src_imm_in(alu_src_imm),
        .shamt_in(shamt),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .reg_write_in(reg_write),
        .wb_sel_in(wb_sel),
        .is_branch_in(is_branch),
        .is_jump_in(is_jump),
        .branch_type_in(branch_type),
        .pc_out(pc_out),
        .rs1_data_out(rs1_data_out),
        .rs2_data_out(rs2_data_out),
        .imm_out(imm_out),
        .rd_out(rd_out),
        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .alu_op_out(alu_op_out),
        .alu_src_imm_out(alu_src_imm_out),
        .shamt_out(shamt_out),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .reg_write_out(reg_write_out),
        .wb_sel_out(wb_sel_out),
        .is_branch_out(is_branch_out),
        .is_jump_out(is_jump_out),
        .branch_type_out(branch_type_out)       
    );
    
endmodule