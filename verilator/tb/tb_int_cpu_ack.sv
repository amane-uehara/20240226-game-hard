`include "test_package.sv"

module tb_int_cpu_ack ();
  import test_package :: *;

  logic clk, reset, uart_rx, uart_tx;
  test_clock test_clock(clk);
  assign uart_rx = 1'b1; // no signal

  mother_board #(.WAIT(8), .FILENAME("")) mother_board(.*);

  task automatic task_reset();
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
  endtask

  logic [15:0][31:0] x;
  assign x = mother_board.cpu.reg_file.x;

  int j;
  initial begin
    j = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[j++] = 32'h001___0___0___1___0___0; // addi ---- x[1] = x[0] + 1
    mother_board.rom.mem[j++] = 32'h000___0___1___0___0___8; // w_intr -- intr[0] = x[1] // intr[0] == ack
    mother_board.rom.mem[j++] = 32'h000___0___0___0___0___A; // halt
    task_reset();
    `check1(1'b0, mother_board.cpu.ack);

    #(PERIOD_PER_INSTRUCT*2-CLOCK_PERIOD);
    `check1(1'b0,  mother_board.cpu.ack);
    #CLOCK_PERIOD;
    `check1(1'b1,  mother_board.cpu.ack);
    #(PERIOD_PER_INSTRUCT-CLOCK_PERIOD);
    `check1(1'b1,  mother_board.cpu.ack);
    #CLOCK_PERIOD;
    `check1(1'b0,  mother_board.cpu.ack);
  end
endmodule
