`timescale 1ns/1ps
`include "../../src/lib_cpu.sv"

module test_top ();
  logic clk;
  logic reset;
  logic uart_tx;
  logic uart_rx;

  localparam CLOCK_HZ       = 100_000_000;
  localparam UART_BAUD_RATE = 32;
  localparam FILENAME       = "rom.mem";

  mother_board #(
    .WAIT(CLOCK_HZ/UART_BAUD_RATE),
    .FILENAME(FILENAME)
  ) mother_board (.*);

  //initial begin
  //  #1;
  //  mother_board.rom.mem[0] = 32'h54311101;
  //  mother_board.rom.mem[1] = 32'h12345678;
  //  mother_board.rom.mem[2] = 32'h12345678;
  //  mother_board.rom.mem[3] = 32'h12345678;
  //  mother_board.rom.mem[4] = 32'h54322201;
  //end

  always #5 clk = ~clk;
  initial   clk = 1'b0;

  initial begin
    reset = 1'b1;
    #10;
    reset = 1'b0;
  end

  initial begin
    uart_rx = 1'b1;
    #100;
    $finish();
  end

  show show(
    mother_board.cpu.rom_data,
    mother_board.cpu.sr,
    mother_board.cpu.gr,
    mother_board.cpu.de,
    mother_board.cpu.ex,
    mother_board.cpu.gr_file.x
  );
endmodule

module show import lib_cpu :: *;(
  input logic [31:0]       rom_data,
  input SPECIAL_REG        sr,
  input GENERAL_REG        gr,
  input DECODE             de,
  input EXECUTE            ex,
  input logic [15:0][31:0] x
);
  typedef enum logic [5:0] {
    OTHER, NOP,
    MOV_I, ADD_I, SUB_I, SLL_I, SRA_I, SRL_I, AND_I, OR_I, XOR_I,
    ADD_R, SUB_R, SLL_R, SRA_R, SRL_R, AND_R, OR_R, XOR_R,
    JALR,
    JZ, JNZ, JGE, JLT,
    LW, SW,
    R_IO, W_IO,
    W_INTR,
    IRET
  } ENUM_OP;

  typedef enum logic [3:0] {
    X0_ZERO, X1_RA, X2_SP, X3_TPTR, X4_TCMP,
    X5_A, X6_B, X7_C, X8_D, X9_E, XA_F, XB_G, XC_H, XD_I, XE_J
  } ENUM_REG;

  ENUM_REG rs1, rs2, rd;
  logic [3:0] i_rs1, i_rs2, i_rd;
  assign i_rs1 = rom_data[15:12];
  assign i_rs2 = rom_data[19:16];
  assign i_rd  = rom_data[11:8];

  ENUM_OP op;
  always_comb begin
    casez (rom_data[7:0])
      {4'h0, 4'h0}:
        if (i_rs1 == 4'd0) op = MOV_I;
        else op = ADD_I;
      {4'h1, 4'h0}: op = SUB_I;
      {4'h2, 4'h0}: op = SLL_I;
      {4'h3, 4'h0}: op = SRA_I;
      {4'h4, 4'h0}: op = AND_I;
      {4'h5, 4'h0}: op = OR_I;
      {4'h6, 4'h0}: op = XOR_I;
      {4'h0, 4'h1}: op = ADD_R;
      {4'h1, 4'h1}: op = SUB_R;
      {4'h2, 4'h1}: op = SLL_R;
      {4'h3, 4'h1}: op = SRA_R;
      {4'h4, 4'h1}: op = AND_R;
      {4'h5, 4'h1}: op = OR_R;
      {4'h6, 4'h1}: op = XOR_R;
      {4'h0, 4'h2}: op = JALR;
      {4'h0, 4'h3}: op = JZ;
      {4'h1, 4'h3}: op = JNZ;
      {4'h2, 4'h3}: op = JGE;
      {4'h3, 4'h3}: op = JLT;
      {4'h0, 4'h4}: op = SW;
      {4'h0, 4'h5}: op = LW;
      {4'h0, 4'h6}: op = R_IO;
      {4'h0, 4'h7}: op = W_IO;
      {4'h0, 4'h8}: op = W_INTR;
      {4'h0, 4'h9}: op = IRET;
      default:      op = OTHER;
    endcase
  end

  always_comb begin
    case (i_rs1)
      4'h0: rs1 = X0_ZERO;
      4'h1: rs1 = X1_RA;
      4'h2: rs1 = X2_SP;
      4'h3: rs1 = X3_TPTR;
      4'h4: rs1 = X4_TCMP;
      4'h5: rs1 = X5_A;
      4'h6: rs1 = X6_B;
      4'h7: rs1 = X7_C;
      4'h8: rs1 = X8_D;
      4'h9: rs1 = X9_E;
      4'hA: rs1 = XA_F;
      4'hB: rs1 = XB_G;
      4'hC: rs1 = XC_H;
      4'hD: rs1 = XD_I;
      4'hE: rs1 = XE_J;
    endcase
  end

  always_comb begin
    case (i_rs2)
      4'h0: rs2 = X0_ZERO;
      4'h1: rs2 = X1_RA;
      4'h2: rs2 = X2_SP;
      4'h3: rs2 = X3_TPTR;
      4'h4: rs2 = X4_TCMP;
      4'h5: rs2 = X5_A;
      4'h6: rs2 = X6_B;
      4'h7: rs2 = X7_C;
      4'h8: rs2 = X8_D;
      4'h9: rs2 = X9_E;
      4'hA: rs2 = XA_F;
      4'hB: rs2 = XB_G;
      4'hC: rs2 = XC_H;
      4'hD: rs2 = XD_I;
      4'hE: rs2 = XE_J;
    endcase
  end

  always_comb begin
    case (i_rd)
      4'h0: rd = X0_ZERO;
      4'h1: rd = X1_RA;
      4'h2: rd = X2_SP;
      4'h3: rd = X3_TPTR;
      4'h4: rd = X4_TCMP;
      4'h5: rd = X5_A;
      4'h6: rd = X6_B;
      4'h7: rd = X7_C;
      4'h8: rd = X8_D;
      4'h9: rd = X9_E;
      4'hA: rd = XA_F;
      4'hB: rd = XB_G;
      4'hC: rd = XC_H;
      4'hD: rd = XD_I;
      4'hE: rd = XE_J;
    endcase
  end

  logic [31:0] imm;
  assign imm = {{20{rom_data[31]}}, rom_data[31:20]};

endmodule;
