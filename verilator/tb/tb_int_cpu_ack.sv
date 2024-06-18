`include "test_package.sv"

module tb_int_cpu_ack ();
  import test_package :: *;

  logic clk, reset, uart_rx, uart_tx;
  test_clock test_clock(clk);
  assign uart_rx = 1'b1; // no signal

  mother_board #(.WAIT(8), .FILENAME("")) mother_board(.*);

  task automatic task_reset_wait(input int delay_cycle);
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
    #(PERIOD_PER_INSTRUCT*delay_cycle);
  endtask

  logic [15:0][31:0] x;
  assign x = mother_board.cpu.gr_file.x;

  int j;
  initial begin
    j = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[j++] = 32'h001___0___0___1___0___0; // addi ---- x[1] = x[0] + 1
    mother_board.rom.mem[j++] = 32'h000___0___1___0___0___8; // w_intr -- intr[0] = x[1] // intr[0] == ack
    mother_board.rom.mem[j++] = 32'h000___0___0___0___0___A; // halt
    `check32(32'b0, {31'd0, mother_board.cpu.ack});
    task_reset_wait(j-1);
    `check32(32'b1, {31'd0, mother_board.cpu.ack});
    #(CLOCK_PERIOD*2);
    `check32(32'b1, {31'd0, mother_board.cpu.ack});
    #1;
    `check32(32'b0, {31'd0, mother_board.cpu.ack});
  end
endmodule
