`include "test_package.sv"

module tb_int_cpu_jump ();
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

  logic [($size(mother_board.cpu.mem_file.mem)-1):0][31:0] mem;
  assign mem = mother_board.cpu.mem_file.mem;

  int i;
  initial begin
    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___2___3___0___0; // addi ---- x[3] = x[2] + 4
    mother_board.rom.mem[i++] = 32'h000___0___3___4___0___2; // jalr ---- x[4] = pc + 4; pc = x[3]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h009___0___0___2___0___0; // addi ---- x[2] = x[0] + 9
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd3, x[4]);
    `check32(32'd9, x[2]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___2___3___0___0; // addi ---- x[3] = x[2] + 4
    mother_board.rom.mem[i++] = 32'h000___0___3___0___0___3; // jeq  ---- if opt(x[0]) {pc = x[3]}
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h009___0___0___2___0___0; // addi ---- x[2] = x[0] + 9
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd9, x[2]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___2___3___0___0; // addi ---- x[3] = x[2] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___0___0___3; // jeq  ---- if opt(x[2]) {pc = x[3]}
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    mother_board.rom.mem[i++] = 32'h009___0___0___2___0___0; // addi ---- x[2] = x[0] + 9
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd3, x[2]);
  end
endmodule