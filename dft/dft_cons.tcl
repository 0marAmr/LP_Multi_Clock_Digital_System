
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
set R_CLK_NAME REF_CLK
set R_CLK_PER 10
set U_CLK_NAME UART_CLK
set U_CLK_PER 271.297
set S_CLK_NAME scan_clk
set S_CLK_PER 100

set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW 0.1
set CLK_LAT 0
set CLK_RISE_FALL 0.01

set RX_CLK_PER [expr $U_CLK_PER * 1]
set TX_CLK_PER [expr $U_CLK_PER * 32]


# 1. Master Clock Definitions 
create_clock -name $R_CLK_NAME -period $R_CLK_PER -waveform "0 [expr $R_CLK_PER/2]" [get_ports REF_CLK]
create_clock -name $U_CLK_NAME -period $U_CLK_PER -waveform "0 [expr $U_CLK_PER/2]" [get_ports UART_CLK]
create_clock -name $S_CLK_NAME -period $S_CLK_PER -waveform "0 [expr $S_CLK_PER/2]" [get_ports scan_clk]

# 2. Generated Clock Definitions
create_generated_clock -master_clock "REF_CLK" -source [get_ports REF_CLK] -name "ALU_CLK" -divide_by 1 [get_ports U_12_CLK_GATE/o_GATED_CLK]

create_generated_clock -master_clock "UART_CLK" -source [get_ports UART_CLK] -name "TX_CLK" -divide_by 32 [get_ports U10_TX_CLK_DIV/o_div_clk]
create_generated_clock -master_clock "UART_CLK" -source [get_ports UART_CLK] -name "RX_CLK" -divide_by 1 [get_ports U9_RX_CLK_DIV/o_div_clk]

# 3. Clock Latencies
set_clock_latency $CLK_LAT [get_clocks $R_CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $U_CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $S_CLK_NAME]

set_clock_latency $CLK_LAT [get_clocks ALU_CLK]
set_clock_latency $CLK_LAT [get_clocks RX_CLK]
set_clock_latency $CLK_LAT [get_clocks TX_CLK]


# 4. Clock Uncertainties
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $R_CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [get_clocks $R_CLK_NAME]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $U_CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [get_clocks $U_CLK_NAME]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks ALU_CLK]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [get_clocks ALU_CLK]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks RX_CLK]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [get_clocks RX_CLK]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks TX_CLK]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [get_clocks TX_CLK]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks scan_clk]
set_clock_uncertainty -hold $CLK_HOLD_SKEW [get_clocks scan_clk]

# 5. Clock Transitions
set_clock_transition $CLK_RISE_FALL [get_clocks $R_CLK_NAME]
set_clock_transition $CLK_RISE_FALL [get_clocks $U_CLK_NAME]
set_clock_transition $CLK_RISE_FALL [get_clocks RX_CLK]
set_clock_transition $CLK_RISE_FALL [get_clocks TX_CLK]
set_clock_transition $CLK_RISE_FALL [get_clocks ALU_CLK]


set_dont_touch_network "$R_CLK_NAME $U_CLK_NAME $S_CLK_NAME RST"

####################################################################################



####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################
set_clock_groups -asynchronous -group [get_clocks "$R_CLK_NAME ALU_CLK"] -group [get_clocks "$U_CLK_NAME RX_CLK TX_CLK"] -group [get_clocks $S_CLK_NAME]
  

####################################################################################
           #########################################################
             #### Section 3 : set input/output delay on ports ####
           #########################################################
####################################################################################
set in1_delay  [expr 0.2*$R_CLK_PER]
set out1_delay [expr 0.2*$R_CLK_PER]

set in2_delay  [expr 0.2*$RX_CLK_PER]
set out2_delay [expr 0.2*$RX_CLK_PER]

set in3_delay  [expr 0.2*$TX_CLK_PER]
set out3_delay [expr 0.2*$TX_CLK_PER]

set in4_delay  [expr 0.2*$S_CLK_PER]
set out4_delay [expr 0.2*$S_CLK_PER]

#Constrain Input Paths
set_input_delay $in1_delay -clock $R_CLK_NAME [get_port PAR_EN]
set_input_delay $in1_delay -clock $R_CLK_NAME [get_port PAR_TYP]
set_input_delay $in1_delay -clock $R_CLK_NAME [get_port PRESCALE]
set_input_delay $in2_delay -clock RX_CLK [get_port RX_IN]
set_input_delay $in4_delay -clock $S_CLK_NAME [get_port SI]
set_input_delay $in4_delay -clock $S_CLK_NAME [get_port SE]
set_input_delay $in4_delay -clock $S_CLK_NAME [get_port test_mode]


#Constrain Output Paths
set_output_delay $out3_delay -clock TX_CLK [get_port TX_OUT]
set_output_delay $out2_delay -clock RX_CLK [get_port PAR_ERR]
set_output_delay $out2_delay -clock RX_CLK [get_port STP_ERR]
set_output_delay $out4_delay -clock $S_CLK_NAME [get_port SO]


####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port PAR_EN]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port PAR_TYP]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port PRESCALE]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port RX_IN]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port SI]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port SE]
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port test_mode]


####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################
set_load 0.5 [get_port TX_OUT]
set_load 0.5 [get_port PAR_ERR]
set_load 0.5 [get_port STP_ERR]
set_load 0.5 [get_port SO]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################

#set_wire_load_model -name tsmc13_wl30 -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c

####################################################################################



