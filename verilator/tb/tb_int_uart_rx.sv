`include "test_package.sv"

module tb_int_uart_rx ();
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
  task automatic task_uart_rx(input logic [7:0] tmp);
    uart_rx = 1'b0;   #(WAIT*CLOCK_PERIOD); // start bit
    uart_rx = tmp[0]; #(WAIT*CLOCK_PERIOD);
    uart_rx = tmp[1]; #(WAIT*CLOCK_PERIOD);
    uart_rx = tmp[2]; #(WAIT*CLOCK_PERIOD);
    uart_rx = tmp[3]; #(WAIT*CLOCK_PERIOD);
    uart_rx = tmp[4]; #(WAIT*CLOCK_PERIOD);
    uart_rx = tmp[5]; #(WAIT*CLOCK_PERIOD);
    uart_rx = tmp[6]; #(WAIT*CLOCK_PERIOD);
    uart_rx = tmp[7]; #(WAIT*CLOCK_PERIOD);
    uart_rx = 1'b1;   #(WAIT*CLOCK_PERIOD); // stop bit
  endtask

  logic [15:0][31:0] x;
  assign x = mother_board.cpu.reg_file.x;

  logic [($size(mother_board.cpu.mem_file.mem)-1):0][31:0] mem;
  assign mem = mother_board.cpu.mem_file.mem;

  task test_task_uart_receive;
    task_reset();
    task_uart_rx(8'h8F);
    `check32(32'h8F, {24'd0, mother_board.cpu.rx_data});
    `check32(32'b1, {31'd0, mother_board.cpu.irr});
  endtask

  task task_rom_intr(output int end_addr);
    int i;
    i = 0; //                       imm  rs2 rs1 rd  opt opcode
    mother_board.rom.mem[i++] = 32'h007___0___0___1___0___0; // 0x0            | x[1] = label_trap
    mother_board.rom.mem[i++] = 32'h002___0___1___0___0___8; // 0x1            | intr(2) = x[1]
    mother_board.rom.mem[i++] = 32'h001___0___0___2___0___0; // 0x2            | x[2] = 1
    mother_board.rom.mem[i++] = 32'h001___0___2___0___0___8; // 0x3            | intr(1) = x[2]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___a; // 0x4            | halt()
    mother_board.rom.mem[i++] = 32'h006___0___0___3___0___0; // 0x5 unreach    | x[3] = 6
    mother_board.rom.mem[i++] = 32'h000___0___3___0___0___3; // 0x6 unreach    | pc = x[3]
    mother_board.rom.mem[i++] = 32'h001___0___0___4___0___6; // 0x7 label_trap | x[4] = io(1)
    mother_board.rom.mem[i++] = 32'h001___0___0___5___0___0; // 0x8            | x[5] = 1
    mother_board.rom.mem[i++] = 32'h000___0___5___0___0___8; // 0x9            | intr(0) = x[5]
    mother_board.rom.mem[i++] = 32'h000___0___0___0___0___9; // 0xa            | iret()
    mother_board.rom.mem[i++] = 32'h00d___0___0___6___0___0; // 0xb unreach    | x[6] = 0xd
    mother_board.rom.mem[i++] = 32'h000___0___6___0___0___3; // 0xc unreach    | pc = x[6]
    end_addr = i;
  endtask

  task test_task_uart_intr_ack_on;
    int end_addr;
    task_rom_intr(end_addr);
    task_reset();
    task_uart_rx(8'h8F);
    #(PERIOD_PER_INSTRUCT*end_addr);

    `check32(32'd7, x[1]);
    `check32(32'd1, x[2]);
    `check32(32'd0, x[3]);
    `check32(32'h8F, x[4]);
    `check32(32'd1, x[5]);
    `check32(32'd0, x[6]);
    `check32(32'h8F, {24'd0, mother_board.cpu.rx_data});
    `check32(32'b0, {31'd0, mother_board.cpu.irr});

    #(PERIOD_PER_INSTRUCT*4);
    `check32(32'd0, x[3]);
    `check32(32'd0, x[6]);
  endtask

  task test_task_uart_intr_ack_off;
    int end_addr;
    task_rom_intr(end_addr);
    mother_board.rom.mem[8] = 32'h0; // (intr(0) = 1) -> (intr(0) = 0)

    task_reset();
    task_uart_rx(8'h8F);
    #(PERIOD_PER_INSTRUCT*end_addr);

    `check32(32'd7, x[1]);
    `check32(32'd1, x[2]);
    `check32(32'd0, x[3]);
    `check32(32'h8F, x[4]);
    `check32(32'd0, x[5]); // ack off
    `check32(32'd0, x[6]);
    `check32(32'h8F, {24'd0, mother_board.cpu.rx_data});
    `check32(32'b1, {31'd0, mother_board.cpu.irr}); // ack off

    #(PERIOD_PER_INSTRUCT*4);
    `check32(32'd0, x[3]);
    `check32(32'd0, x[6]);
  endtask

  task test_task_uart_intr_off;
    int end_addr;
    task_rom_intr(end_addr);
    mother_board.rom.mem[2] = 32'h0; // (intr(1) = 1) -> (intr(1) = 0)

    task_reset();
    task_uart_rx(8'h8F);
    #(PERIOD_PER_INSTRUCT*end_addr);

    `check32(32'd7, x[1]);
    `check32(32'd0, x[2]); // intr off
    `check32(32'd0, x[3]);
    `check32(32'd0, x[4]); // io unreach
    `check32(32'd0, x[5]); // ack unreach
    `check32(32'd0, x[6]);
    `check32(32'h8F, {24'd0, mother_board.cpu.rx_data});
    `check32(32'b1, {31'd0, mother_board.cpu.irr}); // ack unreach

    #(PERIOD_PER_INSTRUCT*4);
    `check32(32'd0, x[3]);
    `check32(32'd0, x[6]);
  endtask

  initial begin
    test_task_uart_receive;
    test_task_uart_intr_ack_on;
    test_task_uart_intr_ack_off;
    test_task_uart_intr_off;
  end
endmodule
