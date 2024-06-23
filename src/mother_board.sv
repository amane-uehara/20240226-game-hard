module mother_board #(parameter WAIT, FILENAME) (
  input  logic clk, reset,
  input  logic uart_rx,
  output logic uart_tx
);
  logic [7:0] rx_data;
  logic rx_update;
  receiver #(.WAIT(WAIT)) receiver (
    .clk, .reset,
    .uart_rx,
    .update(rx_update),
    .data(rx_data)
  );

  logic [7:0] tx_data;
  logic tx_req, tx_busy;
  transmitter #(.WAIT(WAIT)) transmitter (
    .clk, .reset,
    .uart_tx,
    .send_req(tx_req),
    .data(tx_data),
    .busy(tx_busy)
  );

  logic irr;
  logic ack;
  uart_intr uart_intr (
    .clk, .reset,
    .rx_update,
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
    .irr, .ack, .rx_data,
    .tx_req, .tx_data, .tx_busy
  );
endmodule
