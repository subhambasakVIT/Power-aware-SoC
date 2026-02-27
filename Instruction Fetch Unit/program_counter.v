`timescale 1ns / 1ps

module program_counter #(
    parameter PC_WIDTH = 16,
    parameter PC_RESET = {PC_WIDTH{1'b0}},    // reset/boot address (default 0)
    parameter PC_INC   = 16'd2                // increment (bytes) for 16-bit instructions
) (
    input  wire                     clk,
    input  wire                     rst_n,           
    input  wire                     enable,          
    input  wire [1:0]               pc_sel,          
    input  wire [PC_WIDTH-1:0]      branch_target,
    input  wire [PC_WIDTH-1:0]      jump_target,
    input  wire [PC_WIDTH-1:0]      exception_vector,
    output reg  [PC_WIDTH-1:0]      pc,              // current PC 
    output wire [PC_WIDTH-1:0]      next_pc          // combinational next PC
);

    // combinational next pc candidates
    wire [PC_WIDTH-1:0] pc_plus_inc;
    assign pc_plus_inc = pc + PC_INC;

    assign next_pc = (pc_sel == 2'b00) ? pc_plus_inc :
                     (pc_sel == 2'b01) ? branch_target :
                     (pc_sel == 2'b10) ? jump_target :
                                         exception_vector;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= PC_RESET;
        end else begin
            if (enable) begin
                pc <= next_pc;
            end else begin
                pc <= pc; // hold on stall
            end
        end
    end
endmodule
