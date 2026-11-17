## EDGE Artix-7 board pin constraints
## Confirm the exact board revision/manual before programming.

set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 20.000 -name sys_clk [get_ports clk]

## Push buttons: active-high
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {pb[0]}]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {pb[1]}]
set_property -dict {PACKAGE_PIN M12 IOSTANDARD LVCMOS33} [get_ports {pb[2]}]
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports {pb[3]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {pb[4]}]

## First five onboard LEDs
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports {led[4]}]

## Four-digit seven-segment display: digit enables active-high,
## segment outputs active-low.
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {digit[0]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {digit[1]}]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports {digit[2]}]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {digit[3]}]

set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[0]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[1]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[3]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[4]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[6]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {Seven_Seg[7]}]

## Onboard buzzer output; ensure the board's buzzer-enable jumper is set.
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVCMOS33} [get_ports Buzzer]

## Barricade command (servo/relay driver). NOT on a fixed board pin: choose a free
## header pin from your board manual, uncomment and edit the line below.
## set_property -dict {PACKAGE_PIN <FREE_PIN> IOSTANDARD LVCMOS33} [get_ports barricade_closed]
## Until a pin is assigned, allow bitstream generation with an unplaced port:
set_property SEVERITY {Warning} [get_drc_checks UCIO]
set_property SEVERITY {Warning} [get_drc_checks NSTD]
