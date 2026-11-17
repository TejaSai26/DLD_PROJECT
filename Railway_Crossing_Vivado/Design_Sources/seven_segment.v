`timescale 1ns/1ps
module seven_segment #(
    parameter integer REFRESH_DIV = 50000
)(
    input  wire clk,
    input  wire reset,
    input  wire [5:0] value,
    output reg  [3:0] digit = 4'b0000,
    output reg  [7:0] Seven_Seg = 8'b11111111
);
    reg [31:0] refresh_count = 0;
    reg [1:0] scan = 0;
    reg [3:0] number;
    reg [3:0] tens;
    reg [3:0] ones;

    always @(*) begin
        tens = value / 10;
        ones = value % 10;
        case (scan)
            2'd0: number = 4'd0;
            2'd1: number = 4'd0;
            2'd2: number = tens;
            default: number = ones;
        endcase

        case (number)
            4'd0: Seven_Seg = 8'b11000000;
            4'd1: Seven_Seg = 8'b11111001;
            4'd2: Seven_Seg = 8'b10100100;
            4'd3: Seven_Seg = 8'b10110000;
            4'd4: Seven_Seg = 8'b10011001;
            4'd5: Seven_Seg = 8'b10010010;
            4'd6: Seven_Seg = 8'b10000010;
            4'd7: Seven_Seg = 8'b11111000;
            4'd8: Seven_Seg = 8'b10000000;
            4'd9: Seven_Seg = 8'b10010000;
            default: Seven_Seg = 8'b11111111;
        endcase

        case (scan)
            2'd0: digit = 4'b1000; // leftmost
            2'd1: digit = 4'b0100;
            2'd2: digit = 4'b0010;
            2'd3: digit = 4'b0001; // rightmost
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            refresh_count <= 0;
            scan <= 0;
        end else if (refresh_count >= REFRESH_DIV-1) begin
            refresh_count <= 0;
            scan <= scan + 1'b1;
        end else begin
            refresh_count <= refresh_count + 1;
        end
    end
endmodule
