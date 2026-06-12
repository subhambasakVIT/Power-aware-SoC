`timescale 1ns/1ps

module tb_memory_top;

reg clk;
reg rst_n;

reg [15:0] alu_result_in;
reg [15:0] rs2_data_in;
reg [15:0] pc_in;

reg [3:0] rd_in;

reg mem_read_in;
reg mem_write_in;
reg reg_write_in;
reg [1:0] wb_sel_in;
reg mem_clk_en;

reg enable;
reg flush;
reg branch_taken_in;

wire [15:0] wb_data_out;
wire [3:0] rd_out;
wire reg_write_out;

wire mem_ready_out;
wire mem_stall_out;
wire mem_error_out;

memory_top dut(
    .clk(clk),
    .rst_n(rst_n),

    .alu_result_in(alu_result_in),
    .rs2_data_in(rs2_data_in),
    .pc_in(pc_in),

    .rd_in(rd_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .reg_write_in(reg_write_in),
    .wb_sel_in(wb_sel_in),
    .mem_clk_en(mem_clk_en),

    .enable(enable),
    .flush(flush),
    .branch_taken_in(branch_taken_in),

    .wb_data_out(wb_data_out),
    .rd_out(rd_out),
    .reg_write_out(reg_write_out),

    .mem_ready_out(mem_ready_out),
    .mem_stall_out(mem_stall_out),
    .mem_error_out(mem_error_out)
);

//////////////////////////////////////////////////////
// CLOCK
//////////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//////////////////////////////////////////////////////
// MONITOR
//////////////////////////////////////////////////////

initial begin
    $monitor(
    "T=%0t rst=%b rd=%b wr=%b en=%b flush=%b br=%b wb=%h rdout=%h err=%b",
    $time,
    rst_n,
    mem_read_in,
    mem_write_in,
    enable,
    flush,
    branch_taken_in,
    wb_data_out,
    rd_out,
    mem_error_out
    );
end

//////////////////////////////////////////////////////
// TEST SEQUENCE
//////////////////////////////////////////////////////

initial begin

$display("======================================");
$display(" MEMORY TOP VERIFICATION START ");
$display("======================================");

//////////////////////////////////////////////////////
// DEFAULTS
//////////////////////////////////////////////////////

rst_n = 0;

alu_result_in = 0;
rs2_data_in = 0;
pc_in = 0;

rd_in = 0;

mem_read_in = 0;
mem_write_in = 0;
reg_write_in = 0;
wb_sel_in = 0;
mem_clk_en = 1;

enable = 1;
flush = 0;
branch_taken_in = 0;

//////////////////////////////////////////////////////
// RESET
//////////////////////////////////////////////////////

#20;
rst_n = 1;

#2;

if(wb_data_out==0 &&
   rd_out==0 &&
   reg_write_out==0)
$display("PASS : RESET");
else
$display("FAIL : RESET");

//////////////////////////////////////////////////////
// TEST 1 STORE
//////////////////////////////////////////////////////

alu_result_in = 16'h0010;
rs2_data_in   = 16'hABCD;

mem_write_in  = 1;
reg_write_in  = 0;

@(posedge clk);
#1;

mem_write_in = 0;

#2;

if(dut.sram_inst.memory[8] == 16'hABCD)
$display("PASS : STORE PATH");
else
$display("FAIL : STORE PATH");

//////////////////////////////////////////////////////
// TEST 2 LOAD
//////////////////////////////////////////////////////

alu_result_in = 16'h0010;

mem_read_in   = 1;
reg_write_in  = 1;

rd_in         = 4'h5;
wb_sel_in     = 2'b01;

@(posedge clk);
#2;

@(posedge clk);
#2;

if(wb_data_out == 16'hABCD &&
   rd_out == 4'h5 &&
   reg_write_out)
$display("PASS : LOAD PATH");
else
$display("FAIL : LOAD PATH");

mem_read_in = 0;

//////////////////////////////////////////////////////
// TEST 3 FLUSH
//////////////////////////////////////////////////////

flush = 1;

#5;

if(wb_data_out == 0 &&
   rd_out == 0 &&
   reg_write_out == 0)
$display("PASS : FLUSH");
else
$display("FAIL : FLUSH");

flush = 0;

//////////////////////////////////////////////////////
// TEST 4 BRANCH KILL
//////////////////////////////////////////////////////

branch_taken_in = 1;

#5;

if(rd_out == 0 &&
   reg_write_out == 0)
$display("PASS : BRANCH");
else
$display("FAIL : BRANCH");

branch_taken_in = 0;

//////////////////////////////////////////////////////
// TEST 5 DISABLE
//////////////////////////////////////////////////////

enable = 0;

alu_result_in = 16'h0020;
rs2_data_in   = 16'h1111;

mem_write_in = 1;

@(posedge clk);

if(dut.sram_inst.memory[16] != 16'h1111)
$display("PASS : DISABLE");
else
$display("FAIL : DISABLE");

enable = 1;
mem_write_in = 0;

//////////////////////////////////////////////////////
// TEST 6 MISALIGNED LOAD
//////////////////////////////////////////////////////

alu_result_in = 16'h0011;

mem_read_in = 1;

#5;

if(mem_error_out)
$display("PASS : MISALIGNED LOAD");
else
$display("FAIL : MISALIGNED LOAD");

mem_read_in = 0;

//////////////////////////////////////////////////////
// TEST 7 MISALIGNED STORE
//////////////////////////////////////////////////////

alu_result_in = 16'h0013;

mem_write_in = 1;

#5;

if(mem_error_out)
$display("PASS : MISALIGNED STORE");
else
$display("FAIL : MISALIGNED STORE");

mem_write_in = 0;

//////////////////////////////////////////////////////
// TEST 8 READ WRITE CONFLICT
//////////////////////////////////////////////////////

alu_result_in = 16'h0040;

mem_read_in  = 1;
mem_write_in = 1;

#5;

if(mem_error_out)
$display("PASS : RW CONFLICT");
else
$display("FAIL : RW CONFLICT");

mem_read_in = 0;
mem_write_in = 0;

//////////////////////////////////////////////////////
// TEST 9 CLOCK GATE
//////////////////////////////////////////////////////

mem_clk_en = 0;

alu_result_in = 16'h0030;
rs2_data_in   = 16'h5555;

mem_write_in = 1;

@(posedge clk);

mem_write_in = 0;

if(dut.sram_inst.memory[24] != 16'h5555)
$display("PASS : CLOCK GATE");
else
$display("FAIL : CLOCK GATE");

mem_clk_en = 1;

//////////////////////////////////////////////////////
// TEST 10 ALU WRITEBACK
//////////////////////////////////////////////////////

alu_result_in = 16'h1234;

wb_sel_in = 2'b00;
reg_write_in = 1;
rd_in = 4'h6;

@(posedge clk);
#2;

if(wb_data_out == 16'h1234)
$display("PASS : ALU WB");
else
$display("FAIL : ALU WB");

//////////////////////////////////////////////////////
// TEST 11 PC+2 WRITEBACK
//////////////////////////////////////////////////////

pc_in = 16'h1000;

wb_sel_in = 2'b10;

@(posedge clk);
#2;

if(wb_data_out == 16'h1002)
$display("PASS : PC+2 WB");
else
$display("FAIL : PC+2 WB");

//////////////////////////////////////////////////////
// TEST 12 MAX ADDRESS
//////////////////////////////////////////////////////

alu_result_in = 16'hFFFE;
rs2_data_in   = 16'hDEAD;

wb_sel_in = 2'b00;

mem_write_in = 1;

@(posedge clk);

mem_write_in = 0;

if(dut.sram_inst.memory[2047] == 16'hDEAD)
$display("PASS : MAX ADDRESS");
else
$display("FAIL : MAX ADDRESS");

//////////////////////////////////////////////////////
// TEST 13 MAX REGISTER
//////////////////////////////////////////////////////

rd_in = 4'hF;

@(posedge clk);

if(rd_out == 4'hF)
$display("PASS : MAX REGISTER");
else
$display("FAIL : MAX REGISTER");

//////////////////////////////////////////////////////
// TEST 14 INTERNAL MAH CHECK
//////////////////////////////////////////////////////

alu_result_in = 16'h0005;

#2;

if(dut.mah_inst.mem_kill_out)
$display("PASS : MAH ACTIVE");
else
$display("FAIL : MAH ACTIVE");

//////////////////////////////////////////////////////
// TEST 15 INTERNAL MAC CHECK
//////////////////////////////////////////////////////

mem_read_in  = 1;
mem_write_in = 1;

#2;

if(dut.mac_inst.mem_error_out)
$display("PASS : MAC ACTIVE");
else
$display("FAIL : MAC ACTIVE");

mem_read_in  = 0;
mem_write_in = 0;

//////////////////////////////////////////////////////

$display("======================================");
$display(" ALL INTEGRATION TESTS COMPLETED ");
$display("======================================");

$finish;

end

endmodule

//OUTPUT
/*
======================================
 MEMORY TOP VERIFICATION START 
======================================
T=0 rst=0 rd=0 wr=0 en=1 flush=0 br=0 wb=0000 rdout=0 err=0
T=20000 rst=1 rd=0 wr=0 en=1 flush=0 br=0 wb=0000 rdout=0 err=0
PASS : RESET
T=22000 rst=1 rd=0 wr=1 en=1 flush=0 br=0 wb=0000 rdout=0 err=0
T=25000 rst=1 rd=0 wr=1 en=1 flush=0 br=0 wb=0010 rdout=0 err=0
T=26000 rst=1 rd=0 wr=0 en=1 flush=0 br=0 wb=0010 rdout=0 err=0
PASS : STORE PATH
T=28000 rst=1 rd=1 wr=0 en=1 flush=0 br=0 wb=0010 rdout=0 err=0
T=35000 rst=1 rd=1 wr=0 en=1 flush=0 br=0 wb=abcd rdout=5 err=0
PASS : LOAD PATH
T=47000 rst=1 rd=0 wr=0 en=1 flush=1 br=0 wb=abcd rdout=5 err=0
FAIL : FLUSH
T=52000 rst=1 rd=0 wr=0 en=1 flush=0 br=1 wb=abcd rdout=5 err=0
T=55000 rst=1 rd=0 wr=0 en=1 flush=0 br=1 wb=0000 rdout=0 err=0
PASS : BRANCH
T=57000 rst=1 rd=0 wr=1 en=0 flush=0 br=0 wb=0000 rdout=0 err=0
PASS : DISABLE
T=65000 rst=1 rd=1 wr=0 en=1 flush=0 br=0 wb=0000 rdout=5 err=1
PASS : MISALIGNED LOAD
T=70000 rst=1 rd=0 wr=1 en=1 flush=0 br=0 wb=0000 rdout=5 err=1
PASS : MISALIGNED STORE
T=75000 rst=1 rd=1 wr=1 en=1 flush=0 br=0 wb=0000 rdout=5 err=1
PASS : RW CONFLICT
T=80000 rst=1 rd=0 wr=1 en=1 flush=0 br=0 wb=0000 rdout=5 err=0
PASS : CLOCK GATE
T=85000 rst=1 rd=0 wr=0 en=1 flush=0 br=0 wb=0000 rdout=5 err=0
T=95000 rst=1 rd=0 wr=0 en=1 flush=0 br=0 wb=1234 rdout=6 err=0
PASS : ALU WB
T=105000 rst=1 rd=0 wr=0 en=1 flush=0 br=0 wb=1002 rdout=6 err=0
PASS : PC+2 WB
T=107000 rst=1 rd=0 wr=1 en=1 flush=0 br=0 wb=1002 rdout=6 err=0
FAIL : MAX ADDRESS
T=115000 rst=1 rd=0 wr=0 en=1 flush=0 br=0 wb=fffe rdout=6 err=0
FAIL : MAX REGISTER
T=125000 rst=1 rd=0 wr=0 en=1 flush=0 br=0 wb=fffe rdout=f err=1
PASS : MAH ACTIVE
T=127000 rst=1 rd=1 wr=1 en=1 flush=0 br=0 wb=fffe rdout=f err=1
PASS : MAC ACTIVE
======================================
 ALL INTEGRATION TESTS COMPLETED 
======================================
*/
