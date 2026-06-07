`timescale 1ns / 1ps

module tb_sram_wrapper;

parameter DATA_WIDTH = 16;
parameter DEPTH = 2048;

reg clk;
reg rst_n;

reg [DATA_WIDTH-1:0] mem_addr_in;
reg [DATA_WIDTH-1:0] mem_wdata_in;
reg mem_read_in;
reg mem_write_in;
reg mem_enable_in;
reg mem_clk_en;

wire [DATA_WIDTH-1:0] mem_rdata_out;

sram_wrapper #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .mem_addr_in(mem_addr_in),
    .mem_wdata_in(mem_wdata_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_enable_in(mem_enable_in),
    .mem_clk_en(mem_clk_en),
    .mem_rdata_out(mem_rdata_out)
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
    $display(" SRAM WRAPPER VERIFICATION STARTED ");
    $display("======================================");
end

initial begin
    $monitor(
        "T=%0t rst=%b addr=%h wr=%b rd=%b en=%b clk_en=%b wdata=%h rdata=%h",
        $time,
        rst_n,
        mem_addr_in,
        mem_write_in,
        mem_read_in,
        mem_enable_in,
        mem_clk_en,
        mem_wdata_in,
        mem_rdata_out
    );
end

//////////////////////////////////////////////////
// Tasks
//////////////////////////////////////////////////

task write_mem;
input [15:0] addr;
input [15:0] data;
begin

    @(negedge clk);

    mem_addr_in  = addr;
    mem_wdata_in = data;
    mem_write_in = 1;
    mem_read_in  = 0;

    @(posedge clk);

    #1;
    mem_write_in = 0;

end
endtask

task read_mem;
input [15:0] addr;
input [15:0] expected;
begin

    @(negedge clk);

    mem_addr_in = addr;
    mem_read_in = 1;
    mem_write_in = 0;

    #2;

    if(mem_rdata_out === expected)
        $display("PASS : READ addr=%h data=%h", addr, expected);
    else
        $display("FAIL : READ addr=%h Expected=%h Actual=%h",
                 addr, expected, mem_rdata_out);

    mem_read_in = 0;

end
endtask

//////////////////////////////////////////////////
// Test Sequence
//////////////////////////////////////////////////

initial begin

    rst_n = 0;

    mem_addr_in = 0;
    mem_wdata_in = 0;
    mem_read_in = 0;
    mem_write_in = 0;
    mem_enable_in = 0;
    mem_clk_en = 0;

    //////////////////////////////////////////////////
    // Reset
    //////////////////////////////////////////////////

    #20;

    rst_n = 1;
    mem_enable_in = 1;
    mem_clk_en = 1;

    $display("\nTEST1 : RESET COMPLETE");

    //////////////////////////////////////////////////
    // Single Write / Read
    //////////////////////////////////////////////////

    write_mem(16'd20,16'hABCD);

    $display("Internal memory[10]=%h",
              dut.memory[10]);

    read_mem(16'd20,16'hABCD);

    //////////////////////////////////////////////////
    // Address Conversion
    //////////////////////////////////////////////////

    write_mem(16'd4,16'h1111);

    read_mem(16'd5,16'h1111);

    //////////////////////////////////////////////////
    // Clock Disable
    //////////////////////////////////////////////////

    mem_clk_en = 0;

    write_mem(16'd30,16'hAAAA);

    mem_clk_en = 1;

    read_mem(16'd30,16'h0000);

    //////////////////////////////////////////////////
    // Memory Disable
    //////////////////////////////////////////////////

    mem_enable_in = 0;

    @(negedge clk);

    mem_addr_in = 16'd20;
    mem_read_in = 1;

    #2;

    if(mem_rdata_out == 16'h0000)
        $display("PASS : MEMORY DISABLE");
    else
        $display("FAIL : MEMORY DISABLE");

    mem_read_in = 0;

    mem_enable_in = 1;

    //////////////////////////////////////////////////
    // Maximum Address
    //////////////////////////////////////////////////

    write_mem(16'd4094,16'hDEAD);

    $display("Internal memory[2047]=%h",
              dut.memory[2047]);

    read_mem(16'd4094,16'hDEAD);

    //////////////////////////////////////////////////
    // All Ones
    //////////////////////////////////////////////////

    write_mem(16'd100,16'hFFFF);

    read_mem(16'd100,16'hFFFF);

    //////////////////////////////////////////////////
    // Alternating Pattern
    //////////////////////////////////////////////////

    write_mem(16'd102,16'hAAAA);

    read_mem(16'd102,16'hAAAA);

    //////////////////////////////////////////////////
    // Read + Write Same Cycle
    //////////////////////////////////////////////////

    @(negedge clk);

    mem_addr_in  = 16'd200;
    mem_wdata_in = 16'h5555;

    mem_write_in = 1;
    mem_read_in  = 1;

    @(posedge clk);

    #1;

    $display("INFO : READ+WRITE SAME CYCLE");
    $display("INFO : rdata=%h", mem_rdata_out);

    mem_write_in = 0;
    mem_read_in = 0;

    //////////////////////////////////////////////////
    // Illegal Address
    //////////////////////////////////////////////////

    write_mem(16'hFFFF,16'hBEEF);

    $display("INFO : memory[2047]=%h",
              dut.memory[2047]);

    //////////////////////////////////////////////////
    // Finish
    //////////////////////////////////////////////////

    #50;

    $display("\n======================================");
    $display(" ALL TESTS COMPLETED ");
    $display("======================================");

    $finish;

end

endmodule




/*OUTPUT:
======================================
 SRAM WRAPPER VERIFICATION STARTED 
======================================
T=0 rst=0 addr=0000 wr=0 rd=0 en=0 clk_en=0 wdata=0000 rdata=0000

TEST1 : RESET COMPLETE
T=20000 rst=1 addr=0014 wr=1 rd=0 en=1 clk_en=1 wdata=abcd rdata=0000
Internal memory[10]=abcd
T=26000 rst=1 addr=0014 wr=0 rd=0 en=1 clk_en=1 wdata=abcd rdata=0000
T=30000 rst=1 addr=0014 wr=0 rd=1 en=1 clk_en=1 wdata=abcd rdata=abcd
PASS : READ addr=0014 data=abcd
T=32000 rst=1 addr=0014 wr=0 rd=0 en=1 clk_en=1 wdata=abcd rdata=0000
T=40000 rst=1 addr=0004 wr=1 rd=0 en=1 clk_en=1 wdata=1111 rdata=0000
T=46000 rst=1 addr=0004 wr=0 rd=0 en=1 clk_en=1 wdata=1111 rdata=0000
T=50000 rst=1 addr=0005 wr=0 rd=1 en=1 clk_en=1 wdata=1111 rdata=1111
PASS : READ addr=0005 data=1111
T=52000 rst=1 addr=0005 wr=0 rd=0 en=1 clk_en=0 wdata=1111 rdata=0000
T=60000 rst=1 addr=001e wr=1 rd=0 en=1 clk_en=0 wdata=aaaa rdata=0000
T=66000 rst=1 addr=001e wr=0 rd=0 en=1 clk_en=1 wdata=aaaa rdata=0000
T=70000 rst=1 addr=001e wr=0 rd=1 en=1 clk_en=1 wdata=aaaa rdata=0000
PASS : READ addr=001e data=0000
T=72000 rst=1 addr=001e wr=0 rd=0 en=0 clk_en=1 wdata=aaaa rdata=0000
T=80000 rst=1 addr=0014 wr=0 rd=1 en=0 clk_en=1 wdata=aaaa rdata=0000
PASS : MEMORY DISABLE
T=82000 rst=1 addr=0014 wr=0 rd=0 en=1 clk_en=1 wdata=aaaa rdata=0000
T=90000 rst=1 addr=0ffe wr=1 rd=0 en=1 clk_en=1 wdata=dead rdata=0000
Internal memory[2047]=dead
T=96000 rst=1 addr=0ffe wr=0 rd=0 en=1 clk_en=1 wdata=dead rdata=0000
T=100000 rst=1 addr=0ffe wr=0 rd=1 en=1 clk_en=1 wdata=dead rdata=dead
PASS : READ addr=0ffe data=dead
T=102000 rst=1 addr=0ffe wr=0 rd=0 en=1 clk_en=1 wdata=dead rdata=0000
T=110000 rst=1 addr=0064 wr=1 rd=0 en=1 clk_en=1 wdata=ffff rdata=0000
T=116000 rst=1 addr=0064 wr=0 rd=0 en=1 clk_en=1 wdata=ffff rdata=0000
T=120000 rst=1 addr=0064 wr=0 rd=1 en=1 clk_en=1 wdata=ffff rdata=ffff
PASS : READ addr=0064 data=ffff
T=122000 rst=1 addr=0064 wr=0 rd=0 en=1 clk_en=1 wdata=ffff rdata=0000
T=130000 rst=1 addr=0066 wr=1 rd=0 en=1 clk_en=1 wdata=aaaa rdata=0000
T=136000 rst=1 addr=0066 wr=0 rd=0 en=1 clk_en=1 wdata=aaaa rdata=0000
T=140000 rst=1 addr=0066 wr=0 rd=1 en=1 clk_en=1 wdata=aaaa rdata=aaaa
PASS : READ addr=0066 data=aaaa
T=142000 rst=1 addr=0066 wr=0 rd=0 en=1 clk_en=1 wdata=aaaa rdata=0000
T=150000 rst=1 addr=00c8 wr=1 rd=1 en=1 clk_en=1 wdata=5555 rdata=0000
T=155000 rst=1 addr=00c8 wr=1 rd=1 en=1 clk_en=1 wdata=5555 rdata=5555
INFO : READ+WRITE SAME CYCLE
INFO : rdata=5555
T=156000 rst=1 addr=00c8 wr=0 rd=0 en=1 clk_en=1 wdata=5555 rdata=0000
T=160000 rst=1 addr=ffff wr=1 rd=0 en=1 clk_en=1 wdata=beef rdata=0000
INFO : memory[2047]=beef
T=166000 rst=1 addr=ffff wr=0 rd=0 en=1 clk_en=1 wdata=beef rdata=0000

======================================
 ALL TESTS COMPLETED 
======================================
*/
