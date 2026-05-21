`timescale 1ns / 1ps

module mw_wb_reg #(
    parameter DATA_WIDTH = 16,
    parameter REGISTER_WIDTH = 4
) (
    // Clock and Reset
    input wire clk,
    input wire rst_n,

    // Pipeline Control
    input wire enable,
    input wire flush,
    input wire branch_taken_in,

    // Writeback Inputs
    input wire [DATA_WIDTH-1:0] wb_data_in,
    input wire [REGISTER_WIDTH-1:0] rd_in,
    input wire reg_write_in,
    
    // Outputs to reg file
    output wire [DATA_WIDTH-1:0] wb_data_out,
    output wire [REGISTER_WIDTH-1:0] rd_out,
    output wire reg_write_out
);

    // Internal Signal
    reg [DATA_WIDTH-1:0] wb_data_reg;
    reg [REGISTER_WIDTH-1:0] rd_reg;
    reg reg_write_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_data_reg <= {DATA_WIDTH{1'b0}};
            rd_reg <= {REGISTER_WIDTH{1'b0}};
            reg_write_reg <= 1'b0;
        end else if (enable) begin
            if (flush || branch_taken_in) begin
                wb_data_reg <= {DATA_WIDTH{1'b0}};
                rd_reg <= {REGISTER_WIDTH{1'b0}};
                reg_write_reg <= 1'b0;
            end else begin
                wb_data_reg <= wb_data_in;
                rd_reg <= rd_in;
                reg_write_reg <= reg_write_in;
            end
        end else begin
            wb_data_reg <= wb_data_reg;
            rd_reg <= rd_reg;
            reg_write_reg <= reg_write_reg;
        end
    end

    assign wb_data_out = wb_data_reg;
    assign rd_out = rd_reg;
    assign reg_write_out = reg_write_reg;
    
endmodule