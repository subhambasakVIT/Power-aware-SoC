`timescale 1ns/1ps

module tb_mac;

reg [15:0] mem_addr_in;
reg [15:0] mem_wdata_in;
reg [15:0] mem_rdata_in;

reg mem_read_in;
reg mem_write_in;
reg mem_valid_in;
reg mem_kill_in;

wire [15:0] mem_addr_out;
wire [15:0] mem_wdata_out;
wire [15:0] mem_rdata_out;

wire mem_read_out;
wire mem_write_out;
wire mem_valid_out;
wire mem_enable_out;
wire mem_ready_out;
wire mem_stall_out;
wire mem_error_out;

mac dut(
    .mem_addr_in(mem_addr_in),
    .mem_wdata_in(mem_wdata_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_valid_in(mem_valid_in),
    .mem_kill_in(mem_kill_in),
    .mem_rdata_in(mem_rdata_in),

    .mem_addr_out(mem_addr_out),
    .mem_wdata_out(mem_wdata_out),
    .mem_rdata_out(mem_rdata_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_valid_out(mem_valid_out),
    .mem_enable_out(mem_enable_out),
    .mem_ready_out(mem_ready_out),
    .mem_stall_out(mem_stall_out),
    .mem_error_out(mem_error_out)
);

initial begin

$display("======================================");
$display(" MAC VERIFICATION START ");
$display("======================================");

$monitor(
"T=%0t valid=%b rd=%b wr=%b kill=%b enable=%b ready=%b err=%b",
$time,
mem_valid_in,
mem_read_in,
mem_write_in,
mem_kill_in,
mem_enable_out,
mem_ready_out,
mem_error_out
);

//////////////////////////////////////////////////
// T1 VALID READ
//////////////////////////////////////////////////

mem_addr_in  = 16'h1000;
mem_wdata_in = 16'hAAAA;
mem_rdata_in = 16'h1234;

mem_valid_in = 1;
mem_read_in  = 1;
mem_write_in = 0;
mem_kill_in  = 0;

#10;

if(mem_enable_out &&
   mem_read_out &&
  !mem_write_out &&
  !mem_error_out)
$display("PASS : VALID READ");
else
$display("FAIL : VALID READ");

//////////////////////////////////////////////////
// T2 VALID WRITE
//////////////////////////////////////////////////

mem_read_in  = 0;
mem_write_in = 1;

#10;

if(mem_enable_out &&
   mem_write_out &&
  !mem_error_out)
$display("PASS : VALID WRITE");
else
$display("FAIL : VALID WRITE");

//////////////////////////////////////////////////
// T3 KILL REQUEST
//////////////////////////////////////////////////

mem_kill_in = 1;

#10;

if(!mem_enable_out &&
   mem_error_out)
$display("PASS : KILL");
else
$display("FAIL : KILL");

//////////////////////////////////////////////////
// T4 RW CONFLICT
//////////////////////////////////////////////////

mem_kill_in  = 0;
mem_read_in  = 1;
mem_write_in = 1;

#10;

if(!mem_enable_out &&
   mem_error_out)
$display("PASS : RW CONFLICT");
else
$display("FAIL : RW CONFLICT");

//////////////////////////////////////////////////
// T5 INVALID TRANSACTION
//////////////////////////////////////////////////

mem_valid_in = 0;
mem_read_in  = 1;
mem_write_in = 0;

#10;

if(!mem_enable_out &&
   !mem_error_out)
$display("PASS : INVALID ACCESS");
else
$display("FAIL : INVALID ACCESS");

//////////////////////////////////////////////////
// T6 DATA PASS THROUGH
//////////////////////////////////////////////////

mem_rdata_in = 16'hBEEF;

#10;

if(mem_rdata_out == 16'hBEEF)
$display("PASS : RDATA PASS");
else
$display("FAIL : RDATA PASS");

//////////////////////////////////////////////////
// T7 ADDRESS PASS
//////////////////////////////////////////////////

mem_addr_in = 16'hFFFF;

#10;

if(mem_addr_out == 16'hFFFF)
$display("PASS : ADDRESS PASS");
else
$display("FAIL : ADDRESS PASS");

//////////////////////////////////////////////////
// T8 WDATA PASS
//////////////////////////////////////////////////

mem_wdata_in = 16'hDEAD;

#10;

if(mem_wdata_out == 16'hDEAD)
$display("PASS : WDATA PASS");
else
$display("FAIL : WDATA PASS");

//////////////////////////////////////////////////
// T9 STALL CHECK
//////////////////////////////////////////////////

if(mem_stall_out == 0)
$display("PASS : STALL");
else
$display("FAIL : STALL");

//////////////////////////////////////////////////
// T10 KILL + CONFLICT
//////////////////////////////////////////////////

mem_valid_in = 1;
mem_read_in = 1;
mem_write_in = 1;
mem_kill_in = 1;

#10;

if(mem_error_out &&
  !mem_enable_out)
$display("PASS : KILL + CONFLICT");
else
$display("FAIL : KILL + CONFLICT");

$display("======================================");
$display(" ALL TESTS COMPLETED ");
$display("======================================");

$finish;

end

endmodule


//OUTPUT
/*
======================================
 MAC VERIFICATION START 
======================================
T=0 valid=1 rd=1 wr=0 kill=0 enable=1 ready=1 err=0
PASS : VALID READ
T=10000 valid=1 rd=0 wr=1 kill=0 enable=1 ready=1 err=0
PASS : VALID WRITE
T=20000 valid=1 rd=0 wr=1 kill=1 enable=0 ready=0 err=1
PASS : KILL
T=30000 valid=1 rd=1 wr=1 kill=0 enable=0 ready=0 err=1
PASS : RW CONFLICT
T=40000 valid=0 rd=1 wr=0 kill=0 enable=0 ready=0 err=0
PASS : INVALID ACCESS
PASS : RDATA PASS
PASS : ADDRESS PASS
PASS : WDATA PASS
PASS : STALL
T=80000 valid=1 rd=1 wr=1 kill=1 enable=0 ready=0 err=1
PASS : KILL + CONFLICT
======================================
 ALL TESTS COMPLETED 
======================================
*/
