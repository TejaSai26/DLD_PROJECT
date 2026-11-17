`timescale 1ns/1ps
module input_conditioner_tb;
    reg clk = 0;
    reg reset = 1;
    reg noisy_in = 0;
    wire clean_out;
    integer errors = 0;

    always #5 clk = ~clk;

    input_conditioner #(.DEBOUNCE_CYCLES(4)) dut (
        .clk(clk), .reset(reset), .noisy_in(noisy_in), .clean_out(clean_out)
    );

    initial begin
        repeat (2) @(posedge clk);
        reset = 0;

        // A short glitch should not pass through the debouncer.
        noisy_in = 1;
        repeat (2) @(posedge clk);
        noisy_in = 0;
        repeat (6) @(posedge clk);
        if (clean_out !== 1'b0) begin
            $display("FAIL: short glitch changed clean_out");
            errors = errors + 1;
        end

        // A stable high level should eventually be accepted.
        noisy_in = 1;
        repeat (8) @(posedge clk);
        if (clean_out !== 1'b1) begin
            $display("FAIL: stable high was not accepted");
            errors = errors + 1;
        end

        // A stable low level should eventually be accepted.
        noisy_in = 0;
        repeat (8) @(posedge clk);
        if (clean_out !== 1'b0) begin
            $display("FAIL: stable low was not accepted");
            errors = errors + 1;
        end

        if (errors == 0) $display("PASS: input_conditioner_tb");
        else $display("FAIL: input_conditioner_tb errors=%0d", errors);
        $finish;
    end
endmodule
