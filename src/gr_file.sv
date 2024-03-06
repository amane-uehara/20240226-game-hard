`include "lib_cpu.sv"

module gr_file import lib_cpu :: *; (
  input  logic        clk, reset, w_en,
  input  logic [ 3:0] rs1, rs2, rd,
  input  logic [31:0] x_rd, mem_val,
  input  logic [ 5:0] mem_addr,
  output GENERAL_REG  gr
);
  logic [15:0][31:0] x, next_x;
  logic [63:0][31:0] mem, next_mem;

  always_comb begin
    next_x = x;
    next_mem = mem;

    if (w_en) begin
      next_x[rd] = x_rd;
      next_mem[mem_addr] = mem_val;
    end
  end

  always_ff @(posedge clk) mem <= next_mem;

  always_ff @(posedge clk) begin
    if (reset) x <= '0;
    else       x <= next_x;
  end

  assign gr.x_rs1   = x[rs1];
  assign gr.x_rs2   = x[rs2];
  assign gr.mem_val = mem[mem_addr];
endmodule
