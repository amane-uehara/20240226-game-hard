module our;
  initial begin
    $display("Current time = %t", $realtime);
    $display("Hello World");
    #10;
    $display("Current time = %t", $realtime);
    $finish;
  end
endmodule
