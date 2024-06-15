`include "test_package.sv"

module tb_int_cpu_calc ();
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
    // ----------------------------------------------------------------------------------------------------
    // x[3] = 3 `calc_i` 1
    // ----------------------------------------------------------------------------------------------------

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___0___0; // addi ---- x[3] = x[2] + 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd4, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___1___0; // subi ---- x[3] = x[2] - 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd2, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___2___0; // slli ---- x[3] = x[2] << 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd6, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___3___0; // srli ---- x[3] = x[2] >> 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd1, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___4___0; // srai ---- x[3] = x[2] >>> 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd1, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___5___0; // andi ---- x[3] = x[2] & 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd1, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___6___0; // ori  ---- x[3] = x[2] | 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd3, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h001___0___2___3___7___0; // xori ---- x[3] = x[2] ^ 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd2, x[3]);

    // ----------------------------------------------------------------------------------------------------
    // x[3] = 5 `calc_i` 6
    // ----------------------------------------------------------------------------------------------------

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___0___0; // addi ---- x[3] = x[2] + 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd11, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___1___0; // subi ---- x[3] = x[2] - 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'hFFFFFFFF, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___2___0; // slli ---- x[3] = x[2] << 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd320, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___3___0; // srli ---- x[3] = x[2] >> 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd0, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___4___0; // srai ---- x[3] = x[2] >>> 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd0, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___5___0; // andi ---- x[3] = x[2] & 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd4, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___6___0; // ori  ---- x[3] = x[2] | 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd7, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h005___0___0___2___0___0; // addi ---- x[2] = x[0] + 5
    mother_board.rom.mem[i++] = 32'h006___0___2___3___7___0; // xori ---- x[3] = x[2] ^ 6
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd3, x[3]);

    // ----------------------------------------------------------------------------------------------------
    // x[3] = -6 `calc_i` 1
    // ----------------------------------------------------------------------------------------------------

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___0___0; // addi ---- x[3] = x[2] + 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(-32'd5, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___1___0; // subi ---- x[3] = x[2] - 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(-32'd7, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___2___0; // slli ---- x[3] = x[2] << 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(-32'd12, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___3___0; // srli ---- x[3] = x[2] >> 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'h7FFFFFFD, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___4___0; // srai ---- x[3] = x[2] >>> 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'hFFFFFFFD, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___5___0; // andi ---- x[3] = x[2] & 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd0, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___6___0; // ori  ---- x[3] = x[2] | 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'hFFFFFFFB, x[3]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h006___0___0___2___0___0; // addi ---- x[2] = x[0] + 6
    mother_board.rom.mem[i++] = 32'h000___2___0___2___1___1; // sub  ---- x[2] = x[0] - x[2]
    mother_board.rom.mem[i++] = 32'h001___0___2___3___7___0; // xori ---- x[3] = x[2] ^ 1
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'hFFFFFFFB, x[3]);

    // ----------------------------------------------------------------------------------------------------
    // x[4] = 4 `calc_r` 3
    // ----------------------------------------------------------------------------------------------------

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___0___1; // add  ---- x[4] = x[3] + x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd7, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___1___1; // sub  ---- x[4] = x[3] - x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'h1, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___2___1; // sll  ---- x[4] = x[3] << x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd32, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___3___1; // srl  ---- x[4] = x[3] >> x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd0, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___4___1; // sra  ---- x[4] = x[3] >>> x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd0, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___5___1; // and  ---- x[4] = x[3] & x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd0, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___6___1; // or   ---- x[4] = x[3] | x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd7, x[4]);

    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h003___0___0___2___0___0; // addi ---- x[2] = x[0] + 3
    mother_board.rom.mem[i++] = 32'h004___0___0___3___0___0; // addi ---- x[3] = x[0] + 4
    mother_board.rom.mem[i++] = 32'h000___2___3___4___7___1; // xor  ---- x[4] = x[3] ^ x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___A; // halt
    task_reset_wait(i);
    `check32(32'd7, x[4]);
  end
endmodule
