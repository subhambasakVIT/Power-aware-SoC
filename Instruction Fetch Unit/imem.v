`timescale 1ns / 1ps

module imem #(
    parameter PC_WIDTH    = 16,           // Program Counter Width
    parameter INSTR_WIDTH = 16,           // Instruction Width
    parameter DEPTH       = 8,            // Number of instructions in the memory
    parameter NOP_INSTR   = 0             // Value returned for invalid or unused addresses
) (
    input wire [PC_WIDTH-1:0]       addr,                 // PC Value
    output reg [INSTR_WIDTH-1:0]    instr                 // Fetched Instruction
);
    reg [INSTR_WIDTH-1:0] mem [0: DEPTH-1];     // Memory Declaration
    reg [$clog2(DEPTH):0] instr_index;          // Instruction Index

    
    always @(*) begin
        instr_index = addr >> 1;            // Byte Address --> Instruction Index
        if (instr_index < DEPTH) begin      // Bound Check
            instr = mem[instr_index];
        end else begin
            instr = NOP_INSTR;
        end
    end

    // Instruction Memory Initialization
    initial begin
        mem[0] = 16'h1111;
        mem[1] = 16'h2222;
        mem[2] = 16'h3333;
        mem[3] = 16'h4444;
        mem[4] = 16'h5555;
        mem[5] = 16'h6666;
        mem[6] = 16'h7777;
        mem[7] = NOP_INSTR;
    end
    
endmodule