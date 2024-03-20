module tb1 (
  output logic [31:0] pass,
  output logic [31:0] fail
);
  initial begin
    pass = 4;
    fail = 2;
  end
endmodule
