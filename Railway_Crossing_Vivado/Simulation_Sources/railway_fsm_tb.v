`timescale 1ns/1ps
module railway_fsm_tb;
    reg clk = 0;
    reg reset = 1;
    reg tick = 0;
    reg s1_event = 0;
    reg s2_event = 0;
    wire [2:0] state;
    wire [5:0] countdown;
    wire direction;
    integer errors = 0;

    localparam OPEN=0, WARNING=1, CLOSING=2, CROSSING=3,
               SAFETY_DELAY=4, OPENING=5, FAULT=6;

    always #5 clk = ~clk;

    railway_fsm #(.WARNING_SECONDS(2), .CROSS_TIMEOUT(4), .SAFETY_SECONDS(2)) dut (
        .clk(clk), .reset(reset), .tick(tick),
        .s1_event(s1_event), .s2_event(s2_event),
        .state(state), .countdown(countdown), .direction(direction)
    );

    task step;
        begin @(posedge clk); #1; end
    endtask

    task pulse_tick;
        begin
            tick = 1; step();
            tick = 0; step();
        end
    endtask

    task check_state;
        input [2:0] expected;
        input [255:0] label_text;
        begin
            if (state !== expected) begin
                $display("FAIL: %0s expected state %0d, got %0d", label_text, expected, state);
                errors = errors + 1;
            end else $display("PASS: %0s", label_text);
        end
    endtask

    initial begin
        step(); reset = 0; step();
        check_state(OPEN, "reset to OPEN");

        // Left-to-right: S1 first, then S2.
        s1_event = 1; step(); s1_event = 0; step();
        check_state(WARNING, "S1 starts WARNING");
        if (direction !== 0) errors = errors + 1;
        pulse_tick(); pulse_tick();
        check_state(CLOSING, "WARNING completes");
        pulse_tick();
        check_state(CROSSING, "CLOSING completes");
        s2_event = 1; step(); s2_event = 0; step();
        check_state(SAFETY_DELAY, "expected opposite sensor accepted");
        pulse_tick(); pulse_tick();
        check_state(OPENING, "safety delay completes");
        pulse_tick();
        check_state(OPEN, "gate returns OPEN");

        // Unexpected simultaneous activation from OPEN must fault.
        s1_event = 1; s2_event = 1; step();
        s1_event = 0; s2_event = 0; step();
        check_state(FAULT, "simultaneous sensors cause FAULT");

        // Reset, start from S2, then verify reverse direction.
        reset = 1; step(); reset = 0; step();
        s2_event = 1; step(); s2_event = 0; step();
        check_state(WARNING, "S2 starts reverse-direction WARNING");
        if (direction !== 1) errors = errors + 1;
        pulse_tick(); pulse_tick(); pulse_tick(); // warning then closing
        check_state(CROSSING, "reverse direction reaches CROSSING");
        s1_event = 1; step(); s1_event = 0; step();
        check_state(SAFETY_DELAY, "S1 is expected for reverse direction");

        // New train during SAFETY_DELAY must re-close (WARNING), not FAULT.
        s2_event = 1; step(); s2_event = 0; step();
        check_state(WARNING, "new train in SAFETY_DELAY re-triggers WARNING");

        if (errors == 0) $display("PASS: railway_fsm_tb");
        else $display("FAIL: railway_fsm_tb errors=%0d", errors);
        $finish;
    end
endmodule
