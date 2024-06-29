`include "test_package.sv"

module test_wave ();
  import test_package :: *;

  logic clk, reset, uart_rx, uart_tx;
  test_clock test_clock(clk);
  assign uart_rx = 1'b1; // no signal

  localparam FILENAME = "../mem/rom.mem";
  mother_board #(
    .WAIT(WAIT),
    .FILENAME(FILENAME)
  ) mother_board (.*);

  initial begin
    $dumpfile({"./wave/", `__FILE__, ".vcd"});
    $dumpvars(0, mother_board);
  end

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
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
  end

  initial begin
    for(;;) begin
      $display("Current time = %t", $realtime);
      #(WAIT*CLOCK_PERIOD);
    end
  end

  initial begin
    #(WAIT*CLOCK_PERIOD*50);
    $finish();
  end
endmodule
