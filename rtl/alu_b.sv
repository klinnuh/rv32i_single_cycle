// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

import dut_pkg::*;

module alu_b (
    input logic [31:0] op_a,
    input logic [31:0] op_b,
    input alu_cnt_e alu_op,

    output logic [31:0] result,
    output logic zero,
    output logic slt_flag
);

  logic signed [31:0] signed_op_a, signed_op_b;
  logic slt_true;

  assign signed_op_a = op_a;
  assign signed_op_b = op_b;

  always_comb begin
    // Set init value
    slt_true = 1'b0;
    unique case (alu_op)
      ALU_ADD: result = op_a + op_b;
      ALU_SUB: result = op_a - op_b;

      ALU_AND: result = op_a & op_b;
      ALU_OR:  result = op_a | op_b;
      ALU_XOR: result = op_a ^ op_b;

      ALU_SLL: result = op_a << op_b[4:0];
      ALU_SRL: result = op_a >> op_b[4:0];
      ALU_SRA: result = signed_op_a >>> op_b[4:0];

      ALU_SLT: begin
        result   = (signed_op_a < signed_op_b) ? 32'h1 : 32'h0;
        slt_true = (signed_op_a < signed_op_b) ? 1'b1 : 1'b0;
      end
      ALU_SLTU: begin
        result   = (op_a < op_b) ? 32'h1 : 32'h0;
        slt_true = (op_a < op_b) ? 1'b1 : 1'b0;
      end

      default: result = 32'hFFFFFFFF;  // Invalid
    endcase
  end

  assign zero = (result == 32'h0) ? 1'b1 : 1'b0;
  assign slt_flag = slt_true;

endmodule
