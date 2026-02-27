`timescale 1ns/1ps

module reg_file #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 4,
    parameter REG_COUNT = 16
) (
    input wire                  clk,            
    input wire                  rst_n,
    input wire [ADDR_WIDTH-1:0] rs1_addr,       // RS1 address from decoder
    input wire [ADDR_WIDTH-1:0] rs2_addr,       // RS2 address from decoder
    input wire [ADDR_WIDTH-1:0] rd_addr,        // Write address from decoder
    input wire [DATA_WIDTH-1:0] write_data,     // Write data from instruction decoder
    input wire                  reg_write,      // Write enable comes from writeback
    output     [DATA_WIDTH-1:0] rs1_data,       // RS1 data goes to ALU, Branch comparator
    output     [DATA_WIDTH-1:0] rs2_data        // RS2 data goes to ALU, Branch comparator
);

    reg [DATA_WIDTH-1:0] register_file [0:REG_COUNT-1];     // Register File R0 - R15 of 16 bits
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for(i = 0; i < REG_COUNT; i = i + 1) begin
                register_file[i] <= 0;
            end
        end else begin
            if (reg_write) begin
                if (rd_addr != 0) begin
                    register_file[rd_addr] <= write_data;
                end
            end
        end 
    end

    assign rs1_data = (rs1_addr == 0) ? 0 : register_file[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 0 : register_file[rs2_addr];
    
endmodule