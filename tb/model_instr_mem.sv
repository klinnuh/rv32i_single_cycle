// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module model_instr_mem #(
    parameter int MEM_WIDTH = 32,
    parameter int MEM_DEPTH = 1024,
    parameter string INIT_FILE = ""
) (
    input logic clk,
    input logic reset_n,

    input logic write_en,
    input logic [31:0] write_addr,
    input logic [31:0] write_data,
    input logic [31:0] addr,

    output logic [31:0] instr_o
);

  // Memory array
  logic [MEM_WIDTH-1:0] mem[0:MEM_DEPTH-1];

  // Nets
  logic [31:0] instr_si;

  // -----------------------------------
  // Optional memory preload
  // -----------------------------------
  initial begin
    if (INIT_FILE != "") begin
      $display("Instruction Memory Model: Loading memory... %s", INIT_FILE);
      $readmemh(INIT_FILE, mem);
    end
  end
  // END -----------------------------------

  // Optional write to intruction memory
  always_ff @(posedge clk) begin
    if (write_en) begin
      mem[write_addr[31:2]] <= write_data;
    end
  end

  // Async read memory
  always_comb begin
    // Stored word assuming little-endian byte order
    instr_si = mem[addr[31:2]];
    instr_o  = {instr_si[7:0], instr_si[15:8], instr_si[23:16], instr_si[31:24]};
  end

endmodule
