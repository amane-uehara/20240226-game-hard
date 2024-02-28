`include "lib_cpu.sv"

module cpu (
  input  logic        clk, reset,
  output logic [31:0] pc,
  input  logic [31:0] instruction,
  input  logic        irr,
  output logic        ack,
  input  logic [31:0] r_data,
  output logic        w_req,
  output logic [31:0] w_data,
  input  logic        w_busy
);
  import lib_cpu :: *;

  typedef enum logic [2:0] {
    STAGE_FE,
    STAGE_DE,
    STAGE_EX,
    STAGE_WR
  } STAGE;

  STAGE stage, next_stage;
  always_comb begin
    unique case (stage)
      STAGE_FE: next_stage = STAGE_DE;
      STAGE_DE: next_stage = STAGE_EX;
      STAGE_EX: next_stage = STAGE_WR;
      STAGE_WR: next_stage = STAGE_FE;
      default:  next_stage = STAGE_FE;
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) stage <= STAGE_FE;
    else       stage <= next_stage;
  end

  REGISTERS regs, next_regs;
  DECODE    de,   next_de;
  EXECUTE   ex,   next_ex;

  decoder decoder(
    .de(next_de),
    .regs,
    .ex,
    .instruction,
    .w_busy,
    .irr,
    .r_data
  );

  always_ff @(posedge clk) begin
    if (reset)
      de <= '0;
    else if (stage == STAGE_DE)
      de <= next_de;
  end

  alu alu(.ex(next_ex), .de);

  always_ff @(posedge clk) begin
    if (reset)
      ex <= '0;
    else if (stage == STAGE_EX)
      ex <= next_ex;
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      regs.pc <= 32'd0;
      regs.x <= '0;
      regs.intr_en <= 1'b0;
    end else if (stage == STAGE_WR) begin
      regs.pc <= ex.pc;
      regs.x[ex.rd] <= ex.x_rd;
      regs.mem[ex.addr_4byte] <= ex.mem_val;
      regs.intr_en <= ex.intr_en;
    end
  end

  assign pc = regs.pc;
  assign w_req = ex.w_req & (stage == STAGE_WR);
  assign w_data = ex.w_data;
  assign ack = ex.ack & (stage == STAGE_WR);
endmodule
