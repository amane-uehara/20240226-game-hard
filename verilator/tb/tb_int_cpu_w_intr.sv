`include "test_package.sv"

module tb_int_cpu_w_intr ();
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
        32'h001___0___0___1___0___0 // addi ---- x[1] = x[0] + 1
      , 32'h001___0___1___0___0___8 // w_intr -- intr[1] = x[1] // intr[1] == intr_en
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'b1, {31'd0, mother_board.cpu.state.intr_en});

    init_mem_restart_cpu('{
        //  imm  rs2 rs1 rd  opt opcode
        32'h007___0___0___1___0___0 // addi ---- x[1] = x[0] + 7
      , 32'h002___0___1___0___0___8 // w_intr -- intr[2] = x[1] // intr[2] == intr_vec
      , 32'h000___0___0___0___0___A // halt
    });
    `check32(32'd7, mother_board.cpu.state.intr_vec);
  end
endmodule
