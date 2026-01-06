// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

import dut_pkg::*;

module control_unit_b (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    input logic alu_zero,  // ALU output when result == 32'h0
    input logic alu_slt,   // ALU output when SLT/SLTU == true;

    // Outputs
    output alu_cnt_e       alu_op,
    output logic           reg_write,
    output logic           mem_read,
    output logic           mem_write,
    output logic           alu_src,     // 0: register, 1: imm value	; For R2
    output logic     [1:0] alu_src_r1,  // MUX: 'd0: R1 source, 'd1: 0 value, 'd2: PC  value
    output logic     [1:0] pc_src,      // 0: PC+4, 1: Jump or branch, 2: ALU(JALR)
    output logic           jump,        // JAL/JALR
    output logic     [1:0] wb_src       // '0: ALU, '1: mem, '2: PC+4
);

  // OPCODES params
  localparam logic [6:0] OPCODE_RTYPE = 7'b0110011;
  localparam logic [6:0] OPCODE_ITYPE = 7'b0010011;
  localparam logic [6:0] OPCODE_LOAD = 7'b0000011;
  localparam logic [6:0] OPCODE_STORE = 7'b0100011;
  localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
  localparam logic [6:0] OPCODE_JAL = 7'b1101111;
  localparam logic [6:0] OPCODE_JALR = 7'b1100111;
  localparam logic [6:0] OPCODE_LUI = 7'b0110111;
  localparam logic [6:0] OPCODE_AUIPC = 7'b0010111;

  // -----------------------------------------------
  // Control logic block
  // -----------------------------------------------
  always_comb begin

    // Default drive values
    alu_op = ALU_ADD;
    reg_write = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    alu_src = 1'b0;
    alu_src_r1 = 2'd0;
    pc_src = 2'b0;
    jump = 1'b0;
    wb_src = 2'd0;

    unique case (opcode)
      OPCODE_RTYPE: begin
        reg_write = 1'b1;

        unique case ({
          funct7, funct3
        })
          {7'b0000000, 3'b000} : alu_op = ALU_ADD;
          {7'b0100000, 3'b000} : alu_op = ALU_SUB;
          {7'b0000000, 3'b111} : alu_op = ALU_AND;
          {7'b0000000, 3'b110} : alu_op = ALU_OR;
          {7'b0000000, 3'b100} : alu_op = ALU_XOR;
          {7'b0000000, 3'b001} : alu_op = ALU_SLL;
          {7'b0000000, 3'b101} : alu_op = ALU_SRL;
          {7'b0100000, 3'b101} : alu_op = ALU_SRA;
          {7'b0000000, 3'b010} : alu_op = ALU_SLT;
          {7'b0000000, 3'b011} : alu_op = ALU_SLTU;
          default: alu_op = ALU_ADD;
        endcase
      end

      OPCODE_ITYPE: begin
        reg_write = 1'b1;
        alu_src   = 1'b1;

        unique case (funct3)
          3'b000:  alu_op = ALU_ADD;
          3'b111:  alu_op = ALU_AND;
          3'b110:  alu_op = ALU_OR;
          3'b100:  alu_op = ALU_XOR;
          3'b001:  alu_op = ALU_SLL;
          3'b101: begin
            if (funct7 == 7'b0000000) 
							alu_op = ALU_SRL;
            else if (funct7 == 7'b0100000) 
							alu_op = ALU_SRA;
          end
          default: alu_op = ALU_ADD;
        endcase
      end

      OPCODE_LOAD: begin
        reg_write = 1'b1;
        wb_src = 2'd1;
        mem_read = 1'b1;
        alu_src = 1'b1;
        alu_op = ALU_ADD;
      end

      OPCODE_STORE: begin
        mem_write = 1'b1;
        alu_src = 1'b1;
        alu_op = ALU_ADD;
      end

			OPCODE_BRANCH: begin
				alu_op = ALU_SUB;

				// Branch logic
				case (funct3)
					3'b000: begin // BEQ
						if (alu_zero)
							pc_src = 2'b01;
						else
							pc_src = 2'b00;
					end
					3'b001: begin // BNE
						if (!alu_zero)
							pc_src = 2'b01;
						else
							pc_src = 2'b00;
					end
					3'b100: begin // BLT
						alu_op = ALU_SLT;
						if (alu_slt)
							pc_src = 2'b01;
						else
							pc_src = 2'b00;
					end
					3'b101: begin // BGE
						alu_op = ALU_SLT;
						if (!alu_slt)
							pc_src = 2'b01;
						else
							pc_src = 2'b00;
					end
					3'b110: begin // BLTU
						alu_op = ALU_SLTU;
						if (alu_slt)
							pc_src = 2'b01;
						else
							pc_src = 2'b00;
					end
					3'b111: begin // BGEU
						alu_op = ALU_SLTU;
						if (!alu_slt)
							pc_src = 2'b01;
						else
							pc_src = 2'b00;
					end
					default: pc_src = 2'b00;
				endcase
			end

      OPCODE_JAL: begin
        reg_write = 1'b1;
        wb_src = 2'd2;
        jump = 1'b1;
        pc_src = 2'b01;
        alu_op = ALU_ADD;
      end

      OPCODE_JALR: begin
        reg_write = 1'b1;
        wb_src = 2'd2;
        alu_src = 1'b1;
        jump = 1'b1;
        pc_src = 2'b10;
        alu_op = ALU_ADD;
      end

      OPCODE_LUI: begin
        reg_write = 1'b1;
        alu_src   = 1'b1;
        alu_src_r1 = 2'd1;
        alu_op    = ALU_ADD;
      end

      OPCODE_AUIPC: begin
        reg_write = 1'b1;
        alu_src   = 1'b1;
        alu_src_r1 = 2'd2;
        alu_op    = ALU_ADD;
      end

      default: begin
        alu_op = ALU_ADD;
      end
    endcase
  end

endmodule
