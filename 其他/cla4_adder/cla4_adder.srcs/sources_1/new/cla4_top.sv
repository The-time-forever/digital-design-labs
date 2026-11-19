`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 11:38:50
// Design Name: 
// Module Name: cla4_top
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


module cla4_top (
    input  logic [7:0] sw,
    input  logic       cin_n,
    output logic [7:0] led
);

    logic [3:0] a;
    logic [3:0] b;
    logic       cin;
    logic [3:0] sum;
    logic       cout;

    assign a   = sw[3:0];     
    assign b   = sw[7:4];     
    assign cin = ~cin_n;      

    cla4 u_cla4 (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .sum  (sum),
        .cout (cout)
    );

    assign led[3:0] = sum;
    assign led[4]   = cout;
    assign led[5]   = cin;
    assign led[7:6] = 2'b00;

endmodule