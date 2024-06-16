`include "test_package.sv"

module tb_int_cpu_jump ();
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
  assign x = mother_board.cpu.gr_file.x;

  initial begin
    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h003___0___0___2___0___0 // addi ---- x[2] = x[0] + 3
      , 32'h004___0___2___3___0___0 // addi ---- x[3] = x[2] + 4
      , 32'h000___0___3___4___0___2 // jalr ---- x[4] = pc + 4; pc = x[3]
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h009___0___0___2___0___0 // addi ---- x[2] = x[0] + 9
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd3, x[4]);
    `check32(32'd9, x[2]);

    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h003___0___0___2___0___0 // addi ---- x[2] = x[0] + 3
      , 32'h004___0___2___3___0___0 // addi ---- x[3] = x[2] + 4
      , 32'h000___0___3___0___0___3 // jeq  ---- if opt(x[0]) {pc = x[3]}
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h009___0___0___2___0___0 // addi ---- x[2] = x[0] + 9
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd9, x[2]);

    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h003___0___0___2___0___0 // addi ---- x[2] = x[0] + 3
      , 32'h004___0___2___3___0___0 // addi ---- x[3] = x[2] + 4
      , 32'h000___2___3___0___0___3 // jeq  ---- if opt(x[2]) {pc = x[3]}
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h000___0___0___0___0___A // halt
      , 32'h009___0___0___2___0___0 // addi ---- x[2] = x[0] + 9
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd3, x[2]);
  end
endmodule
