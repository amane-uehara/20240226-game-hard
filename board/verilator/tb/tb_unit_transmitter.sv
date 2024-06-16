`include "test_package.sv"

module tb_unit_transmitter();
  import test_package :: *;
  logic clk, reset;
  logic uart_tx, send_req, busy;
  logic [7:0] data;
  transmitter #(.WAIT(8)) transmitter (.*);

  test_clock test_clock(clk);

  // uart task
  task automatic task_check_uart_1bit(input int line_number, input logic e, input logic a);
    fn_expected_actual_check(`__FILE__, line_number, {31'd0, e}, {31'd0, a});
    fn_expected_actual_check(`__FILE__, line_number, 32'd1, {31'd0, busy});
    #(WAIT*CLOCK_PERIOD-1);
    fn_expected_actual_check(`__FILE__, line_number, {31'd0, e}, {31'd0, a});
    fn_expected_actual_check(`__FILE__, line_number, 32'd1, {31'd0, busy});
    #1;
  endtask

  task automatic task_uart_tx(input logic [7:0] tmp_data);
    task_check_uart_1bit(`__LINE__, 1'b0, uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[0], uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[1], uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[2], uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[3], uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[4], uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[5], uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[6], uart_tx);
    task_check_uart_1bit(`__LINE__, tmp_data[7], uart_tx);
    task_check_uart_1bit(`__LINE__, 1'b1, uart_tx);
  endtask

  initial begin
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
    #RESET_PERIOD;

    send_req = 1'b1;
    data = 8'h5A;
    @(posedge clk);
    @(posedge clk);
    send_req = 1'b0;
    data = 8'h0;
  end

  initial begin
    @(negedge reset);
    #RESET_PERIOD;
    `check32(32'd1, {31'd0, uart_tx});
    `check32(32'd0, {31'd0, busy});
  end

  initial begin
    @(posedge send_req);
    @(posedge clk);
    #1;
    task_uart_tx(8'h5A);
    `check32(32'd1, {31'd0, uart_tx});
    `check32(32'd0, {31'd0, busy});
  end
endmodule
