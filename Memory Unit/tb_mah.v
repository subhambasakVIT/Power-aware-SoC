`timescale 1ns / 1ps

module tb_mah;

reg [15:0] mem_addr_in;
reg [15:0] mem_wdata_in;
reg [15:0] mem_rdata_in;

reg mem_read_in;
reg mem_write_in;
reg mem_valid_in;

wire [15:0] mem_addr_out;
wire [15:0] mem_wdata_out;
wire [15:0] mem_rdata_out;

wire mem_read_out;
wire mem_write_out;
wire mem_valid_out;

wire misaligned_access;
wire mem_kill_out;

mah dut (
    .mem_addr_in(mem_addr_in),
    .mem_wdata_in(mem_wdata_in),
    .mem_rdata_in(mem_rdata_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_valid_in(mem_valid_in),

    .mem_addr_out(mem_addr_out),
    .mem_wdata_out(mem_wdata_out),
    .mem_rdata_out(mem_rdata_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_valid_out(mem_valid_out),
    .misaligned_access(misaligned_access),
    .mem_kill_out(mem_kill_out)
);

initial begin

    $display("======================================");
    $display(" MAH VERIFICATION START ");
    $display("======================================");

    $monitor(
      "T=%0t addr_in=%h addr_out=%h misalign=%b kill=%b rd=%b wr=%b valid=%b",
      $time,
      mem_addr_in,
      mem_addr_out,
      misaligned_access,
      mem_kill_out,
      mem_read_out,
      mem_write_out,
      mem_valid_out
    );

    ////////////////////////////////////
    // T1 EVEN ADDRESS
    ////////////////////////////////////

    mem_addr_in = 16'h0004;
    mem_wdata_in = 16'hAAAA;
    mem_rdata_in = 16'h1234;

    mem_read_in = 0;
    mem_write_in = 1;
    mem_valid_in = 1;

    #10;

    if(mem_addr_out==16'h0004 &&
       misaligned_access==0 &&
       mem_kill_out==0)
        $display("PASS : EVEN ADDRESS");
    else
        $display("FAIL : EVEN ADDRESS");

    ////////////////////////////////////
    // T2 ODD ADDRESS
    ////////////////////////////////////

    mem_addr_in = 16'h0005;

    #10;

    if(mem_addr_out==16'h0004 &&
       misaligned_access==1 &&
       mem_kill_out==1)
        $display("PASS : ODD ADDRESS");
    else
        $display("FAIL : ODD ADDRESS");

    ////////////////////////////////////
    // T3 WRITE DATA PASS
    ////////////////////////////////////

    if(mem_wdata_out==16'hAAAA)
        $display("PASS : WDATA PASS");
    else
        $display("FAIL : WDATA PASS");

    ////////////////////////////////////
    // T4 READ DATA PASS
    ////////////////////////////////////

    if(mem_rdata_out==16'h1234)
        $display("PASS : RDATA PASS");
    else
        $display("FAIL : RDATA PASS");

    ////////////////////////////////////
    // T5 READ CONTROL
    ////////////////////////////////////

    mem_read_in = 1;
    mem_write_in = 0;

    #10;

    if(mem_read_out==1 &&
       mem_write_out==0)
        $display("PASS : READ CONTROL");
    else
        $display("FAIL : READ CONTROL");

    ////////////////////////////////////
    // T6 WRITE CONTROL
    ////////////////////////////////////

    mem_read_in = 0;
    mem_write_in = 1;

    #10;

    if(mem_read_out==0 &&
       mem_write_out==1)
        $display("PASS : WRITE CONTROL");
    else
        $display("FAIL : WRITE CONTROL");

    ////////////////////////////////////
    // T7 VALID CONTROL
    ////////////////////////////////////

    mem_valid_in = 0;

    #10;

    if(mem_valid_out==0)
        $display("PASS : VALID CONTROL");
    else
        $display("FAIL : VALID CONTROL");

    ////////////////////////////////////
    // T8 MAX EVEN ADDRESS
    ////////////////////////////////////

    mem_addr_in = 16'hFFFE;

    #10;

    if(mem_addr_out==16'hFFFE &&
       mem_kill_out==0)
        $display("PASS : MAX EVEN");
    else
        $display("FAIL : MAX EVEN");

    ////////////////////////////////////
    // T9 MAX ODD ADDRESS
    ////////////////////////////////////

    mem_addr_in = 16'hFFFF;

    #10;

    if(mem_addr_out==16'hFFFE &&
       mem_kill_out==1)
        $display("PASS : MAX ODD");
    else
        $display("FAIL : MAX ODD");

    ////////////////////////////////////
    // T10 READ + WRITE
    ////////////////////////////////////

    mem_read_in = 1;
    mem_write_in = 1;

    #10;

    if(mem_read_out==1 &&
       mem_write_out==1)
        $display("PASS : READ+WRITE");
    else
        $display("FAIL : READ+WRITE");

    ////////////////////////////////////

    $display("======================================");
    $display(" ALL TESTS COMPLETED ");
    $display("======================================");

    $finish;

end

endmodule

//OUTPUT
/*
======================================
 MAH VERIFICATION START 
======================================
T=0 addr_in=0004 addr_out=0004 misalign=0 kill=0 rd=0 wr=1 valid=1
PASS : EVEN ADDRESS
T=10000 addr_in=0005 addr_out=0004 misalign=1 kill=1 rd=0 wr=1 valid=1
PASS : ODD ADDRESS
PASS : WDATA PASS
PASS : RDATA PASS
T=20000 addr_in=0005 addr_out=0004 misalign=1 kill=1 rd=1 wr=0 valid=1
PASS : READ CONTROL
T=30000 addr_in=0005 addr_out=0004 misalign=1 kill=1 rd=0 wr=1 valid=1
PASS : WRITE CONTROL
T=40000 addr_in=0005 addr_out=0004 misalign=1 kill=1 rd=0 wr=1 valid=0
PASS : VALID CONTROL
T=50000 addr_in=fffe addr_out=fffe misalign=0 kill=0 rd=0 wr=1 valid=0
PASS : MAX EVEN
T=60000 addr_in=ffff addr_out=fffe misalign=1 kill=1 rd=0 wr=1 valid=0
PASS : MAX ODD
T=70000 addr_in=ffff addr_out=fffe misalign=1 kill=1 rd=1 wr=1 valid=0
PASS : READ+WRITE
======================================
 ALL TESTS COMPLETED 
======================================
*/
