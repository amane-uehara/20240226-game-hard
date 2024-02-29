`include "lib_cpu.sv"

module reg_file import lib_cpu :: *; (
  input  logic     clk, reset, w_en,
  output REGISTERS regs,
  input  EXECUTE   ex
);
  always_ff @(posedge clk) begin
    if (reset) begin
      regs.pc <= 32'd0;
      regs.x <= '0;
      regs.intr_en <= 1'b0;
    end else if (w_en) begin
      regs.pc <= ex.pc;
      regs.x[ex.rd] <= ex.x_rd;
      regs.mem[ex.mem_index] <= ex.mem_val;
      regs.intr_en <= ex.intr_en;
    end
  end
endmodule
