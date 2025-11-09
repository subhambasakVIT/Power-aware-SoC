`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2025 00:53:02
// Design Name: 
// Module Name: ALU_BIT16
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fulladder(input a,b,c, output sum,carry);
    assign sum   = a ^ b ^ c;
    assign carry = (a & b) | (b & c) | (a & c);
endmodule

module gate(input a,b, output c);
assign c = a^b;
endmodule

module ADDER_SUBTRACTOR(input [15:0]a,b,input wire c, output[16:0]res );

wire [15:0]carry;
wire [15:0]temp;

gate x1(c,b[0],temp[0]);
gate x2(c,b[1],temp[1]);
gate x3(c,b[2],temp[2]);
gate x4(c,b[3],temp[3]);
gate x5(c,b[4],temp[4]);
gate x6(c,b[5],temp[5]);
gate x7(c,b[6],temp[6]);
gate x8(c,b[7],temp[7]);
gate x9(c,b[8],temp[8]);
gate x10(c,b[9],temp[9]);
gate x11(c,b[10],temp[10]);
gate x12(c,b[11],temp[11]);
gate x13(c,b[12],temp[12]);
gate x14(c,b[13],temp[13]);
gate x15(c,b[14],temp[14]);
gate x16(c,b[15],temp[15]);

fulladder FA1(a[0],temp[0],c,res[0],carry[0]);
fulladder FA2(a[1],temp[1],carry[0],res[1],carry[1]);
fulladder FA3(a[2],temp[2],carry[1],res[2],carry[2]);
fulladder FA4(a[3],temp[3],carry[2],res[3],carry[3]);
fulladder FA5(a[4],temp[4],carry[3],res[4],carry[4]);
fulladder FA6(a[5],temp[5],carry[4],res[5],carry[5]);
fulladder FA7(a[6],temp[6],carry[5],res[6],carry[6]);
fulladder FA8(a[7],temp[7],carry[6],res[7],carry[7]);
fulladder FA9(a[8],temp[8],carry[7],res[8],carry[8]);
fulladder FA10(a[9],temp[9],carry[8],res[9],carry[9]);
fulladder FA11(a[10],temp[10],carry[9],res[10],carry[10]);
fulladder FA12(a[11],temp[11],carry[10],res[11],carry[11]);
fulladder FA13(a[12],temp[12],carry[11],res[12],carry[12]);
fulladder FA14(a[13],temp[13],carry[12],res[13],carry[13]);
fulladder FA15(a[14],temp[14],carry[13],res[14],carry[14]);
fulladder FA16(a[15],temp[15],carry[14],res[15],carry[15]);

assign res[16] = (c == 1'b1) ? (carry[15] ^ carry[14]) : carry[15];

endmodule

module multiplier_16bit(input  [15:0] a,input  [15:0] b,output reg [31:0] product);
    
    integer i;
    always @(*) 
        begin
            product = 0;
            for (i = 0; i < 16; i = i + 1)
                if (b[i])
                    product = product + (a << i);
        end
endmodule

module divider_16bit_struct (input  [15:0] dividend,input  [15:0] divisor,output reg [15:0] quotient,output reg [15:0] remainder);
    integer i;

    always @(*) begin
        quotient  = 0;
        remainder = 0;
        
        for (i = 15; i >= 0; i = i - 1) begin
            remainder = {remainder[14:0], dividend[i]};
            if (remainder >= divisor) begin
                remainder = remainder - divisor;
                quotient[i] = 1;
            end
        end
    end
endmodule

module LSL_16 (
    input  [15:0] a,
    input  [3:0]  shamt,
    output [15:0] y
);
    assign y = a << shamt;
endmodule

module LSR_16 (
    input  [15:0] a,
    input  [3:0]  shamt,
    output [15:0] y
);
    assign y = a >> shamt;
endmodule

module ASR_16 (
    input  signed [15:0] a,
    input  [3:0]  shamt,
    output signed [15:0] y
);
    assign y = a >>> shamt;
endmodule

module ASL_16 (
    input  signed [15:0] a,
    input  [3:0]  shamt,
    output signed [15:0] y
);
    assign y = a <<< shamt;
endmodule

module incrementer_16 (
    input  [15:0] a,
    output [15:0] y
);
    assign y = a + 16'd1;
endmodule

module decrementer_16 (
    input  [15:0] a,
    output [15:0] y
);
    assign y = a - 16'd1;
endmodule



module ALU_BIT_16 (input  [15:0] A, B,input  [3:0]  shamt,input  [3:0]  sel,input cin,output reg [31:0] result,output reg [15:0] remainder,output reg carry_out);

    // Internal wires
    wire [16:0] addsub_res;
    wire [31:0] mult_res;
    wire [15:0] div_q, div_r;
    wire [15:0] lsl_res, lsr_res, asr_res, asl_res;
    wire [15:0] inc_res, dec_res;

    // Module Instantiations
    ADDER_SUBTRACTOR U1 (.a(A), .b(B), .c(cin), .res(addsub_res));
    multiplier_16bit  U2 (.a(A), .b(B), .product(mult_res));
    divider_16bit_struct U3 (.dividend(A), .divisor(B), .quotient(div_q), .remainder(div_r));
    LSL_16 U4 (.a(A), .shamt(shamt), .y(lsl_res));
    LSR_16 U5 (.a(A), .shamt(shamt), .y(lsr_res));
    ASR_16 U6 (.a(A), .shamt(shamt), .y(asr_res));
    ASL_16 U7 (.a(A), .shamt(shamt), .y(asl_res));
    incrementer_16 U8 (.a(A), .y(inc_res));
    decrementer_16 U9 (.a(A), .y(dec_res));

    // Operation Selection
    always @(*) begin
        case (sel)
            4'b0000: begin // ADD
                result     = {16'b0, addsub_res[15:0]};
                carry_out  = addsub_res[16];
                remainder  = 0;
            end
            4'b0001: begin // SUB
                result     = {16'b0, addsub_res[15:0]};
                carry_out  = addsub_res[16];
                remainder  = 0;
            end
            4'b0010: begin // MULTIPLY
                result     = mult_res;
                carry_out  = 0;
                remainder  = 0;
            end
            4'b0011: begin // DIVIDE
                result     = {16'b0, div_q};
                remainder  = div_r;
                carry_out  = 0;
            end
            4'b0100: begin // LSL
                result     = {16'b0, lsl_res};
                carry_out  = 0;
                remainder  = 0;
            end
            4'b0101: begin // LSR
                result     = {16'b0, lsr_res};
                carry_out  = 0;
                remainder  = 0;
            end
            4'b0110: begin // ASR
                result     = {16'b0, asr_res};
                carry_out  = 0;
                remainder  = 0;
            end
            4'b0111: begin // ASL
                result     = {16'b0, asl_res};
                carry_out  = 0;
                remainder  = 0;
            end
            4'b1000: begin // INCREMENT
                result     = {16'b0, inc_res};
                carry_out  = 0;
                remainder  = 0;
            end
            4'b1001: begin // DECREMENT
                result     = {16'b0, dec_res};
                carry_out  = 0;
                remainder  = 0;
            end
            default: begin
                result     = 0;
                carry_out  = 0;
                remainder  = 0;
            end
        endcase
    end
endmodule

