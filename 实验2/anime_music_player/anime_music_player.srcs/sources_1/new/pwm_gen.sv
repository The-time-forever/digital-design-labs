module pwm_gen (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        pwm_en,
    input  wire [31:0] counter_arr,
    input  wire [31:0] counter_ccr,
    output reg         pwm_out
);

    reg [31:0] counter;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 32'd0;
            pwm_out <= 1'b0;
        end else begin
            if (!pwm_en || counter_arr == 32'd0) begin
                counter <= 32'd0;
                pwm_out <= 1'b0;
            end else begin
                if (counter >= counter_arr)
                    counter <= 32'd0;
                else
                    counter <= counter + 1'b1;

                if (counter < counter_ccr)
                    pwm_out <= 1'b1;
                else
                    pwm_out <= 1'b0;
            end
        end
    end

endmodule