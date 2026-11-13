`timescale 1ns / 1ps

module anime_music_player_top (
    input  wire       clk,       // 50MHz
    input  wire       reset_n,   // active-low reset

    input  wire       key0,      // play/pause  (clock mode: select field)
    input  wire       key1,      // next song   (clock mode: field +1)
    input  wire       key2,      // speed up    (clock mode: field -1)
    input  wire       key3,      // speed down  (clock mode: pause/run)

    input  wire [1:0] sw_vol,        // volume: SW0~SW1
    input  wire       sw_mode,       // 0=music mode  1=clock mode  (SW7)
    input  wire [1:0] sw_alarm_song, // alarm song select SW3:SW2
    input  wire       sw_alarm_en,   // alarm enable SW5
    input  wire       sw_alarm_set,  // alarm set mode SW6

    output wire       beep,      // buzzer
    output wire [7:0] led,       // status LEDs

    output wire       seg_dio,
    output wire       seg_sclk,
    output wire       seg_rclk
);

    // ---------------------------------------------------------------
    // Key debounce
    // ---------------------------------------------------------------
    wire key0_pulse;
    wire key1_pulse;
    wire key2_pulse;
    wire key3_pulse;

    key_debounce u_key0 (
        .clk       (clk),
        .reset_n   (reset_n),
        .key_in    (key0),
        .key_pulse (key0_pulse)
    );

    key_debounce u_key1 (
        .clk       (clk),
        .reset_n   (reset_n),
        .key_in    (key1),
        .key_pulse (key1_pulse)
    );

    key_debounce u_key2 (
        .clk       (clk),
        .reset_n   (reset_n),
        .key_in    (key2),
        .key_pulse (key2_pulse)
    );

    key_debounce u_key3 (
        .clk       (clk),
        .reset_n   (reset_n),
        .key_in    (key3),
        .key_pulse (key3_pulse)
    );

    // ---------------------------------------------------------------
    // Two-stage synchronizer for sw_mode (SW7)
    // ---------------------------------------------------------------
    reg  sw_mode_r0;
    reg  sw_mode_r1;
    wire clock_mode;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sw_mode_r0 <= 1'b0;
            sw_mode_r1 <= 1'b0;
        end else begin
            sw_mode_r0 <= sw_mode;
            sw_mode_r1 <= sw_mode_r0;
        end
    end

    assign clock_mode = sw_mode_r1;

    // Two-stage synchronizers for alarm switches
    reg [1:0] sw_alarm_song_r0, sw_alarm_song_r1;
    reg       sw_alarm_en_r0,   sw_alarm_en_r1;
    reg       sw_alarm_set_r0,  sw_alarm_set_r1;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sw_alarm_song_r0 <= 2'b00;
            sw_alarm_song_r1 <= 2'b00;
            sw_alarm_en_r0   <= 1'b0;
            sw_alarm_en_r1   <= 1'b0;
            sw_alarm_set_r0  <= 1'b0;
            sw_alarm_set_r1  <= 1'b0;
        end else begin
            sw_alarm_song_r0 <= sw_alarm_song;
            sw_alarm_song_r1 <= sw_alarm_song_r0;
            sw_alarm_en_r0   <= sw_alarm_en;
            sw_alarm_en_r1   <= sw_alarm_en_r0;
            sw_alarm_set_r0  <= sw_alarm_set;
            sw_alarm_set_r1  <= sw_alarm_set_r0;
        end
    end

    // Detect rising edge of clock_mode (0->1 transition = entering clock mode)
    reg  clock_mode_d;
    wire clock_mode_rise;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            clock_mode_d <= 1'b0;
        else
            clock_mode_d <= clock_mode;
    end

    assign clock_mode_rise = clock_mode && !clock_mode_d;

    // ---------------------------------------------------------------
    // Music control state (only updated in music mode)
    // ---------------------------------------------------------------
    reg       play_en;
    reg [1:0] song_id;
    reg [1:0] speed_level;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            play_en     <= 1'b0;
            song_id     <= 2'd0;
            speed_level <= 2'd1;   // default: normal speed
        end else if (clock_mode_rise) begin
            play_en <= 1'b0;       // mute immediately when switching to clock mode
        end else if (!clock_mode) begin
            if (key0_pulse)
                play_en <= ~play_en;

            if (key1_pulse) begin
                if (song_id == 2'd2)
                    song_id <= 2'd0;
                else
                    song_id <= song_id + 1'b1;
            end

            if (key2_pulse) begin
                if (speed_level < 2'd2)
                    speed_level <= speed_level + 1'b1;
            end

            if (key3_pulse) begin
                if (speed_level > 2'd0)
                    speed_level <= speed_level - 1'b1;
            end
        end
    end

    // ---------------------------------------------------------------
    // Alarm start pulse (1-cycle, gated on clock_mode)
    // clock_alarm_active is declared in the clock-core section below;
    // Verilog net forward references are valid within a module.
    // ---------------------------------------------------------------
    reg  alarm_active_d;
    wire alarm_start_pulse;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            alarm_active_d <= 1'b0;
        else
            alarm_active_d <= clock_alarm_active;
    end

    // Only fire in clock mode so music-mode playback is never interrupted
    assign alarm_start_pulse = clock_mode && clock_alarm_active && !alarm_active_d;

    // Alarm song index: SW3:SW2  00->0  01->1  10->2  11->0
    wire [1:0] alarm_song_id;
    assign alarm_song_id = (sw_alarm_song_r1 == 2'b01) ? 2'd1 :
                           (sw_alarm_song_r1 == 2'b10) ? 2'd2 : 2'd0;

    // Effective playback signals
    //   clock mode + alarm active  -> force alarm song, play=1, normal speed
    //   music mode                 -> original song_id / play_en / speed_level
    //   clock mode, no alarm       -> play_en forced 0 (silent)
    wire [1:0] effective_song_id;
    wire       effective_play_en;
    wire [1:0] effective_speed_level;

    assign effective_song_id     = (clock_mode && clock_alarm_active) ? alarm_song_id : song_id;
    assign effective_play_en     = (clock_mode && clock_alarm_active) ? 1'b1          : ((!clock_mode) && play_en);
    assign effective_speed_level = (clock_mode && clock_alarm_active) ? 2'd1          : speed_level;

    // ---------------------------------------------------------------
    // Note scheduler and pitch decoder
    // ---------------------------------------------------------------
    wire [15:0] note_word;
    wire        note_change;

    note_scheduler u_note_scheduler (
        .clk           (clk),
        .reset_n       (reset_n),
        .play_en       (effective_play_en),
        .song_id       (effective_song_id),
        .speed_level   (effective_speed_level),
        .restart_pulse (alarm_start_pulse),
        .note_word     (note_word),
        .note_change   (note_change)
    );

    wire [31:0] counter_arr;

    pitch_decoder u_pitch_decoder (
        .note_word   (note_word),
        .counter_arr (counter_arr)
    );

    // ---------------------------------------------------------------
    // Volume / duty cycle
    // ---------------------------------------------------------------
    reg [31:0] counter_ccr;

    always @(*) begin
        case (sw_vol)
            2'b00: counter_ccr = counter_arr >> 3;
            2'b01: counter_ccr = counter_arr >> 2;
            2'b10: counter_ccr = counter_arr >> 1;
            2'b11: counter_ccr = counter_arr - (counter_arr >> 2);
            default: counter_ccr = counter_arr >> 1;
        endcase
    end

    // PWM buzzer - silenced in clock mode
    pwm_gen u_pwm_gen (
        .clk         (clk),
        .reset_n     (reset_n),
        .pwm_en      (effective_play_en && (counter_arr != 32'd0)),
        .counter_arr (counter_arr),
        .counter_ccr (counter_ccr),
        .pwm_out     (beep)
    );

    // ---------------------------------------------------------------
    // Rhythm LED (shifts on every note change)
    // ---------------------------------------------------------------
    reg [2:0] rhythm_led;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rhythm_led <= 3'b001;
        end else if (note_change) begin
            rhythm_led <= {rhythm_led[1:0], rhythm_led[2]};
        end
    end

    // ---------------------------------------------------------------
    // Music display data
    // ---------------------------------------------------------------
    wire [3:0] disp_song;
    wire [3:0] disp_play;
    wire [3:0] disp_speed;
    wire [3:0] disp_octave;
    wire [3:0] disp_note;
    wire [3:0] disp_vol;

    assign disp_song   = {2'b00, song_id} + 4'd1;
    assign disp_play   = play_en ? 4'd1 : 4'd0;
    assign disp_speed  = {2'b00, speed_level};
    assign disp_octave = note_word[15:12];
    assign disp_note   = note_word[11:8];
    assign disp_vol    = {2'b00, sw_vol};

    // From MSB: song# blank play blank speed vol octave note
    wire [31:0] music_disp_data;
    assign music_disp_data = {
        disp_song,
        4'hF,
        disp_play,
        4'hF,
        disp_speed,
        disp_vol,
        disp_octave,
        disp_note
    };

    // ---------------------------------------------------------------
    // Clock core
    // ---------------------------------------------------------------
    wire [31:0] clock_disp_data;
    wire [1:0]  clock_set_field;
    wire        clock_running;
    wire        clock_blink;
    wire        clock_alarm_active;

    clock_core u_clock_core (
        .clk             (clk),
        .reset_n         (reset_n),
        .key_sel_pulse   (clock_mode ? key0_pulse : 1'b0),
        .key_inc_pulse   (clock_mode ? key1_pulse : 1'b0),
        .key_dec_pulse   (clock_mode ? key2_pulse : 1'b0),
        .key_pause_pulse (clock_mode ? key3_pulse : 1'b0),
        .alarm_set_mode  (clock_mode ? sw_alarm_set_r1 : 1'b0),
        .alarm_enable    (sw_alarm_en_r1),
        .alarm_song_sel  (sw_alarm_song_r1),
        .disp_data       (clock_disp_data),
        .set_field       (clock_set_field),
        .clock_running   (clock_running),
        .blink_1hz       (clock_blink),
        .alarm_active    (clock_alarm_active)
    );

    // ---------------------------------------------------------------
    // Display mux: clock mode shows HH-MM-SS, music mode shows status
    // ---------------------------------------------------------------
    wire [31:0] disp_data;
    assign disp_data = clock_mode ? clock_disp_data : music_disp_data;

    // ---------------------------------------------------------------
    // LED mux (single assign to avoid multi-driver)
    //   Music mode: [7:5]=rhythm  [4:3]=speed  [2:1]=song  [0]=play
    //   Clock mode: [7]=blink  [6:3]=0  [2:1]=set_field  [0]=running
    // ---------------------------------------------------------------
    // Clock mode LED: [7]=blink [6]=alarm_active [5:3]=0 [2:1]=set_field [0]=running
    assign led = clock_mode ?
        {clock_blink, clock_alarm_active, 3'b000, clock_set_field, clock_running} :
        {rhythm_led, speed_level, song_id, play_en};

    // ---------------------------------------------------------------
    // Seven-segment display via 74HC595
    // ---------------------------------------------------------------
    wire [7:0] seg_sel;
    wire [6:0] seg_seg;

    hex8_scan u_hex8_scan (
        .clk       (clk),
        .reset_n   (reset_n),
        .en        (1'b1),
        .disp_data (disp_data),
        .sel       (seg_sel),
        .seg       (seg_seg)
    );

    hc595_driver u_hc595_driver (
        .clk     (clk),
        .reset_n (reset_n),
        .data    ({1'b1, seg_seg, seg_sel}),
        .s_en    (1'b1),
        .ds      (seg_dio),
        .sh_cp   (seg_sclk),
        .st_cp   (seg_rclk)
    );

endmodule
