`ifndef LIB_CPU_SV
`define LIB_CPU_SV

package lib_cpu;
  typedef struct packed {
    logic [31:0] pc;
    logic        irr;
    logic        intr_en;
    logic [31:0] intr_pc;
    logic [31:0] intr_vec;
    logic        w_busy;
    logic [ 7:0] r_data;
  } SPECIAL_REG;

  typedef struct packed {
    logic [ 3:0] opcode;
    logic [ 3:0] opt;
    logic [11:0] imm;
    logic [31:0] x_rs1;
    logic [31:0] x_rs2;
    SPECIAL_REG  sr;
  } DECODE;

  typedef struct packed {
    logic [31:0] pc;
    logic        w_req;
    logic [ 7:0] w_data;
    logic        ack;
    logic        w_rd;
    logic [31:0] x_rd;
    logic        mem_r_req;
    logic        mem_w_req;
    logic [ 5:0] mem_addr;
    logic        intr_en;
    logic [31:0] intr_pc;
    logic [31:0] intr_vec;
  } EXECUTE;
endpackage

`endif
