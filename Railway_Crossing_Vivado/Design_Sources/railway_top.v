`timescale 1ns/1ps
module railway_top #(
    parameter integer CLK_HZ = 50000000,
    parameter integer DEBOUNCE_CYCLES = 500000,
    parameter integer WARNING_SECONDS = 5,
    parameter integer CROSS_TIMEOUT = 30,
    parameter integer SAFETY_SECONDS = 5,
    parameter integer DISPLAY_REFRESH_DIV = 50000,
    parameter integer BUZZER_TONE_HZ = 3800,
    parameter integer BUZZER_BEEP_HALF_PERIOD = 12500000
)(
    input  wire clk,
    input  wire [4:0] pb,
    output reg  [4:0] led = 5'b0,
    output wire [3:0] digit,
    output wire [7:0] Seven_Seg,
    output wire Buzzer,
    output wire barricade_closed   // 1 = lower/keep closed, 0 = raise/keep open
);
    wire reset_clean;
    wire s1_clean;
    wire s2_clean;
    reg s1_previous = 1'b0;
    reg s2_previous = 1'b0;
    wire s1_event;
    wire s2_event;
    wire tick;
    wire restart;
    reg [2:0] state_prev = 3'd0;
    wire [2:0] state;
    wire [5:0] countdown;

    // Board buttons are active-high. pb[4] = reset, pb[2] = S1, pb[3] = S2.
    input_conditioner #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) reset_filter
        (.clk(clk), .reset(1'b0), .noisy_in(pb[4]), .clean_out(reset_clean));

    input_conditioner #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) s1_filter
        (.clk(clk), .reset(reset_clean), .noisy_in(pb[2]), .clean_out(s1_clean));

    input_conditioner #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) s2_filter
        (.clk(clk), .reset(reset_clean), .noisy_in(pb[3]), .clean_out(s2_clean));

    assign s1_event = s1_clean & ~s1_previous;
    assign s2_event = s2_clean & ~s2_previous;

    always @(posedge clk) begin
        if (reset_clean) begin
            s1_previous <= 1'b0;
            s2_previous <= 1'b0;
        end else begin
            s1_previous <= s1_clean;
            s2_previous <= s2_clean;
        end
    end

    clock_tick #(.CLK_HZ(CLK_HZ)) one_second_timer
        (.clk(clk), .reset(reset_clean), .restart(restart), .tick(tick));

    always @(posedge clk) state_prev <= state;
    assign restart = (state != state_prev);   // restart 1 s timer on every state change

    // Fail-safe barricade command: closed in CLOSING, CROSSING, SAFETY_DELAY, FAULT.
    assign barricade_closed = (state == 3'd2) | (state == 3'd3) |
                              (state == 3'd4) | (state == 3'd6);

    railway_fsm #(
        .WARNING_SECONDS(WARNING_SECONDS),
        .CROSS_TIMEOUT(CROSS_TIMEOUT),
        .SAFETY_SECONDS(SAFETY_SECONDS)
    ) controller (
        .clk(clk),
        .reset(reset_clean),
        .tick(tick),
        .s1_event(s1_event),
        .s2_event(s2_event),
        .state(state),
        .countdown(countdown),
        .direction()
    );

    seven_segment #(.REFRESH_DIV(DISPLAY_REFRESH_DIV)) display_unit
        (.clk(clk), .reset(reset_clean), .value(countdown),
         .digit(digit), .Seven_Seg(Seven_Seg));

    buzzer_controller #(
        .CLK_HZ(CLK_HZ),
        .TONE_HZ(BUZZER_TONE_HZ),
        .BEEP_HALF_PERIOD_CYCLES(BUZZER_BEEP_HALF_PERIOD)
    ) sound_unit (
        .clk(clk),
        .reset(reset_clean),
        .warning(state == 3'd1),
        .fault(state == 3'd6),
        .Buzzer(Buzzer)
    );

    // Onboard LEDs: 0=OPEN/OPENING, 1=WARNING/CLOSING,
    // 2=CROSSING, 3=SAFETY_DELAY, 4=FAULT.
    always @(*) begin
        led = 5'b0;
        case (state)
            3'd0: led[0] = 1'b1;
            3'd1: led[1] = 1'b1;
            3'd2: led[1] = 1'b1;
            3'd3: led[2] = 1'b1;
            3'd4: led[3] = 1'b1;
            3'd5: led[0] = 1'b1;
            3'd6: led[4] = 1'b1;
            default: led[4] = 1'b1;
        endcase
    end
endmodule
