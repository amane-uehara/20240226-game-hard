`include "lib_cpu.sv"

module cpu (
  input  logic        clk, reset,
  output logic [10:0] rom_addr,
  input  logic [31:0] rom_data,
  input  logic        irr,
  output logic        ack,
  input  logic [ 7:0] rx_data,
  output logic        tx_req,
  output logic [ 7:0] tx_data,
  input  logic        tx_busy
);
  import lib_cpu :: *;

  STATE state;
  assign rom_addr = state.pc[10:0];
  assign ack = state.ack;
  assign tx_req = state.tx_req;
  assign tx_data = state.tx_data;

  STATE next_state;
  always_ff @(posedge clk) begin
    if (reset) state <= '0;
    else state <= next_state;
  end

  always_comb begin
    next_state.pc = state.pc + 32'd1;
    next_state.ack = 1'b0;
    next_state.tx_req = 1'b0;
    next_state.tx_data = state.tx_data;

    if (irr) begin
      next_state.pc = 32'd3;
    end else begin
      case (rom_data[3:0])
        4'd0: next_state.pc = state.pc; // halt
        4'd1: next_state.pc = {24'd0, rom_data[31:24]};
        4'd2: next_state.ack = 1'b1;
        4'd3: next_state.tx_req = 1'b1;
        4'd4: next_state.tx_data = rom_data[31:24];
        4'd5: next_state.tx_data = rx_data;
      endcase
    end
  end
endmodule
