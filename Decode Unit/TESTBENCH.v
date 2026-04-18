`timescale 1ns/1ps

module decode_top_tb;

    // Parameters
    parameter PC_WIDTH       = 16;
    parameter DATA_WIDTH     = 16;
    parameter INSTR_WIDTH    = 16;
    parameter REGISTER_WIDTH = 4;

    // DUT Inputs
    reg clk;
    reg rst_n;
    reg [INSTR_WIDTH-1:0] instr_in;
    reg [PC_WIDTH-1:0] pc_in;
    reg [DATA_WIDTH-1:0] wb_data;
    reg [REGISTER_WIDTH-1:0] wb_rd;
    reg wb_reg_write;
    reg [REGISTER_WIDTH-1:0] prev_rd;
    reg prev_mem_read;
    reg flush;

    // DUT Outputs
    wire [PC_WIDTH-1:0] pc_out;
    wire [DATA_WIDTH-1:0] rs1_data_out;
    wire [DATA_WIDTH-1:0] rs2_data_out;
    wire [INSTR_WIDTH-1:0] imm_out;
    wire [REGISTER_WIDTH-1:0] rd_out;
    wire [REGISTER_WIDTH-1:0] rs1_out;
    wire [REGISTER_WIDTH-1:0] rs2_out;
    wire [REGISTER_WIDTH-1:0] alu_op_out;
    wire alu_src_imm_out;
    wire [REGISTER_WIDTH-1:0] shamt_out;
    wire mem_read_out;
    wire mem_write_out;
    wire reg_write_out;
    wire [1:0] wb_sel_out;
    wire is_branch_out;
    wire is_jump_out;
    wire [1:0] branch_type_out;
    wire pc_en;
    wire if_de_en;
    wire bubble;

    //----------------------------------------
    // Instantiate DUT
    //----------------------------------------
    decode_top DUT (
        .clk(clk),
        .rst_n(rst_n),
        .instr_in(instr_in),
        .pc_in(pc_in),
        .wb_data(wb_data),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .prev_rd(prev_rd),
        .prev_mem_read(prev_mem_read),
        .flush(flush),

        .pc_out(pc_out),
        .rs1_data_out(rs1_data_out),
        .rs2_data_out(rs2_data_out),
        .imm_out(imm_out),
        .rd_out(rd_out),
        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .alu_op_out(alu_op_out),
        .alu_src_imm_out(alu_src_imm_out),
        .shamt_out(shamt_out),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .reg_write_out(reg_write_out),
        .wb_sel_out(wb_sel_out),
        .is_branch_out(is_branch_out),
        .is_jump_out(is_jump_out),
        .branch_type_out(branch_type_out),
        .pc_en(pc_en),
        .if_de_en(if_de_en),
        .bubble(bubble)
    );

    //----------------------------------------
    // Clock Generation
    //----------------------------------------
    always #5 clk = ~clk;

    //----------------------------------------
    // Monitor
    //----------------------------------------
    initial begin
        $display("==========================================================================");
        $display("Time\tPC\tInstr\tRD\tRS1\tRS2\tALU_OP\tMEM_RD\tSTALL\tBUBBLE");
        $display("==========================================================================");

        $monitor("%0t\t%h\t%h\t%h\t%h\t%h\t%h\t%b\t%b\t%b",
            $time, pc_out, instr_in, rd_out, rs1_out, rs2_out,
            alu_op_out, mem_read_out, ~pc_en, bubble
        );
    end

    //----------------------------------------
    // Stimulus
    //----------------------------------------
    initial begin
        // Init
        clk = 0;
        rst_n = 0;
        instr_in = 0;
        pc_in = 0;
        wb_data = 0;
        wb_rd = 0;
        wb_reg_write = 0;
        prev_rd = 0;
        prev_mem_read = 0;
        flush = 0;

        // Reset
        #10;
        rst_n = 1;
        $display("\n>>> RESET RELEASED <<<\n");

        //--------------------------------------------------
        // 1. ALU Instruction (ADD)
        // opcode=0000, rd=1, rs1=2, rs2=3
        //--------------------------------------------------
        #10;
        instr_in = 16'b0000_0001_0010_0011;
        pc_in = 16'h0002;

        //--------------------------------------------------
        // 2. Immediate Instruction
        //--------------------------------------------------
        #10;
        instr_in = 16'b1000_0010_0011_0101; // ADDI
        pc_in = 16'h0004;

        //--------------------------------------------------
        // 3. LOAD Instruction
        //--------------------------------------------------
        #10;
        instr_in = 16'b1010_0011_0000_1010; // LOAD
        pc_in = 16'h0006;
        prev_rd = 4'b0011;
        prev_mem_read = 1;

        //--------------------------------------------------
        // 4. Hazard Case (should stall + bubble)
        //--------------------------------------------------
        #10;
        instr_in = 16'b0000_0100_0011_0001; // depends on rd=3
        pc_in = 16'h0008;

        //--------------------------------------------------
        // 5. Remove hazard
        //--------------------------------------------------
        #10;
        prev_mem_read = 0;
        instr_in = 16'b0001_0101_0110_0111;
        pc_in = 16'h000A;

        //--------------------------------------------------
        // 6. Flush test
        //--------------------------------------------------
        #10;
        flush = 1;
        instr_in = 16'b1100_0001_0010_0011; // branch
        pc_in = 16'h000C;

        #10;
        flush = 0;

        //--------------------------------------------------
        // Finish
        //--------------------------------------------------
        #50;
        $finish;
    end

endmodule
