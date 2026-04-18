`timescale 1ns / 1ps
module sram (
    input clk,
    input we,
    input en,
    input [15:0] addr,
    input [15:0] din,
    output reg [15:0] dout
);

    reg [15:0] mem [0:255];

    // Initialization (IMPORTANT FIX)
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 16'h0000;
    end

    // Stable synchronous read/write
    always @(posedge clk) begin
        if (en) begin
            if (we)
                mem[addr[7:0]] <= din;

            // ALWAYS update output → avoids X
            dout <= mem[addr[7:0]];
        end
        else begin
            // HOLD previous value (no X propagation)
            dout <= dout;
        end
    end

endmodule
