`include "lib_cpu.sv"

module gr_file import lib_cpu :: *; (
  input  logic        clk, reset, w_en,
  input  logic [ 3:0] rs1, rs2, rd,
  input  logic [31:0] x_rd, mem_val,
  input  logic [ 5:0] mem_addr,
  output GENERAL_REG  gr
);
  logic [15:0][31:0] x;
  logic [63:0][31:0] mem;

  always_ff @(posedge clk) begin
    if (reset) begin
      x <= '0;
    end else if (w_en) begin
      x[rd] <= x_rd;
      mem[mem_addr] <= mem_val;
    end
  end

  assign gr.x_rs1   = x[rs1];
  assign gr.x_rs2   = x[rs2];
  assign gr.mem_val = mem[mem_addr];
endmodule
