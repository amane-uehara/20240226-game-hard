set_property -dict {PACKAGE_PIN R2 IOSTANDARD SSTL135} [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10 -waveform {0 5} [get_ports {clk}];

set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33} [get_ports {n_reset}];
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {uart_tx}];
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {uart_rx}];
