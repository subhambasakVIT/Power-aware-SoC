`timescale 1ns / 1ps

module tb_memory_writeback_selector;

reg [15:0] alu_result_in;
reg [15:0] mem_result_in;
reg [15:0] pc_in;

reg [1:0] wb_sel_in;

reg flush;
reg branch_taken_in;

reg [3:0] rd_in;
reg reg_write_in;

wire [15:0] wb_data_out;
wire [3:0] rd_out;
wire reg_write_out;

memory_writeback_selector dut(
    .alu_result_in(alu_result_in),
    .mem_result_in(mem_result_in),
    .pc_in(pc_in),
    .wb_sel_in(wb_sel_in),
    .flush(flush),
    .branch_taken_in(branch_taken_in),
    .rd_in(rd_in),
    .reg_write_in(reg_write_in),
    .wb_data_out(wb_data_out),
    .rd_out(rd_out),
    .reg_write_out(reg_write_out)
);

initial begin

    $display("======================================");
    $display(" MEMORY WRITEBACK SELECTOR TEST ");
    $display("======================================");

    $monitor(
        "T=%0t wb_sel=%b flush=%b branch=%b wb_data=%h rd=%h reg_write=%b",
        $time,
        wb_sel_in,
        flush,
        branch_taken_in,
        wb_data_out,
        rd_out,
        reg_write_out
    );

    ////////////////////////////////////////////////////
    // Initialize
    ////////////////////////////////////////////////////

    alu_result_in = 16'hAAAA;
    mem_result_in = 16'h1234;
    pc_in = 16'h1000;

    rd_in = 4'h5;
    reg_write_in = 1;

    flush = 0;
    branch_taken_in = 0;

    ////////////////////////////////////////////////////
    // T1
    ////////////////////////////////////////////////////

    wb_sel_in = 2'b00;
    #10;

    if(wb_data_out == 16'hAAAA)
        $display("PASS : ALU SELECT");
    else
        $display("FAIL : ALU SELECT");

    ////////////////////////////////////////////////////
    // T2
    ////////////////////////////////////////////////////

    wb_sel_in = 2'b01;
    #10;

    if(wb_data_out == 16'h1234)
        $display("PASS : MEMORY SELECT");
    else
        $display("FAIL : MEMORY SELECT");

    ////////////////////////////////////////////////////
    // T3
    ////////////////////////////////////////////////////

    wb_sel_in = 2'b10;
    #10;

    if(wb_data_out == 16'h1002)
        $display("PASS : PC+2 SELECT");
    else
        $display("FAIL : PC+2 SELECT");

    ////////////////////////////////////////////////////
    // T4
    ////////////////////////////////////////////////////

    wb_sel_in = 2'b11;
    #10;

    if(wb_data_out == 16'h0000)
        $display("PASS : DEFAULT SELECT");
    else
        $display("FAIL : DEFAULT SELECT");

    ////////////////////////////////////////////////////
    // T5
    ////////////////////////////////////////////////////

    wb_sel_in = 2'b00;
    flush = 1;

    #10;

    if((wb_data_out==0) &&
       (rd_out==0) &&
       (reg_write_out==0))
        $display("PASS : FLUSH");
    else
        $display("FAIL : FLUSH");

    ////////////////////////////////////////////////////
    // T6
    ////////////////////////////////////////////////////

    flush = 0;
    branch_taken_in = 1;

    #10;

    if((wb_data_out==0) &&
       (rd_out==0) &&
       (reg_write_out==0))
        $display("PASS : BRANCH KILL");
    else
        $display("FAIL : BRANCH KILL");

    ////////////////////////////////////////////////////
    // T7
    ////////////////////////////////////////////////////

    flush = 1;
    branch_taken_in = 1;

    #10;

    if((wb_data_out==0) &&
       (rd_out==0) &&
       (reg_write_out==0))
        $display("PASS : FLUSH + BRANCH");
    else
        $display("FAIL : FLUSH + BRANCH");

    ////////////////////////////////////////////////////
    // T8
    ////////////////////////////////////////////////////

    flush = 0;
    branch_taken_in = 0;

    reg_write_in = 0;

    #10;

    if(reg_write_out == 0)
        $display("PASS : REG_WRITE PASS");
    else
        $display("FAIL : REG_WRITE PASS");

    ////////////////////////////////////////////////////
    // T9
    ////////////////////////////////////////////////////

    reg_write_in = 1;
    rd_in = 4'hF;

    #10;

    if(rd_out == 4'hF)
        $display("PASS : MAX REGISTER");
    else
        $display("FAIL : MAX REGISTER");

    ////////////////////////////////////////////////////
    // End
    ////////////////////////////////////////////////////

    #10;

    $display("======================================");
    $display(" ALL TESTS COMPLETED ");
    $display("======================================");

    $finish;

end

endmodule


//OUTPUT
/*
======================================
 MEMORY WRITEBACK SELECTOR TEST 
======================================
T=0 wb_sel=00 flush=0 branch=0 wb_data=aaaa rd=5 reg_write=1
PASS : ALU SELECT
T=10000 wb_sel=01 flush=0 branch=0 wb_data=1234 rd=5 reg_write=1
PASS : MEMORY SELECT
T=20000 wb_sel=10 flush=0 branch=0 wb_data=1002 rd=5 reg_write=1
PASS : PC+2 SELECT
T=30000 wb_sel=11 flush=0 branch=0 wb_data=0000 rd=5 reg_write=1
PASS : DEFAULT SELECT
T=40000 wb_sel=00 flush=1 branch=0 wb_data=0000 rd=0 reg_write=0
PASS : FLUSH
T=50000 wb_sel=00 flush=0 branch=1 wb_data=0000 rd=0 reg_write=0
PASS : BRANCH KILL
T=60000 wb_sel=00 flush=1 branch=1 wb_data=0000 rd=0 reg_write=0
PASS : FLUSH + BRANCH
T=70000 wb_sel=00 flush=0 branch=0 wb_data=aaaa rd=5 reg_write=0
PASS : REG_WRITE PASS
T=80000 wb_sel=00 flush=0 branch=0 wb_data=aaaa rd=f reg_write=1
PASS : MAX REGISTER
======================================
 ALL TESTS COMPLETED 
======================================
*/
