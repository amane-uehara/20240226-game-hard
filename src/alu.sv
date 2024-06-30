`include "lib_cpu.sv"
`include "lib_alu.sv"

module alu import lib_cpu :: *; (
  input  logic       clk, reset,
  input  DECODE      de,
  input  SPECIAL_REG sr,
  output EXECUTE     ex
);
  import lib_alu :: *;

  EXECUTE next_ex;
  always_comb begin
    if (de.irr & sr.intr_en == 1'b1)
      next_ex = fn_icall(de, sr);
    else unique case (de.opcode)
      4'h0:    next_ex = fn_calci(de, sr);
      4'h1:    next_ex = fn_calcr(de, sr);
      4'h2:    next_ex = fn_jalr(de, sr);
      4'h3:    next_ex = fn_jcc(de, sr);
      4'h4:    next_ex = fn_lw(de, sr);
      4'h5:    next_ex = fn_sw(de, sr);
      4'h6:    next_ex = fn_r_io(de, sr);
      4'h7:    next_ex = fn_w_io(de, sr);
      4'h8:    next_ex = fn_w_intr(de, sr);
      4'h9:    next_ex = fn_iret(de, sr);
      4'hA:    next_ex = fn_halt(de, sr);
      default: next_ex = fn_nop(de, sr);
    endcase
  end

  logic is_update_reg;
  logic [1:0] counter, next_counter;
  assign next_counter = counter + 2'd1;
  always_ff @(posedge clk) begin
    if (reset) counter <= 2'd0;
    else       counter <= next_counter;
  end
  assign is_update_reg = (counter == 2'd3);

  always_ff @(posedge clk) begin
    if (reset) ex <= '0;
    else if (is_update_reg) ex <= next_ex;
  end
endmodule
