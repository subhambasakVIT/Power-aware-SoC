`timescale 1ns / 1ps

module branch_target_calculator #(
    parameter PC_WIDTH = 16,
    parameter IMM_WIDTH = 16
) (
    input  wire [PC_WIDTH-1:0]      pc,           // Current PC value
    input  wire [IMM_WIDTH-1:0]     immediate,    // Immediate value from instruction
    input  wire                     is_jalr,      // JALR instruction flag
    input  wire [PC_WIDTH-1:0]      rs1_data,     // Register data for JALR
    output wire [PC_WIDTH-1:0]      target_addr,  // Calculated target address
    output wire                     misaligned    // Flag for misaligned address
);

    // Internal signals
    wire [PC_WIDTH-1:0] pc_plus_imm;
    wire [PC_WIDTH-1:0] reg_plus_imm;
    
    // Calculate PC + immediate 
    assign pc_plus_imm = pc + immediate;
    
    // Calculate register + immediate 
    assign reg_plus_imm = rs1_data + immediate;
    
    // Select target based on instruction type
    assign target_addr = is_jalr ? reg_plus_imm : pc_plus_imm;
    
    // Misaligned address 
    assign misaligned = target_addr[0]; 
    
endmodule