`timescale 1ns / 1ps
`include "program_counter.v"
`include "if_de_reg.v"
`include "imem.v"

module ifu_top #(
    parameter PC_WIDTH    = 16,                     // Program Counter width
    parameter INSTR_WIDTH = 16                      // Instruction Width
) (
    // Input Signals
    input wire                    clk,
    input wire                    rst_n,
    input wire                    stall,
    input wire                    flush,
    input wire [1:0]              pc_sel,
    input wire [PC_WIDTH-1:0]     branch_target,
    input wire [PC_WIDTH-1:0]     jump_target,
    input wire [PC_WIDTH-1:0]     exception_vector,

    // Output Signals
    output wire [PC_WIDTH-1:0]    if_pc,            // Program Counter value and the IF stage
    output wire [INSTR_WIDTH-1:0] if_instr          // Instruction at the IF stage
);

    // Internal Signals
    wire                          enable;
    wire [PC_WIDTH-1:0]           pc_current;
    wire [PC_WIDTH-1:0]           pc_next;
    wire [INSTR_WIDTH-1:0]        imem_instr;

    // Enable Logic (stall freezes PC and if_de_reg)
    assign enable = ~stall;

    //----------------------------
    // Program Counter
    //----------------------------
    program_counter #(
        .PC_WIDTH(PC_WIDTH)
    ) pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .pc_sel(pc_sel),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .exception_vector(exception_vector),
        .pc(pc_current),
        .next_pc(pc_next)
    );

    //----------------------------
    // Instruction Memory
    //----------------------------
    imem #(
        .PC_WIDTH(PC_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) imem_inst (
        .addr(pc_current),
        .instr(imem_instr)
    );

    //----------------------------
    // IF/DE Register
    //----------------------------
    if_de_reg #(
        .PC_WIDTH(PC_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) if_de_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .flush(flush),
        .instr_in(imem_instr),
        .pc_in(pc_current),
        .instr_out(if_instr),
        .pc_out(if_pc)
    );

endmodule