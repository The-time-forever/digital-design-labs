`timescale 1ns / 1ps

module clock_core (
    input  wire        clk,
    input  wire        reset_n,

    input  wire        key_sel_pulse,    // S0
    input  wire        key_inc_pulse,    // S1: field +1
    input  wire        key_dec_pulse,    // S2: field -1
    input  wire        key_pause_pulse,  // S3: stop alarm OR toggle pause/run

    // Alarm switches (already synchronized in top)
    input  wire        alarm_set_mode,   // SW6: 0=time edit  1=alarm edit
    input  wire        alarm_enable,     // SW5: 1=alarm on
    input  wire [1:0]  alarm_song_sel,   // SW3:SW2: 00->song1 01->song2 10->song3 11->song1

    output wire [31:0] disp_data,
    output reg  [1:0]  set_field,
    output reg         clock_running,
    output reg         blink_1hz,
    output reg         alarm_active      // 1 = alarm is ringing
);

    localparam integer CLK_FREQ   = 50_000_000;
    localparam integer ALARM_SECS = 10;          // auto-off after 10 seconds

    reg [25:0] div_cnt;
    wire tick_1s;
    assign tick_1s = (div_cnt == CLK_FREQ - 1);

    // Current time BCD (hour 00-23, min/sec 00-59)
    reg [3:0] hour_t, hour_o;
    reg [3:0] min_t,  min_o;
    reg [3:0] sec_t,  sec_o;

    // Alarm time BCD (default 00:01)
    reg [3:0] alm_hour_t, alm_hour_o;
    reg [3:0] alm_min_t,  alm_min_o;

    // Alarm ring duration counter (counts seconds while alarm_active)
    reg [3:0] alarm_ring_sec;

    // Detect alarm_set_mode transitions to reset set_field
    reg prev_alarm_set_mode;

    // Alarm trigger: combinational, true for ~1 second when time matches alarm
    wire alarm_trigger;
    assign alarm_trigger = alarm_enable && !alarm_set_mode &&
                           (hour_t == alm_hour_t) && (hour_o == alm_hour_o) &&
                           (min_t  == alm_min_t)  && (min_o  == alm_min_o)  &&
                           (sec_t  == 4'd0)        && (sec_o  == 4'd0);

    // 1Hz divider
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            div_cnt <= 26'd0;
        else if (tick_1s)
            div_cnt <= 26'd0;
        else
            div_cnt <= div_cnt + 1'b1;
    end

    // Main control block
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            hour_t              <= 4'd0;
            hour_o              <= 4'd0;
            min_t               <= 4'd0;
            min_o               <= 4'd0;
            sec_t               <= 4'd0;
            sec_o               <= 4'd0;
            alm_hour_t          <= 4'd0;
            alm_hour_o          <= 4'd0;
            alm_min_t           <= 4'd0;
            alm_min_o           <= 4'd1;   // default alarm 00:01
            set_field           <= 2'd0;
            clock_running       <= 1'b1;
            blink_1hz           <= 1'b0;
            alarm_active        <= 1'b0;
            alarm_ring_sec      <= 4'd0;
            prev_alarm_set_mode <= 1'b0;
        end else begin

            prev_alarm_set_mode <= alarm_set_mode;

            // Reset set_field on SW6 transition
            if (alarm_set_mode != prev_alarm_set_mode)
                set_field <= 2'd0;

            // blink every second
            if (tick_1s)
                blink_1hz <= ~blink_1hz;

            // -------------------------------------------------------
            // Alarm active management (priority order via NBA last-write)
            // -------------------------------------------------------

            // (A) SW5=0 forces alarm off immediately
            if (!alarm_enable) begin
                alarm_active   <= 1'b0;
                alarm_ring_sec <= 4'd0;
            end

            // (B) Auto ring counter: turn off after ALARM_SECS seconds
            if (alarm_active && tick_1s) begin
                if (alarm_ring_sec >= ALARM_SECS - 1) begin
                    alarm_active   <= 1'b0;
                    alarm_ring_sec <= 4'd0;
                end else begin
                    alarm_ring_sec <= alarm_ring_sec + 1'b1;
                end
            end

            // (C) Alarm trigger: start ringing when time matches (first cycle only)
            //     alarm_trigger already gates on alarm_enable, so no conflict with (A)
            if (alarm_trigger && !alarm_active) begin
                alarm_active   <= 1'b1;
                alarm_ring_sec <= 4'd0;
            end

            // -------------------------------------------------------
            // S3: stop alarm if ringing, otherwise toggle pause/run
            // -------------------------------------------------------
            if (key_pause_pulse) begin
                if (alarm_active)
                    alarm_active <= 1'b0;
                else
                    clock_running <= ~clock_running;
            end

            // -------------------------------------------------------
            // S0: cycle active edit field
            // -------------------------------------------------------
            if (key_sel_pulse) begin
                if (!alarm_set_mode) begin
                    if (set_field == 2'd2) set_field <= 2'd0;
                    else                   set_field <= set_field + 1'b1;
                end else begin
                    set_field <= set_field[0] ? 2'd0 : 2'd1;
                end
            end

            // -------------------------------------------------------
            // Auto-advance current time (independent of alarm edit keys)
            // -------------------------------------------------------
            if (clock_running && tick_1s) begin
                if (sec_o == 4'd9) begin
                    sec_o <= 4'd0;
                    if (sec_t == 4'd5) begin
                        sec_t <= 4'd0;
                        if (min_o == 4'd9) begin
                            min_o <= 4'd0;
                            if (min_t == 4'd5) begin
                                min_t <= 4'd0;
                                if (hour_t == 4'd2 && hour_o == 4'd3) begin
                                    hour_t <= 4'd0; hour_o <= 4'd0;
                                end else if (hour_o == 4'd9) begin
                                    hour_o <= 4'd0; hour_t <= hour_t + 1'b1;
                                end else begin
                                    hour_o <= hour_o + 1'b1;
                                end
                            end else begin
                                min_t <= min_t + 1'b1;
                            end
                        end else begin
                            min_o <= min_o + 1'b1;
                        end
                    end else begin
                        sec_t <= sec_t + 1'b1;
                    end
                end else begin
                    sec_o <= sec_o + 1'b1;
                end
            end

            // -------------------------------------------------------
            // S1/S2 edit — target depends on alarm_set_mode
            // (separate if blocks so auto-advance is not blocked)
            // -------------------------------------------------------
            if (!alarm_set_mode) begin

                if (key_inc_pulse) begin
                    case (set_field)
                        2'd0: begin  // hour ++
                            if (hour_t == 4'd2 && hour_o == 4'd3) begin
                                hour_t <= 4'd0; hour_o <= 4'd0;
                            end else if (hour_o == 4'd9) begin
                                hour_o <= 4'd0; hour_t <= hour_t + 1'b1;
                            end else begin
                                hour_o <= hour_o + 1'b1;
                            end
                        end
                        2'd1: begin  // minute ++
                            if (min_o == 4'd9) begin
                                min_o <= 4'd0;
                                if (min_t == 4'd5) min_t <= 4'd0;
                                else               min_t <= min_t + 1'b1;
                            end else begin
                                min_o <= min_o + 1'b1;
                            end
                        end
                        2'd2: begin  // second ++
                            if (sec_o == 4'd9) begin
                                sec_o <= 4'd0;
                                if (sec_t == 4'd5) sec_t <= 4'd0;
                                else               sec_t <= sec_t + 1'b1;
                            end else begin
                                sec_o <= sec_o + 1'b1;
                            end
                        end
                        default: ;
                    endcase
                end else if (key_dec_pulse) begin
                    case (set_field)
                        2'd0: begin  // hour --
                            if (hour_t == 4'd0 && hour_o == 4'd0) begin
                                hour_t <= 4'd2; hour_o <= 4'd3;
                            end else if (hour_o == 4'd0) begin
                                hour_o <= 4'd9; hour_t <= hour_t - 1'b1;
                            end else begin
                                hour_o <= hour_o - 1'b1;
                            end
                        end
                        2'd1: begin  // minute --
                            if (min_t == 4'd0 && min_o == 4'd0) begin
                                min_t <= 4'd5; min_o <= 4'd9;
                            end else if (min_o == 4'd0) begin
                                min_o <= 4'd9; min_t <= min_t - 1'b1;
                            end else begin
                                min_o <= min_o - 1'b1;
                            end
                        end
                        2'd2: begin  // second --
                            if (sec_t == 4'd0 && sec_o == 4'd0) begin
                                sec_t <= 4'd5; sec_o <= 4'd9;
                            end else if (sec_o == 4'd0) begin
                                sec_o <= 4'd9; sec_t <= sec_t - 1'b1;
                            end else begin
                                sec_o <= sec_o - 1'b1;
                            end
                        end
                        default: ;
                    endcase
                end

            end else begin

                if (key_inc_pulse) begin
                    if (set_field == 2'd0) begin  // alarm hour ++
                        if (alm_hour_t == 4'd2 && alm_hour_o == 4'd3) begin
                            alm_hour_t <= 4'd0; alm_hour_o <= 4'd0;
                        end else if (alm_hour_o == 4'd9) begin
                            alm_hour_o <= 4'd0; alm_hour_t <= alm_hour_t + 1'b1;
                        end else begin
                            alm_hour_o <= alm_hour_o + 1'b1;
                        end
                    end else begin  // alarm minute ++
                        if (alm_min_o == 4'd9) begin
                            alm_min_o <= 4'd0;
                            if (alm_min_t == 4'd5) alm_min_t <= 4'd0;
                            else                   alm_min_t <= alm_min_t + 1'b1;
                        end else begin
                            alm_min_o <= alm_min_o + 1'b1;
                        end
                    end
                end else if (key_dec_pulse) begin
                    if (set_field == 2'd0) begin  // alarm hour --
                        if (alm_hour_t == 4'd0 && alm_hour_o == 4'd0) begin
                            alm_hour_t <= 4'd2; alm_hour_o <= 4'd3;
                        end else if (alm_hour_o == 4'd0) begin
                            alm_hour_o <= 4'd9; alm_hour_t <= alm_hour_t - 1'b1;
                        end else begin
                            alm_hour_o <= alm_hour_o - 1'b1;
                        end
                    end else begin  // alarm minute --
                        if (alm_min_t == 4'd0 && alm_min_o == 4'd0) begin
                            alm_min_t <= 4'd5; alm_min_o <= 4'd9;
                        end else if (alm_min_o == 4'd0) begin
                            alm_min_o <= 4'd9; alm_min_t <= alm_min_t - 1'b1;
                        end else begin
                            alm_min_o <= alm_min_o - 1'b1;
                        end
                    end
                end

            end
        end
    end

    // Song number for display: 00->1  01->2  10->3  11->1
    wire [3:0] song_disp;
    assign song_disp = (alarm_song_sel == 2'b01) ? 4'd2 :
                       (alarm_song_sel == 2'b10) ? 4'd3 : 4'd1;

    // Display mux: normal=HH-MM-SS  alarm_set=A#-HH-MM
    assign disp_data = alarm_set_mode ?
        {4'hA, song_disp, 4'hE, alm_hour_t, alm_hour_o, 4'hE, alm_min_t, alm_min_o} :
        {hour_t, hour_o, 4'hE, min_t, min_o, 4'hE, sec_t, sec_o};

endmodule
