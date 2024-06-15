`include "test_package.sv"

module test_top ();
  import test_package :: *;
  tb1 tb1;
  tb2 tb2;
  tb_int_uart_rx tb_int_uart_rx;
  tb_int_uart_tx tb_int_uart_tx;

  initial begin
    #(CLOCK_PERIOD*10000);
    fn_show_total_result();
    $finish;
  end
endmodule
