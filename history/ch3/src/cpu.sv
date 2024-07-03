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

  logic [3:0] counter;
  always_ff @(posedge clk) begin
    if (reset) counter <= 4'b1;
    else       counter <= {counter[2:0], counter[3]};
  end

  logic stage_de, stage_wb;
  assign stage_de = counter[1];
  assign stage_wb = counter[3];

  DECODE de;
  always_ff @(posedge clk) begin
    if (reset) begin
      de         <= '0;
    end else if (stage_de) begin
      de.opcode  <= rom_data[ 3: 0];
      de.imm     <= rom_data[31:20];
      de.irr     <= irr;
      de.rx_data <= rx_data;
    end
  end

  STATE state;
  EXECUTE ex;

  alu alu(.clk, .reset, .de, .state, .ex);

  always_ff @(posedge clk) begin
    if (reset) state <= '0;
    else if (stage_wb) state <= ex.state;
  end

  assign rom_addr = state.pc[10:0];
  assign ack = state.ack;
  assign tx_req = state.tx_req;
  assign tx_data = state.tx_data;
endmodule
