`timescale 1ns/1ps

module forwarding_unit #(
    parameter REGISTER_WIDTH = 4
) (
    input wire [REGISTER_WIDTH-1:0] rs1,
    input wire [REGISTER_WIDTH-1:0] rs2,
    input wire [REGISTER_WIDTH-1:0] prev_rd,
    input wire prev_reg_write,
    output reg forwardA,
    output reg forwardB
);

    // Internal Signal
    wire rs1_match;
    wire rs2_match;
    wire valid_forward;

    // Comparator Logic
    assign rs1_match = (rs1 == prev_rd);
    assign rs2_match = (rs2 == prev_rd);
    assign valid_forward = prev_reg_write && (prev_rd != 0);

    always @(*) begin
        forwardA = 1'b0;
        forwardB = 1'b0;

        if (valid_forward && rs1_match) begin
            forwardA = 1'b1;
        end 
        if (valid_forward && rs2_match) begin
            forwardB = 1'b1;
        end 
    end 
    
endmodule