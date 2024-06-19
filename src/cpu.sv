`include "lib_cpu.sv"

module cpu (
  input  logic        clk, reset,
  output logic [10:0] rom_addr,
  input  logic [31:0] rom_data,
  input  logic        irr,
  output logic        ack,
  input  logic [ 7:0] r_data,
  output logic        w_req,
  output logic [ 7:0] w_data,
  input  logic        w_busy
);
  import lib_cpu :: *;

  logic is_update_reg;
  logic [4:0] counter, next_counter;
  assign next_counter = {counter[3:0], counter[4]};
  always_ff @(posedge clk) begin
    if (reset) counter <= 5'b1;
    else       counter <= next_counter;
  end
  assign is_update_reg = (counter == 5'b1);

  logic [31:0] x_rs1, x_rs2, mem_r_val;
  SPECIAL_REG sr;
  EXECUTE ex;

  always_ff @(posedge clk) begin
    if (reset) begin
      sr          <= '0;
    end else if (is_update_reg) begin
      sr.pc       <= ex.pc;
      sr.irr      <= irr;
      sr.intr_en  <= ex.intr_en;
      sr.intr_pc  <= ex.intr_pc;
      sr.intr_vec <= ex.intr_vec;
      sr.w_busy   <= w_busy;
      sr.r_data   <= r_data;
    end
  end

  logic [31:0] gr_w_val;
  assign gr_w_val = ex.mem_r_req ? mem_r_val : ex.x_rd;

  gr_file gr_file(
    .clk, .reset,
    .w_en(is_update_reg & ex.w_rd),
    .rs1(rom_data[15:12]),
    .rs2(rom_data[19:16]),
    .rd(rom_data[11:8]),
    .x_rd(gr_w_val),
    .x_rs1(x_rs1),
    .x_rs2(x_rs2)
  );

  mem_file mem_file(
    .clk, .reset,
    .w_en(is_update_reg & ex.mem_w_req),
    .addr(ex.mem_addr),
    .r_data(mem_r_val),
    .w_data(ex.x_rd)
  );

  DECODE de;
  always_ff @(posedge clk) begin
    if (reset) begin
      de        <= '0;
    end else begin
      de.opcode <= rom_data[ 3: 0];
      de.opt    <= rom_data[ 7: 4];
      de.imm    <= rom_data[31:20];
      de.x_rs1  <= x_rs1;
      de.x_rs2  <= x_rs2;
      de.sr     <= sr;
    end
  end

  alu alu(.clk, .reset, .de, .ex);

  assign rom_addr = sr.pc[10:0];
  assign ack = ex.ack;
  assign w_req = ex.w_req & is_update_reg;
  assign w_data = ex.w_data;
endmodule
