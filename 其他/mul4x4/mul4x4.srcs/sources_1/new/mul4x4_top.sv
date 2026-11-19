`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 19:47:49
// Design Name: 
// Module Name: mul4x4_top
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


module full_adder (
    input  logic x,
    input  logic y,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign sum  = x ^ y ^ cin;
    assign cout = (x & y) | (x & cin) | (y & cin);
endmodule



module ripple_adder8 (
    input  logic [7:0] x,
    input  logic [7:0] y,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
    logic [8:0] c;

    assign c[0] = cin;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_fa
            full_adder u_fa (
                .x    (x[i]),
                .y    (y[i]),
                .cin  (c[i]),
                .sum  (sum[i]),
                .cout (c[i+1])
            );
        end
    endgenerate

    assign cout = c[8];
endmodule



module multiplier4x4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] p
);
    logic [7:0] pp0;
    logic [7:0] pp1;
    logic [7:0] pp2;
    logic [7:0] pp3;

    logic [7:0] s01;
    logic [7:0] s012;
    logic [7:0] s0123;

    logic c01;
    logic c012;
    logic c0123;


    assign pp0 = {4'b0000, (a & {4{b[0]}})};
    assign pp1 = {3'b000,  (a & {4{b[1]}}), 1'b0};
    assign pp2 = {2'b00,   (a & {4{b[2]}}), 2'b00};
    assign pp3 = {1'b0,    (a & {4{b[3]}}), 3'b000};

    ripple_adder8 add01 (
        .x    (pp0),
        .y    (pp1),
        .cin  (1'b0),
        .sum  (s01),
        .cout (c01)
    );

    ripple_adder8 add012 (
        .x    (s01),
        .y    (pp2),
        .cin  (1'b0),
        .sum  (s012),
        .cout (c012)
    );

    ripple_adder8 add0123 (
        .x    (s012),
        .y    (pp3),
        .cin  (1'b0),
        .sum  (s0123),
        .cout (c0123)
    );

    assign p = s0123;
endmodule


module mul4x4_top (
    input  logic [7:0] sw,
    output logic [7:0] led
);
    logic [3:0] a;
    logic [3:0] b;
    logic [7:0] p;

    assign a = sw[3:0];  
    assign b = sw[7:4];  

    multiplier4x4 u_multiplier4x4 (
        .a (a),
        .b (b),
        .p (p)
    );

    assign led = p;      
endmodule


