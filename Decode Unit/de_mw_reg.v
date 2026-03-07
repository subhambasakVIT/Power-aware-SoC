`timescale 1ns/1ps

module de_mw_reg #(
    parameter PC_WIDTH       = 16,
    parameter DATA_WIDTH     = 16,
    parameter INSTR_WIDTH    = 16,
    parameter REGISTER_WIDTH = 4
) (
    input wire                      clk,                // Clock Signal
    input wire                      rst_n,              // Reset Signal

    input wire                      enable,             // Enable Signal (HDU Signal)
    input wire                      bubble,             // Stall Signal (HDU Signal)  
    
    input wire [PC_WIDTH-1:0]       pc_in,              // Program Count Input (PC Signal)

    // Register File Signals
    input wire [DATA_WIDTH-1:0]     rs1_data_in,        // Register 1 Data Input (Reg File signal)
    input wire [DATA_WIDTH-1:0]     rs2_data_in,        // Register 2 Data Input (       "       )

    // Immediate Generator Signal
    input wire [INSTR_WIDTH-1:0]    imm_in,             // Immediate Data Input

    // Instruction Decoder Signals
    input wire [REGISTER_WIDTH-1:0] rd_in,              // Destination Register Signal
    input wire [REGISTER_WIDTH-1:0] rs1_in,             // Sourse Register 1
    input wire [REGISTER_WIDTH-1:0] rs2_in,             // Source Register 2
    input wire [REGISTER_WIDTH-1:0] alu_op_in,          // ALU Operation input
    input wire                      alu_src_imm_in,     // Selects Reg vs Imm

    // ALU Signal
    input wire [REGISTER_WIDTH-1:0] shamt_in,           // Shift Operation Signal

    // Instruction Decoder Signal 
    input wire                      mem_read_in,        // Memory Read Signal
    input wire                      mem_write_in,       // Memory Write Signal
    input wire                      reg_write_in,       // Register read signal
    input wire [1:0]                wb_sel_in,          // Selects ALU result, memory data or PC + 2
    input wire                      is_branch_in,       // Branch Signal
    input wire                      is_jump_in,         // Jump Signal
    input wire [1:0]                branch_type_in,     // Type of Branch Signal

    // Corresponding Output Signals
    output reg [PC_WIDTH-1:0]       pc_out,

    output reg [DATA_WIDTH-1:0]     rs1_data_out,
    output reg [DATA_WIDTH-1:0]     rs2_data_out,

    output reg [INSTR_WIDTH-1:0]    imm_out,

    output reg [REGISTER_WIDTH-1:0] rd_out,
    output reg [REGISTER_WIDTH-1:0] rs1_out,
    output reg [REGISTER_WIDTH-1:0] rs2_out,
    output reg [REGISTER_WIDTH-1:0] alu_op_out,
    output reg                      alu_src_imm_out,

    output reg [REGISTER_WIDTH-1:0] shamt_out,

    output reg                      mem_read_out,
    output reg                      mem_write_out,
    output reg                      reg_write_out,
    output reg [1:0]                wb_sel_out,
    output reg                      is_branch_out,
    output reg                      is_jump_out,
    output reg [1:0]                branch_type_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out          <= {PC_WIDTH{1'b0}};
            rs1_data_out    <= {DATA_WIDTH{1'b0}};
            rs2_data_out    <= {DATA_WIDTH{1'b0}};
            imm_out         <= {INSTR_WIDTH{1'b0}};
            rd_out          <= {REGISTER_WIDTH{1'b0}};
            rs1_out         <= {REGISTER_WIDTH{1'b0}};
            rs2_out         <= {REGISTER_WIDTH{1'b0}};
            alu_op_out      <= {REGISTER_WIDTH{1'b0}};
            alu_src_imm_out <= 1'b0;
            shamt_out       <= {REGISTER_WIDTH{1'b0}};
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            reg_write_out   <= 1'b0;
            wb_sel_out      <= 2'b0;
            is_branch_out   <= 1'b0;
            is_jump_out     <= 1'b0;
            branch_type_out <= 2'b0;
        end else if (enable) begin
            pc_out          <= pc_in;
            rs1_data_out    <= rs1_data_in;
            rs2_data_out    <= rs2_data_in;
            imm_out         <= imm_in;
            rd_out          <= rd_in;
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            alu_op_out      <= alu_op_in;
            alu_src_imm_out <= alu_src_imm_in;
            shamt_out       <= shamt_in;

            if (bubble) begin
                mem_read_out    <= 1'b0;
                mem_write_out   <= 1'b0;
                reg_write_out   <= 1'b0;
                wb_sel_out      <= 2'b0;
                is_branch_out   <= 1'b0;
                is_jump_out     <= 1'b0;
                branch_type_out <= 2'b0;
            end else begin
                mem_read_out    <= mem_read_in;
                mem_write_out   <= mem_write_in;
                reg_write_out   <= reg_write_in;
                wb_sel_out      <= wb_sel_in;
                is_branch_out   <= is_branch_in;
                is_jump_out     <= is_jump_in;
                branch_type_out <= branch_type_in;
            end
        end else begin
            pc_out          <= pc_out;
            rs1_data_out    <= rs1_data_out;
            rs2_data_out    <= rs2_data_out;
            imm_out         <= imm_out;
            rd_out          <= rd_out;
            rs1_out         <= rs1_out;
            rs2_out         <= rs2_out;
            alu_op_out      <= alu_op_out;
            alu_src_imm_out <= alu_src_imm_out;
            shamt_out       <= shamt_out;
            mem_read_out    <= mem_read_out;
            mem_write_out   <= mem_write_out;
            reg_write_out   <= reg_write_out;
            wb_sel_out      <= wb_sel_out;
            is_branch_out   <= is_branch_out;
            is_jump_out     <= is_jump_out;
            branch_type_out <= branch_type_out;
        end
    end
    
endmodule