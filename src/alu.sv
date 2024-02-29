`include "lib_cpu.sv"
`include "lib_alu.sv"

module alu import lib_cpu :: *; (
  output EXECUTE ex,
  input  DECODE  de
);
  import lib_alu :: fn_alu;
  assign ex = fn_alu(de);
endmodule
