module test_top ();
  logic clk;

  localparam CLOCK_PERIOD = 10;
  always #(CLOCK_PERIOD/2) clk <= ~clk;
  initial clk = 1'b0;

  logic [31:0] tb1_pass, tb1_fail;
  tb1 tb1(.pass(tb1_pass), .fail(tb1_fail));

  logic [31:0] tb2_pass, tb2_fail;
  tb2 tb2(.pass(tb2_pass), .fail(tb2_fail));

  logic [31:0] total_pass, total_fail;
  assign total_pass = tb1_pass + tb2_pass;
  assign total_fail = tb1_fail + tb2_fail;

  initial begin
    #(CLOCK_PERIOD*100);
    $display("TOTAL PASS: %d", total_pass);
    $display("TOTAL FAIL: %d", total_fail);
    $finish;
  end
endmodule
