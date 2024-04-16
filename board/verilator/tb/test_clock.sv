`include "test_package.sv"

module test_clock(
  output logic clk
);
  import test_package :: *;
  always #(CLOCK_PERIOD/2) clk <= ~clk;
  initial clk = 1'b0;
endmodule
