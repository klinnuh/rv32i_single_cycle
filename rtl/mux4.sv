// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module mux4 (
    input logic [31:0] in0,
    input logic [31:0] in1,
    input logic [31:0] in2,
    input logic [31:0] in3,
    input logic [ 1:0] sel,

    output logic [31:0] out_o
);

  always_comb begin
    unique case (sel)
      2'd0: out_o = in0;
      2'd1: out_o = in1;
      2'd2: out_o = in2;
      2'd3: out_o = in3;
      default: out_o = 32'b0;
    endcase
  end

endmodule
