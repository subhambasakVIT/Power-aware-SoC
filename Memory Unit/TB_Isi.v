`timescale 1ns/1ps

module tb_lsi;

reg [15:0] alu_result_in;
reg [15:0] rs2_data_in;

reg mem_read_in;
reg mem_write_in;
reg reg_write_in;

reg [3:0] rd_in;

reg branch_taken_in;
reg enable;
reg flush;

reg [1:0] wb_sel_in;

reg [15:0] pc_in;

wire [15:0] mem_addr;
wire [15:0] mem_wdata;
wire mem_read;
wire mem_write;
wire mem_valid;

wire reg_write_out;
wire [3:0] rd_out;
wire [1:0] wb_sel_out;

wire [15:0] alu_result_out;
wire [15:0] pc_out;

lsi dut(
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

    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_valid(mem_valid),

    .reg_write_out(reg_write_out),
    .rd_out(rd_out),
    .wb_sel_out(wb_sel_out),

    .alu_result_out(alu_result_out),
    .pc_out(pc_out)
);

initial begin

$display("======================================");
$display(" LSI VERIFICATION START ");
$display("======================================");

$monitor(
"T=%0t en=%b flush=%b branch=%b rd=%h wr=%h valid=%b reg_write=%b rd_out=%h wb_sel=%b",
$time,
enable,
flush,
branch_taken_in,
mem_read,
mem_write,
mem_valid,
reg_write_out,
rd_out,
wb_sel_out
);

//////////////////////////////////////////////////
// T1 NORMAL LOAD
//////////////////////////////////////////////////

alu_result_in=16'h1000;
rs2_data_in=16'hAAAA;
mem_read_in=1;
mem_write_in=0;
reg_write_in=1;
rd_in=4'h5;
wb_sel_in=2'b01;
pc_in=16'h2000;

enable=1;
flush=0;
branch_taken_in=0;

#10;

if(mem_read && mem_valid)
$display("PASS : NORMAL LOAD");
else
$display("FAIL : NORMAL LOAD");

//////////////////////////////////////////////////
// T2 NORMAL STORE
//////////////////////////////////////////////////

mem_read_in=0;
mem_write_in=1;

#10;

if(mem_write && mem_valid)
$display("PASS : NORMAL STORE");
else
$display("FAIL : NORMAL STORE");

//////////////////////////////////////////////////
// T3 FLUSH
//////////////////////////////////////////////////

flush=1;

#10;

if(!mem_read &&
   !mem_write &&
   !mem_valid &&
   !reg_write_out &&
   rd_out==0)
$display("PASS : FLUSH");
else
$display("FAIL : FLUSH");

//////////////////////////////////////////////////
// T4 BRANCH
//////////////////////////////////////////////////

flush=0;
branch_taken_in=1;

#10;

if(!mem_read &&
   !mem_write &&
   !reg_write_out)
$display("PASS : BRANCH");
else
$display("FAIL : BRANCH");

//////////////////////////////////////////////////
// T5 DISABLE
//////////////////////////////////////////////////

branch_taken_in=0;
enable=0;

#10;

if(!mem_read &&
   !mem_write &&
   !reg_write_out)
$display("PASS : DISABLE");
else
$display("FAIL : DISABLE");

//////////////////////////////////////////////////
// T6 ADDRESS PASS
//////////////////////////////////////////////////

enable=1;

#10;

if(mem_addr==16'h1000)
$display("PASS : ADDRESS PASS");
else
$display("FAIL : ADDRESS PASS");

//////////////////////////////////////////////////
// T7 STORE DATA PASS
//////////////////////////////////////////////////

if(mem_wdata==16'hAAAA)
$display("PASS : WDATA PASS");
else
$display("FAIL : WDATA PASS");

//////////////////////////////////////////////////
// T8 ALU PASS
//////////////////////////////////////////////////

if(alu_result_out==16'h1000)
$display("PASS : ALU PASS");
else
$display("FAIL : ALU PASS");

//////////////////////////////////////////////////
// T9 PC PASS
//////////////////////////////////////////////////

if(pc_out==16'h2000)
$display("PASS : PC PASS");
else
$display("FAIL : PC PASS");

//////////////////////////////////////////////////
// T10 MAX VALUES
//////////////////////////////////////////////////

alu_result_in=16'hFFFF;
rs2_data_in=16'hFFFF;
rd_in=4'hF;
wb_sel_in=2'b11;

#10;

if(mem_addr==16'hFFFF &&
   mem_wdata==16'hFFFF &&
   rd_out==4'hF)
$display("PASS : MAX VALUES");
else
$display("FAIL : MAX VALUES");

//////////////////////////////////////////////////
// T11 FLUSH + BRANCH
//////////////////////////////////////////////////

flush=1;
branch_taken_in=1;

#10;

if(!mem_valid &&
   !reg_write_out &&
   rd_out==0)
$display("PASS : FLUSH+BRANCH");
else
$display("FAIL : FLUSH+BRANCH");

$display("======================================");
$display(" ALL TESTS COMPLETED ");
$display("======================================");

$finish;

end

endmodule

//OUTPUT
/*
======================================
 LSI VERIFICATION START 
======================================
T=0 en=1 flush=0 branch=0 rd=1 wr=0 valid=1 reg_write=1 rd_out=5 wb_sel=01
PASS : NORMAL LOAD
T=10000 en=1 flush=0 branch=0 rd=0 wr=1 valid=1 reg_write=1 rd_out=5 wb_sel=01
PASS : NORMAL STORE
T=20000 en=1 flush=1 branch=0 rd=0 wr=0 valid=0 reg_write=0 rd_out=0 wb_sel=00
PASS : FLUSH
T=30000 en=1 flush=0 branch=1 rd=0 wr=0 valid=0 reg_write=0 rd_out=0 wb_sel=00
PASS : BRANCH
T=40000 en=0 flush=0 branch=0 rd=0 wr=0 valid=0 reg_write=0 rd_out=5 wb_sel=01
PASS : DISABLE
T=50000 en=1 flush=0 branch=0 rd=0 wr=1 valid=1 reg_write=1 rd_out=5 wb_sel=01
PASS : ADDRESS PASS
PASS : WDATA PASS
PASS : ALU PASS
PASS : PC PASS
T=60000 en=1 flush=0 branch=0 rd=0 wr=1 valid=1 reg_write=1 rd_out=f wb_sel=11
PASS : MAX VALUES
T=70000 en=1 flush=1 branch=1 rd=0 wr=0 valid=0 reg_write=0 rd_out=0 wb_sel=00
PASS : FLUSH+BRANCH
======================================
 ALL TESTS COMPLETED 
======================================
*/
