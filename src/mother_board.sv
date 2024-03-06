module mother_board #(parameter WAIT, FILENAME) (
  input  logic clk, reset,
  input  logic uart_rx,
  output logic uart_tx
);
  logic [7:0] uart_r_data;
  logic uart_update;
  receiver #(.WAIT(WAIT)) receiver (
    .clk, .reset,
    .uart_rx,
    .update(uart_update),
    .data(uart_r_data)
  );

  logic [7:0] uart_w_data;
  logic uart_w_req, uart_busy;
  transmitter #(.WAIT(WAIT)) transmitter (
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
    .uart_update,
    .ack,
    .irr
  );

  logic [10:0] rom_addr;
  logic [31:0] rom_data;
  rom #(.FILENAME(FILENAME)) rom (
    .clk,
    .addr(rom_addr),
    .data(rom_data)
  );

  cpu cpu (
    .clk, .reset,
    .rom_addr, .rom_data,
    .irr, .ack, .r_data(uart_r_data),
    .w_req(uart_w_req), .w_data(uart_w_data), .w_busy(uart_busy)
  );
endmodule
