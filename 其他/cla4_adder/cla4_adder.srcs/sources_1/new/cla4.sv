`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 11:37:31
// Design Name: 
// Module Name: cla4
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


module cla4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);

    logic [3:0] g;      
    logic [3:0] p;      
    logic [3:0] x;      
    logic [4:0] c;      

    assign g = a & b;
    assign p = a | b;  
    assign x = a ^ b;

    assign c[0] = cin;

    assign c[1] = g[0] | (p[0] & c[0]);

    assign c[2] = g[1] |
                  (p[1] & g[0]) |
                  (p[1] & p[0] & c[0]);

    assign c[3] = g[2] |
                  (p[2] & g[1]) |
                  (p[2] & p[1] & g[0]) |
                  (p[2] & p[1] & p[0] & c[0]);

    assign c[4] = g[3] |
                  (p[3] & g[2]) |
                  (p[3] & p[2] & g[1]) |
                  (p[3] & p[2] & p[1] & g[0]) |
                  (p[3] & p[2] & p[1] & p[0] & c[0]);

    assign sum  = x ^ c[3:0];
    assign cout = c[4];

endmodule
