`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 19:53:00
// Design Name: 
// Module Name: tb_mul4x4
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


module tb_mul4x4;

    logic [7:0] sw;
    logic [7:0] led;

    logic [7:0] expected;
    integer i;

    mul4x4_top dut (
        .sw  (sw),
        .led (led)
    );

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            sw = i[7:0];
            #10;

            expected = {4'b0000, sw[3:0]} * {4'b0000, sw[7:4]};

            if (led !== expected) begin
                $display("ERROR: sw=%b, A=%0d, B=%0d, led=%b, expected=%b",
                         sw, sw[3:0], sw[7:4], led, expected);
                $stop;
            end
        end

        $display("PASS: all 256 input combinations passed.");
        $stop;
    end

endmodule
