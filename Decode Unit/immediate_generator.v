`timescale 1ns/1ps

module immediate_generator #(
    parameter INSTR_WIDTH = 16,
    parameter IMME_WIDTH = 12
) (
    input wire [IMME_WIDTH-1:0] imm_raw,
    input wire [1:0] imm_type,
    output reg [INSTR_WIDTH-1:0] imm_out
);
    // Raw immediate signals
    wire [3:0] imm4_raw; 
    wire [7:0] imm8_raw; 
    wire [11:0] imm12_raw;

    
    assign imm4_raw = imm_raw[3:0];
    assign imm8_raw = imm_raw[7:0];
    assign imm12_raw = imm_raw[11:0];

    // Sign extended immediate signals
    wire [INSTR_WIDTH-1:0] imm4_ext;
    wire [INSTR_WIDTH-1:0] imm8_ext;
    wire [INSTR_WIDTH-1:0] imm12_ext;

    assign imm4_ext = {{12{imm4_raw[3]}}, imm4_raw};
    assign imm8_ext = {{8{imm8_raw[7]}}, imm8_raw};
    assign imm12_ext = {{4{imm12_raw[11]}}, imm12_raw};

    // Branch and Jump immediate signals
    wire [INSTR_WIDTH-1:0] branch_imm;
    wire [INSTR_WIDTH-1:0] jump_imm;
    
    assign branch_imm = imm4_ext << 1;  
    assign jump_imm = imm12_ext << 1;

    // Immediate signal selection logic
    always @(*) begin
        case (imm_type)
            2'b00: imm_out = imm4_ext; 
            2'b01: imm_out = imm8_ext;
            2'b10: imm_out = branch_imm;
            2'b11: imm_out = jump_imm;
            default: imm_out = {INSTR_WIDTH{1'b0}};
        endcase
    end
    
endmodule

