`ifndef TEST_PACKAGE_SV
`define TEST_PACKAGE_SV

`define check32(E,A) fn_expected_actual_check_32bit(`__FILE__, `__LINE__, E, A)
`define check1(E,A) fn_expected_actual_check_1bit(`__FILE__, `__LINE__, E, A)

package test_package;
  // parameter
  localparam CLOCK_PERIOD = 10;
  localparam CLOCK_PER_INSTRUCT = 5;
  localparam PERIOD_PER_INSTRUCT = CLOCK_PERIOD*CLOCK_PER_INSTRUCT;
  localparam RESET_PERIOD = (CLOCK_PERIOD/2*3);
  localparam WAIT = 8; // uart wait


  //global variable
  string fail_message_list[];
  int total_fail_count_dict[string];
  int total_pass_count_dict[string];
  int file_name_dict[string];

  //check function
  function void fn_expected_actual_check_32bit(
    string file_name,
    int line_number,
    logic [31:0] expected,
    logic [31:0] actual
  );
    string message_tail;
    message_tail = $sformatf("%s:%0d - Expected %1d, Got %1d", file_name, line_number, expected, actual);
    file_name_dict[file_name] = 1;
    if (expected !== actual) begin
      total_fail_count_dict[file_name] += 1;
      fail_message_list = {fail_message_list, message_tail};
    end else begin
      total_pass_count_dict[file_name] += 1;
    end
  endfunction

  function void fn_expected_actual_check_1bit(
    string file_name,
    int line_number,
    logic expected,
    logic actual
  );
    fn_expected_actual_check_32bit(file_name, line_number, {31'd0, expected}, {31'd0, actual});
  endfunction

  function void fn_show_total_result();
    string sorted_keys[];
    int total_pass_count;
    int total_fail_count;
    total_pass_count = 0;
    total_fail_count = 0;

    $display("----------------------------------------------------------------------------------------------------");
    foreach (file_name_dict[key]) sorted_keys = {sorted_keys, key};
    sorted_keys.sort();

    foreach (sorted_keys[i]) begin
      if (total_fail_count_dict.exists(sorted_keys[i]) == 0) $write("O   ");
      else $write("X   ");
      $display("%-30s %3d/ %3d"
         , sorted_keys[i]
         , total_pass_count_dict[sorted_keys[i]]
         , total_pass_count_dict[sorted_keys[i]] + total_fail_count_dict[sorted_keys[i]]
      );

      total_pass_count += total_pass_count_dict[sorted_keys[i]];
      total_fail_count += total_fail_count_dict[sorted_keys[i]];
    end

    if (total_fail_count == 0) $write("O   ");
    else $write("X   ");
    $display("%-30s %3d/ %3d"
       , "--- TOTAL ---"
       , total_pass_count
       , total_pass_count+total_fail_count
    );

    $display("----------------------------------------------------------------------------------------------------");
    if ($size(fail_message_list) == 0) begin
      $display("ALL TESTS PASSED");
    end else begin
      $display("FAILED LIST");
      foreach (fail_message_list[i]) begin
        $display("* %s", fail_message_list[i]);
      end
    end
    $display("----------------------------------------------------------------------------------------------------");
  endfunction
endpackage

`endif
