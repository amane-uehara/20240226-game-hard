`include "test_package.sv"

module test_top ();
  import test_package :: *;
  tb_unit_rom         tb_unit_rom;
  tb_unit_transmitter tb_unit_transmitter;
  tb_int_cpu_calc     tb_int_cpu_calc;
  tb_int_cpu_mem      tb_int_cpu_mem;
  tb_int_cpu_jump     tb_int_cpu_jump;
  tb_int_cpu_w_intr   tb_int_cpu_w_intr;
  tb_int_cpu_ack      tb_int_cpu_ack;
  tb_int_uart_rx      tb_int_uart_rx;
  tb_int_uart_tx      tb_int_uart_tx;

  initial begin
    #(CLOCK_PERIOD*10000);
    fn_show_total_result();
    $finish;
  end
endmodule
