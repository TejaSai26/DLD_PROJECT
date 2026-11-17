`timescale 1ns/1ps
module railway_tb;
    reg clk = 0;
    reg [4:0] pb = 5'b0;
    wire [4:0] led;
    wire [3:0] digit;
    wire [7:0] Seven_Seg;
    wire Buzzer;
    wire barricade_closed;

    localparam OPEN=0, WARNING=1, CLOSING=2, CROSSING=3,
               SAFETY_DELAY=4, OPENING=5, FAULT=6;

    always #5 clk = ~clk;

    // Accelerated parameters are ONLY for simulation.
    // Hardware top defaults remain set for the 50 MHz board clock.
    railway_top #(
        .CLK_HZ(1000),
        .DEBOUNCE_CYCLES(3),
        .WARNING_SECONDS(2),
        .CROSS_TIMEOUT(6),
        .SAFETY_SECONDS(2),
        .DISPLAY_REFRESH_DIV(3),
        .BUZZER_TONE_HZ(10),
        .BUZZER_BEEP_HALF_PERIOD(8)
    ) dut (
        .clk(clk), .pb(pb), .led(led),
        .digit(digit), .Seven_Seg(Seven_Seg), .Buzzer(Buzzer),
        .barricade_closed(barricade_closed)
    );

    task wait_cycles;
        input integer n;
        integer k;
        begin for (k=0; k<n; k=k+1) @(posedge clk); end
    endtask

    task press_button;
        input integer button_number;
        begin
            pb[button_number] = 1'b1;
            wait_cycles(12);
            pb[button_number] = 1'b0;
            wait_cycles(12);
        end
    endtask

    task wait_for_state;
        input [2:0] expected;
        input integer max_cycles;
        integer k;
        begin
            k=0;
            while (dut.state !== expected && k < max_cycles) begin
                @(posedge clk);
                k=k+1;
            end
            if (dut.state === expected)
                $display("PASS: reached state %0d", expected);
            else begin
                $display("FAIL: timed out waiting for state %0d; current=%0d", expected, dut.state);
                $fatal(1);
            end
        end
    endtask

    initial begin
        $display("Starting complete railway crossing system simulation...");
        wait_cycles(5);
        press_button(4); // reset button pb[4]
        wait_cycles(5);

        // S1 = pb[2], then expected opposite sensor S2 = pb[3].
        press_button(2);
        wait_for_state(WARNING, 30);
        wait_for_state(CLOSING, 2500);
        wait_for_state(CROSSING, 1200);
        press_button(3);
        wait_for_state(SAFETY_DELAY, 50);
        wait_for_state(OPENING, 2500);
        wait_for_state(OPEN, 1200);

        $display("PASS: complete left-to-right crossing sequence");
        $display("Simulation completed. Inspect waveforms for LEDs, display and buzzer.");
        $finish;
    end

    initial begin
        #2000000;
        $display("FAIL: global simulation timeout");
        $fatal(1);
    end
endmodule
