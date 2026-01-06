// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`include "uvm_macros.svh"

`include "CLK_CYCLE.sv"
`include "clkgen.sv"

`include "dut_if.sv"
`include "model_instr_mem.sv"

module top;
  // import uvm_pkg::*;

  // -----------------------------------
  // TEST files
  // -----------------------------------
  localparam string HEX_F = "all_instr_chain_test.hex";          // <Change hex file to load to instruction memory model>
  localparam string HEX_F_DIR = "../tb/programs";
  localparam string INSTR_MEM_LOAD = $sformatf("%s/%s", HEX_F_DIR, HEX_F);

  // Load data memory
  localparam string DATA_HEX_F = "array_data_mem.hex";
  localparam string DATA_HEX_LOAD = $sformatf("%s/%s", HEX_F_DIR, DATA_HEX_F);
  // END -------------------------------

  logic clk;

  // Instantiate DUT interface
  dut_if dif (clk);

  // Instantiate clock generator
  clkgen ck (clk);

  // Instantiate DUT
  rv32i_core u_dut (
    .clk             (clk),
    .reset_n         (dif.reset_n),
    .instr_mem_data_i(dif.instr_mem_data_i),

    .instr_mem_req_o    (dif.instr_mem_req_o),
    .instr_mem_addr_o   (dif.instr_mem_addr_o),
    .data_mem_readreq_o (dif.data_mem_readreq_o),
    .data_mem_writereq_o(dif.data_mem_writereq_o),
    .data_mem_addr      (dif.data_mem_addr),
    .data_mem_write_data(dif.data_mem_write_data),
    .data_mem_funct3    (dif.data_mem_funct3),
    .data_mem_data_o    (dif.data_mem_data_o)
  );
  
  // Instantiate Instruction memory block
  model_instr_mem #(
    .MEM_WIDTH(32),
    .MEM_DEPTH(2048),
    .INIT_FILE(INSTR_MEM_LOAD)
  ) u_model_instr_mem (
    .clk    (clk),
    .reset_n(dif.reset_n),
    .addr   (dif.instr_mem_addr_o),

    .instr_o(dif.instr_mem_data_i)
  );


  // -----------------------------------
  // Memory-mapped sim output
  // -----------------------------------
  // Table header
  initial begin
    #1;
    $display("\n--- Memory-mapped Output Table ---");
    $display("%-10s | %-10s | %-12s | %-16s | %-12s",
            "Time (ps)", "InstrAddr", "Instr", "WriteData_dec", "WriteData_hex");
    $display("%s",
            "----------------------------------------------------------------------------------------------");
  end

  always @(posedge clk) begin
    if (dif.data_mem_writereq_o && dif.data_mem_addr == 32'h1000_0000) begin
      $display("%-10s | %-10s | %-12s | %-16s | %-12s",
        $sformatf("%0t",        $time),
        $sformatf("0x%08h",     dif.instr_mem_addr_o),
        $sformatf("0x%08h",     dif.instr_mem_data_i),
        $sformatf("%0d",        dif.data_mem_write_data),
        $sformatf("0x%08h",     dif.data_mem_write_data)
      );
    end
  end
  // END -------------------------------

  // Load data memory
  initial begin
    $display("Data memory: Loading memory... %s", DATA_HEX_LOAD);
    $readmemh(DATA_HEX_LOAD, u_dut.u_data_mem_b.mem);
  end

  // Sim
  initial begin
    dif.reset_n = 0;
    repeat (2) @(dif.clk);
    dif.reset_n = 1;

    #10000;
    $finish;
  end

endmodule
