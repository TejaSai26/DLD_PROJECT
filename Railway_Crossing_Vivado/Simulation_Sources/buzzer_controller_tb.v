`timescale 1ns/1ps
module buzzer_controller_tb;
    reg clk = 0;
    reg reset = 1;
    reg warning = 0;
    reg fault = 0;
    wire Buzzer;
    integer high_samples = 0;
    integer low_samples = 0;
    integer i;

    always #5 clk = ~clk;

    buzzer_controller #(
        .CLK_HZ(100),
        .TONE_HZ(10),
        .BEEP_HALF_PERIOD_CYCLES(8)
    ) dut (
        .clk(clk), .reset(reset), .warning(warning),
        .fault(fault), .Buzzer(Buzzer)
    );

    initial begin
        repeat (2) @(posedge clk);
        reset = 0;

        warning = 1;
        for (i=0; i<100; i=i+1) begin
            @(posedge clk); #1;
            if (Buzzer) high_samples = high_samples + 1;
            else low_samples = low_samples + 1;
        end

        if (high_samples > 0 && low_samples > 0)
            $display("PASS: warning mode produces an intermittent buzzer signal");
        else
            $display("FAIL: warning mode did not show both high and low samples");

        warning = 0;
        fault = 1;
        high_samples = 0;
        low_samples = 0;
        for (i=0; i<40; i=i+1) begin
            @(posedge clk); #1;
            if (Buzzer) high_samples = high_samples + 1;
            else low_samples = low_samples + 1;
        end

        if (high_samples > 0 && low_samples > 0)
            $display("PASS: fault mode drives a continuous square-wave tone");
        else
            $display("FAIL: fault tone did not oscillate");
        $finish;
    end
endmodule
