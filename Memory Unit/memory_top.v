`timescale 1ns / 1ps
`include "lsi.v"
`include "mah.v"
`include "mac.v"
`include "sram_wrapper.v"
`include "memory_writeback_selector.v"
`include "mw_wb_reg.v"

module memory_top #(
    parameter DATA_WIDTH = 16,
    parameter REGISTER_WIDTH = 4,
    parameter PC_WIDTH = 16
) (
    // Clock and Reset
    input wire clk,
    input wire rst_n,

    // Data Path inputs
    input wire [DATA_WIDTH-1:0] alu_result_in,
    input wire [DATA_WIDTH-1:0] rs2_data_in,
    input wire [PC_WIDTH-1:0] pc_in,

    // Control Path inputs
    input wire [REGISTER_WIDTH-1:0] rd_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire reg_write_in,
    input wire [1:0] wb_sel_in,
    input wire mem_clk_en,

    // Pipeline Control
    input wire enable,
    input wire flush,
    input wire branch_taken_in,

    // Output to Register File
    output wire [DATA_WIDTH-1:0] wb_data_out,
    output wire [REGISTER_WIDTH-1:0] rd_out,
    output wire reg_write_out,

    // Memory Status Outpus
    output wire mem_ready_out,
    output wire mem_stall_out,
    output wire mem_error_out
);
    
    // Internal Signals
    // Load Store Interface
    wire [DATA_WIDTH-1:0] mem_addr_lsi;
    wire [DATA_WIDTH-1:0] mem_wdata_lsi;
    wire mem_read_lsi;
    wire mem_write_lsi;
    wire mem_valid_lsi;
    wire [REGISTER_WIDTH-1:0] rd_lsi;
    wire reg_write_lsi;
    wire [1:0] wb_sel_lsi;
    wire [DATA_WIDTH-1:0] alu_result_lsi;
    wire [PC_WIDTH-1:0] pc_lsi;

    // Memory Alignment Handler
    wire [DATA_WIDTH-1:0] mem_addr_mah;
    wire [DATA_WIDTH-1:0] mem_wdata_mah;
    wire [DATA_WIDTH-1:0] mem_rdata_mah;
    wire mem_read_mah;
    wire mem_write_mah;
    wire mem_valid_mah;
    wire mem_kill_mah;
    wire misaligned_access;

    // Memory Access Controller
    wire [DATA_WIDTH-1:0] mem_addr_mac;
    wire [DATA_WIDTH-1:0] mem_wdata_mac;
    wire [DATA_WIDTH-1:0] mem_rdata_mac;
    wire mem_ready_mac;
    wire mem_stall_mac;
    wire mem_error_mac;
    wire mem_read_mac;
    wire mem_write_mac;
    wire mem_valid_mac;
    wire mem_enable_mac; 

    // SRAM Wrapper
    wire [DATA_WIDTH-1:0] mem_rdata_sram;

    // Memory Writeback Selector
    wire [DATA_WIDTH-1:0] wb_data_mws;
    wire [REGISTER_WIDTH-1:0] rd_mws;
    wire reg_write_mws;

    // MW_WB_Register
    wire [DATA_WIDTH-1:0] wb_data_reg;
    wire [REGISTER_WIDTH-1:0] rd_reg;
    wire reg_write_reg;

    //-----------------------------
    // Load Store Interface
    //-----------------------------
    lsi lsi_inst (
        .alu_result_in(alu_result_in),
        .rs2_data_in(rs2_data_in),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .reg_write_in(reg_write_in),
        .rd_in(rd_in),
        .branch_taken_in(branch_taken_in),
        .enable(enable),
        .flush(flush),
        .wb_sel_in(wb_sel_in),
        .pc_in(pc_in),

        .mem_addr(mem_addr_lsi),
        .mem_wdata(mem_wdata_lsi),
        .mem_read(mem_read_lsi),
        .mem_write(mem_write_lsi),
        .mem_valid(mem_valid_lsi),
        .reg_write_out(reg_write_lsi),
        .rd_out(rd_lsi),
        .wb_sel_out(wb_sel_lsi),
        .alu_result_out(alu_result_lsi),
        .pc_out(pc_lsi)
    );

    //-----------------------------
    // Memory Alignment Handler
    //-----------------------------
    mah mah_inst (
        .mem_addr_in(mem_addr_lsi),
        .mem_wdata_in(mem_wdata_lsi),
        .mem_rdata_in(mem_rdata_mac),
        .mem_read_in(mem_read_lsi),
        .mem_write_in(mem_write_lsi),
        .mem_valid_in(mem_valid_lsi),

        .mem_addr_out(mem_addr_mah),
        .mem_wdata_out(mem_wdata_mah),
        .mem_rdata_out(mem_rdata_mah),
        .mem_read_out(mem_read_mah),
        .mem_write_out(mem_write_mah),
        .mem_valid_out(mem_valid_mah),
        .misaligned_access(misaligned_access),
        .mem_kill_out(mem_kill_mah)
    );

    //-----------------------------
    // Memory Access Controller
    //-----------------------------
    mac mac_inst (
        .mem_addr_in(mem_addr_mah),
        .mem_wdata_in(mem_wdata_mah),
        .mem_read_in(mem_read_mah),
        .mem_write_in(mem_write_mah),
        .mem_valid_in(mem_valid_mah),
        .mem_kill_in(mem_kill_mah),
        .mem_rdata_in(mem_rdata_sram),

        .mem_addr_out(mem_addr_mac),
        .mem_wdata_out(mem_wdata_mac),
        .mem_rdata_out(mem_rdata_mac),
        .mem_read_out(mem_read_mac),
        .mem_write_out(mem_write_mac),
        .mem_valid_out(mem_valid_mac),
        .mem_enable_out(mem_enable_mac),
        .mem_ready_out(mem_ready_mac),
        .mem_stall_out(mem_stall_mac),
        .mem_error_out(mem_error_mac)
    );

    //-----------------------------
    // SRAM Wrapper
    //-----------------------------
    sram_wrapper sram_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr_in(mem_addr_mac),
        .mem_wdata_in(mem_wdata_mac),
        .mem_read_in(mem_read_mac),
        .mem_write_in(mem_write_mac),
        .mem_enable_in(mem_enable_mac),
        .mem_clk_en(mem_clk_en),
        .mem_rdata_out(mem_rdata_sram)
    );

    //-----------------------------
    // Memory Writeback Selector
    //-----------------------------
    memory_writeback_selector mws_inst (
        .alu_result_in(alu_result_lsi),
        .mem_result_in(mem_rdata_mah),
        .pc_in(pc_lsi),
        .wb_sel_in(wb_sel_lsi),
        .flush(flush),
        .branch_taken_in(branch_taken_in),
        .rd_in(rd_lsi),
        .reg_write_in(reg_write_lsi),

        .wb_data_out(wb_data_mws),
        .rd_out(rd_mws),
        .reg_write_out(reg_write_mws)
    );

    //-----------------------------
    // MW/WB Register
    //-----------------------------
    mw_wb_reg mw_wb_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .flush(flush),
        .branch_taken_in(branch_taken_in),

        .wb_data_in(wb_data_mws),
        .rd_in(rd_mws),
        .reg_write_in(reg_write_mws),

        .wb_data_out(wb_data_out),
        .rd_out(rd_out),
        .reg_write_out(reg_write_out)
    );    

    assign mem_ready_out = mem_ready_mac;
    assign mem_stall_out = mem_stall_mac;
    assign mem_error_out = mem_error_mac;

endmodule