// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`timescale 1ns / 1ps

module rv32i_core (
    input logic clk,
    input logic reset_n,

    // Fetch stage interface
    input logic [31:0] instr_mem_data_i,
    output logic instr_mem_req_o,
    output logic [31:0] instr_mem_addr_o,

    // Data memory interface
    output logic data_mem_readreq_o,
    output logic data_mem_writereq_o,
    output logic [31:0] data_mem_addr,
    output logic [31:0] data_mem_write_data,
    output logic [2:0] data_mem_funct3,
    output logic [31:0] data_mem_data_o

);
  import dut_pkg::*;

  // ------------------------
  // Internal nets
  // ------------------------

  // Program counter
  logic [31:0] pc;
  logic [31:0] pc_plus_4;
  logic [31:0] pc_plus_imm;
  logic [31:0] jalr_target_pc;
  logic [31:0] m_pc_next;

  // Fetch block
  logic [31:0] fetch_instr;

  // Decode block
  logic [6:0] dec_opcode;
  logic [4:0] dec_rs1;
  logic [4:0] dec_rs2;
  logic [4:0] dec_rd;
  logic [2:0] dec_funct3;
  logic [6:0] dec_funct7;
  logic [31:0] dec_imm;

  // Register file
  logic [31:0] rf_rs1_data;
  logic [31:0] rf_rs2_data;
  logic [31:0] m_write_rf;

  // Control unit
  logic cnt_reg_write;
  logic cnt_mem_read;
  logic cnt_mem_write;
  logic cnt_alu_src;
  logic [1:0] cnt_alu_src_r1;
  logic [1:0] cnt_pc_src;
  logic cnt_jump;
  logic [1:0] cnt_wb_src;

  // ALU
  logic alu_zero;
  logic alu_slt;
  alu_cnt_e cnt_alu_op;
  logic [31:0] f_zero_32b;
  logic [31:0] m_alu_op_a;
  logic [31:0] m_alu_op_b;
  logic [31:0] alu_result;

  // Data memory
  logic [31:0] dmem_data;

  // Force
  assign f_zero_32b = 32'h0;

  // END --------------------

  // ------------------------
  // Fetch
  // ------------------------
  fetch_b u_fetch (
      // In
      .clk              (clk),
      .reset_n          (reset_n),
      .instr_mem_pc_i   (pc),
      .mem_rd_data_i    (instr_mem_data_i),
      // Out
      .instr_mem_req_o  (instr_mem_req_o),
      .instr_mem_addr_o (instr_mem_addr_o),
      .instr_mem_instr_o(fetch_instr)
  );

  // ------------------------
  // Decode
  // ------------------------
  decode_b u_decode (
      // In
      .instr (fetch_instr),
      // Out
      .opcode(dec_opcode),
      .rs1   (dec_rs1),
      .rs2   (dec_rs2),
      .rd    (dec_rd),
      .funct3(dec_funct3),
      .funct7(dec_funct7),
      .imm   (dec_imm)
  );

  // ------------------------
  // Register file
  // ------------------------
  reg_file_b u_reg_file (
      // In
      .clk    (clk),
      .reset_n(reset_n),

      .rs1_addr   (dec_rs1),
      .rs2_addr   (dec_rs2),
      .rd_write_en(cnt_reg_write),
      .rd_addr    (dec_rd),
      .data       (m_write_rf),
      // Out
      .rs1_data   (rf_rs1_data),
      .rs2_data   (rf_rs2_data)
  );

  // ------------------------
  // Control unit
  // ------------------------
  control_unit_b u_control_unit (
      // In
      .opcode    (dec_opcode),
      .funct3    (dec_funct3),
      .funct7    (dec_funct7),
      .alu_zero  (alu_zero),
      .alu_slt   (alu_slt),
      // Out
      .alu_op    (cnt_alu_op),
      .reg_write (cnt_reg_write),
      .mem_read  (cnt_mem_read),
      .mem_write (cnt_mem_write),
      .alu_src   (cnt_alu_src),
      .alu_src_r1(cnt_alu_src_r1),
      .pc_src    (cnt_pc_src),
      .jump      (cnt_jump),
      .wb_src    (cnt_wb_src)
  );

  // ------------------------
  // ALU
  // ------------------------
  // Op_a MUX
  mux4 u_mux4_alu_op_a (
      .in0(rf_rs1_data),
      .in1(f_zero_32b),
      .in2(pc),
      .in3(f_zero_32b),
      .sel(cnt_alu_src_r1),

      .out_o(m_alu_op_a)
  );

  // Op_b MUX
  mux2 u_mux2_alu_op_b (
      .in0(rf_rs2_data),
      .in1(dec_imm),
      .sel(cnt_alu_src),

      .out_o(m_alu_op_b)
  );

  // ALU unit
  alu_b u_alu (
      // In
      .op_a    (m_alu_op_a),
      .op_b    (m_alu_op_b),
      .alu_op  (cnt_alu_op),
      // Out
      .result  (alu_result),
      .zero    (alu_zero),
      .slt_flag(alu_slt)
  );

  // ------------------------
  // Data memory
  // ------------------------

  data_mem_b #(
      .MEM_DEPTH(1024)
  ) u_data_mem_b (
      // In
      .clk       (clk),
      .reset_n   (reset_n),
      .mem_read  (cnt_mem_read),
      .mem_write (cnt_mem_write),
      .addr      (alu_result),
      .write_data(rf_rs2_data),
      .funct3    (dec_funct3),
      // Out
      .data_o    (dmem_data)
  );

  // ------------------------
  // MUX write back to register file
  // ------------------------
  mux4 u_mux4_rf_wb (
      .in0(alu_result),
      .in1(dmem_data),
      .in2(pc_plus_4),
      .in3(f_zero_32b),
      .sel(cnt_wb_src),

      .out_o(m_write_rf)
  );

  // ------------------------
  // Program counter
  // ------------------------
  // Program counter adder
  pc_adder_b u_pc_adder (
      // In
      .pc(pc),
      .imm(dec_imm),
      // Out
      .pc_plus_4(pc_plus_4),
      .pc_plus_imm(pc_plus_imm)
  );
  // MUX program counter
  assign jalr_target_pc = alu_result;
	
  mux4 u_mux4_pc (
      .in0(pc_plus_4),
      .in1(pc_plus_imm),
      .in2(jalr_target_pc),
      .in3(f_zero_32b),
      .sel(cnt_pc_src),

      .out_o(m_pc_next)
  );

  // Program counter FF
  pc_b u_pc_b (
      //In
      .clk      (clk),
      .reset_n  (reset_n),
      .pc_next_i(m_pc_next),
      // Out
      .pc_o     (pc)
  );

  // END ------------------------

  // ------------------------
  // Output data memory interface
  // ------------------------
  assign data_mem_readreq_o  = cnt_mem_read;
  assign data_mem_writereq_o = cnt_mem_write;
  assign data_mem_addr       = alu_result;
  assign data_mem_write_data = rf_rs2_data;
  assign data_mem_funct3     = dec_funct3;
  assign data_mem_data_o     = dmem_data;

endmodule
