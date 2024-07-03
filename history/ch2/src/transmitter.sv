module transmitter #(parameter WAIT) (
  input  logic       clk, reset,
  output logic       uart_tx,
  input  logic       send_req,
  input  logic [7:0] data,
  output logic       busy
);
  typedef struct packed {
    logic        busy;
    logic [31:0] clk_cnt;
    logic [3:0]  bit_cnt;
    logic [9:0]  buff;
  } STATE;

  STATE curt, next;
  always_ff @(posedge clk) begin
    if (reset) curt <= '{buff: ~10'b0, default: '0};
    else       curt <= next;
  end

  assign uart_tx = curt.buff[0];
  assign busy    = curt.busy;

  logic is_bgn, is_edge, is_end;
  assign is_bgn  = ~curt.busy && send_req;
  assign is_edge =  curt.busy && (curt.clk_cnt == WAIT-1);
  assign is_end  =  is_edge   && (curt.bit_cnt == 4'd9);

  assign next.busy = curt.busy ? ~is_end : is_bgn;
  assign next.clk_cnt = (is_bgn || is_edge) ? 32'd0 : curt.clk_cnt + 32'd1;

  always_comb begin
    if (is_bgn) begin
      next.bit_cnt = 4'd0;
      next.buff    = {1'b1, data[7:0], 1'b0};
    end else if (is_edge) begin
      next.bit_cnt = curt.bit_cnt + 4'd1;
      next.buff    = {1'b1, curt.buff[9:1]};
    end else begin
      next.bit_cnt = curt.bit_cnt;
      next.buff    = curt.buff;
    end
  end
endmodule
