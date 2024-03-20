module tb2 (
  output logic [31:0] pass,
  output logic [31:0] fail
);
  initial begin
    pass = 3;
    fail = 1;
  end
endmodule
