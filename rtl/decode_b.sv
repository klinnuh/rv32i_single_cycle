// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module decode_b (
    input logic [31:0] instr,

    output logic [6:0]  opcode,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [31:0] imm
);

  // Decode instruction
  assign opcode = instr[6:0];
  assign rd = instr[11:7];
  assign funct3 = instr[14:12];
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign funct7 = instr[31:25];

  // imm value generation
  always_comb begin
    unique case (opcode)
      // I-type:
      7'b0010011, 7'b0000011, 7'b1100111: begin
        imm = {{20{instr[31]}}, instr[31:20]};
      end

      // S-type:
      7'b0100011: begin
        imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      end

      // B-type:
      7'b1100011: begin
        imm = {{20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      end

      // U-type:
      7'b0110111, 7'b0010111: begin
        imm = {instr[31:12], 12'b0};
      end

      // J-type:
      7'b1101111: begin
        imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      end

      default: begin
        imm = 32'h0;
      end
    endcase
  end

endmodule
