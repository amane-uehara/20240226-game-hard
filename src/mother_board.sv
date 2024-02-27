module mother_board (
  input  logic clk, reset,
  input  logic uart_rx,
  output logic uart_tx
);
  logic [7:0] uart_r_data;
  logic uart_update;
  receiver receiver (
    .clk, .reset,
    .uart_rx,
    .update(uart_update),
    .data(uart_r_data)
  );

  logic [7:0] uart_w_data;
  logic uart_w_req, uart_busy;
  transmitter transmitter (
    .clk, .reset,
    .uart_tx,
    .send_req(uart_w_req),
    .data(uart_w_data),
    .busy(uart_busy)
  );

  logic irr;
  logic ack;
  uart_intr uart_intr (
    .clk, .reset,
    .uart_update, .ack, .irr
  );

  logic [8:0]  addr;
  logic [31:0] rom_data;
  rom rom (
    .clk, .addr,
    .data(rom_data)
  );

  cpu cpu (
    .clk, .reset,
    .rom_addr, .rom_data,
    .uart_w_req, .uart_w_data, .uart_busy,
    .irr, .ack, .uart_r_data
  );
endmodule
