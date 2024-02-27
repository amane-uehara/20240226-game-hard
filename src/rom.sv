module rom #(parameter FILENAME) (
  input  logic        clk,
  input  logic  [8:0] addr,
  output logic [31:0] r_data
);
  logic [31:0] mem [511:0];
  logic  [8:0] addr_reg;

  assign r_data = mem[addr_reg];

  always @(posedge clk) begin
    addr_reg <= addr;
  end

  initial $readmemh(FILENAME, mem);
endmodule
