`ifndef TEST_PACKAGE_SV
`define TEST_PACKAGE_SV

package test_package;
  // parameter
  localparam CLOCK_PERIOD = 10;
  localparam CLOCK_PER_INSTRUCT = 4;
  localparam PERIOD_PER_INSTRUCT = CLOCK_PERIOD*CLOCK_PER_INSTRUCT;
  localparam RESET_PERIOD = (CLOCK_PERIOD/2*3);

  //global variable
  int total_fail_count = 0;
  int total_pass_count = 0;
  string fail_message_list[10000];
  int fail_message_list_index = 0;

  //check function
  function void fn_expected_actual_check(
    string file_name,
    int line_number,
    logic [31:0] expected,
    logic [31:0] actual
  );
    string message_tail;
    message_tail = $sformatf("%s:%0d - Expected %1d, Got %1d", file_name, line_number, expected, actual);
    if (expected !== actual) begin
      $display("FAILED %s", message_tail);
      total_fail_count++;

      fail_message_list[fail_message_list_index] = message_tail;
      fail_message_list_index++;
    end else begin
      $display("PASSED %s", message_tail);
      total_pass_count++;
    end
  endfunction

  function void fn_show_total_result();
    $display("----------------------------------------------------------------------------------------------------");
    $display("TOTAL PASS: %0d/%0d", total_pass_count, total_pass_count+total_fail_count);
    $display("TOTAL FAIL: %0d/%0d", total_fail_count, total_pass_count+total_fail_count);
    $display("----------------------------------------------------------------------------------------------------");
    $display("FAILED LIST");
    for (int i=0; i<fail_message_list_index; i++) begin
      $display("* %s", fail_message_list[i]);
    end
    $display("----------------------------------------------------------------------------------------------------");
  endfunction
endpackage

`endif