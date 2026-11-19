`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/08 23:46:20
// Design Name: 
// Module Name: logic_lut_top
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


module logic_lut_top (
    input  logic [3:0] din,   
    input  logic [1:0] sel,   
    output logic [7:0] led    
);

    logic A;
    logic B;

    logic y_and;
    logic y_or;
    logic y_xor;
    logic y_nand;
    logic y;

    assign A = din[0];   // SW0 作为 A
    assign B = din[1];   // SW1 作为 B

    mux4_1 u_and (
        .d   (4'b1000),
        .sel ({A, B}),
        .y   (y_and)
    );

    mux4_1 u_or (
        .d   (4'b1110),
        .sel ({A, B}),
        .y   (y_or)
    );

    mux4_1 u_xor (
        .d   (4'b0110),
        .sel ({A, B}),
        .y   (y_xor)
    );

    mux4_1 u_nand (
        .d   (4'b0111),
        .sel ({A, B}),
        .y   (y_nand)
    );

    mux4_1 u_func_sel (
        .d   ({y_nand, y_xor, y_or, y_and}),
        .sel (sel),
        .y   (y)
    );

    assign led[0] = y;

    assign led[1] = A;
    assign led[2] = B;
    assign led[3] = sel[0];
    assign led[4] = sel[1];

    assign led[7:5] = 3'b000;

endmodule
