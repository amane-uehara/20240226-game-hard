`ifndef LIB_CPU_SV
`define LIB_CPU_SV

package lib_cpu;
  typedef enum logic [2:0] {
    STAGE_FE,
    STAGE_DE,
    STAGE_EX,
    STAGE_WR
  } STAGE;

  typedef struct packed {
    logic [15:0][31:0] x;
    logic [63:0][31:0] mem;
    logic       [31:0] pc;
    logic              intr_en;
  } REGISTERS;

  typedef struct packed {
    logic [ 3:0] opcode;
    logic [ 3:0] opt;
    logic [ 3:0] rd;
    logic [ 3:0] rs1;
    logic [ 3:0] rs2;
    logic [31:0] imm12;
    logic [31:0] imm16;
    logic [31:0] x_rd;
    logic [31:0] x_rs1;
    logic [31:0] x_rs2;
    logic [ 5:0] mem_index;
    logic [31:0] mem_val;
    logic        w_busy;
    logic [31:0] r_data;
    logic [31:0] pc;
    logic        intr_en;
    logic        irr;
    logic        is_intr;
  } DECODE;

  typedef struct packed {
    logic [31:0] pc;
    logic        w_req;
    logic [31:0] w_data;
    logic        ack;
    logic [ 3:0] rd;
    logic [31:0] x_rd;
    logic [ 5:0] mem_index;
    logic [31:0] mem_val;
    logic        intr_en;
  } EXECUTE;
endpackage

`endif
