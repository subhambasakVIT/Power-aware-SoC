`timescale 1ns/1ps

module hazard_detection #(
    parameter REG_WIDTH = 4
) (
    input wire [REG_WIDTH-1:0] rs1,
    input wire [REG_WIDTH-1:0] rs2,
    input wire [REG_WIDTH-1:0] prev_rd,
    input wire prev_mem_read,
    output stall,
    output pc_en,
    output if_de_en,
    output bubble
);

    // Internal Signals
    wire rs1_hazard;
    wire rs2_hazard;
    wire dependency;
    wire load_hazard;

    // Detecting register matches
    assign rs1_hazard = (prev_rd == rs1);
    assign rs2_hazard = (prev_rd == rs2);

    // Checking dependency
    assign dependency = rs1_hazard | rs2_hazard;

    // Checking Load instruction
    assign load_hazard = prev_mem_read;

    // Stall Condition
    assign stall = load_hazard && dependency && (prev_rd != 4'b0000);

    // Pipeline Controls
    assign pc_en = ~stall;
    assign if_de_en = ~stall;
    assign bubble = stall;
    
endmodule