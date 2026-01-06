// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Klenn Louie Laure

`include "CLK_CYCLE.sv"

module clkgen (
    output logic clk
);

  initial begin
    clk <= 0;
    forever #(`CLK_CYCLE / 2) clk <= ~clk;
  end

endmodule
