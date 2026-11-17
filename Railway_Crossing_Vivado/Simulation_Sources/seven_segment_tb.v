`timescale 1ns/1ps
module seven_segment_tb;
    reg clk = 0;
    reg reset = 1;
    reg [5:0] value = 25;
    wire [3:0] digit;
    wire [7:0] Seven_Seg;
    reg [3:0] seen = 0;
    integer i;

    always #5 clk = ~clk;

    seven_segment #(.REFRESH_DIV(2)) dut (
        .clk(clk), .reset(reset), .value(value),
        .digit(digit), .Seven_Seg(Seven_Seg)
    );

    initial begin
        repeat (2) @(posedge clk);
        reset = 0;
        // Allow multiple complete scans and record which digit enables appear.
        for (i=0; i<40; i=i+1) begin
            @(posedge clk); #1;
            seen = seen | digit;
        end

        if (seen === 4'b1111)
            $display("PASS: all four display digits were scanned");
        else
            $display("FAIL: not all digits scanned, seen=%b", seen);

        // 25 should use tens=2 and ones=5. Segment patterns are active-low.
        value = 5;
        repeat (12) @(posedge clk);
        $display("INFO: display scan test completed; inspect Seven_Seg/digit in waveform for 0005 and 0025.");
        $finish;
    end
endmodule
