module receiver #(parameter WAIT) (
  input  logic       clk, reset,
  input  logic       uart_rx,
  output logic       update,
  output logic [7:0] data
);
  typedef struct packed {
    logic        busy;
    logic [31:0] clk_cnt;
    logic [3:0]  bit_cnt;
    logic [9:0]  buff;
    logic        update;
    logic [7:0]  data;
  } STATE;

  STATE curt, next;
  always_ff @(posedge clk) begin
    if (reset) curt <= '0;
    else       curt <= next;
  end

  assign update = curt.update;
  assign data   = curt.data;

  logic is_bgn, is_mid, is_edge, is_end;
  assign is_bgn  = ~curt.busy && ~uart_rx;
  assign is_mid  = (curt.clk_cnt == WAIT/2);
  assign is_edge = (curt.clk_cnt == WAIT-1);
  assign is_end  = curt.busy && is_mid && (curt.bit_cnt == 4'd9);

  assign next.busy = curt.busy ? ~is_end : is_bgn;

  always_comb begin
    if (is_bgn) begin
      next.clk_cnt = 32'd0;
      next.bit_cnt = 4'd0;
    end else if (is_edge) begin
      next.clk_cnt = 32'd0;
      next.bit_cnt = curt.bit_cnt + 4'd1;
    end else begin
      next.clk_cnt = curt.clk_cnt + 32'd1;
      next.bit_cnt = curt.bit_cnt;
    end
  end

  assign next.buff   = is_mid ? {uart_rx, curt.buff[9:1]} : curt.buff;
  assign next.update = is_end && uart_rx;
  assign next.data   = next.update ? curt.buff[9:2] : curt.data;
endmodule