`include "test_package.sv"

module test_top ();
  import test_package :: *;
  tb1 tb1;
  tb2 tb2;

  initial begin
    #(CLOCK_PERIOD*100);
    fn_show_total_result();
    $finish;
  end
endmodule
