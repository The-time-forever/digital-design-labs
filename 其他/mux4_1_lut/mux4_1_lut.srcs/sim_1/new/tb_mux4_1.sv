`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/08 23:07:13
// Design Name: 
// Module Name: tb_mux4_1
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


`timescale 1ns / 1ps

module tb_mux4_1;

    logic [3:0] d;
    logic [1:0] sel;
    logic       y;

    logic expected;

    mux4_1 dut (
        .d   (d),
        .sel (sel),
        .y   (y)
    );

    initial begin
        d   = 4'b0000;
        sel = 2'b00;
        #10;

        for (int data = 0; data < 16; data++) begin
            d = data[3:0];

            for (int s = 0; s < 4; s++) begin
                sel = s[1:0];
                #10;

                expected = d[sel];

                if (y !== expected) begin
                    $error("ERROR: d=%b sel=%b y=%b expected=%b",
                           d, sel, y, expected);
                end
            end
        end

        $display("MUX4_1 simulation passed.");
        $stop;
    end

endmodule
