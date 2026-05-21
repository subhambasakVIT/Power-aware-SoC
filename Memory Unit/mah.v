`timescale 1ns / 1ps

module mah #(
    parameter DATA_WIDTH = 16
) (
    input wire [DATA_WIDTH-1:0] mem_addr_in,
    input wire [DATA_WIDTH-1:0] mem_wdata_in,
    input wire [DATA_WIDTH-1:0] mem_rdata_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_valid_in,

    output wire [DATA_WIDTH-1:0] mem_addr_out,
    output wire [DATA_WIDTH-1:0] mem_wdata_out,
    output wire [DATA_WIDTH-1:0] mem_rdata_out,
    output wire mem_read_out,
    output wire mem_write_out,
    output wire mem_valid_out,
    output wire misaligned_access,
    output wire mem_kill_out
);

        // Misalignment Detection
        assign misaligned_access = mem_addr_in[0];

        // Forcing Alignment
        assign mem_addr_out = {mem_addr_in[DATA_WIDTH-1:1], 1'b0};

        // Parsing Write Data
        assign mem_wdata_out = mem_wdata_in;

        // Parsing Read Data
        assign mem_rdata_out = mem_rdata_in;

        // Parsing Control Signals
        assign mem_read_out = mem_read_in;
        assign mem_write_out = mem_write_in;
        assign mem_valid_out = mem_valid_in;

        // Kill Operation
        assign mem_kill_out = misaligned_access;
    
endmodule