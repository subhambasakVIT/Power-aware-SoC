`timescale 1ns/1ps

module branch_condition_checker #(
    parameter DATA_WIDTH = 16
) (
    input wire [DATA_WIDTH-1:0] operand_A,
    input wire [DATA_WIDTH-1:0] operand_B,
    input wire is_branch,
    input wire is_jump,
    input wire [1:0] branch_type,
    output reg branch_taken 
);

    // Internal Signals
    wire equal_flag;
    wire not_equal_flag;
    reg branch_condition;

    assign equal_flag = (operand_A == operand_B);
    assign not_equal_flag = ~equal_flag;

    always @(*) begin
        case (branch_type)
            2'b00: branch_condition = equal_flag;
            2'b01: branch_condition = not_equal_flag;
            default: branch_condition = 1'b0;
        endcase
    end

    always @(*) begin
        if (is_jump) begin
            branch_taken = 1'b1;
        end else if (is_branch) begin
            branch_taken = branch_condition;
        end else begin
            branch_taken = 1'b0;
        end
    end
    
endmodule