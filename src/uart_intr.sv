module uart_intr (
  input  logic clk, reset,
  input  logic rx_update,
  input  logic ack,
  output logic irr
);
  logic next_irr;
  always_ff @(posedge clk) begin
    if (reset) irr <= 1'b0;
    else       irr <= next_irr;
  end

  always_comb begin
    if (rx_update) next_irr = 1'b1;
    else if (ack)  next_irr = 1'b0;
    else           next_irr = irr;
  end
endmodule
