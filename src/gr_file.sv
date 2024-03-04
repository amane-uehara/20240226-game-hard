`include "lib_cpu.sv"

module gr_file import lib_cpu :: *; (
  input  logic       clk, reset, w_en,
  input  logic [4:0] rs1, rs2, rd,
  input  EXECUTE     ex,
  output GENERAL_REG gr
);
  logic [15:0][31:0] x;
  logic [63:0][31:0] mem;

  always_ff @(posedge clk) begin
    if (reset) begin
      x <= '0;
    end else if (w_en) begin
      x[rd] <= x_rd;
      mem[ex.mem_addr] <= ex.mem_val;
    end
  end
endmodule
