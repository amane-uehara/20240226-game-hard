`include "test_package.sv"

module test_top ();
  import test_package :: *;
  tb1 tb1;
  tb2 tb2;
  tb3 tb3;

  initial begin
    #(CLOCK_PERIOD*10000);
    fn_show_total_result();
    $finish;
  end
endmodule
