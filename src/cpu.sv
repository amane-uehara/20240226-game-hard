module cpu (
  input  logic        clk, reset,
  output logic [31:0] rom_addr,
  input  logic [31:0] rom_data,
  output logic        uart_w_req,
  output logic [31:0] uart_w_data,
  input  logic        uart_busy,
  input  logic        irr,
  output logic        ack,
  input  logic [31:0] uart_r_data
);
endmodule
