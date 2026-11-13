module song_rom (
    input  wire [7:0]  addr,
    output reg  [15:0] note_word
);

    // 普通音符编码：
    // octave: 0低音，1中音，2高音
    // note  : 1~7 对应 Do Re Mi Fa Sol La Si
    // dur   : 音长单位，越大越长
    function automatic [15:0] N(
        input [3:0] octave,
        input [3:0] note,
        input [2:0] dur
    );
        begin
            N = {octave, note, 2'd0, dur, 3'd0};
        end
    endfunction

    // 休止符
    function automatic [15:0] R(
        input [2:0] dur
    );
        begin
            R = {4'd0, 4'd0, 2'd0, dur, 3'd0};
        end
    endfunction

    always @(*) begin
        case (addr)

            // Song0: Weathering With You - Is There Still Anything That Love Can Do?
            // 取第 13 小节开始的上方主旋律，单音蜂鸣器简化版
            // 简化旋律大致来自：
            // 5 111 211 55 53 | 3 22 13 | 0 65 |
            // 5 111 211 55 53 | 3 22 111 -

            8'd0 : note_word = N(4'd2, 4'd5, 3'd2);

            8'd1 : note_word = N(4'd2, 4'd1, 3'd1);
            8'd2 : note_word = N(4'd2, 4'd1, 3'd1);
            8'd3 : note_word = N(4'd2, 4'd1, 3'd1);

            8'd4 : note_word = N(4'd2, 4'd2, 3'd1);
            8'd5 : note_word = N(4'd2, 4'd1, 3'd1);
            8'd6 : note_word = N(4'd2, 4'd1, 3'd1);

            8'd7 : note_word = N(4'd2, 4'd5, 3'd1);
            8'd8 : note_word = N(4'd2, 4'd5, 3'd1);
            8'd9 : note_word = N(4'd2, 4'd5, 3'd1);
            8'd10: note_word = N(4'd2, 4'd5, 3'd1);
            8'd11: note_word = N(4'd2, 4'd3, 3'd2);

            8'd12: note_word = N(4'd2, 4'd3, 3'd2);
            8'd13: note_word = N(4'd2, 4'd2, 3'd1);
            8'd14: note_word = N(4'd2, 4'd2, 3'd2);
            8'd15: note_word = N(4'd2, 4'd1, 3'd1);
            8'd16: note_word = N(4'd2, 4'd3, 3'd1);
            8'd17: note_word = N(4'd2, 4'd3, 3'd3);

            8'd18: note_word = R(3'd2);
            8'd19: note_word = N(4'd2, 4'd6, 3'd1);
            8'd20: note_word = N(4'd2, 4'd5, 3'd1);

            8'd21: note_word = N(4'd2, 4'd5, 3'd2);

            8'd22: note_word = N(4'd2, 4'd1, 3'd1);
            8'd23: note_word = N(4'd2, 4'd1, 3'd1);
            8'd24: note_word = N(4'd2, 4'd1, 3'd1);

            8'd25: note_word = N(4'd2, 4'd2, 3'd1);
            8'd26: note_word = N(4'd2, 4'd1, 3'd1);
            8'd27: note_word = N(4'd2, 4'd1, 3'd1);

            8'd28: note_word = N(4'd2, 4'd5, 3'd1);
            8'd29: note_word = N(4'd2, 4'd5, 3'd1);
            8'd30: note_word = N(4'd2, 4'd5, 3'd1);
            8'd31: note_word = N(4'd2, 4'd5, 3'd1);
            8'd32: note_word = N(4'd2, 4'd3, 3'd2);

            8'd33: note_word = N(4'd2, 4'd3, 3'd2);
            8'd34: note_word = N(4'd2, 4'd2, 3'd1);
            8'd35: note_word = N(4'd2, 4'd2, 3'd2);

            8'd36: note_word = N(4'd2, 4'd1, 3'd1);
            8'd37: note_word = N(4'd2, 4'd1, 3'd1);
            8'd38: note_word = N(4'd2, 4'd1, 3'd7);

                        // Song1: Your Name - Sparkle (movie ver.)
            // 取第 9 小节附近开始的右手上方主旋律，单音蜂鸣器简化版
            // 谱面原标记：1=B, 4/4, ?=124
            // 本工程暂按相对简谱转调播放

            8'd48: note_word = N(4'd2, 4'd1, 3'd2);

            8'd49: note_word = N(4'd2, 4'd3, 3'd1);
            8'd50: note_word = N(4'd2, 4'd3, 3'd1);
            8'd51: note_word = N(4'd2, 4'd3, 3'd1);

            8'd52: note_word = N(4'd2, 4'd3, 3'd1);
            8'd53: note_word = N(4'd2, 4'd3, 3'd1);
            8'd54: note_word = N(4'd2, 4'd2, 3'd1);

            8'd55: note_word = N(4'd2, 4'd2, 3'd1);
            8'd56: note_word = N(4'd2, 4'd2, 3'd1);
            8'd57: note_word = N(4'd2, 4'd1, 3'd1);

            8'd58: note_word = N(4'd2, 4'd1, 3'd6);
            8'd59: note_word = R(3'd2);
            8'd60: note_word = R(3'd2);

            8'd61: note_word = N(4'd2, 4'd5, 3'd2);

            8'd62: note_word = N(4'd2, 4'd3, 3'd1);
            8'd63: note_word = N(4'd2, 4'd3, 3'd1);
            8'd64: note_word = N(4'd2, 4'd3, 3'd1);

            8'd65: note_word = N(4'd2, 4'd3, 3'd1);
            8'd66: note_word = N(4'd2, 4'd3, 3'd1);
            8'd67: note_word = N(4'd2, 4'd2, 3'd1);

            8'd68: note_word = N(4'd2, 4'd2, 3'd1);
            8'd69: note_word = N(4'd2, 4'd2, 3'd1);
            8'd70: note_word = N(4'd2, 4'd1, 3'd1);

            8'd71: note_word = N(4'd2, 4'd3, 3'd3);

            8'd72: note_word = N(4'd2, 4'd3, 3'd2);
            8'd73: note_word = N(4'd2, 4'd3, 3'd1);
            8'd74: note_word = N(4'd2, 4'd3, 3'd1);
            8'd75: note_word = N(4'd2, 4'd5, 3'd1);
            8'd76: note_word = N(4'd2, 4'd2, 3'd2);

            8'd77: note_word = N(4'd2, 4'd1, 3'd6);

            8'd78: note_word = N(4'd2, 4'd3, 3'd2);
            8'd79: note_word = N(4'd2, 4'd3, 3'd1);
            8'd80: note_word = N(4'd2, 4'd3, 3'd1);

            8'd81: note_word = N(4'd2, 4'd3, 3'd1);
            8'd82: note_word = N(4'd2, 4'd3, 3'd1);
            8'd83: note_word = N(4'd2, 4'd3, 3'd1);
            8'd84: note_word = N(4'd2, 4'd2, 3'd1);

            8'd85: note_word = N(4'd2, 4'd2, 3'd1);
            8'd86: note_word = N(4'd2, 4'd2, 3'd1);
            8'd87: note_word = N(4'd2, 4'd1, 3'd1);

            8'd88: note_word = N(4'd2, 4'd1, 3'd6);
            8'd89: note_word = R(3'd2);
            8'd90: note_word = R(3'd2);
            
                        // Song2: Kessoku Band - Guitar, Loneliness and Blue Planet
            // 根据吉他 TAB 前奏节奏简化成单音 riff
            // 原谱是多弦和弦/扫弦，蜂鸣器版本只保留高音走向和摇滚节奏
            // 建议播放时使用 speed_level = 2，音量 sw_vol = 2'b10 或 2'b11

            // Phrase A: 4 4 - 3 3 - 2 2 - 3 3
            8'd112: note_word = N(4'd2, 4'd4, 3'd1);
            8'd113: note_word = N(4'd2, 4'd4, 3'd1);
            8'd114: note_word = R(3'd1);
            8'd115: note_word = N(4'd2, 4'd3, 3'd1);
            8'd116: note_word = N(4'd2, 4'd3, 3'd1);
            8'd117: note_word = R(3'd1);
            8'd118: note_word = N(4'd2, 4'd2, 3'd1);
            8'd119: note_word = N(4'd2, 4'd2, 3'd1);
            8'd120: note_word = R(3'd1);
            8'd121: note_word = N(4'd2, 4'd3, 3'd1);
            8'd122: note_word = N(4'd2, 4'd3, 3'd1);
            8'd123: note_word = R(3'd1);

            // Phrase B: 6 6 - 5 5 - 1' 1' - 5 5
            8'd124: note_word = N(4'd1, 4'd6, 3'd1);
            8'd125: note_word = N(4'd1, 4'd6, 3'd1);
            8'd126: note_word = R(3'd1);
            8'd127: note_word = N(4'd1, 4'd5, 3'd1);
            8'd128: note_word = N(4'd1, 4'd5, 3'd1);
            8'd129: note_word = R(3'd1);
            8'd130: note_word = N(4'd2, 4'd1, 3'd1);
            8'd131: note_word = N(4'd2, 4'd1, 3'd1);
            8'd132: note_word = R(3'd1);
            8'd133: note_word = N(4'd1, 4'd5, 3'd1);
            8'd134: note_word = N(4'd1, 4'd5, 3'd1);
            8'd135: note_word = R(3'd1);

            // Phrase C: 4 4 4 3 2 3 4 5
            8'd136: note_word = N(4'd2, 4'd4, 3'd1);
            8'd137: note_word = N(4'd2, 4'd4, 3'd1);
            8'd138: note_word = N(4'd2, 4'd4, 3'd1);
            8'd139: note_word = N(4'd2, 4'd3, 3'd1);
            8'd140: note_word = N(4'd2, 4'd2, 3'd1);
            8'd141: note_word = N(4'd2, 4'd3, 3'd1);
            8'd142: note_word = N(4'd2, 4'd4, 3'd1);
            8'd143: note_word = N(4'd2, 4'd5, 3'd1);

            // Phrase D: 6 5 4 3 2 - 1 -
            8'd144: note_word = N(4'd2, 4'd6, 3'd1);
            8'd145: note_word = N(4'd2, 4'd5, 3'd1);
            8'd146: note_word = N(4'd2, 4'd4, 3'd1);
            8'd147: note_word = N(4'd2, 4'd3, 3'd1);
            8'd148: note_word = N(4'd2, 4'd2, 3'd1);
            8'd149: note_word = R(3'd1);
            8'd150: note_word = N(4'd2, 4'd1, 3'd2);
            8'd151: note_word = R(3'd2);
            
            
            default: note_word = R(3'd4);

        endcase
    end

endmodule