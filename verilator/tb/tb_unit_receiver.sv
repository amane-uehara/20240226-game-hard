`include "test_package.sv"

module tb_unit_receiver ();
  import test_package :: *;

  logic clk, reset, uart_rx, update;
  logic [7:0] data;

  test_clock test_clock(clk);
  receiver #(.WAIT(WAIT)) receiver (.*);

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

  initial begin
    task_reset();
    task_uart_rx(8'h8F);
  end

  initial begin
    #RESET_PERIOD;
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(WAIT*CLOCK_PERIOD/2);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h0, {24'd0, data});

    #(CLOCK_PERIOD);
    `check32(32'b1, {31'd0, update});
    `check32(32'h8F, {24'd0, data});

    #(CLOCK_PERIOD);
    `check32(32'b0, {31'd0, update});
    `check32(32'h8F, {24'd0, data});
  end
endmodule
