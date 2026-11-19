`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 11:40:35
// Design Name: 
// Module Name: cla4_tb
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


module cla4_tb;

    logic [3:0] a;
    logic [3:0] b;
    logic       cin;
    logic [3:0] sum;
    logic       cout;

    logic [4:0] expected;

    cla4 dut (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .sum  (sum),
        .cout (cout)
    );

    initial begin
        for (int ia = 0; ia < 16; ia++) begin
            for (int ib = 0; ib < 16; ib++) begin
                for (int ic = 0; ic < 2; ic++) begin

                    a   = ia[3:0];
                    b   = ib[3:0];
                    cin = ic[0];

                    #10;

                    expected = {1'b0, a} + {1'b0, b} + cin;

                    assert ({cout, sum} == expected)
                    else begin
                        $display("ERROR: a=%b b=%b cin=%b, result=%b_%b, expected=%b",
                                 a, b, cin, cout, sum, expected);
                        $stop;
                    end
                end
            end
        end

        $display("CLA4 TEST PASS!");
        $stop;
    end

endmodule
