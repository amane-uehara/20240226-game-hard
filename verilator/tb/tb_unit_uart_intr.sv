`include "test_package.sv"

module tb_unit_uart_intr();
  import test_package :: *;

  logic clk, reset, rx_update, ack, irr;
  uart_intr uart_intr (.*);

  test_clock test_clock(clk);

  initial begin
    reset = 1'b1;
    #RESET_PERIOD;
    reset = 1'b0;
  end

  initial begin
    ack = 1'b0;
    rx_update = 1'b0;
    #RESET_PERIOD;
    #RESET_PERIOD;
    `check1(1'b0, irr);

    ack = 1'b1;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);

    ack = 1'b0;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);

    ack = 1'b0;
    rx_update = 1'b1;
    #CLOCK_PERIOD; `check1(1'b1, irr);
    #CLOCK_PERIOD; `check1(1'b1, irr);
    #CLOCK_PERIOD; `check1(1'b1, irr);
    #CLOCK_PERIOD; `check1(1'b1, irr);

    ack = 1'b0;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b1, irr);
    #CLOCK_PERIOD; `check1(1'b1, irr);
    #CLOCK_PERIOD; `check1(1'b1, irr);
    #CLOCK_PERIOD; `check1(1'b1, irr);

    ack = 1'b1;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);

    ack = 1'b0;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);
    #CLOCK_PERIOD; `check1(1'b0, irr);

    ack = 1'b1;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);

    ack = 1'b0;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);

    ack = 1'b0;
    rx_update = 1'b1;
    #CLOCK_PERIOD; `check1(1'b1, irr);

    ack = 1'b0;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b1, irr);

    ack = 1'b1;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);

    ack = 1'b0;
    rx_update = 1'b0;
    #CLOCK_PERIOD; `check1(1'b0, irr);
  end
endmodule
