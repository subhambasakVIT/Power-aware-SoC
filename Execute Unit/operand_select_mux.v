`timescale 1ns/1ps

module operand_select_mux #(
    parameter DATA_WIDTH = 16
) (
    input wire [DATA_WIDTH-1:0]     rs1_data,       // Register 1 Data
    input wire [DATA_WIDTH-1:0]     rs2_data,       // Register 2 Data
    input wire [DATA_WIDTH-1:0]     imm_data,       // Immediate Data
    input wire [DATA_WIDTH-1:0]     forward_data,   // Forwarded data from forwarding unit
    input wire                      alu_src_imm,    // reg vs imm data selection signal
    input wire                      forwardA,       // Reg 1 forwarded flag
    input wire                      forwardB,       // Reg 2 forwarded flag
    output     [DATA_WIDTH-1:0]     operand_A,      // First operand going to the ALU
    output     [DATA_WIDTH-1:0]     operand_B       // Second operand going to the ALU
);

    // Internal Signals
    wire [DATA_WIDTH-1:0] rs2_forward_mux;

    assign operand_A       = (forwardA) ? forward_data : rs1_data;
    assign rs2_forward_mux = (forwardB) ? forward_data : rs2_data;
    assign operand_B       = (alu_src_imm) ? imm_data : rs2_forward_mux;
    
endmodule