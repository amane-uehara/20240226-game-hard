`include "lib_cpu.sv"

module alu import lib_cpu :: *; (
  input  logic   clk, reset,
  input  DECODE  de,
  input  STATE   state,
  output EXECUTE ex
);
  EXECUTE next_ex;
  always_comb begin
    next_ex.state = state;
    next_ex.state.pc = state.pc + 32'd1;
    next_ex.state.tx_req = 1'b0;
    next_ex.state.ack = 1'b0;

    if (de.irr && state.intr_en) begin
      next_ex.state.pc = state.intr_vec;
      next_ex.state.intr_pc = state.pc;
      next_ex.state.intr_en = 1'b0;
    end else case (de.opcode)
      4'd0: next_ex.state.pc = {20'd0, de.imm};
      4'd1: next_ex.state.tx_data = de.imm[7:0];
      4'd2: next_ex.state.tx_req = 1'b1;
      4'd3: next_ex.state.pc = state.pc; // halt
      4'd4: next_ex.state.tx_data = de.rx_data;
      4'd5: next_ex.state.intr_vec = {20'd0, de.imm};
      4'd6: next_ex.state.intr_en = de.imm[0];
      4'd7: next_ex.state.ack = 1'b1;
      4'd8: begin // iret
        next_ex.state.pc = state.intr_pc;
        next_ex.state.intr_en = 1'b1;
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) ex <= '0;
    else ex <= next_ex;
  end
endmodule
