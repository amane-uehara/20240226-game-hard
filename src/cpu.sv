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

  logic [31:0] x_rs1, x_rs2, mem_r_val;
  STATE state;
  EXECUTE ex;

  always_ff @(posedge clk) begin
    if (reset) state <= '0;
    else       state <= ex.state;
  end

  assign rom_addr = state.pc[10:0];
  assign ack = state.ack;
  assign tx_req = state.tx_req;
  assign tx_data = state.tx_data;

  logic [31:0] gr_w_val;
  assign gr_w_val = ex.mem_r_req ? mem_r_val : ex.x_rd;

  gr_file gr_file(
    .clk, .reset,
    .w_en(ex.w_rd),
    .rs1(rom_data[15:12]),
    .rs2(rom_data[19:16]),
    .rd(rom_data[11:8]),
    .x_rd(gr_w_val),
    .x_rs1(x_rs1),
    .x_rs2(x_rs2)
  );

  mem_file mem_file(
    .clk, .reset,
    .w_en(ex.mem_w_req),
    .addr(ex.mem_addr),
    .r_data(mem_r_val),
    .w_data(ex.x_rd)
  );

  DECODE de;
  always_ff @(posedge clk) begin
    if (reset) begin
      de        <= '0;
    end else begin
      de.opcode  <= rom_data[ 3: 0];
      de.opt     <= rom_data[ 7: 4];
      de.imm     <= rom_data[31:20];
      de.x_rs1   <= x_rs1;
      de.x_rs2   <= x_rs2;
      de.irr     <= irr;
      de.tx_busy <= tx_busy;
      de.rx_data <= rx_data;
    end
  end

  alu alu(.clk, .reset, .de, .state, .ex);
endmodule
