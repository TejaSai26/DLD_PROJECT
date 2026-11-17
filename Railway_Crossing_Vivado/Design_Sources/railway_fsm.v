`timescale 1ns/1ps
module railway_fsm #(
    parameter integer WARNING_SECONDS = 5,
    parameter integer CROSS_TIMEOUT   = 30,
    parameter integer SAFETY_SECONDS  = 5
)(
    input  wire clk,
    input  wire reset,
    input  wire tick,
    input  wire s1_event,
    input  wire s2_event,
    output reg  [2:0] state = 3'd0,
    output reg  [5:0] countdown = 0,
    output reg        direction = 1'b0
);
    localparam [2:0] OPEN         = 3'd0;
    localparam [2:0] WARNING      = 3'd1;
    localparam [2:0] CLOSING      = 3'd2;
    localparam [2:0] CROSSING     = 3'd3;
    localparam [2:0] SAFETY_DELAY = 3'd4;
    localparam [2:0] OPENING      = 3'd5;
    localparam [2:0] FAULT        = 3'd6;

    always @(posedge clk) begin
        if (reset) begin
            state <= OPEN;
            countdown <= 0;
            direction <= 1'b0;
        end else begin
            case (state)
                OPEN: begin
                    countdown <= 0;
                    if (s1_event && s2_event) begin
                        state <= FAULT;
                    end else if (s1_event) begin
                        direction <= 1'b0; // S1 first; S2 is expected next
                        countdown <= WARNING_SECONDS;
                        state <= WARNING;
                    end else if (s2_event) begin
                        direction <= 1'b1; // S2 first; S1 is expected next
                        countdown <= WARNING_SECONDS;
                        state <= WARNING;
                    end
                end

                WARNING: begin
                    if (s1_event || s2_event) begin
                        state <= FAULT;
                    end else if (tick) begin
                        if (countdown <= 1) begin
                            countdown <= 1;
                            state <= CLOSING;
                        end else begin
                            countdown <= countdown - 1'b1;
                        end
                    end
                end

                CLOSING: begin
                    if (s1_event || s2_event) begin
                        state <= FAULT;
                    end else if (tick) begin
                        countdown <= CROSS_TIMEOUT;
                        state <= CROSSING;
                    end
                end

                CROSSING: begin
                    if (s1_event && s2_event) begin
                        state <= FAULT;
                    end else if ((!direction && s2_event) || (direction && s1_event)) begin
                        countdown <= SAFETY_SECONDS;
                        state <= SAFETY_DELAY;
                    end else if ((!direction && s1_event) || (direction && s2_event)) begin
                        state <= FAULT;
                    end else if (tick) begin
                        if (countdown <= 1) begin
                            countdown <= 0;
                            state <= FAULT;
                        end else begin
                            countdown <= countdown - 1'b1;
                        end
                    end
                end

                SAFETY_DELAY: begin
                    if (s1_event && s2_event) begin
                        state <= FAULT;
                    end else if (s1_event) begin
                        direction <= 1'b0;          // new train from S1 side: close again
                        countdown <= WARNING_SECONDS;
                        state <= WARNING;
                    end else if (s2_event) begin
                        direction <= 1'b1;          // new train from S2 side: close again
                        countdown <= WARNING_SECONDS;
                        state <= WARNING;
                    end else if (tick) begin
                        if (countdown <= 1) begin
                            countdown <= 0;
                            state <= OPENING;
                        end else begin
                            countdown <= countdown - 1'b1;
                        end
                    end
                end

                OPENING: begin
                    if (s1_event && s2_event) begin
                        state <= FAULT;
                    end else if (s1_event) begin
                        direction <= 1'b0;          // new train from S1 side: close again
                        countdown <= WARNING_SECONDS;
                        state <= WARNING;
                    end else if (s2_event) begin
                        direction <= 1'b1;          // new train from S2 side: close again
                        countdown <= WARNING_SECONDS;
                        state <= WARNING;
                    end else if (tick) begin
                        countdown <= 0;
                        state <= OPEN;
                    end
                end

                FAULT: begin
                    state <= FAULT;
                    countdown <= 0;
                end

                default: begin
                    state <= FAULT;
                    countdown <= 0;
                end
            endcase
        end
    end
endmodule
