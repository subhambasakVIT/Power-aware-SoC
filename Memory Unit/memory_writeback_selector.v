`timescale 1ns / 1ps

module memory_writeback_selector #(
    parameter DATA_WIDTH = 16,
    parameter PC_WIDTH = 16,
    parameter REGISTER_WIDTH = 4
) (
    input wire [DATA_WIDTH-1:0] alu_result_in,
    input wire [DATA_WIDTH-1:0] mem_result_in,
    input wire [PC_WIDTH-1:0] pc_in,
    input wire [1:0] wb_sel_in,
    input wire flush,
    input wire branch_taken_in,
    input wire [REGISTER_WIDTH-1:0] rd_in,
    input wire reg_write_in,

    output wire [DATA_WIDTH-1:0] wb_data_out,
    output wire [REGISTER_WIDTH-1:0] rd_out,
    output wire reg_write_out
);

    // Internal Signal
    reg [DATA_WIDTH-1:0] wb_data;

    // Writeback Select Logic
    always @(*) begin
        case (wb_sel_in)
            2'b00: wb_data = alu_result_in;
            2'b01: wb_data = mem_result_in;
            2'b10: wb_data = pc_in + 16'd2;
            default: wb_data = {DATA_WIDTH{1'b0}};
        endcase
    end

    // Control Logic
    assign reg_write_out = (flush || branch_taken_in) ? 1'b0 : reg_write_in;
    assign rd_out = (flush || branch_taken_in) ? {REGISTER_WIDTH{1'b0}} : rd_in;
    assign wb_data_out = (flush || branch_taken_in) ? {DATA_WIDTH{1'b0}} : wb_data; 
    
endmodule