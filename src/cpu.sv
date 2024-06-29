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

  logic is_update_reg;
  logic [1:0] counter, next_counter;
  assign next_counter = counter + 2'd1;
  always_ff @(posedge clk) begin
    if (reset) counter <= 2'd0;
    else       counter <= next_counter;
  end
  assign is_update_reg = (counter == 2'd2);

  logic [31:0] x_rs1, x_rs2, mem_r_val;
  SPECIAL_REG sr;
  EXECUTE ex;

  always_ff @(posedge clk) begin
    if (reset) begin
      sr          <= '0;
    end else begin
      sr.pc       <= ex.pc;
      sr.intr_en  <= ex.intr_en;
      sr.intr_pc  <= ex.intr_pc;
      sr.intr_vec <= ex.intr_vec;
      sr.ack      <= ex.ack;
      sr.tx_req   <= ex.tx_req;
      sr.tx_data  <= ex.tx_data;
    end
  end

  assign rom_addr = sr.pc[10:0];
  assign ack = sr.ack;
  assign tx_req = sr.tx_req;
  assign tx_data = sr.tx_data;

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
    end else if (is_update_reg) begin
      de.opcode  <= rom_data[ 3: 0];
      de.opt     <= rom_data[ 7: 4];
      de.imm     <= rom_data[31:20];
      de.x_rs1   <= x_rs1;
      de.x_rs2   <= x_rs2;
      de.irr     <= irr;
      de.tx_busy <= tx_busy;
      de.rx_data <= rx_data;
      de.sr      <= sr;
    end
  end

  alu alu(.clk, .reset, .de, .ex);
endmodule
