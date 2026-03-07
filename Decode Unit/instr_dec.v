`timescale 1ns / 1ps

module instr_dec #(
    parameter INSTR_WIDTH = 16,
    parameter REGISTER_WIDTH = 4,
    parameter IMME_WIDTH = 12
) (
    // Input Signal
    input wire [INSTR_WIDTH-1:0] instr,

    // Decoded Instruction Signals
    output reg [REGISTER_WIDTH-1:0] opcode,
    output reg [REGISTER_WIDTH-1:0] rd,     // Read Signal
    output reg [REGISTER_WIDTH-1:0] rs1,    // Sourse Reg 1
    output reg [REGISTER_WIDTH-1:0] rs2,    // Source Reg 2
    output reg [IMME_WIDTH-1:0] imm_raw,    // Immediate Value
    output reg [1:0] imm_type,              // Type of Immediate Value
    
    // ALU Control Signals
    output reg [REGISTER_WIDTH-1:0] alu_op, // Encodes ADD, SUB...
    output reg alu_src_imm,                 // Selects reg vs imm
    
    // Memory Control Signals
    output reg mem_read,                   // For LOAD ops
    output reg mem_write,                  // For STORE ops

    // Writeback Control Signals
    output reg reg_write,                  // Enables register file write
    output reg [1:0] wb_sel,               // Selects ALU Result, memoty data or PC + 2

    // Flow Control Signals
    output reg is_branch,                  
    output reg is_jump,                        
    output reg [1:0] branch_type                 
);
    
    always @(*) begin
        
        // NOP (default) Values
        rd          = 4'b0000;
        rs1         = 4'b0000;
        rs2         = 4'b0000;
        imm_raw     = 12'b0;
        imm_type    = 2'b0;
        alu_op      = 4'b0000;
        alu_src_imm = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        reg_write   = 1'b0;
        wb_sel      = 2'b00;
        is_branch   = 1'b0;
        is_jump     = 1'b0;
        branch_type = 1'b0;

        opcode      = instr[15:12];
        
        case (opcode)
            // ALU Operations
            4'b0000,
            4'b0001,
            4'b0010,
            4'b0011,
            4'b0100,
            4'b0101,
            4'b0110,
            4'b0111: begin
                rd = instr[11:8];
                rs1 = instr[7:4];
                rs2 = instr[3:0];
                alu_op = opcode;
                reg_write = 1'b1;
                wb_sel = 2'b00;
            end

            // Immediate Operations
            4'b1000, 4'b1001: begin
                rd = instr[11:8];
                rs1 = instr[7:4];
                imm_raw[3:0] = instr[3:0];
                imm_type = 2'b00;
                alu_src_imm = 1'b1;
                alu_op = (opcode == 4'b1000) ? 4'b0000 : 4'b0001;
                reg_write = 1'b1;
                wb_sel = 2'b00;
            end

            // LOAD
            4'b1010: begin
                rd = instr[11:8];
                imm_raw[7:0] = instr[7:0];
                imm_type = 2'b01;
                alu_op = 4'b0000;
                alu_src_imm = 1'b1;
                mem_read = 1'b1;
                reg_write = 1'b1;
                wb_sel = 2'b01;
            end

            // STORE
            4'b1011: begin
                rs1 = instr[11:8];
                rs2 = instr[11:8];
                imm_raw[7:0] = instr[7:0];
                imm_type = 2'b01;
                alu_op = 4'b0000;
                alu_src_imm = 1'b1;
                mem_write = 1'b1;
                reg_write = 1'b0;
            end

            // BEQ -> Branch if Equal
            4'b1100: begin
                rs1 = instr[11:8];
                rs2 = instr[7:4];
                imm_raw[3:0] = instr[3:0];
                imm_type = 2'b10;
                alu_op = 4'b0001;
                is_branch = 1'b1;
                branch_type = 2'b00;
            end

            // BNE -> Branch if not Equal
            4'b1101: begin
                rs1 = instr[11:8];
                rs2 = instr[7:4];
                imm_raw[3:0] = instr[3:0];
                imm_type = 2'b10;
                alu_op = 4'b0001;
                is_branch = 1'b1;
                branch_type = 2'b01;
            end

            // JUMP
            4'b1110: begin
                imm_raw = instr[11:0];
                imm_type = 2'b11;
                is_jump = 1'b1;
                reg_write = 1'b1;
                wb_sel = 2'b10;
            end
        endcase
    end
    
endmodule
