`include "lib_cpu.sv"

module cpu (
  input  logic        clk, reset,
  output logic [31:0] addr,
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
    STAGE_EX
  } STAGE;

  STAGE stage, next_stage;
  always_comb begin
    unique case (stage)
      STAGE_FE: next_stage = STAGE_DE;
      STAGE_DE: next_stage = STAGE_EX;
      STAGE_EX: next_stage = STAGE_FE;
      default:  next_stage = STAGE_FE;
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) stage <= STAGE_FE;
    else       stage <= next_stage;
  end

  DECODE de, next_de;
  EXECUTE ex, next_ex;

  decoder decoder(
    .clk, .reset,
    .de(next_de),
    .ex,
    .instruction,
    .w_busy,
    .irr,
    .r_data
  );

  always_ff @(posedge clk) begin
    if (reset)                  de <= '0;
    else if (stage == STAGE_DE) de <= next_de;
    else                        de <= de;
  end

  alu alu(
    .clk, .reset,
    .ex(next_ex),
    .de
  );

  always_ff @(posedge clk) begin
    if (reset)                  ex <= '0;
    else if (stage == STAGE_EX) ex <= next_ex;
    else                        ex <= ex;
  end

  assign addr = ex.addr;
  assign w_req = ex.w_req;
  assign w_data = ex.w_data;
  assign ack = ex.ack;
endmodule
