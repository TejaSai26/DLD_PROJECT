`timescale 1ns/1ps
module buzzer_controller #(
    parameter integer CLK_HZ = 50000000,
    parameter integer TONE_HZ = 3800,
    parameter integer BEEP_HALF_PERIOD_CYCLES = 12500000
)(
    input  wire clk,
    input  wire reset,
    input  wire warning,
    input  wire fault,
    output wire Buzzer
);
    localparam integer TONE_DIV = (CLK_HZ / (2*TONE_HZ) < 1) ? 1 : CLK_HZ / (2*TONE_HZ);

    reg [31:0] tone_count = 0;
    reg [31:0] beep_count = 0;
    reg tone = 1'b0;
    reg beep_on = 1'b0;

    always @(posedge clk) begin
        if (reset) begin
            tone_count <= 0;
            beep_count <= 0;
            tone <= 1'b0;
            beep_on <= 1'b0;
        end else begin
            if (tone_count >= TONE_DIV-1) begin
                tone_count <= 0;
                tone <= ~tone;
            end else begin
                tone_count <= tone_count + 1;
            end

            if (beep_count >= BEEP_HALF_PERIOD_CYCLES-1) begin
                beep_count <= 0;
                beep_on <= ~beep_on;
            end else begin
                beep_count <= beep_count + 1;
            end
        end
    end

    // Warning: intermittent tone. Fault: continuous tone.
    assign Buzzer = tone & (fault | (warning & beep_on));
endmodule
