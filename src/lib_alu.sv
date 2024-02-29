`ifndef LIB_ALU_SV
`define LIB_ALU_SV
`include "lib_cpu.sv"

package lib_alu;
  import lib_cpu :: *;

  function automatic EXECUTE fn_alu(input DECODE de);
    unique case (de.opcode)
      4'h0:    fn_alu = fn_lih(de);
      4'h1:    fn_alu = fn_calci(de);
      4'h2:    fn_alu = fn_calcr(de);
      4'h3:    fn_alu = fn_sw(de);
      4'h4:    fn_alu = fn_lw(de);
      4'h5:    fn_alu = fn_jalr(de);
      4'h6:    fn_alu = fn_jcc(de);
      default: fn_alu = fn_nop(de);
    endcase
  endfunction

  function automatic REG_EXECUTE fn_nop (input REG_DECODE de);
    fn_nop.pc         = de.pc + 32'd4;
    fn_nop.w_req      = 1'b0;
    fn_nop.w_data     = 32'd0;
    fn_nop.ack        = 1'b0;
    fn_nop.rd         = de.rd;
    fn_nop.x_rd       = de.x_rd;
    fn_nop.addr_4byte = de.addr_4byte;
    fn_nop.mem_val    = de.mem_val;
    fn_nop.intr_en    = de.intr_en;
  endfunction

  function automatic EXECUTE fn_lih (input DECODE de);
    fn_lih = fn_nop(de);
    fn_lih.x_rd = {de.imm16[15:0], de.x_rd[15:0]};
  endfunction

  function automatic logic [31:0] fn_calc (
    input logic [3:0] opt,
    input logic [31:0] a, b, default_val
  );
    unique case (opt)
      4'h0:    fn_calc = a + b;
      4'h1:    fn_calc = a - b;
      4'h2:    fn_calc = a << b[0:4];
      4'h3:    fn_calc = signed'(a) >> b[0:4];
      4'h4:    fn_calc = a & b;
      4'h5:    fn_calc = a | b;
      4'h6:    fn_calc = a ^ b;
      default: fn_calc = default_val;
    endcase
  endfunction

  function automatic EXECUTE fn_calci (input DECODE de);
    fn_calci = fn_nop(de);
    fn_calci = fn_calc(de.opt, de.x_rs1, de.imm16, de.x_rd);
  endfunction

  function automatic EXECUTE fn_calcr (input DECODE de);
    fn_calcr = fn_nop(de);
    fn_calci = fn_calc(de.opt, de.x_rs1, de.x_rs2, de.x_rd);
  endfunction

  function automatic EXECUTE fn_sw (input DECODE de);
    fn_sw = fn_nop(de);
    fn_sw.mem_val = de.x_rs1;
  endfunction

  function automatic EXECUTE fn_lw (input DECODE de);
    fn_lw = fn_nop(de);
    fn_lw.x_rd = de.mem_val;
  endfunction

  function automatic EXECUTE fn_jalr (input DECODE de);
    fn_jalr = fn_nop(de);
    fn_jalr.x_rd = de.pc + 32'd4;
    fn_jalr.pc = de.x_rs2; // rs1にしたい
  endfunction

  function automatic EXECUTE fn_jcc (input DECODE de);
    fn_jcc = fn_nop(de);
    fn_jcc.x_rd = de.pc + 32'd4;

    logic is_jmp;
    unique case (de.opt)
      4'h0:    is_jmp = (de.x_rs1 == 32'd0);
      4'h1:    is_jmp = (de.x_rs1 != 32'd0);
      4'h2:    is_jmp = (de.x_rs1[31] == 1'b0); // de.x_rs1 >= 0
      4'h3:    is_jmp = (de.x_rs1[31] != 1'b0); // de.x_rs1 <  0
      default: is_jmp = 1'b0;
    endcase

    fn_jcc.pc = is_jmp ? de.x_rs2; // rs1にしたい
  endfunction

endpackage

`endif
