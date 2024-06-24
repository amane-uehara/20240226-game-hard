`include "test_package.sv"

module tb_unit_transmitter();
  import test_package :: *;
  logic clk, reset;
  logic uart_tx, send_req, busy;
  logic [7:0] data;
  transmitter #(.WAIT(WAIT)) transmitter (.*);

  test_clock test_clock(clk);

  logic [7:0] const_data;
  assign const_data = 8'h5A;

  initial begin
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
    #RESET_PERIOD;

    send_req = 1'b1;
    data = const_data;
    @(posedge clk);
    @(posedge clk);
    send_req = 1'b0;
    data = 8'h0;
  end

  initial begin
    @(posedge send_req);
    @(posedge clk);

    `check1(1'b1, uart_tx);

    `check1(1'b0, busy);
    #1;
    `check1(1'b1, busy);

    `check1(1'b0         , uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(1'b0         , uart_tx); #1;
    `check1(const_data[0], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[0], uart_tx); #1;
    `check1(const_data[1], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[1], uart_tx); #1;
    `check1(const_data[2], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[2], uart_tx); #1;
    `check1(const_data[3], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[3], uart_tx); #1;
    `check1(const_data[4], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[4], uart_tx); #1;
    `check1(const_data[5], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[5], uart_tx); #1;
    `check1(const_data[6], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[6], uart_tx); #1;
    `check1(const_data[7], uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(const_data[7], uart_tx); #1;
    `check1(1'b1         , uart_tx); #(WAIT*CLOCK_PERIOD-1);
    `check1(1'b1         , uart_tx);

    `check1(1'b1, busy);
    #1;
    `check1(1'b0, busy);

    `check1(1'b1, uart_tx);
  end
endmodule
