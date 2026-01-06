// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module pc_adder_b (
    input logic [31:0] pc,
    input logic [31:0] imm,

    output logic [31:0] pc_plus_4,
    output logic [31:0] pc_plus_imm
);

  assign pc_plus_4   = pc + 32'd4;
  assign pc_plus_imm = pc + imm;

endmodule
