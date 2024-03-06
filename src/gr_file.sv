`include "lib_cpu.sv"

module gr_file import lib_cpu :: *; (
  input  logic        clk, reset, w_en,
  input  logic [ 3:0] rs1, rs2, rd,
  input  logic [31:0] x_rd,
  output logic [31:0] x_rs1, x_rs2
);
  logic [15:0][31:0] x, next_x;

  always_comb begin
    next_x = x;
    if (w_en) begin
      next_x[rd] = x_rd;
    end
  end

  always_ff @(posedge clk) begin
    if (reset) x <= '0;
    else       x <= next_x;
  end

  assign x_rs1 = x[rs1];
  assign x_rs2 = x[rs2];
endmodule
