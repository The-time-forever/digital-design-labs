`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/09 19:31:36
// Design Name: 
// Module Name: hamming_code
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


module hamming_code (
    input  logic [3:0] data_in,    
    input  logic [2:0] err_pos,    

    output logic [6:0] code_out,   
    output logic [6:0] code_err,   
    output logic [2:0] syndrome,  
    output logic [6:0] code_fix,  
    output logic [3:0] data_fix,   
    output logic       error_flag
);

    logic B8, B4, B2, B1;
    logic P1, P2, P3;

    assign {B8, B4, B2, B1} = data_in;

    assign P1 = B8 ^ B2 ^ B1;
    assign P2 = B8 ^ B4 ^ B1;
    assign P3 = B8 ^ B4 ^ B2;

    assign code_out = {B8, B4, B2, P3, B1, P2, P1};

    function automatic logic [6:0] pos_mask(input logic [2:0] pos);
        case (pos)
            3'd0: pos_mask = 7'b000_0000; 
            3'd1: pos_mask = 7'b000_0001; 
            3'd2: pos_mask = 7'b000_0010; 
            3'd3: pos_mask = 7'b000_0100; 
            3'd4: pos_mask = 7'b000_1000; 
            3'd5: pos_mask = 7'b001_0000; 
            3'd6: pos_mask = 7'b010_0000; 
            3'd7: pos_mask = 7'b100_0000; 
            default: pos_mask = 7'b000_0000;
        endcase
    endfunction

    assign code_err = code_out ^ pos_mask(err_pos);

    assign syndrome[0] = code_err[6] ^ code_err[4] ^ code_err[2] ^ code_err[0]; 
    assign syndrome[1] = code_err[6] ^ code_err[5] ^ code_err[2] ^ code_err[1]; 
    assign syndrome[2] = code_err[6] ^ code_err[5] ^ code_err[4] ^ code_err[3]; 

    assign error_flag = |syndrome;

    assign code_fix = code_err ^ pos_mask(syndrome);

    assign data_fix = {code_fix[6], code_fix[5], code_fix[4], code_fix[2]};

endmodule


module hamming_code_top (
    input  logic [6:0] sw,
    output logic [7:0] led
);

    logic [6:0] code_out;
    logic [6:0] code_err;
    logic [2:0] syndrome;
    logic [6:0] code_fix;
    logic [3:0] data_fix;
    logic       error_flag;

    hamming_code u_hamming_code (
        .data_in    (sw[3:0]),     
        .err_pos    (sw[6:4]),     
        .code_out   (code_out),
        .code_err   (code_err),
        .syndrome   (syndrome),
        .code_fix   (code_fix),
        .data_fix   (data_fix),
        .error_flag (error_flag)
    );


    assign led[2:0] = syndrome;


    assign led[6:3] = data_fix;


    assign led[7] = error_flag;

endmodule
