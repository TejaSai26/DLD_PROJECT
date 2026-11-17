`timescale 1ns/1ps
module input_conditioner #(
    parameter integer DEBOUNCE_CYCLES = 500000
)(
    input  wire clk,
    input  wire reset,
    input  wire noisy_in,
    output reg  clean_out = 1'b0
);
    reg sync_ff1 = 1'b0;
    reg sync_ff2 = 1'b0;
    reg [31:0] count = 0;

    always @(posedge clk) begin
        if (reset) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
            clean_out <= 1'b0;
            count <= 0;
        end else begin
            sync_ff1 <= noisy_in;
            sync_ff2 <= sync_ff1;

            if (sync_ff2 == clean_out) begin
                count <= 0;
            end else if (DEBOUNCE_CYCLES <= 1 || count >= DEBOUNCE_CYCLES-1) begin
                clean_out <= sync_ff2;
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule
