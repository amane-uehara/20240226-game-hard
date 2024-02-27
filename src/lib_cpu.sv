`ifndef LIB_CPU_SV
`define LIB_CPU_SV

package lib_cpu;
  typedef struct packed {
    logic [6:0]  opcode;
    logic        is_intr;
    logic [31:0] instruction;
    logic        w_busy;
    logic        irr;
    logic [31:0] r_data;
  } DECODE;

  typedef struct packed {
    logic [31:0]       addr;
    logic              w_req;
    logic [31:0]       w_data;
    logic              ack;
    logic              intr_en;
    logic [31:0][31:0] x;
    logic [31:0][31:0] mem;
  } EXECUTE;
endpackage

`endif
