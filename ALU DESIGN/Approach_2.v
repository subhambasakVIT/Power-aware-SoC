`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.11.2025 17:46:55
// Design Name: 
// Module Name: alu_16_bit
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


// 16-bit ALU with extended operations
// Optimized for ASIC implementation with sequential multiplier and divider

module alu_16bit (
    input clk,                
    input rst_n,              
    input [15:0] a,           
    input [15:0] b,           
    input [3:0] alu_op,       
    input start,             
    input cin,                
    output reg [15:0] result, 
    output reg cout,          
    output reg zero,          
    output reg negative,      
    output reg overflow,      
    output reg busy,          
    output reg done          
);

// Operation codes
localparam OP_ADD  = 4'b0000;
localparam OP_SUB  = 4'b0001;
localparam OP_MUL  = 4'b0010;
localparam OP_DIV  = 4'b0011;
localparam OP_INC  = 4'b0100;
localparam OP_DEC  = 4'b0101;
localparam OP_NOT  = 4'b0110;  
localparam OP_LSL  = 4'b0111;  
localparam OP_LSR  = 4'b1000;  
localparam OP_ASR  = 4'b1001;  
localparam OP_ASL  = 4'b1010;  
localparam OP_AND  = 4'b1011;  
localparam OP_OR   = 4'b1100;  
localparam OP_XOR  = 4'b1101;  

// Internal wires for combinational ops
wire [15:0] add_result, sub_result, inc_result, dec_result;
wire add_cout, sub_cout, inc_cout, dec_cout;

// Sequential signals
wire [31:0] mul_product;
wire mul_done, mul_busy;
wire [15:0] div_quotient, div_remainder;
wire div_done, div_busy;

// Addition: A + B + 1 
ripple_carry_adder_16 adder (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(add_result),
    .cout(add_cout)
);

// Subtraction: A - B = A + (~B) + 1
ripple_carry_adder_16 subtractor (
    .a(a),
    .b(~b),
    .cin(1'b1),
    .sum(sub_result),
    .cout(sub_cout)
);

// Increment: A + 1
ripple_carry_adder_16 incrementer (
    .a(a),
    .b(16'b0000_0000_0000_0001),
    .cin(1'b0),
    .sum(inc_result),
    .cout(inc_cout)
);

// Decrement: A - 1
ripple_carry_adder_16 decrementer (
    .a(a),
    .b(16'b1111_1111_1111_1110),
    .cin(1'b1),
    .sum(dec_result),
    .cout(dec_cout)
);

// Sequential shift-and-add multiplier 
sequential_multiplier_16 multiplier (
    .clk(clk),
    .rst_n(rst_n),
    .start(start && (alu_op == OP_MUL)),
    .a(a),
    .b(b),
    .product(mul_product),
    .done(mul_done),
    .busy(mul_busy)
);

// Sequential shift-and-subtract divider 
sequential_divider_16 divider (
    .clk(clk),
    .rst_n(rst_n),
    .start(start && (alu_op == OP_DIV)),
    .dividend(a),
    .divisor(b),
    .quotient(div_quotient),
    .remainder(div_remainder),
    .done(div_done),
    .busy(div_busy)
);

always @(*) begin
    cout = 1'b0;
    overflow = 1'b0;
    busy = 1'b0;
    done = 1'b0;
    
    case(alu_op)
        OP_ADD: begin
            result = add_result;
            cout = add_cout;
            overflow = (a[15] == b[15]) && (a[15] != result[15]);
        end
        
        OP_SUB: begin
            result = sub_result;
            cout = sub_cout;
            overflow = (a[15] != b[15]) && (a[15] != result[15]);
        end
        
        OP_MUL: begin
            result = mul_product[15:0];  
            cout = |mul_product[31:16];  
            overflow = |mul_product[31:16];
            busy = mul_busy;
            done = mul_done;
        end
        
        OP_DIV: begin
            result = div_quotient;
            cout = 1'b0;
            overflow = (b == 16'b0); 
            busy = div_busy;
            done = div_done;
        end
        
        OP_INC: begin
            result = inc_result;
            cout = inc_cout;
            overflow = (a == 16'h7FFF);
        end
        
        OP_DEC: begin
            result = dec_result;
            cout = dec_cout;
            overflow = (a == 16'h8000);
        end
        
        OP_NOT: begin
            result = ~a;
            cout = 1'b0;
            overflow = 1'b0;
        end
        
        OP_LSL: begin
            result = a << b[3:0];
            cout = (b[3:0] != 0) ? a[16 - b[3:0]] : 1'b0;
            overflow = 1'b0;
        end
        
        OP_LSR: begin
            result = a >> b[3:0];
            cout = (b[3:0] != 0) ? a[b[3:0] - 1] : 1'b0;
            overflow = 1'b0;
        end
        
        OP_ASR: begin
            result = $signed(a) >>> b[3:0];
            cout = (b[3:0] != 0) ? a[b[3:0] - 1] : 1'b0;
            overflow = 1'b0;
        end
        
        OP_ASL: begin
            result = a <<< b[3:0];
            cout = (b[3:0] != 0) ? a[16 - b[3:0]] : 1'b0;
            overflow = (b[3:0] != 0) && (a[15] != result[15]);
        end
        
        OP_AND: begin
            result = a & b;
            cout = 1'b0;
            overflow = 1'b0;
        end
        
        OP_OR: begin
            result = a | b;
            cout = 1'b0;
            overflow = 1'b0;
        end
        
        OP_XOR: begin
            result = a ^ b;
            cout = 1'b0;
            overflow = 1'b0;
        end
        
        default: begin
            result = 16'b0;
            cout = 1'b0;
            overflow = 1'b0;
        end
    endcase

    zero = (result == 16'b0);
    negative = result[15];
end

endmodule

// 1-bit Full Adder
module full_adder (
    input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// 16-bit Ripple Carry Adder
module ripple_carry_adder_16 (
    input [15:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire [16:0] carry;
    
    assign carry[0] = cin;
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    
    assign cout = carry[16];
endmodule

module sequential_multiplier_16 (
    input clk,
    input rst_n,
    input start,             
    input [15:0] a,         
    input [15:0] b,           
    output reg [31:0] product,
    output reg done,
    output reg busy
);
    localparam IDLE  = 2'b00;
    localparam INIT  = 2'b01;
    localparam COMPUTE = 2'b10;
    localparam DONE  = 2'b11;
    
    reg [1:0] state;
    reg [4:0] count;         
    reg [31:0] accumulator;   
    reg [15:0] multiplier;    
    reg [31:0] multiplicand;  
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            product <= 32'b0;
            done <= 1'b0;
            busy <= 1'b0;
            count <= 5'b0;
            accumulator <= 32'b0;
            multiplier <= 16'b0;
            multiplicand <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    busy <= 1'b0;
                    if (start) begin
                        state <= INIT;
                        busy <= 1'b1;
                    end
                end
                
                INIT: begin
                    accumulator <= 32'b0;
                    multiplicand <= {16'b0, a}; 
                    multiplier <= b;
                    count <= 5'd0;
                    state <= COMPUTE;
                end
                
                COMPUTE: begin
                    if (multiplier[0]) begin
                        accumulator <= accumulator + multiplicand;
                    end
                    
                    multiplier <= multiplier >> 1;
                    multiplicand <= multiplicand << 1;
                    
                    count <= count + 1'b1;
                    
                    if (count == 5'd15) begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    product <= accumulator;
                    done <= 1'b1;
                    busy <= 1'b0;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule

module sequential_divider_16 (
    input clk,
    input rst_n,
    input start,
    input [15:0] dividend,
    input [15:0] divisor,
    output reg [15:0] quotient,
    output reg [15:0] remainder,
    output reg done,
    output reg busy
);
    localparam IDLE    = 2'b00;
    localparam INIT    = 2'b01;
    localparam COMPUTE = 2'b10;
    localparam DONE    = 2'b11;
    
    reg [1:0] state;
    reg [4:0] count;
    reg [31:0] remainder_reg;  
    reg [15:0] divisor_reg;
    reg div_by_zero;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            quotient <= 16'b0;
            remainder <= 16'b0;
            done <= 1'b0;
            busy <= 1'b0;
            count <= 5'b0;
            remainder_reg <= 32'b0;
            divisor_reg <= 16'b0;
            div_by_zero <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    busy <= 1'b0;
                    if (start) begin
                        state <= INIT;
                        busy <= 1'b1;
                    end
                end
                
                INIT: begin
                    if (divisor == 16'b0) begin
                        quotient <= 16'hFFFF;  
                        remainder <= dividend;
                        div_by_zero <= 1'b1;
                        state <= DONE;
                    end else begin
                        remainder_reg <= {16'b0, dividend};
                        divisor_reg <= divisor;
                        count <= 5'd0;
                        div_by_zero <= 1'b0;
                        state <= COMPUTE;
                    end
                end
                
                COMPUTE: begin
                    remainder_reg <= remainder_reg << 1;
                    
                    if (remainder_reg[31]) begin
                        remainder_reg[31:16] <= remainder_reg[31:16] + divisor_reg;
                        remainder_reg[0] <= 1'b0;  
                    end else begin
                        if (remainder_reg[31:16] >= divisor_reg) begin
                            remainder_reg[31:16] <= remainder_reg[31:16] - divisor_reg;
                            remainder_reg[0] <= 1'b1;  
                        end else begin
                            remainder_reg[0] <= 1'b0;  
                        end
                    end
                    
                    count <= count + 1'b1;
                    
                    if (count == 5'd15) begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    if (!div_by_zero) begin
                        quotient <= remainder_reg[15:0];
                        
                        if (remainder_reg[31]) begin
                            remainder <= remainder_reg[31:16] + divisor_reg;
                        end else begin
                            remainder <= remainder_reg[31:16];
                        end
                    end
                    done <= 1'b1;
                    busy <= 1'b0;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
