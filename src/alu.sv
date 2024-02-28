`include "lib_cpu.sv"

module alu import lib_cpu :: *; (
  output EXECUTE ex
  input  DECODE  de
);

  always_comb begin
    ex.pc = de.pc + 32'd4;
    ex.w_req = 1'b0;
    ex.w_data = 32'd0;
    ex.ack = 1'b0;
    ex.rd = de.rd;
    ex.x_rd = de.x_rd;
    ex.addr_4byte = de.addr_4byte;
    ex.mem_val = de.mem_val;
    ex.intr_en = de.intr_en;
  end
endmodule
