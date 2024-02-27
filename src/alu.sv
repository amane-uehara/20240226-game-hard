`include "lib_cpu.sv"

module alu import lib_cpu :: *; (
  input  logic   clk, reset,
  output EXECUTE ex,
  input  DECODE  de
);
  assign ex = '0;
endmodule
