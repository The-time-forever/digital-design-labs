`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 19:33:33
// Design Name: 
// Module Name: hamming_code_tb
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


module hamming_code_tb;

    logic [3:0] data_in;
    logic [2:0] err_pos;

    logic [6:0] code_out;
    logic [6:0] code_err;
    logic [2:0] syndrome;
    logic [6:0] code_fix;
    logic [3:0] data_fix;
    logic       error_flag;

    int error_count = 0;

    hamming_code dut (
        .data_in    (data_in),
        .err_pos    (err_pos),
        .code_out   (code_out),
        .code_err   (code_err),
        .syndrome   (syndrome),
        .code_fix   (code_fix),
        .data_fix   (data_fix),
        .error_flag (error_flag)
    );

    initial begin
        for (int d = 0; d < 16; d++) begin
            for (int e = 0; e < 8; e++) begin
                data_in = d[3:0];
                err_pos = e[2:0];
                #10;

                if (data_fix !== data_in) begin
                    $display("ERROR: data_in=%b err_pos=%0d data_fix=%b syndrome=%b",
                              data_in, err_pos, data_fix, syndrome);
                    error_count++;
                end

                if (syndrome !== err_pos) begin
                    $display("ERROR: data_in=%b err_pos=%0d syndrome=%b",
                              data_in, err_pos, syndrome);
                    error_count++;
                end
            end
        end

        if (error_count == 0)
            $display("PASS: all hamming code tests passed.");
        else
            $display("FAIL: error_count=%0d", error_count);

        $stop;
    end

endmodule
