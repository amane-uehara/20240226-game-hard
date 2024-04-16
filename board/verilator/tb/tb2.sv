`include "test_package.sv"

module tb2 ();
  import test_package :: *;

  logic clk, reset, uart_rx, uart_tx;
  test_clock test_clock(clk);
  assign uart_rx = 1'b1; // no signal

  mother_board #(.WAIT(8), .FILENAME("")) mother_board(.*);

  function void check(
    input int line_number,
    input logic [31:0] expected,
    input logic [31:0] actual
  );
    fn_expected_actual_check(`__FILE__, line_number, expected, actual);
  endfunction

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
    mother_board.rom.mem[i++] = 32'h001___0___0___1___0___0; // addi ---- x[1] = x[0] + 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    check(`__LINE__, 32'd1, x[1]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___0___0; // addi ---- x[3] = x[2] + 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    check(`__LINE__, 32'd4, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___0___0; // addi ---- x[3] = x[2] + 1
    mother_board.rom.mem[i++] = 32'h000___2___3___4___0___1; // add  ---- x[4] = x[3] + x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    check(`__LINE__, 32'd7, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___2___3___0___0; // addi ---- x[3] = x[2] + 4
    mother_board.rom.mem[i++] = 32'h000___3___2___0___0___5; // sw   ---- mem[x[2]] = x[3]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    check(`__LINE__, 32'd7, mem[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___2___3___0___0; // addi ---- x[3] = x[2] + 4
    mother_board.rom.mem[i++] = 32'h000___3___2___0___0___5; // sw   ---- mem[x[2]] = x[3]
    mother_board.rom.mem[i++] = 32'h000___0___2___4___0___4; // lw   ---- x[4] = mem[x[2]]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    check(`__LINE__, 32'd7, x[4]);

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
    check(`__LINE__, 32'd3, x[4]);
    check(`__LINE__, 32'd9, x[2]);

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
    check(`__LINE__, 32'd9, x[2]);

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
    check(`__LINE__, 32'd3, x[2]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h000___0___0___1___0___0; // addi ---- x[1] = x[0] + 0
    mother_board.rom.mem[i++] = 32'h001___0___0___2___0___0; // addi ---- x[2] = x[0] + 1
    mother_board.rom.mem[i++] = 32'h003___2___1___0___0___8; // w_intr -- intr[x[1]] = x[2] // intr[1] == ack
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i-1);
    check(`__LINE__, 32'b1, {31'd0, mother_board.cpu.ack});

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h001___0___0___1___0___0; // addi ---- x[1] = x[0] + 1
    mother_board.rom.mem[i++] = 32'h001___0___0___2___0___0; // addi ---- x[2] = x[0] + 1
    mother_board.rom.mem[i++] = 32'h003___2___1___0___0___8; // w_intr -- intr[x[1]] = x[2] // intr[1] == intr_en
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    check(`__LINE__, 32'b1, {31'd0, mother_board.cpu.sr.intr_en});

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h002___0___0___1___0___0; // addi ---- x[1] = x[0] + 2
    mother_board.rom.mem[i++] = 32'h007___0___0___2___0___0; // addi ---- x[2] = x[0] + 7
    mother_board.rom.mem[i++] = 32'h003___2___1___0___0___8; // w_intr -- intr[x[1]] = x[2] // intr[2] == intr_vec
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    check(`__LINE__, 32'd7, mother_board.cpu.sr.intr_vec);
  end
endmodule
