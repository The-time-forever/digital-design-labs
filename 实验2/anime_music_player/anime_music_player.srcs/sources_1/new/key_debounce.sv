module key_debounce #(
    parameter CNT_MAX = 20'd1_000_000   // 50MHz 下约 20ms
)(
    input  wire clk,
    input  wire reset_n,
    input  wire key_in,
    output reg  key_pulse
);

    reg key_sync0;
    reg key_sync1;
    reg key_state;
    reg [19:0] cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            key_sync0 <= 1'b1;
            key_sync1 <= 1'b1;
        end else begin
            key_sync0 <= key_in;
            key_sync1 <= key_sync0;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            key_state <= 1'b1;
            key_pulse <= 1'b0;
            cnt <= 20'd0;
        end else begin
            key_pulse <= 1'b0;

            if (key_sync1 == key_state) begin
                cnt <= 20'd0;
            end else begin
                if (cnt == CNT_MAX - 1'b1) begin
                    key_state <= key_sync1;
                    cnt <= 20'd0;

                    // 只在“稳定按下”时产生一个时钟周期脉冲
                    if (key_sync1 == 1'b0)
                        key_pulse <= 1'b1;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end

endmodule