`timescale 1ns / 1ps

module sram_wrapper #(
    parameter DATA_WIDTH = 16,
    parameter  DEPTH = 2048
) (
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] mem_addr_in,
    input wire [DATA_WIDTH-1:0] mem_wdata_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_enable_in,
    input wire mem_clk_en,

    output reg [DATA_WIDTH-1:0] mem_rdata_out
);

    localparam ADDR_INDEX_WIDTH = $clog2(DEPTH);

    // Internal Signals
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    reg [ADDR_INDEX_WIDTH-1:0] mem_index;

    integer i;
    
    // Address Conversion Logic
    always @(*) begin
        mem_index = mem_addr_in >> 1;
    end

    // Write Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i=i+1) begin
                memory[i] <= 0;
            end
        end else if (mem_clk_en && mem_enable_in && mem_write_in) begin
            if (mem_index < DEPTH) begin
                memory[mem_index] <= mem_wdata_in;    
            end            
        end
    end

    // Read Logic
    always @(*) begin
        if (mem_enable_in && mem_read_in && (mem_index < DEPTH)) begin
            mem_rdata_out = memory[mem_index];
        end else begin
            mem_rdata_out = {DATA_WIDTH{1'b0}};
        end
    end

endmodule