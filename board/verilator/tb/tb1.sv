module tb1 (
  output logic [31:0] pass,
  output logic [31:0] fail
);
  localparam CLOCK_PERIOD = 10;
  localparam FILENAME = "../mem/rom.mem";

  logic clk;
  always #(CLOCK_PERIOD/2) clk <= ~clk;
  initial clk = 1'b0;

  logic [10:0] addr;
  logic [31:0] data;
  rom #(.FILENAME(FILENAME)) rom (
    .clk,
    .addr,
    .data
  );

  int test_count = 0;
  int fail_count = 0;
  int pass_count = 0;

  function void check_function(input logic [10:0] in_addr, input logic [31:0] expected);
    begin
      addr = in_addr;
      #20;
      check($sformatf("Test Case [%s] %1d", `__FILE__, test_count), expected, data);
      test_count++;
    end
  endfunction

  task check(string name, logic [31:0] expected, logic [31:0] actual);
    if (expected !== actual) begin
      $display("%s: FAILED - Expected %1d, Got %1d", name, expected, actual);
      fail_count++;
    end else begin
      $display("%s: PASSED", name);
      pass_count++;
    end
  endtask

  initial begin
    rom.mem[0] = 32'd3;
    rom.mem[1] = 32'd4;
    rom.mem[2] = 32'd5;
    check_function(11'd1, 32'd4);

    rom.mem[0] = 32'd6;
    rom.mem[1] = 32'd7;
    rom.mem[2] = 32'd8;
    check_function(11'd2, 32'd8);

    rom.mem[0] = 32'd9;
    rom.mem[1] = 32'd10;
    rom.mem[2] = 32'd11;
    check_function(11'd2, 32'd7);

    pass = pass_count;
    fail = fail_count;
  end
endmodule
