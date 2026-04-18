`timescale 1ns / 1ps

module ifu_top_tb;

    reg clk;
    reg rst_n;
    reg stall;
    reg flush;

    reg [15:0] jump_target;
    reg [15:0] exception_vector;
    reg [15:0] rs1_data;

    wire [15:0] if_pc;
    wire [15:0] if_instr;

    ifu_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush(flush),
        .jump_target(jump_target),
        .exception_vector(exception_vector),
        .rs1_data(rs1_data),
        .if_pc(if_pc),
        .if_instr(if_instr)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        stall = 0;
        flush = 0;

        jump_target = 16'h0020;
        exception_vector = 16'h00F0;
        rs1_data = 16'h0010;

        $display("==========================================================================");
        $display("Time\tPC\tInstr\tOpcode\tBranch\tJump\tJALR\tMisalign");
        $display("==========================================================================");

        $monitor("%0t\t%h\t%h\t%h\t%b\t%b\t%b\t%b",
            $time,
            if_pc,
            if_instr,
            uut.opcode,
            uut.is_branch,
            uut.is_jump,
            uut.is_jalr,
            uut.misaligned
        );

        // -------------------------
        // RESET
        // -------------------------
        #10;
        rst_n = 1;
        $display("\n>>> RESET RELEASED <<<\n");

        // -------------------------
        // SEQUENTIAL EXECUTION
        // -------------------------
        #30;
        $display("\n>>> SEQUENTIAL EXECUTION <<<\n");

        // -------------------------
        // BRANCH TEST (from imem[0])
        // -------------------------
        #40;
        $display("\n>>> BRANCH TEST <<<\n");

        // -------------------------
        // JUMP TEST (from imem[1])
        // -------------------------
        #40;
        $display("\n>>> JUMP TEST <<<\n");

        // -------------------------
        // JALR TEST (from imem[2])
        // -------------------------
        #40;
        $display("\n>>> JALR TEST <<<\n");

        // -------------------------
        // MISALIGNED TEST
        // (force rs1_data to odd base)
        // -------------------------
        #40;
        $display("\n>>> MISALIGNED ADDRESS TEST <<<\n");
        rs1_data = 16'h0011;  // odd → misaligned when added

        #40;
        rs1_data = 16'h0010;  // restore

        // -------------------------
        // STALL TEST
        // -------------------------
        #40;
        $display("\n>>> STALL ENABLED <<<\n");
        stall = 1;

        #40;
        stall = 0;
        $display("\n>>> STALL RELEASED <<<\n");

        // -------------------------
        // FLUSH TEST
        // -------------------------
        #40;
        $display("\n>>> FLUSH ACTIVATED <<<\n");
        flush = 1;

        #10;
        flush = 0;

        // -------------------------
        // EXCEPTION TEST
        // (force misalignment via immediate effect)
        // -------------------------
        #40;
        $display("\n>>> EXCEPTION VECTOR TEST <<<\n");

        // -------------------------
        // CONTINUE EXECUTION
        // -------------------------
        #100;
        $display("\n>>> CONTINUING NORMAL EXECUTION <<<\n");

        #100;
        $display("\n>>> SIMULATION FINISHED <<<");
        $finish;
    end

endmodule
