`include "lib_cpu.sv"
`include "lib_alu.sv"

module alu import lib_cpu :: *; (
  input  logic   clk, reset, w_en,
  output EXECUTE ex,
  input  DECODE  de
);
  import lib_alu :: fn_alu;

  EXECUTE next_ex;
  assign next_ex = fn_alu(de);

  always_ff @(posedge clk) begin
    if (reset)
      ex <= '0;
    else if (w_en)
      ex <= next_ex;
  end
endmodule
