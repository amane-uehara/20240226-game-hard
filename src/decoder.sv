`include "lib_cpu.sv"

module decoder import lib_cpu :: *; (
  input  logic        clk, reset,
  output DECODE       de,
  input  EXECUTE      ex,
  input  logic [31:0] instruction,
  input  logic        w_busy,
  input  logic        irr,
  input  logic [31:0] r_data
);
  assign de = '0;
endmodule
