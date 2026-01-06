// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module mux2 (
    input logic [31:0] in0,
    input logic [31:0] in1,
    input logic        sel,

    output logic [31:0] out_o
);

  always_comb begin
    unique case (sel)
      1'b0: out_o = in0;
      1'b1: out_o = in1;
      default: out_o = 32'b0;
    endcase
  end

endmodule
