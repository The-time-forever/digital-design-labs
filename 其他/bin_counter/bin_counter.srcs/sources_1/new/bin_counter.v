`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 20:04:45
// Design Name: 
// Module Name: bin_counter
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


module bin_counter
(
    input  wire clk,
    input  wire reset_n,
    output reg  led
);

    wire reset;
    assign reset = ~reset_n;

    parameter MCNT = 24_999_999;

    reg [24:0] cnt;

    // 计数器计数
    always @(posedge clk or posedge reset) begin
        if (reset)
            cnt <= 25'd0;
        else if (cnt == MCNT)
            cnt <= 25'd0;
        else
            cnt <= cnt + 1'b1;
    end

    // LED 输出控制
    always @(posedge clk or posedge reset) begin
        if (reset)
            led <= 1'b1;
        else if (cnt == MCNT)
            led <= ~led;
        else
            led <= led;
    end

endmodule
