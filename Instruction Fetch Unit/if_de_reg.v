`timescale 1ns / 1ps

module if_de_reg #(
    parameter INSTR_WIDTH = 16,
    parameter PC_WIDTH    = 16,
    parameter NOP_INSTR   = {INSTR_WIDTH{1'b0}}, 
    parameter PC_RESET    = {PC_WIDTH{1'b0}}
) (
    input  wire                         clk,
    input  wire                         rst_n,       
    input  wire                         enable,      
    input  wire                         flush,       
    input  wire [INSTR_WIDTH-1:0]       instr_in,
    input  wire [PC_WIDTH-1:0]          pc_in,
    output reg  [INSTR_WIDTH-1:0]       instr_out,
    output reg  [PC_WIDTH-1:0]          pc_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_out <= NOP_INSTR;
            pc_out    <= PC_RESET;
        end else begin
            if (flush) begin
                instr_out <= NOP_INSTR;
                pc_out    <= PC_RESET;
            end else if (enable) begin
                instr_out <= instr_in;
                pc_out    <= pc_in;
            end else begin
                instr_out <= instr_out; // hold
                pc_out    <= pc_out;
            end
        end
    end

endmodule
