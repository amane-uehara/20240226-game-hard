`include "lib_cpu.sv"

module mem_file import lib_cpu :: *; (
  input  logic        clk, reset, w_en,
  input  logic [31:0] w_data,
  input  logic [ 5:0] addr,
  output logic [31:0] r_data
);
  logic [63:0][31:0] mem, next_mem;

  always_comb begin
    next_mem       = mem;
    next_mem[addr] = w_data;
  end

  always_ff @(posedge clk) begin
    if (reset)     mem <= '0;
    else if (w_en) mem <= next_mem;
  end

  assign r_data = mem[addr];
endmodule
