`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/08 23:50:10
// Design Name: 
// Module Name: tb_logic_lut_top
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


module tb_logic_lut_top;

    logic [3:0] din;
    logic [1:0] sel;
    logic [7:0] led;

    logic A;
    logic B;

    assign A = din[0];
    assign B = din[1];

    logic_lut_top dut (
        .din (din),
        .sel (sel),
        .led (led)
    );

    initial begin
        $display(" A B | sel | function | led[0]");

        din = 4'b0000;
        sel = 2'b00;
        #10;

        for (int ab = 0; ab < 4; ab++) begin
            din[1:0] = ab[1:0];

            for (int f = 0; f < 4; f++) begin
                sel = f[1:0];
                #10;

                case (sel)
                    2'b00: $display(" %b %b |  %b  | AND      |   %b", A, B, sel, led[0]);
                    2'b01: $display(" %b %b |  %b  | OR       |   %b", A, B, sel, led[0]);
                    2'b10: $display(" %b %b |  %b  | XOR      |   %b", A, B, sel, led[0]);
                    2'b11: $display(" %b %b |  %b  | NAND     |   %b", A, B, sel, led[0]);
                endcase
            end
        end

        $display("Simulation finished.");
        $stop;
    end

endmodule
