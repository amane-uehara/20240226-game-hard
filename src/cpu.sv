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

  GENERAL_REG gr;
  SPECIAL_REG sr;
  EXECUTE ex;

  logic is_update_reg;

  sr_file sr_file(
    .clk, .reset, .w_en(is_update_reg),
    .irr,
    .w_busy,
    .r_data,
    .ex,
    .sr
  );

  gr_file gr_file(
    .clk, .reset, .w_en(is_update_reg),
    .rs1(instruction[15:12]),
    .rs2(instruction[19:16]),
    .rd(instruction[11:8]),
    .ex,
    .gr
  );

  DECODE de;
  assign de.opcode = instruction[ 3: 0];
  assign de.opt    = instruction[ 7: 4];
  assign de.imm    = instruction[31:20];
  assign de.sr     = sr;
  assign de.gr     = gr;

  alu alu(.clk, .reset, .de, .ex);
endmodule
