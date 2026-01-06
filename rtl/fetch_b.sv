// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module fetch_b (
    input logic clk,
    input logic reset_n,

    input logic [31:0] instr_mem_pc_i,
    input logic [31:0] mem_rd_data_i,

    output logic instr_mem_req_o,
    output logic [31:0] instr_mem_addr_o,
    output logic [31:0] instr_mem_instr_o
);

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      instr_mem_req_o <= 1'b0;
    end else begin
      instr_mem_req_o <= 1'b1;
    end
  end

  assign instr_mem_addr_o  = instr_mem_pc_i;
  assign instr_mem_instr_o = mem_rd_data_i;

endmodule
