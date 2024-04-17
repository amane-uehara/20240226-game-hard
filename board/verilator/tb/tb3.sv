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

  task test_task_uart_receive;
    task_reset();
    task_uart_rx(8'h8F);
    check(`__LINE__, 32'h8F, {24'd0, mother_board.cpu.r_data});
    check(`__LINE__, 32'b1, {31'd0, mother_board.cpu.irr});
  endtask

  task task_rom_intr(output int end_addr);
    int i;
    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h002___0___0___1___0___0; // 0x0 | x[1] = 2
    mother_board.rom.mem[i++] = 32'h009___0___0___2___0___0; // 0x1 | x[2] = label_trap
    mother_board.rom.mem[i++] = 32'h000___2___1___0___0___8; // 0x2 | intr(x[1]) = x[2]
    mother_board.rom.mem[i++] = 32'h001___0___0___3___0___0; // 0x3 | x[3] = 1
    mother_board.rom.mem[i++] = 32'h001___0___0___4___0___0; // 0x4 | x[4] = 1
    mother_board.rom.mem[i++] = 32'h000___4___3___0___0___8; // 0x5 | intr(x[3]) = x[4]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___a; // 0x6 | halt()
    mother_board.rom.mem[i++] = 32'h006___0___0___5___0___0; // 0x7 | x[5] = 6   // unreach
    mother_board.rom.mem[i++] = 32'h000___0___5___0___0___3; // 0x8 | pc = x[5]  // unreach
    mother_board.rom.mem[i++] = 32'h001___0___0___6___0___0; // 0x9 | x[6] = 1   // label_trap
    mother_board.rom.mem[i++] = 32'h000___0___6___7___0___6; // 0xa | x[7] = io(x[6])
    mother_board.rom.mem[i++] = 32'h000___6___0___0___0___8; // 0xb | intr(zero) = x[6]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___9; // 0xc | iret()
    mother_board.rom.mem[i++] = 32'h00d___0___0___8___0___0; // 0xd | x[8] = 0xd // unreach
    mother_board.rom.mem[i++] = 32'h000___0___8___0___0___3; // 0xe | pc = x[8]  // unreach
    end_addr = i;
  endtask

  task test_task_uart_intr_ack_on;
    int end_addr;
    task_rom_intr(end_addr);
    task_reset();
    task_uart_rx(8'h8F);
    #(PERIOD_PER_INSTRUCT*end_addr);

    check(`__LINE__, 32'd2, x[1]);
    check(`__LINE__, 32'd9, x[2]);
    check(`__LINE__, 32'd1, x[3]);
    check(`__LINE__, 32'd1, x[4]);
    check(`__LINE__, 32'd0, x[5]);
    check(`__LINE__, 32'h1, x[6]);
    check(`__LINE__, 32'h8F, x[7]);
    check(`__LINE__, 32'd0, x[8]);
    check(`__LINE__, 32'h8F, {24'd0, mother_board.cpu.r_data});
    check(`__LINE__, 32'b0, {31'd0, mother_board.cpu.irr});

    #(PERIOD_PER_INSTRUCT*4);
    check(`__LINE__, 32'd6, x[5]);
  endtask

  task test_task_uart_intr_ack_off;
    int end_addr;
    task_rom_intr(end_addr);
    mother_board.rom.mem[11] = 32'h0; // DELETE intr(zero) = x[6]

    task_reset();
    task_uart_rx(8'h8F);
    #(PERIOD_PER_INSTRUCT*end_addr);

    check(`__LINE__, 32'd2, x[1]);
    check(`__LINE__, 32'd9, x[2]);
    check(`__LINE__, 32'd1, x[3]);
    check(`__LINE__, 32'd1, x[4]);
    check(`__LINE__, 32'd0, x[5]);
    check(`__LINE__, 32'h1, x[6]);
    check(`__LINE__, 32'h8F, x[7]);
    check(`__LINE__, 32'd0, x[8]);
    check(`__LINE__, 32'h8F, {24'd0, mother_board.cpu.r_data});
    check(`__LINE__, 32'b1, {31'd0, mother_board.cpu.irr}); // ack off
  endtask

  task test_task_uart_intr_off;
    int end_addr;
    task_rom_intr(end_addr);
    mother_board.rom.mem[4] = 32'h0; // DELETE x[4] = 1

    task_reset();
    task_uart_rx(8'h8F);
    #(PERIOD_PER_INSTRUCT*end_addr);

    check(`__LINE__, 32'd2, x[1]);
    check(`__LINE__, 32'd9, x[2]);
    check(`__LINE__, 32'd1, x[3]);
    check(`__LINE__, 32'd0, x[4]); // intr off
    check(`__LINE__, 32'd0, x[5]);
    check(`__LINE__, 32'd0, x[6]);
    check(`__LINE__, 32'd0, x[7]);
    check(`__LINE__, 32'd0, x[8]);
    check(`__LINE__, 32'h8F, {24'd0, mother_board.cpu.r_data});
    check(`__LINE__, 32'b1, {31'd0, mother_board.cpu.irr}); // ack off
  endtask

  initial begin
    test_task_uart_receive;
    test_task_uart_intr_ack_on;
    test_task_uart_intr_ack_off;
    test_task_uart_intr_off;
  end
endmodule
