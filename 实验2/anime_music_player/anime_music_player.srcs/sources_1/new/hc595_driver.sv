`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/11 19:58:10
// Design Name: 
// Module Name: hc595_driver
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


module hc595_driver (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] data,
    input  wire        s_en,

    output reg         ds,
    output reg         sh_cp,
    output reg         st_cp
);

    localparam S_LOAD       = 3'd0;
    localparam S_SHIFT_HIGH = 3'd1;
    localparam S_SHIFT_LOW  = 3'd2;
    localparam S_LATCH_HIGH = 3'd3;
    localparam S_LATCH_LOW  = 3'd4;

    reg [2:0]  state;
    reg [15:0] r_data;
    reg [4:0]  bit_cnt;
    reg [1:0]  div_cnt;

    wire tick_en;
    assign tick_en = (div_cnt == 2'd3);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            div_cnt <= 2'd0;
        else
            div_cnt <= div_cnt + 1'b1;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state  <= S_LOAD;
            r_data <= 16'd0;
            bit_cnt <= 5'd0;
            ds     <= 1'b0;
            sh_cp  <= 1'b0;
            st_cp  <= 1'b0;
        end else if (tick_en) begin
            case (state)

                S_LOAD: begin
                    r_data  <= s_en ? data : 16'hFFFF;
                    bit_cnt <= 5'd0;
                    sh_cp   <= 1'b0;
                    st_cp   <= 1'b0;
                    ds      <= s_en ? data[15] : 1'b1;
                    state   <= S_SHIFT_HIGH;
                end

                S_SHIFT_HIGH: begin
                    sh_cp <= 1'b1;
                    state <= S_SHIFT_LOW;
                end

                S_SHIFT_LOW: begin
                    sh_cp <= 1'b0;

                    if (bit_cnt == 5'd15) begin
                        state <= S_LATCH_HIGH;
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                        ds <= r_data[14 - bit_cnt];
                        state <= S_SHIFT_HIGH;
                    end
                end

                S_LATCH_HIGH: begin
                    st_cp <= 1'b1;
                    state <= S_LATCH_LOW;
                end

                S_LATCH_LOW: begin
                    st_cp <= 1'b0;
                    state <= S_LOAD;
                end

                default: begin
                    state <= S_LOAD;
                end

            endcase
        end
    end

endmodule
