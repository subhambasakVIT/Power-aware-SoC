`timescale 1ns / 1ps

module lsi #(
    parameter DATA_WIDTH     = 16,
    parameter REGISTER_WIDTH = 4,
    parameter PC_WIDTH = 16
) (
    input wire [DATA_WIDTH-1:0]     alu_result_in,
    input wire [DATA_WIDTH-1:0]     rs2_data_in,
    input wire                      mem_read_in,
    input wire                      mem_write_in,
    input wire                      reg_write_in,
    input wire [REGISTER_WIDTH-1:0] rd_in,
    input wire                      branch_taken_in,
    input wire                      enable,
    input wire                      flush,
    input wire [1:0]                wb_sel_in,
    input wire [PC_WIDTH-1:0]       pc_in,

    output wire [DATA_WIDTH-1:0]    mem_addr,
    output wire [DATA_WIDTH-1:0]    mem_wdata,
    output wire                     mem_read,
    output wire                     mem_write,
    output wire                     mem_valid,

    output wire                     reg_write_out,
    output wire [REGISTER_WIDTH-1:0] rd_out,
    output wire [1:0]               wb_sel_out,

    output wire [DATA_WIDTH-1:0] alu_result_out,
    output wire [PC_WIDTH-1:0]   pc_out   // if using JAL   
);

    // Address and Data Path
    assign mem_addr  = alu_result_in;
    assign mem_wdata = rs2_data_in;
    
    // Control Logic
    assign mem_read  = (flush || branch_taken_in || !enable) ? 1'b0 : mem_read_in;
    assign mem_write = (flush || branch_taken_in || !enable) ? 1'b0 : mem_write_in;

    assign mem_valid = mem_read || mem_write;

    // Pipeline Pass-through
    assign rd_out        = (flush || branch_taken_in) ? {REGISTER_WIDTH{1'b0}} : rd_in;
    assign reg_write_out = (flush || branch_taken_in || !enable) ? 1'b0 : reg_write_in;

    // Wb Selec Logic
    assign wb_sel_out = (flush || branch_taken_in) ? 2'b00 : wb_sel_in;

    // Forwarding Signals to MWS
    assign alu_result_out = alu_result_in;
    assign pc_out = pc_in;

endmodule