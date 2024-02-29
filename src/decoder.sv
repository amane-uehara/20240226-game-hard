`include "lib_cpu.sv"

module decoder import lib_cpu :: *; (
  output DECODE       de
  input  REGISTERS    regs,
  input  logic [31:0] instruction,
  input  logic        w_busy,
  input  logic        irr,
  input  logic [31:0] r_data
);
  assign de = '0;
  assign de.calcr = instruction[3:0]
  assign de.opt   = instruction[7:4]
  assign de.rd    = instruction[11:8]
  assign de.rs1   = instruction[15:12]
  assign de.rs2   = instruction[19:16]

  logic s;
  assign s = instruction[31];
  assign de.imm12 = {{20{s}, instruction[31:20]};
  assign de.imm16 = {{16{s}, instruction[31:16]};

  assign de.x_rd  = regs.x[de.rd];
  assign de.x_rs1 = regs.x[de.rs1];
  assign de.x_rs2 = regs.x[de.rs2];

  logic [31:0] addr;
  assign addr = de.x_rs1 + de.imm12;
  assign de.addr_4byte = addr[9:2];
  assign de.mem_val = regs.mem[de.addr_4byte];

  assign de.w_busy = w_busy;
  assign de.r_data = r_data;
  assign de.pc = regs.pc;
  assign de.intr_en = regs.intr_en;
  assign de.irr = irr;
  assign de.is_intr = de.intr_en & de.irr;
endmodule
