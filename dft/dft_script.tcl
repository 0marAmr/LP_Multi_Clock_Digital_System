########################### Define Top Module ############################
                                                   
set top_module SYS_TOP_DFT

##################### Define Working Library Directory ######################

define_design_lib work -path ./work

############################# Formality Setup File ##########################
                                                   
set_svf $top_module.svf

################## Design Compiler Library Files Setup ######################

puts "###########################################"
puts "#      #setting Design Libraries          #"
puts "###########################################"

#Add the Paths of the libraries and RTL Files to the search_path variable

set PROJECT_PATH "/home/IC/LP_Multi_Clk_Digital_System"

lappend search_path "$PROJECT_PATH/rtl"
lappend search_path "$PROJECT_PATH/rtl/UART"
lappend search_path "$PROJECT_PATH/rtl/ASYNC_FIFO"
lappend search_path "$PROJECT_PATH/rtl/DATA_SYNC"
lappend search_path "$PROJECT_PATH/std_cells"

set SSLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"

# Standard Cells Libraries (Timing Corners)
set target_library [list $SSLIB $FFLIB $TTLIB]


## Standard Cell & Hard Macros libraries 
set link_library [list "*" $SSLIB $FFLIB $TTLIB]

######################## Reading RTL Files #################################

puts "###########################################"
puts "#             Reading RTL Files           #"
puts "###########################################"

set file_format "verilog"

# MUX
analyze -format $file_format "mux2X1.v"
# UART
analyze -format $file_format "RX_DATA_SAMPLING.v"
analyze -format $file_format "RX_DESERIALIZER.v"
analyze -format $file_format "RX_FSM.v"
analyze -format $file_format "RX_PARITY_CHECK.v"
analyze -format $file_format "RX_EDGE_BIT_COUNTER.v"
analyze -format $file_format "RX_START_CHECK.v"
analyze -format $file_format "RX_STOP_CHECK.v"
analyze -format $file_format "TX_FSM.v"
analyze -format $file_format "TX_OUTPUT.v"
analyze -format $file_format "TX_PARITY_CALC.v"
analyze -format $file_format "TX_SERIALIZER.v"
analyze -format $file_format "UART_RX.v"
analyze -format $file_format "UART_TX.v"
analyze -format $file_format "UART.v"
# ASYNC_FIFO
analyze -format $file_format "ASYNC_FIFO_MEMORY.v"
analyze -format $file_format "ASYNC_FIFO_BIT_SYNC.v"
analyze -format $file_format "ASYNC_FIFO_RD.v"
analyze -format $file_format "ASYNC_FIFO_WR.v"
analyze -format $file_format "ASYNC_FIFO.v"
# DATA_SYNC
analyze -format $file_format "DATA_SYNC_EN_SYNC.v"
analyze -format $file_format "DATA_SYNC_OP.v"
analyze -format $file_format "DATA_SYNC_PULSE_GEN.v"
analyze -format $file_format "DATA_SYNC.v"
# CLK_DIVIDER
analyze -format $file_format "CLK_DIV.v"
# CLK_GATING
analyze -format $file_format "CLK_GATING.v"
# PRESCALE_CONVERTER
analyze -format $file_format "Prescale_to_DivRatio.v"
# PULSE_GENERATOR
analyze -format $file_format "PULSE_GEN.v"
# REGISTER_FILE
analyze -format $file_format "Register_File.v"
# RST_SYNC
analyze -format $file_format "RST_SYNC.v"
# ALU
analyze -format $file_format "ALU.v"
#SYS_CONTROLLER
analyze -format $file_format "SYS_CTRL.v"
#SYS_TOP
analyze -format $file_format "SYS_TOP_DFT.v"

elaborate -lib WORK SYS_TOP_DFT

###################### Defining toplevel ###################################

current_design $top_module

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design >> reports/check_design.rpt

#################### Define Design Constraints #########################
puts "###############################################"
puts "############ Design Constraints #### ##########"
puts "###############################################"

source -echo ./dft_cons.tcl

#################### Archirecture Scan Chains #########################
puts "###############################################"
puts "############ Configure scan chains ############"
puts "###############################################"

set_scan_configuration -clock_mixing no_mix -style multiplexed_flip_flop -replace true -max_length 100  

###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"


compile -scan

################################################################### 
# Setting Test Timing Variables
################################################################### 

# Preclock Measure Protocol (default protocol)
set test_default_period 100
set test_default_delay 0
set test_default_bidir_delay 0
set test_default_strobe 20
set test_default_strobe_width 0


########################## Define DFT Signals ##########################

set_dft_signal -port [get_ports scan_clk]  -type ScanClock   -view existing_dft  -timing {30 60}
set_dft_signal -port [get_ports scan_rst]  -type Reset       -view existing_dft  -active_state 0
set_dft_signal -port [get_ports test_mode] -type Constant    -view existing_dft  -active_state 1 
set_dft_signal -port [get_ports test_mode] -type TestMode    -view spec          -active_state 1 
set_dft_signal -port [get_ports SE]        -type ScanEnable  -view spec          -active_state 1   -usage scan
set_dft_signal -port [get_ports SI]        -type ScanDataIn  -view spec 
set_dft_signal -port [get_ports SO]        -type ScanDataOut -view spec  

############################# Create Test Protocol #######################
                                           
create_test_protocol

###################### Pre-DFT Design Rule Checking #######################

dft_drc -verbose

############################# Preview DFT ##############################

preview_dft -show scan_summary

############################# Insert DFT ##############################

insert_dft
compile -scan -incremental

###################### Design Rule Checking #######################

dft_drc -verbose -coverage_estimate

##################### Close Formality Setup file ###########################

set_svf -off

#############################################################################
# Write out files
#############################################################################

write_file -format verilog -hierarchy -output netlists/$top_module.ddc
write_file -format verilog -hierarchy -output netlists/$top_module.v
write_sdf  sdf/$top_module.sdf
write_sdc  -nosplit sdc/$top_module.sdc

####################### reporting ##########################################

report_area -hierarchy > reports/area.rpt
report_power -hierarchy > reports/power.rpt
report_timing -delay_type min -max_paths 20 > reports/hold.rpt
report_timing -delay_type max -max_paths 20 > reports/setup.rpt
report_clock -attributes > reports/clocks.rpt
report_constraint -all_violators -nosplit > reports/constraints.rpt

################# starting graphical user interface #######################

#gui_start

#exit
