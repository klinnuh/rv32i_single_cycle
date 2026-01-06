// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module reg_file_b (
    input logic clk,
    input logic reset_n,

    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic rd_write_en,
    input logic [4:0] rd_addr,
    input logic [31:0] data,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

  // Memory-size = 32
  localparam int MEM_SIZE = 32;
  logic [31:0] regs_file[MEM_SIZE];

  // Memory write seq block
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      for (int i = 0; i < MEM_SIZE; i++) begin
        regs_file[i] <= 32'h0;
      end
    end else begin
      if (rd_write_en && (rd_addr != 5'h0)) begin
        regs_file[rd_addr] <= data;
      end
    end
  end

  // Async memory read comb block
  assign rs1_data = (rs1_addr == 5'h0) ? 32'h0 : regs_file[rs1_addr];
  assign rs2_data = (rs2_addr == 5'h0) ? 32'h0 : regs_file[rs2_addr];

endmodule
