// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

interface dut_if (
    input clk
);
  // <Change signals/ports>
  // Inputs
  logic reset_n;
  logic [31:0] instr_mem_data_i;
  logic instr_mem_req_o;
  logic [31:0] instr_mem_addr_o;

  // Outputs
  logic data_mem_readreq_o;
  logic data_mem_writereq_o;
  logic [31:0] data_mem_addr;
  logic [31:0] data_mem_write_data;
  logic [2:0] data_mem_funct3;
  logic [31:0] data_mem_data_o;

  clocking cb1 @(posedge clk);
    default input #1step output #(0.1 * `CLK_CYCLE);
    output reset_n;
  endclocking
endinterface
