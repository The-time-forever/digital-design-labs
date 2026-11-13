`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/11 19:57:19
// Design Name: 
// Module Name: hex8_scan
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


module hex8_scan (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        en,
    input  wire [31:0] disp_data,

    output reg  [7:0]  sel,
    output reg  [6:0]  seg
);

    // 50MHz / 50000 = 1kHz
    localparam integer SCAN_CNT_MAX = 50_000;

    reg [15:0] scan_cnt;
    reg [7:0]  sel_r;
    reg [3:0]  data_tmp;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scan_cnt <= 16'd0;
        end else begin
            if (scan_cnt == SCAN_CNT_MAX - 1)
                scan_cnt <= 16'd0;
            else
                scan_cnt <= scan_cnt + 1'b1;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sel_r <= 8'b0000_0001;
        end else if (scan_cnt == SCAN_CNT_MAX - 1) begin
            if (sel_r == 8'b1000_0000)
                sel_r <= 8'b0000_0001;
            else
                sel_r <= sel_r << 1;
        end
    end

    always @(*) begin
        case (sel_r)
            8'b0000_0001: data_tmp = disp_data[3:0];
            8'b0000_0010: data_tmp = disp_data[7:4];
            8'b0000_0100: data_tmp = disp_data[11:8];
            8'b0000_1000: data_tmp = disp_data[15:12];
            8'b0001_0000: data_tmp = disp_data[19:16];
            8'b0010_0000: data_tmp = disp_data[23:20];
            8'b0100_0000: data_tmp = disp_data[27:24];
            8'b1000_0000: data_tmp = disp_data[31:28];
            default:      data_tmp = 4'hF;
        endcase
    end

    // 共阳极数码管，段码低电平点亮
    always @(*) begin
        case (data_tmp)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0111111;  // 横杠
            4'hF: seg = 7'b1111111;  // 空白
            default: seg = 7'b1111111;
        endcase
    end

    always @(*) begin
        if (en)
            sel = sel_r;
        else
            sel = 8'b0000_0000;
    end

endmodule
