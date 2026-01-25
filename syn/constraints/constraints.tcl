
# ---------------------------------------------
# Clocks
# ---------------------------------------------
create_clock -domain domain_clk -name "clk" -period 20.0 [get_ports clk]

set_clock_transition 0.1 [get_clocks clk]

set_clock_uncertainty 1.0 [get_clocks clk]
set_clock_uncertainty 1.0 [get_clocks clk]

# ---------------------------------------------
# External delays
# ---------------------------------------------
# Input delays
set_input_delay 1.0 -clock clk [get_ports {instr_mem_data_i}]
set_input_delay 1.0 -clock clk [get_ports reset_n]
set_input_transition 0.08 [get_ports {instr_mem_data_i reset_n}]

# Output delays
set_output_delay 1.0 -clock clk [get_ports instr_mem_req_o]
set_output_delay 1.0 -clock clk [get_ports instr_mem_addr_o]
set_output_delay 1.0 -clock clk [get_ports data_mem_readreq_o]
set_output_delay 1.0 -clock clk [get_ports data_mem_writereq_o]
set_output_delay 1.0 -clock clk [get_ports data_mem_addr]
set_output_delay 1.0 -clock clk [get_ports data_mem_write_data]
set_output_delay 1.0 -clock clk [get_ports data_mem_funct3]
set_output_delay 1.0 -clock clk [get_ports data_mem_data_o]

# ---------------------------------------------
# False paths
# ---------------------------------------------
set_false_path -from [get_ports reset_n]

# ---------------------------------------------
# Design
# ---------------------------------------------

# Load
set_load 0.05 [all_outputs]

# DRC
set_max_fanout 15.0 [current_design]
set_max_transition 2.0 [current_design]
set_driving_cell -lib_cell BUF_X2 [all_outputs]
