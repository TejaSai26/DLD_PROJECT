# Smart Railway Level-Crossing Automation System

Target board: EDGE Artix-7, XC7A35T family (confirm exact board revision and part in Vivado).

## Source design
- `railway_top.v`: actual FPGA top module.
- `input_conditioner.v`: two-flop synchronizer and debouncer.
- `clock_tick.v`: one-second clock-enable pulse from the 50 MHz board clock.
- `railway_fsm.v`: crossing controller.
- `seven_segment.v`: four-digit multiplexed countdown display.
- `buzzer_controller.v`: intermittent warning tone and continuous fault tone.
- `railway.xdc`: board pin constraints.

## Simulation testbenches
- `railway_tb.v`: complete system simulation top.
- `input_conditioner_tb.v`: input conditioning test.
- `railway_fsm_tb.v`: FSM transition tests.
- `seven_segment_tb.v`: digit multiplexing test.
- `buzzer_controller_tb.v`: buzzer waveform test.

Each testbench is an independent simulation top. There is no need for a Verilog module that instantiates all testbenches. Select the testbench you want to run as the Simulation Top in Vivado.

## Vivado setup
1. Create a new RTL project.
2. Select the exact FPGA part printed on your board. The expected 35T part in the board documentation is `xc7a35tftg256-1`; verify the physical board marking.
3. Add every `.v` file in `Design_Sources` as Design Sources.
4. Add `Constraints/railway.xdc` as a Constraint.
5. Add every `.v` file in `Simulation_Sources` as Simulation Sources.
6. For full system simulation, right-click `railway_tb` and choose **Set as Top** under Simulation Sources.
7. Run **Run Simulation > Run Behavioral Simulation**.
8. For synthesis/bitstream, set `railway_top` as the Design Top (not `railway_tb`).

## Physical button mapping used by this design
- `pb[2]` (left button, M12): S1 sensor simulation.
- `pb[3]` (right button, L13): S2 sensor simulation.
- `pb[4]` (centre button, M14): reset.
- `pb[0]` and `pb[1]` are unused.

## Onboard indicators
- `led[0]`: OPEN or OPENING
- `led[1]`: WARNING or CLOSING
- `led[2]`: CROSSING
- `led[3]`: SAFETY_DELAY
- `led[4]`: FAULT
- Four-digit display: `00` followed by the countdown tens and units.
- Buzzer: intermittent in WARNING, continuous tone in FAULT.

## Important notes
- The testbench uses accelerated parameters. Do not change the hardware defaults just to make simulation faster.
- The 30-second crossing timeout is a demonstration timeout, not a railway-certified safety mechanism.
- Real railway signalling must use certified fail-safe sensors, interlocking, redundancy and safety procedures. This educational project uses push buttons to simulate sensors.
- Confirm the exact board revision, package, clock pin, button pins, display polarity and buzzer jumper against the manual supplied with your board before programming.
- The board's onboard buzzer requires its enable jumper to be in the enabled position.
- FPGA I/O is 3.3 V. Never connect 5 V directly to an FPGA GPIO.
- The external breadboard LEDs are not used by this version; onboard LEDs are used instead.

## Revision notes (verified fixes)
- Added `barricade_closed` output (1 in CLOSING/CROSSING/SAFETY_DELAY/FAULT). Assign a free header pin in railway.xdc.
- `clock_tick` now has `restart`; the 1 s timer re-aligns on every state change so the safety delay is a full SAFETY_SECONDS.
- A sensor event during SAFETY_DELAY or OPENING now re-triggers WARNING (gate closes again) instead of FAULT.
