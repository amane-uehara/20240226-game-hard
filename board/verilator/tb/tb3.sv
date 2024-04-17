`include "test_package.sv"

module tb3 ();
  import test_package :: *;

  logic clk, reset, uart_rx, uart_tx;
  test_clock test_clock(clk);
  initial uart_rx = 1'b1; // no signal

  mother_board #(.WAIT(WAIT), .FILENAME("")) mother_board(.*);

  function void check(
    input int line_number,
    input logic [31:0] expected,
    input logic [31:0] actual
  );
    fn_expected_actual_check(`__FILE__, line_number, expected, actual);
  endfunction

  task automatic task_reset();
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
  endtask

  // uart task
  task automatic task_uart_rx(input logic [7:0] data);
    uart_rx = 1'b0;    #(WAIT*CLOCK_PERIOD); // start bit
    uart_rx = data[0]; #(WAIT*CLOCK_PERIOD);
    uart_rx = data[1]; #(WAIT*CLOCK_PERIOD);
    uart_rx = data[2]; #(WAIT*CLOCK_PERIOD);
    uart_rx = data[3]; #(WAIT*CLOCK_PERIOD);
    uart_rx = data[4]; #(WAIT*CLOCK_PERIOD);
    uart_rx = data[5]; #(WAIT*CLOCK_PERIOD);
    uart_rx = data[6]; #(WAIT*CLOCK_PERIOD);
    uart_rx = data[7]; #(WAIT*CLOCK_PERIOD);
    uart_rx = 1'b1;    #(WAIT*CLOCK_PERIOD); // stop bit
  endtask

  logic [15:0][31:0] x;
  assign x = mother_board.cpu.gr_file.x;

  logic [($size(mother_board.cpu.mem_file.mem)-1):0][31:0] mem;
  assign mem = mother_board.cpu.mem_file.mem;

  int i;
  initial begin
    task_reset();
    task_uart_rx(8'h8F);
    check(`__LINE__, 32'h8F, {24'd0, mother_board.cpu.r_data});
    check(`__LINE__, 32'b1, {31'd0, mother_board.cpu.irr});
  end
endmodule
