
# Set units
# set_units -time ns
# (Assumes default SDC time units)


# Clocks
create_clock -name "clk_main" -period 20.0 -waveform {0.0 10.0} [get_ports clk]
set_clock_uncertainty -setup 1.0 [get_clocks clk_main]
set_clock_uncertainty -hold 0.2 [get_clocks clk_main]

# ---------------------------------------------
# External delays
# ---------------------------------------------
# Input delays
set_input_delay 1.0 -clock clk_main [get_ports instr_mem_data_i]
#set_input_transition 0.2 [get_ports instr_mem_data_i]
set_input_delay 1.0 -clock clk_main [get_ports reset_n]
#set_input_transition 0.2 [get_ports reset_n]

# Output delays
set_output_delay 1.0 -clock clk_main [get_ports instr_mem_req_o]
set_output_delay 1.0 -clock clk_main [get_ports instr_mem_addr_o]
set_output_delay 1.0 -clock clk_main [get_ports data_mem_readreq_o]
set_output_delay 1.0 -clock clk_main [get_ports data_mem_writereq_o]
set_output_delay 1.0 -clock clk_main [get_ports data_mem_addr]
set_output_delay 1.0 -clock clk_main [get_ports data_mem_write_data]
set_output_delay 1.0 -clock clk_main [get_ports data_mem_funct3]
set_output_delay 1.0 -clock clk_main [get_ports data_mem_data_o]

# Drivers
set_drive 2.0 [all_inputs]

# Load
set_load 0.1 [all_outputs]

# Path exceptions
set_false_path -from [get_ports reset_n]

# DRC
set_max_fanout 15.0 [current_design]
set_max_transition 2.0 [current_design]
