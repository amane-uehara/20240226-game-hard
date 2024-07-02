`ifndef LIB_CPU_SV
`define LIB_CPU_SV

package lib_cpu;
  typedef struct packed {
    logic [31:0] pc;
    logic        ack;
    logic        tx_req;
    logic [ 7:0] tx_data;
  } STATE;
endpackage

`endif
