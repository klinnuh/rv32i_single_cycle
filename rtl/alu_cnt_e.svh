// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`ifndef ALU_OP_E
`define ALU_OP_E 

typedef enum logic [3:0] {
  ALU_ADD  = 4'b0000,  // Add
  ALU_SUB  = 4'b0001,  // Subtract / branch comparisons
  ALU_AND  = 4'b0010,  // AND
  ALU_OR   = 4'b0011,  // OR
  ALU_XOR  = 4'b0100,  // XOR
  ALU_SLL  = 4'b0101,  // Shift left logic
  ALU_SRL  = 4'b0110,  // Shift right logic
  ALU_SRA  = 4'b0111,  // Shift right arithmetic
  ALU_SLT  = 4'b1000,  // Signed less than
  ALU_SLTU = 4'b1001   // Unsigned less than
} alu_cnt_e;

`endif
