`timescale 1ns / 1ps

module mac #(
    parameter DATA_WIDTH = 16
) (
    input wire [DATA_WIDTH-1:0] mem_addr_in,
    input wire [DATA_WIDTH-1:0] mem_wdata_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_valid_in,
    input wire mem_kill_in,
    input wire [DATA_WIDTH-1:0] mem_rdata_in,

    output wire [DATA_WIDTH-1:0] mem_addr_out,
    output wire [DATA_WIDTH-1:0] mem_wdata_out,
    output wire [DATA_WIDTH-1:0] mem_rdata_out,
    output wire mem_read_out,
    output wire mem_write_out,
    output wire mem_valid_out,
    output wire mem_enable_out,
    output wire mem_ready_out,
    output wire mem_stall_out,
    output wire mem_error_out
);
    // Internal Signals
    wire valid_access;
    wire read_write_conflict;
    
    // Conflict detection
    assign read_write_conflict = mem_read_in && mem_write_in;
    
    // Valid Access Detection
    assign valid_access = (mem_valid_in && !mem_kill_in && !read_write_conflict) ? 1'b1 : 1'b0;
    
    // Enable Generation
    assign mem_enable_out = valid_access;

    // Control gating
    assign mem_read_out = mem_read_in && valid_access;
    assign mem_write_out = mem_write_in && valid_access;

    // Pass-through Logic
    assign mem_addr_out = mem_addr_in;
    assign mem_wdata_out = mem_wdata_in;

    // Read Data Return
    assign mem_rdata_out = mem_rdata_in;

    // Valid propagation
    assign mem_valid_out = valid_access;

    // Ready & stall logic
    assign mem_ready_out = mem_enable_out;
    assign mem_stall_out = 1'b0;

    // Error Detection
    assign mem_error_out = mem_kill_in || read_write_conflict;
    
endmodule