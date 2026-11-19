`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/11 18:55:57
// Design Name: 
// Module Name: bin_counter_tb
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


`define CLOCK_PERIOD 20
module bin_counter_tb();
    reg clk;
    reg reset_n;wire led;
    bin_counter bin_counter_inst (
    .clk(clk),
    .reset_n(reset_n ),
    .led(led)
    );
    initial clk = 1;
    always #(`CLOCK_PERIOD/2) clk = ~clk;
    initial begin
    reset_n = 1'b0;
    #(`CLOCK_PERIOD *200 + 1);
    reset_n = 1'b1;
    #2000000000;
    $stop;
    end
endmodule
