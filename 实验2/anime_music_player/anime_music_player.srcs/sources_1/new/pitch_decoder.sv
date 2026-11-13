`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/11 19:40:56
// Design Name: 
// Module Name: pitch_decoder
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


module pitch_decoder (
    input  wire [15:0] note_word,
    output reg  [31:0] counter_arr
);

    wire [3:0] octave;
    wire [3:0] note;

    assign octave = note_word[15:12];
    assign note   = note_word[11:8];

    always @(*) begin
        counter_arr = 32'd0;

        case (octave)

            // 低音区，近似 C3~B3
            4'd0: begin
                case (note)
                    4'd1: counter_arr = 32'd382225;
                    4'd2: counter_arr = 32'd340530;
                    4'd3: counter_arr = 32'd303370;
                    4'd4: counter_arr = 32'd286351;
                    4'd5: counter_arr = 32'd255102;
                    4'd6: counter_arr = 32'd227273;
                    4'd7: counter_arr = 32'd202478;
                    default: counter_arr = 32'd0;
                endcase
            end

            // 中音区，近似 C4~B4
            4'd1: begin
                case (note)
                    4'd1: counter_arr = 32'd191113;
                    4'd2: counter_arr = 32'd170262;
                    4'd3: counter_arr = 32'd151685;
                    4'd4: counter_arr = 32'd143172;
                    4'd5: counter_arr = 32'd127551;
                    4'd6: counter_arr = 32'd113636;
                    4'd7: counter_arr = 32'd101239;
                    default: counter_arr = 32'd0;
                endcase
            end

            // 高音区，近似 C5~B5
            4'd2: begin
                case (note)
                    4'd1: counter_arr = 32'd95557;
                    4'd2: counter_arr = 32'd85131;
                    4'd3: counter_arr = 32'd75843;
                    4'd4: counter_arr = 32'd71586;
                    4'd5: counter_arr = 32'd63776;
                    4'd6: counter_arr = 32'd56818;
                    4'd7: counter_arr = 32'd50619;
                    default: counter_arr = 32'd0;
                endcase
            end

            default: begin
                counter_arr = 32'd0;
            end

        endcase
    end

endmodule
