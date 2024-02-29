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
    .clk, .reset, .w_en(stage == STAGE_DE),
    .de,
    .regs,
    .instruction,
    .w_busy,
    .irr,
    .r_data
  );

  alu alu(
    .clk, .reset, .w_en(stage == STAGE_EX),
    .ex(next_ex), .de
  );

  reg_file reg_file(
    .clk, .reset, .w_en(stage == STAGE_WR),
    .regs, .ex
  );

  assign pc = regs.pc;
  assign w_req = ex.w_req & (stage == STAGE_WR);
  assign w_data = ex.w_data;
  assign ack = ex.ack & (stage == STAGE_WR);
endmodule
