`include "test_package.sv"

module tb_int_uart_tx();
  import test_package :: *;

  logic clk, reset, uart_rx, uart_tx;
  test_clock test_clock(clk);
  initial uart_rx = 1'b1; // no signal

  mother_board #(.WAIT(WAIT), .FILENAME("")) mother_board(.*);

  task automatic task_reset();
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
  endtask

  // uart task
  task automatic task_check_uart_1bit(input int line_number, input logic e, input logic a);
    fn_expected_actual_check(`__FILE__, line_number, {31'd0, e}, {31'd0, a});
    fn_expected_actual_check(`__FILE__, line_number, 32'd1, {31'd0, mother_board.transmitter.busy});
    #(WAIT*CLOCK_PERIOD-1);
    fn_expected_actual_check(`__FILE__, line_number, {31'd0, e}, {31'd0, a});
    fn_expected_actual_check(`__FILE__, line_number, 32'd1, {31'd0, mother_board.transmitter.busy});
    #1;
  endtask

  task automatic task_uart_tx(input logic [7:0] data);
    task_check_uart_1bit(`__LINE__, 1'b0, uart_tx);
    task_check_uart_1bit(`__LINE__, data[0], uart_tx);
    task_check_uart_1bit(`__LINE__, data[1], uart_tx);
    task_check_uart_1bit(`__LINE__, data[2], uart_tx);
    task_check_uart_1bit(`__LINE__, data[3], uart_tx);
    task_check_uart_1bit(`__LINE__, data[4], uart_tx);
    task_check_uart_1bit(`__LINE__, data[5], uart_tx);
    task_check_uart_1bit(`__LINE__, data[6], uart_tx);
    task_check_uart_1bit(`__LINE__, data[7], uart_tx);
    task_check_uart_1bit(`__LINE__, 1'b1, uart_tx);
  endtask

  logic [15:0][31:0] x;
  assign x = mother_board.cpu.gr_file.x;

  logic [($size(mother_board.cpu.mem_file.mem)-1):0][31:0] mem;
  assign mem = mother_board.cpu.mem_file.mem;

  int i;
  initial begin
    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h05A___0___0___1___0___0; // x[1] = 0x8F
    mother_board.rom.mem[i++] = 32'h000___0___1___0___0___7; // io(0) = x[1]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset();

    // before send
    #(PERIOD_PER_INSTRUCT*2);
    `check32(32'd1, {31'd0, uart_tx});
    `check32(32'd0, {31'd0, mother_board.transmitter.busy});

    #1;

    // sending
    task_uart_tx(8'h5A);

    // after send
    `check32(32'd1, {31'd0, uart_tx});
    `check32(32'd0, {31'd0, mother_board.transmitter.busy});
  end
endmodule
