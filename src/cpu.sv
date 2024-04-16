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
  logic [1:0] counter, next_counter;
  assign next_counter = counter + 2'd1;
  always_ff @(posedge clk) begin
    if (reset) counter <= 2'd0;
    else       counter <= next_counter;
  end
  assign is_update_reg = (counter == 2'd0);

  SPECIAL_REG sr;
  GENERAL_REG gr;
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

  gr_file gr_file(
    .clk, .reset,
    .w_en(is_update_reg & ex.w_rd),
    .rs1(rom_data[15:12]),
    .rs2(rom_data[19:16]),
    .rd(rom_data[11:8]),
    .x_rd(ex.x_rd),
    .x_rs1(gr.x_rs1),
    .x_rs2(gr.x_rs2)
  );

  mem_file mem_file(
    .clk, .reset,
    .w_en(is_update_reg & ex.mem_w_req),
    .addr(ex.mem_addr),
    .r_data(gr.mem_val),
    .w_data(ex.mem_val)
  );

  DECODE de;
  assign de.opcode = rom_data[ 3: 0];
  assign de.opt    = rom_data[ 7: 4];
  assign de.imm    = rom_data[31:20];
  assign de.sr     = sr;
  assign de.gr     = gr;

  alu alu(.clk, .reset, .de, .ex);

  assign rom_addr = sr.pc[10:0];
  assign ack = ex.ack;
  assign w_req = ex.w_req & is_update_reg;
  assign w_data = ex.w_data;
endmodule
