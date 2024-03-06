module top (
  input  logic clk,
  input  logic n_reset,
  output logic uart_tx,
  input  logic uart_rx
);
  logic tmp_reset, syn_reset;
  always_ff @(posedge clk) tmp_reset <= ~n_reset;
  always_ff @(posedge clk) syn_reset <= tmp_reset;

  logic tmp_uart_rx, syn_uart_rx;
  always_ff @(posedge clk) tmp_uart_rx <= uart_rx;
  always_ff @(posedge clk) syn_uart_rx <= tmp_uart_rx;

  /* CLOCK:27MHz, UART_BAUD_RATE:115200 ROM:2KiB */
  localparam CLOCK_HZ       = 27_000_000;
  localparam UART_BAUD_RATE = 115200;
  localparam FILENAME       = "../../mem/rom.mem";

  mother_board #(
    .WAIT(CLOCK_HZ/UART_BAUD_RATE),
    .FILENAME(FILENAME)
  ) mother_board (
    .clk,
    .reset(syn_reset),
    .uart_tx,
    .uart_rx(syn_uart_rx)
  );
endmodule
