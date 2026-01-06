// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module pc_b (
    input logic clk,
    input logic reset_n,

    input logic [31:0] pc_next_i,

    output logic [31:0] pc_o
);

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      pc_o <= 32'h0000_0000;
    end else begin
      pc_o <= pc_next_i;
    end
  end

endmodule
