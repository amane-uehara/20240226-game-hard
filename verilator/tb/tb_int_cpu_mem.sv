`include "test_package.sv"

module tb_int_cpu_mem ();
  import test_package :: *;

  logic clk, reset, uart_rx, uart_tx;
  test_clock test_clock(clk);
  assign uart_rx = 1'b1; // no signal

  mother_board #(.WAIT(8), .FILENAME("")) mother_board(.*);

  function automatic void init_mem_restart_cpu(input [31:0] init_vals[]);
    int n = init_vals.size();
    mother_board.rom.mem = '{default: '{default: '0}};
    for (int i = 0; i < n; i++) mother_board.rom.mem[i] = init_vals[i];

    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
    #(PERIOD_PER_INSTRUCT*n);
  endfunction

  logic [15:0][31:0] x;
  assign x = mother_board.cpu.reg_file.x;

  initial begin
    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h003___0___0___1___0___0 // addi ---- x[1] = x[0] + 3
      , 32'h004___0___0___2___0___0 // addi ---- x[2] = x[0] + 4
      , 32'h000___2___1___0___0___5 // sw   ---- mem[x[1]] = x[2]
      , 32'h000___0___1___3___0___4 // lw   ---- x[3] = mem[x[1]]
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd3, x[1]);
    `check32(32'd4, x[2]);
    `check32(32'd4, x[3]);

    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h003___0___0___1___0___0 // addi ---- x[1] = x[0] + 3
      , 32'h004___0___0___2___0___0 // addi ---- x[2] = x[0] + 4
      , 32'h002___0___0___3___0___0 // addi ---- x[3] = x[0] + 2
      , 32'h000___2___1___0___0___5 // sw   ---- mem[x[1]] = x[2]
      , 32'h000___3___1___0___0___5 // sw   ---- mem[x[1]] = x[3]
      , 32'h000___0___1___4___0___4 // lw   ---- x[4] = mem[x[1]]
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd3, x[1]);
    `check32(32'd4, x[2]);
    `check32(32'd2, x[3]);
    `check32(32'd2, x[4]);

    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h003___0___0___1___0___0 // addi ---- x[1] = x[0] + 3
      , 32'h004___0___0___2___0___0 // addi ---- x[2] = x[0] + 4
      , 32'h002___0___0___3___0___0 // addi ---- x[3] = x[0] + 2
      , 32'h001___0___0___4___0___0 // addi ---- x[4] = x[0] + 1
      , 32'h000___3___1___0___0___5 // sw   ---- mem[x[1]] = x[3]
      , 32'h000___4___2___0___0___5 // sw   ---- mem[x[2]] = x[4]
      , 32'h000___0___1___5___0___4 // lw   ---- x[5] = mem[x[1]]
      , 32'h000___0___2___6___0___4 // lw   ---- x[6] = mem[x[2]]
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd3, x[1]);
    `check32(32'd4, x[2]);
    `check32(32'd2, x[3]);
    `check32(32'd1, x[4]);
    `check32(32'd2, x[5]);
    `check32(32'd1, x[6]);

    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h003___0___0___1___0___0 // addi ---- x[1] = x[0] + 3
      , 32'h004___0___0___2___0___0 // addi ---- x[2] = x[0] + 4
      , 32'h002___0___0___3___0___0 // addi ---- x[3] = x[0] + 2
      , 32'h001___0___0___4___0___0 // addi ---- x[4] = x[0] + 1
      , 32'h000___3___1___0___0___5 // sw   ---- mem[x[1]] = x[3]
      , 32'h000___4___2___0___0___5 // sw   ---- mem[x[2]] = x[4]
      , 32'h000___0___2___5___0___4 // lw   ---- x[5] = mem[x[2]]
      , 32'h000___0___1___6___0___4 // lw   ---- x[6] = mem[x[1]]
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd3, x[1]);
    `check32(32'd4, x[2]);
    `check32(32'd2, x[3]);
    `check32(32'd1, x[4]);
    `check32(32'd1, x[5]);
    `check32(32'd2, x[6]);
  end
endmodule
