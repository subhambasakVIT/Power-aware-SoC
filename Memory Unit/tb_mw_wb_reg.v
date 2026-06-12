`timescale 1ns / 1ps

module tb_mw_wb_reg;

reg clk;
reg rst_n;

reg enable;
reg flush;
reg branch_taken_in;

reg [15:0] wb_data_in;
reg [3:0] rd_in;
reg reg_write_in;

wire [15:0] wb_data_out;
wire [3:0] rd_out;
wire reg_write_out;

mw_wb_reg dut(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .flush(flush),
    .branch_taken_in(branch_taken_in),
    .wb_data_in(wb_data_in),
    .rd_in(rd_in),
    .reg_write_in(reg_write_in),
    .wb_data_out(wb_data_out),
    .rd_out(rd_out),
    .reg_write_out(reg_write_out)
);

//////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//////////////////////////////////////////////////
// Monitor
//////////////////////////////////////////////////

initial begin

    $display("======================================");
    $display(" MW_WB_REG VERIFICATION START ");
    $display("======================================");

    $monitor(
        "T=%0t en=%b flush=%b branch=%b wb_in=%h wb_out=%h rd=%h reg_write=%b",
        $time,
        enable,
        flush,
        branch_taken_in,
        wb_data_in,
        wb_data_out,
        rd_out,
        reg_write_out
    );

end

//////////////////////////////////////////////////
// Main Test
//////////////////////////////////////////////////

initial begin

    rst_n = 0;

    enable = 0;
    flush = 0;
    branch_taken_in = 0;

    wb_data_in = 0;
    rd_in = 0;
    reg_write_in = 0;

    ////////////////////////////////////////////
    // T1 RESET
    ////////////////////////////////////////////

    #20;

    rst_n = 1;

    if((wb_data_out==0) &&
       (rd_out==0) &&
       (reg_write_out==0))
        $display("PASS : RESET");
    else
        $display("FAIL : RESET");

    ////////////////////////////////////////////
    // T2 NORMAL CAPTURE
    ////////////////////////////////////////////

    @(negedge clk);

    enable = 1;

    wb_data_in = 16'hABCD;
    rd_in = 4'h5;
    reg_write_in = 1;

    @(posedge clk);

    #1;

    if((wb_data_out==16'hABCD) &&
       (rd_out==4'h5) &&
       (reg_write_out==1))
        $display("PASS : NORMAL CAPTURE");
    else
        $display("FAIL : NORMAL CAPTURE");

    ////////////////////////////////////////////
    // T3 HOLD TEST
    ////////////////////////////////////////////

    @(negedge clk);

    enable = 0;

    wb_data_in = 16'h1111;
    rd_in = 4'h2;

    @(posedge clk);

    #1;

    if((wb_data_out==16'hABCD) &&
       (rd_out==4'h5))
        $display("PASS : HOLD");
    else
        $display("FAIL : HOLD");

    ////////////////////////////////////////////
    // T4 FLUSH
    ////////////////////////////////////////////

    @(negedge clk);

    enable = 1;
    flush = 1;

    @(posedge clk);

    #1;

    if((wb_data_out==0) &&
       (rd_out==0) &&
       (reg_write_out==0))
        $display("PASS : FLUSH");
    else
        $display("FAIL : FLUSH");

    flush = 0;

    ////////////////////////////////////////////
    // T5 BRANCH
    ////////////////////////////////////////////

    @(negedge clk);

    branch_taken_in = 1;

    wb_data_in = 16'hFFFF;
    rd_in = 4'hF;
    reg_write_in = 1;

    @(posedge clk);

    #1;

    if((wb_data_out==0) &&
       (rd_out==0))
        $display("PASS : BRANCH KILL");
    else
        $display("FAIL : BRANCH KILL");

    branch_taken_in = 0;

    ////////////////////////////////////////////
    // T6 MAX VALUES
    ////////////////////////////////////////////

    @(negedge clk);

    wb_data_in = 16'hFFFF;
    rd_in = 4'hF;
    reg_write_in = 1;

    @(posedge clk);

    #1;

    if((wb_data_out==16'hFFFF) &&
       (rd_out==4'hF))
        $display("PASS : MAX VALUES");
    else
        $display("FAIL : MAX VALUES");

    ////////////////////////////////////////////
    // T7 FLUSH WHILE DISABLED
    ////////////////////////////////////////////

    @(negedge clk);

    enable = 0;
    flush = 1;

    @(posedge clk);

    #1;

    if((wb_data_out==16'hFFFF) &&
       (rd_out==4'hF))
        $display("PASS : FLUSH IGNORED WHEN DISABLED");
    else
        $display("FAIL : FLUSH IGNORED WHEN DISABLED");

    ////////////////////////////////////////////
    // T8 RESET DURING OPERATION
    ////////////////////////////////////////////

    #5;

    rst_n = 0;

    #2;

    if((wb_data_out==0) &&
       (rd_out==0))
        $display("PASS : ASYNC RESET");
    else
        $display("FAIL : ASYNC RESET");

    rst_n = 1;

    ////////////////////////////////////////////
    // END
    ////////////////////////////////////////////

    #20;

    $display("======================================");
    $display(" ALL TESTS COMPLETED ");
    $display("======================================");

    $finish;

end

endmodule

//OUTPUT
/*
results:

======================================
 MW_WB_REG VERIFICATION START 
======================================
T=0 en=0 flush=0 branch=0 wb_in=0000 wb_out=0000 rd=0 reg_write=0
PASS : RESET
T=20000 en=1 flush=0 branch=0 wb_in=abcd wb_out=0000 rd=0 reg_write=0
T=25000 en=1 flush=0 branch=0 wb_in=abcd wb_out=abcd rd=5 reg_write=1
PASS : NORMAL CAPTURE
T=30000 en=0 flush=0 branch=0 wb_in=1111 wb_out=abcd rd=5 reg_write=1
PASS : HOLD
T=40000 en=1 flush=1 branch=0 wb_in=1111 wb_out=abcd rd=5 reg_write=1
T=45000 en=1 flush=1 branch=0 wb_in=1111 wb_out=0000 rd=0 reg_write=0
PASS : FLUSH
T=46000 en=1 flush=0 branch=0 wb_in=1111 wb_out=0000 rd=0 reg_write=0
T=50000 en=1 flush=0 branch=1 wb_in=ffff wb_out=0000 rd=0 reg_write=0
PASS : BRANCH KILL
T=56000 en=1 flush=0 branch=0 wb_in=ffff wb_out=0000 rd=0 reg_write=0
T=65000 en=1 flush=0 branch=0 wb_in=ffff wb_out=ffff rd=f reg_write=1
PASS : MAX VALUES
T=70000 en=0 flush=1 branch=0 wb_in=ffff wb_out=ffff rd=f reg_write=1
PASS : FLUSH IGNORED WHEN DISABLED
T=81000 en=0 flush=1 branch=0 wb_in=ffff wb_out=0000 rd=0 reg_write=0
PASS : ASYNC RESET
======================================
 ALL TESTS COMPLETED 
======================================
*/
