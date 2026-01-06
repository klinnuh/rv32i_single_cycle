// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module data_mem_b #(
    parameter int MEM_DEPTH = 1024
) (
    input logic clk,
    input logic reset_n,

    input logic mem_read,
    input logic mem_write,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    input logic [2:0] funct3,

    output logic [31:0] data_o
);

  localparam int ADDR_BITS = $clog2(MEM_DEPTH);

  logic [7:0] mem[0:MEM_DEPTH-1];           // Memory-size
  logic invalid_write;                      // Invalid memory write flag
  logic [31:0] tmp_data;

  logic [ADDR_BITS-1:0] addr_ptr;

  // Mask address bits
  assign addr_ptr = addr;

  // Memory write seq block
  always_ff @(posedge clk) begin
    if (mem_write) begin
      unique case (funct3)
        3'b000: begin  // SB
          mem[addr_ptr] <= write_data[7:0];
        end
        3'b001: begin  // SH
          mem[addr_ptr]   <= write_data[7:0];
          mem[addr_ptr+1] <= write_data[15:8];
        end
        3'b010: begin  // SW
          mem[addr_ptr]   <= write_data[7:0];
          mem[addr_ptr+1] <= write_data[15:8];
          mem[addr_ptr+2] <= write_data[23:16];
          mem[addr_ptr+3] <= write_data[31:17];
        end
        default: begin
          // Invalid funct3 for write
          invalid_write <= 1'b1;
        end
      endcase
    end
  end

  // Async memory read comb block
  always_comb begin
    tmp_data = 32'hFFFFFFFF;  // Default value
    if (mem_read) begin
      unique case (funct3)
        3'b000: begin  // LB
          tmp_data = {{24{mem[addr_ptr][7]}}, mem[addr_ptr]};
        end
        3'b001: begin  // LH
          tmp_data = {{16{mem[addr_ptr+1][7]}}, mem[addr_ptr+1], mem[addr_ptr]};
        end
        3'b010: begin  // LW
          tmp_data = {mem[addr_ptr+3], mem[addr_ptr+2], mem[addr_ptr+1], mem[addr_ptr]};
        end
        3'b100: begin  // LBU
          tmp_data = {24'b0, mem[addr_ptr]};
        end
        3'b101: begin  // LHU
          tmp_data = {16'b0, mem[addr_ptr+1], mem[addr_ptr]};
        end
        default: begin
          tmp_data = 32'hFFFFFFFF;  // Invalid funct3
        end
      endcase
    end
  end

  assign data_o = tmp_data;

endmodule
