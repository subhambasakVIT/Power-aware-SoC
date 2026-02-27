`timescale 1ns / 1ps

module tb_ALU_BIT_16;

    reg         clk;
    reg         rst_n;
    reg [15:0]  A, B;
    reg [3:0]   shamt;
    reg [3:0]   sel;
    reg         cin;

    wire [31:0] result;
    wire [15:0] remainder;
    wire        carry_out;

    // DUT
    ALU_BIT_16 dut (
        .clk(clk),
        .rst_n(rst_n),
        .A(A),
        .B(B),
        .shamt(shamt),
        .sel(sel),
        .cin(cin),
        .result(result),
        .remainder(remainder),
        .carry_out(carry_out)
    );

    // Clock
    always #5 clk = ~clk;

    // --------------------------------------------------
    // Monitor (VERY IMPORTANT FOR UNDERSTANDING PIPELINE)
    // --------------------------------------------------
    initial begin
        $display("TIME | sel | sel_r |   A   |   B   | sh | cin |    result    | rem | carry");
        $monitor("%4t |  %0d  |   %0d   | %5d | %5d | %2d |  %b  | %11d | %3d |   %b",
            $time,
            sel,
            dut.sel_r,
            A,
            B,
            shamt,
            cin,
            result,
            remainder,
            carry_out
        );
    end

    // --------------------------------------------------
    // Wait for ALU pipeline latency (2 cycles)
    // --------------------------------------------------
    task wait_alu;
        begin
            @(posedge clk);
            @(posedge clk);
        end
    endtask

    // --------------------------------------------------
    // Apply stimulus (1 cycle valid input)
    // --------------------------------------------------
    task apply(
        input [15:0] a,
        input [15:0] b,
        input [3:0]  s,
        input [3:0]  sh,
        input        c
    );
        begin
            A     = a;
            B     = b;
            sel   = s;
            shamt = sh;
            cin   = c;
            @(posedge clk);
        end
    endtask

    // --------------------------------------------------
    // Test sequence
    // --------------------------------------------------
    initial begin
        // INIT
        clk = 0;
        rst_n = 0;
        A = 0; B = 0; shamt = 0; sel = 0; cin = 0;

        repeat (2) @(posedge clk);
        rst_n = 1;

        // =================================================
        // sel = 0 : ADD
        // =================================================
        $display("\n==== ADD TESTS (sel = 0) ====");
        sel = 4'd0; cin = 0;
        apply(555,   4350, sel, 0, cin); wait_alu;
        apply(60000, 1234, sel, 0, cin); wait_alu;
        apply(16'h00FF, 1, sel, 0, cin); wait_alu;
        apply(16'h0FFF, 1, sel, 0, cin); wait_alu;
        apply(16'hFFFF, 1, sel, 0, cin); wait_alu;

        // =================================================
        // sel = 1 : SUB
        // =================================================
        $display("\n==== SUB TESTS (sel = 1) ====");
        sel = 4'd1; cin = 1;
        apply(5000, 1234, sel, 0, cin); wait_alu;
        apply(3000, 3000, sel, 0, cin); wait_alu;
        apply(1000, 2000, sel, 0, cin); wait_alu;

        // =================================================
        // sel = 2 : MUL
        // =================================================
        $display("\n==== MUL TESTS (sel = 2) ====");
        sel = 4'd2; cin = 0;
        apply(25,   4, sel, 0, cin); wait_alu;
        apply(255, 255, sel, 0, cin); wait_alu;
        apply(16'hFFFF, 2, sel, 0, cin); wait_alu;

        // =================================================
        // sel = 3 : DIV
        // =================================================
        $display("\n==== DIV TESTS (sel = 3) ====");
        sel = 4'd3;
        apply(20, 5, sel, 0, cin); wait_alu;
        apply(20, 6, sel, 0, cin); wait_alu;
        apply(100, 0, sel, 0, cin); wait_alu; // divide-by-zero

        // =================================================
        // sel = 4..7 : SHIFTS
        // =================================================
        $display("\n==== SHIFT TESTS (sel = 4..7) ====");
        A = 16'b1001_0000_0000_0001;

        sel = 4'd4; apply(A,0,sel,1,0); wait_alu;
        sel = 4'd5; apply(A,0,sel,4,0); wait_alu;
        sel = 4'd6; apply(A,0,sel,1,0); wait_alu;
        sel = 4'd7; apply(A,0,sel,4,0); wait_alu;

        // =================================================
        // sel = 8 : INC
        // =================================================
        $display("\n==== INC TESTS (sel = 8) ====");
        sel = 4'd8;
        apply(10,0,sel,0,0); wait_alu;
        apply(16'hFFFF,0,sel,0,0); wait_alu;

        // =================================================
        // sel = 9 : DEC
        // =================================================
        $display("\n==== DEC TESTS (sel = 9) ====");
        sel = 4'd9;
        apply(10,0,sel,0,0); wait_alu;
        apply(0,0,sel,0,0); wait_alu;

        $display("\n==== ALL TESTS COMPLETED ====");
        #40 $finish;
    end

endmodule
