`timescale 1ns/1ps

module rom (
    input  [15:0] addr,
    output reg [15:0] data
);

    reg [15:0] mem [0:255];

    initial begin
        // Initialize ROM (fallback if file missing)
        integer i;
        for (i = 0; i < 256; i = i + 1)
            mem[i] = i;

        // Try loading external file (optional)
        $readmemh("rom_init.mem", mem);
    end

    always @(*) begin
        data = mem[addr[7:0]];
    end

endmodule
