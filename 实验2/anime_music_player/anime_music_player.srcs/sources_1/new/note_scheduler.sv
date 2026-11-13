module note_scheduler (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        play_en,
    input  wire [1:0]  song_id,
    input  wire [1:0]  speed_level,
    input  wire        restart_pulse,  // 1-cycle pulse: rewind to song start

    output reg  [15:0] note_word,
    output reg         note_change
);

    reg [7:0] addr;
    reg [1:0] last_song_id;

    reg [7:0] start_addr;
    reg [7:0] end_addr;

    always @(*) begin
        case (song_id)
            2'd0: begin
                start_addr = 8'd0;
                end_addr   = 8'd38;     // ����֮��
            end

            2'd1: begin
                start_addr = 8'd48;
                end_addr   = 8'd90;     // Sparkle
            end

            2'd2: begin
                start_addr = 8'd112;
                end_addr   = 8'd151;    // �¶�ҡ�� riff
            end

            default: begin
                start_addr = 8'd0;
                end_addr   = 8'd38;
            end
        endcase
    end

    // ROM IP ���
    wire [15:0] rom_note_word;

    anime_song_rom u_anime_song_rom (
        .clka  (clk),
        .addra (addr),
        .douta (rom_note_word)
    );

    // ROM IP ��ͬ����������Ĵ�һ��
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            note_word <= 16'd0;
        else
            note_word <= rom_note_word;
    end

    reg [31:0] base_ticks;

    always @(*) begin
        case (speed_level)
            2'd0: base_ticks = 32'd8_000_000;  // ���٣���Լ 160ms
            2'd1: base_ticks = 32'd6_250_000;  // ��������Լ 125ms
            2'd2: base_ticks = 32'd4_500_000;  // ���٣���Լ 90ms
            default: base_ticks = 32'd6_250_000;
        endcase
    end

    wire [2:0] duration_raw;
    wire [2:0] duration_unit;

    assign duration_raw  = note_word[5:3];
    assign duration_unit = (duration_raw == 3'd0) ? 3'd1 : duration_raw;

    wire [34:0] note_ticks;
    assign note_ticks = base_ticks * duration_unit;

    reg [34:0] tick_cnt;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            addr         <= 8'd0;
            tick_cnt     <= 35'd0;
            last_song_id <= 2'd0;
            note_change  <= 1'b1;
        end else begin
            note_change <= 1'b0;

            // restart_pulse: highest priority, rewind to current song start
            if (restart_pulse) begin
                addr         <= start_addr;
                tick_cnt     <= 35'd0;
                last_song_id <= song_id;   // prevent spurious song-change detect
                note_change  <= 1'b1;
            end else if (song_id != last_song_id) begin
                addr         <= start_addr;
                tick_cnt     <= 35'd0;
                last_song_id <= song_id;
                note_change  <= 1'b1;
            end else if (play_en) begin
                if (tick_cnt >= note_ticks - 1'b1) begin
                    tick_cnt <= 35'd0;
                    note_change <= 1'b1;

                    if (addr >= end_addr)
                        addr <= start_addr;
                    else
                        addr <= addr + 1'b1;
                end else begin
                    tick_cnt <= tick_cnt + 1'b1;
                end
            end
        end
    end

endmodule