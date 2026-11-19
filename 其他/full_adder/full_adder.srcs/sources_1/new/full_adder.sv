`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 11:18:21
// Design Name: 
// Module Name: full_adder
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
    input  logic A,
    input  logic B,
    input  logic Cin,
    output logic S,
    output logic Cout
);

    logic P;

    assign P    = A ^ B;
    assign S    = P ^ Cin;
    assign Cout = (A & B) | (P & Cin);

endmodule
