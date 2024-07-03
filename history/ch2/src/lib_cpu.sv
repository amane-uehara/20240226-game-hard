`ifndef LIB_CPU_SV
`define LIB_CPU_SV

package lib_cpu;
  typedef struct packed {
    logic [31:0] pc;
    logic        ack;
    logic        intr_en;
    logic [31:0] intr_pc;
    logic [31:0] intr_vec;
    logic        tx_req;
    logic [ 7:0] tx_data;
  } STATE;
endpackage

`endif
