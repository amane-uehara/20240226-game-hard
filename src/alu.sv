`include "lib_cpu.sv"
`include "lib_alu.sv"

module alu import lib_cpu :: *; (
  input  logic   clk, reset,
  input  DECODE  de,
  output EXECUTE ex
);
  import lib_alu :: *;

  EXECUTE next_ex;
  always_comb begin
    if (de.irr & de.sr.intr_en == 1'b1)
      next_ex = fn_icall(de);
    else unique case (de.opcode)
      4'h0:    next_ex = fn_calci(de);
      4'h1:    next_ex = fn_calcr(de);
      4'h2:    next_ex = fn_jalr(de);
      4'h3:    next_ex = fn_jcc(de);
      4'h4:    next_ex = fn_lw(de);
      4'h5:    next_ex = fn_sw(de);
      4'h6:    next_ex = fn_r_io(de);
      4'h7:    next_ex = fn_w_io(de);
      4'h8:    next_ex = fn_w_intr(de);
      4'h9:    next_ex = fn_iret(de);
      4'hA:    next_ex = fn_halt(de);
      default: next_ex = fn_nop(de);
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) ex <= '0;
    else       ex <= next_ex;
  end
endmodule
