module memory_controller (
    input  [15:0] addr,
    output rom_sel,
    output sram_sel
);

    assign rom_sel  = (addr < 16'h4000);
    assign sram_sel = (addr >= 16'h4000);

endmodule
