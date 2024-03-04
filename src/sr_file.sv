`include "lib_cpu.sv"

module sr_file import lib_cpu :: *; (
  input  logic        clk, reset, w_en,
  input  logic        irr,
  input  logic [31:0] w_busy,
  input  logic [31:0] r_data,
  input  EXECUTE      ex,
  output SPECIAL_REG  sr
);
  always_ff @(posedge clk) begin
    if (reset) begin
      sr         <= '0;
    end else if (w_en) begin
      sr.pc      <= ex.pc;
      sr.irr     <= irr;
      sr.intr_en <= ex.intr_en;
      sr.w_busy  <= w_busy;
      sr.r_data  <= r_data;
    end
  end
endmodule
