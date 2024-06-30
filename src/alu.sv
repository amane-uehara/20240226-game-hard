`include "lib_cpu.sv"
`include "lib_alu.sv"

module alu import lib_cpu :: *; (
  input  logic   clk, reset,
  input  DECODE  de,
  input  STATE   state,
  output EXECUTE ex
);
  import lib_alu :: *;

  EXECUTE next_ex;
  always_comb begin
    if (de.irr & state.intr_en == 1'b1)
      next_ex = fn_icall(de, state);
    else unique case (de.opcode)
      4'h0:    next_ex = fn_calci(de, state);
      4'h1:    next_ex = fn_calcr(de, state);
      4'h2:    next_ex = fn_jalr(de, state);
      4'h3:    next_ex = fn_jcc(de, state);
      4'h4:    next_ex = fn_lw(de, state);
      4'h5:    next_ex = fn_sw(de, state);
      4'h6:    next_ex = fn_r_io(de, state);
      4'h7:    next_ex = fn_w_io(de, state);
      4'h8:    next_ex = fn_w_intr(de, state);
      4'h9:    next_ex = fn_iret(de, state);
      4'hA:    next_ex = fn_halt(de, state);
      default: next_ex = fn_nop(de, state);
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
