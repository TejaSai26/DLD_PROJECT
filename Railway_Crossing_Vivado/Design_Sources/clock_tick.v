`timescale 1ns/1ps
module clock_tick #(
    parameter integer CLK_HZ = 50000000
)(
    input  wire clk,
    input  wire reset,
    input  wire restart,   // re-align the 1 s period to FSM state entry
    output reg  tick = 1'b0
);
    reg [31:0] count = 0;

    always @(posedge clk) begin
        if (reset || restart) begin
            count <= 0;
            tick <= 1'b0;
        end else if (count >= CLK_HZ-1) begin
            count <= 0;
            tick <= 1'b1;
        end else begin
            count <= count + 1;
            tick <= 1'b0;
        end
    end
endmodule
