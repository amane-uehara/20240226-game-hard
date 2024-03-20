`timescale 1ns/1ps
`include "lib_cpu.sv"

module test_top ();
  logic clk;
  logic reset;
  logic uart_tx;
  logic uart_rx;

  localparam FILENAME = "rom.mem";
  localparam WAIT = 8;
  localparam CLOCK_PERIOD = 10;

  mother_board #(
    .WAIT(WAIT),
    .FILENAME(FILENAME)
  ) mother_board (.*);

  always #(CLOCK_PERIOD/2) clk <= ~clk;
  initial clk = 1'b0;

  initial begin
    reset = 1'b1;
    #10;
    reset = 1'b0;
  end

  initial begin
    $display("Current time = %t", $realtime);
    uart_rx = 1'b1; // no signal
    #2000;
    $display("Current time = %t", $realtime);
    uart_rx = 1'b0; // start bit
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b1; // r_data[0]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b1; // r_data[1]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b1; // r_data[2]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b1; // r_data[3]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b0; // r_data[4]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b0; // r_data[5]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b0; // r_data[6]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b0; // r_data[7]
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b1; // stop bit
    #(WAIT*CLOCK_PERIOD);
    $display("Current time = %t", $realtime);
    uart_rx = 1'b1; // no signal
    #400;
    $display("Current time = %t", $realtime);
    $finish();
  end
endmodule
