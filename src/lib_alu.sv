`ifndef LIB_ALU_SV
`define LIB_ALU_SV
`include "lib_cpu.sv"

package lib_alu;
  import lib_cpu :: *;

  function automatic EXECUTE fn_nop (input DECODE de);
    fn_nop.pc        = de.sr.pc + 32'd1;
    fn_nop.w_req     = 1'b0;
    fn_nop.w_data    = 8'd0;
    fn_nop.ack       = 1'b0;
    fn_nop.w_rd      = 1'b0;
    fn_nop.x_rd      = 32'd0;
    fn_nop.mem_r_req = 1'b0;
    fn_nop.mem_w_req = 1'b0;
    fn_nop.mem_addr  = de.x_rs1[5:0];
    fn_nop.intr_en   = de.sr.intr_en;
    fn_nop.intr_pc   = de.sr.intr_pc;
    fn_nop.intr_vec  = de.sr.intr_vec;
  endfunction

  function automatic logic [31:0] fn_calc (
    input logic [3:0] opt,
    input logic [31:0] a, b
  );
    unique case (opt)
      4'h0:    fn_calc = a + b;
      4'h1:    fn_calc = a - b;
      4'h2:    fn_calc = a << b[4:0];
      4'h3:    fn_calc = a >> b[4:0];
      4'h4:    fn_calc = signed'(a) >>> b[4:0];
      4'h5:    fn_calc = a & b;
      4'h6:    fn_calc = a | b;
      4'h7:    fn_calc = a ^ b;
      default: fn_calc = 32'd0;
    endcase
  endfunction

  function automatic EXECUTE fn_calci (input DECODE de);
    logic s = de.imm[11];
    logic [31:0] imm_ext = {{20{s}}, de.imm[11:0]};

    fn_calci = fn_nop(de);
    fn_calci.w_rd = 1'b1;
    fn_calci.x_rd = fn_calc(de.opt, de.x_rs1, imm_ext);
  endfunction

  function automatic EXECUTE fn_calcr (input DECODE de);
    fn_calcr = fn_nop(de);
    fn_calcr.w_rd = 1'b1;
    fn_calcr.x_rd = fn_calc(de.opt, de.x_rs1, de.x_rs2);
  endfunction

  function automatic EXECUTE fn_jalr (input DECODE de);
    fn_jalr = fn_nop(de);
    fn_jalr.w_rd = 1'b1;
    fn_jalr.x_rd = de.sr.pc + 32'd1;
    fn_jalr.pc = de.x_rs1;
  endfunction

  function automatic EXECUTE fn_jcc (input DECODE de);
      logic zf, sf, is_jmp;
      zf = (de.x_rs2 == 32'd0);
      sf = (de.x_rs2[31] == 1'b0);

      unique case (de.opt)
        4'h0:    is_jmp =  zf;
        4'h1:    is_jmp = ~zf;
        4'h2:    is_jmp =  sf;        // de.x_rs1 >= 0
        4'h3:    is_jmp = ~sf;        // de.x_rs1 <  0
        4'h4:    is_jmp =  sf && ~zf; // de.x_rs1 >  0
        4'h5:    is_jmp = ~sf ||  zf; // de.x_rs1 <= 0
        default: is_jmp = 1'b0;
      endcase

      fn_jcc = fn_nop(de);
      fn_jcc.pc = is_jmp ? de.x_rs1 : de.sr.pc + 32'd1;
  endfunction

  function automatic EXECUTE fn_lw (input DECODE de);
    fn_lw = fn_nop(de);
    fn_lw.mem_r_req = 1'b1;
    fn_lw.w_rd = 1'b1;
  endfunction

  function automatic EXECUTE fn_sw (input DECODE de);
    fn_sw = fn_nop(de);
    fn_sw.mem_w_req = 1'b1;
  endfunction

  function automatic EXECUTE fn_r_io (input DECODE de);
    fn_r_io = fn_nop(de);
    fn_r_io.w_rd = 1'b1;

    case (de.imm)
      12'd0:   fn_r_io.x_rd = {31'd0, de.sr.w_busy};
      12'd1:   fn_r_io.x_rd = {24'd0, de.sr.r_data};
      default: fn_r_io.w_rd = 1'b0;
    endcase
  endfunction

  function automatic EXECUTE fn_w_io (input DECODE de);
    fn_w_io = fn_nop(de);
    fn_w_io.w_req = 1'b1;

    case (de.imm)
      12'd0:   fn_w_io.w_data = de.x_rs1[7:0];
      default: fn_w_io.w_req  = 1'b0;
    endcase
  endfunction

  function automatic EXECUTE fn_w_intr (input DECODE de);
    fn_w_intr = fn_nop(de);
    fn_w_intr.ack      = (de.imm == 12'd0) ? de.x_rs1[0] : 1'b0;
    fn_w_intr.intr_en  = (de.imm == 12'd1) ? de.x_rs1[0] : 1'b0;
    fn_w_intr.intr_vec = (de.imm == 12'd2) ? de.x_rs1    : de.sr.intr_vec;
  endfunction

  function automatic EXECUTE fn_icall (input DECODE de);
    fn_icall         = fn_nop(de);
    fn_icall.pc      = de.sr.intr_vec;
    fn_icall.intr_pc = de.sr.pc;
    fn_icall.intr_en = 1'b0;
  endfunction

  function automatic EXECUTE fn_iret (input DECODE de);
    fn_iret         = fn_nop(de);
    fn_iret.pc      = de.sr.intr_pc;
    fn_iret.intr_en = 1'b1;
  endfunction

  function automatic EXECUTE fn_halt (input DECODE de);
    fn_halt    = fn_nop(de);
    fn_halt.pc = de.sr.pc;
  endfunction
endpackage
`endif
