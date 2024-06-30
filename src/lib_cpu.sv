`ifndef LIB_CPU_SV
`define LIB_CPU_SV

package lib_cpu;
  typedef struct packed {
    logic [31:0] pc;
    logic        intr_en;
    logic [31:0] intr_pc;
    logic [31:0] intr_vec;
    logic        ack;
    logic        tx_req;
    logic [ 7:0] tx_data;
  } SPECIAL_REG;

  typedef struct packed {
    logic [ 3:0] opcode;
    logic [ 3:0] opt;
    logic [11:0] imm;
    logic [31:0] x_rs1;
    logic [31:0] x_rs2;
    logic        irr;
    logic        tx_busy;
    logic [ 7:0] rx_data;
  } DECODE;

  typedef struct packed {
    logic        w_rd;
    logic [31:0] x_rd;
    logic        mem_r_req;
    logic        mem_w_req;
    logic [ 5:0] mem_addr;
    SPECIAL_REG  sr;
  } EXECUTE;
endpackage

`endif
