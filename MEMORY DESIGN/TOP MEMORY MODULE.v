module memory_top (
    input clk,
    input we,
    input [15:0] addr,
    input [15:0] din,
    output reg [15:0] dout
);

    wire rom_sel, sram_sel;
    wire [15:0] rom_data;
    wire [15:0] sram_data;

    // Address decoder
    memory_controller mc (
        .addr(addr),
        .rom_sel(rom_sel),
        .sram_sel(sram_sel)
    );

    // ROM
    rom ROM (
        .addr(addr),
        .data(rom_data)
    );

    // SRAM
    sram SRAM (
        .clk(clk),
        .we(we),
        .en(sram_sel),
        .addr(addr),
        .din(din),
        .dout(sram_data)
    );

    // FINAL OUTPUT (FIXED - NO X PROPAGATION)
    always @(*) begin
        if (rom_sel)
            dout = rom_data;
        else if (sram_sel)
            dout = sram_data;
        else
            dout = 16'h0000;  // safe default
    end

endmodule
