`include "test_package.sv"

module tb_unit_rom ();
  import test_package :: *;
  logic clk;
  test_clock test_clock(clk);

  logic [10:0] addr;
  logic [31:0] data;

  rom #(.FILENAME("")) rom (
    .clk,
    .addr,
    .data
  );

  function void check(
    input int line_number,
    input logic [10:0] in_addr,
    input logic [31:0] expected
  );
    begin
      addr = in_addr;
      #20;
      fn_expected_actual_check(`__FILE__, line_number, expected, data);
    end
  endfunction

  initial begin
    $readmemh("tb1_mem/tb1_1.mem", rom.mem);
    check(`__LINE__, 11'd1, 32'd4);

    $readmemh("tb1_mem/tb1_2.mem", rom.mem);
    check(`__LINE__, 11'd2, 32'd8);

    //$readmemh("tb1_mem/tb1_3.mem", rom.mem);
    //check(`__LINE__, 11'd2, 32'd7);

    rom.mem[0] = 32'd255;
    rom.mem[1] = 32'd255;
    rom.mem[2] = 32'd7;
    check(`__LINE__, 11'd2, 32'd7);
  end
endmodule
