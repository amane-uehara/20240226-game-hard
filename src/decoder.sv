`include "lib_cpu.sv"

module decoder import lib_cpu :: *; (
  input  logic        clk, reset, w_en,
  output DECODE       de,
  input  REGISTERS    regs,
  input  logic [31:0] instruction,
  input  logic        w_busy,
  input  logic        irr,
  input  logic [31:0] r_data
);
  DECODE next_de;
  assign next_de.opcode = instruction[3:0];
  assign next_de.opt    = instruction[7:4];
  assign next_de.rd     = instruction[11:8];
  assign next_de.rs1    = instruction[15:12];
  assign next_de.rs2    = instruction[19:16];

  logic s;
  assign s = instruction[31];
  assign next_de.imm12 = {{20{s}}, instruction[31:20]};
  assign next_de.imm16 = {{16{s}}, instruction[31:16]};

  assign next_de.x_rd  = regs.x[next_de.rd];
  assign next_de.x_rs1 = regs.x[next_de.rs1];
  assign next_de.x_rs2 = regs.x[next_de.rs2];

  logic [31:0] addr;
  assign addr = next_de.x_rs1 + next_de.imm12;
  assign next_de.mem_index = addr[7:2];
  assign next_de.mem_val = regs.mem[next_de.mem_index];

  assign next_de.w_busy = w_busy;
  assign next_de.r_data = r_data;
  assign next_de.pc = regs.pc;
  assign next_de.intr_en = regs.intr_en;
  assign next_de.irr = irr;
  assign next_de.is_intr = next_de.intr_en & next_de.irr;

  always_ff @(posedge clk) begin
    if (reset)
      de <= '0;
    else if (w_en)
      de <= next_de;
  end
endmodule
