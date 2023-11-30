############################  Search PATH ################################

set PROJECT_PATH "/home/IC/LP_Multi_Clk_Digital_System"
set LIB_PATH     "/home/IC/tsmc_fb_cl013g_sc/aci/sc-m"

lappend search_path "$LIB_PATH/synopsys"
lappend search_path "$PROJECT_PATH/rtl"
lappend search_path "$PROJECT_PATH/rtl/UART"
lappend search_path "$PROJECT_PATH/rtl/ASYNC_FIFO"
lappend search_path "$PROJECT_PATH/rtl/DATA_SYNC"
lappend search_path "$PROJECT_PATH/std_cells"

########################### Define Top Module ############################
                                                   
set top_module SYS_TOP_DFT

############################## Formality Setup File ##############################
set synopsys_auto_setup true
set_svf "$PROJECT_PATH/dft/$top_module.svf"

####################### Read Reference tech libs ########################

set SSLIB "$PROJECT_PATH/std_cells/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "$PROJECT_PATH/std_cells/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "$PROJECT_PATH/std_cells/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

read_db -container Ref [list $SSLIB $TTLIB $FFLIB]

## Read Reference Design Files
# MUX
read_verilog -container Ref "mux2X1.v"
# UART
read_verilog -container Ref "RX_DATA_SAMPLING.v"
read_verilog -container Ref "RX_DESERIALIZER.v"
read_verilog -container Ref "RX_FSM.v"
read_verilog -container Ref "RX_PARITY_CHECK.v"
read_verilog -container Ref "RX_EDGE_BIT_COUNTER.v"
read_verilog -container Ref "RX_START_CHECK.v"
read_verilog -container Ref "RX_STOP_CHECK.v"
read_verilog -container Ref "TX_FSM.v"
read_verilog -container Ref "TX_OUTPUT.v"
read_verilog -container Ref "TX_PARITY_CALC.v"
read_verilog -container Ref "TX_SERIALIZER.v"
read_verilog -container Ref "UART_RX.v"
read_verilog -container Ref "UART_TX.v"
read_verilog -container Ref "UART.v"
# ASYNC_FIFO
read_verilog -container Ref "ASYNC_FIFO_MEMORY.v"
read_verilog -container Ref "ASYNC_FIFO_BIT_SYNC.v"
read_verilog -container Ref "ASYNC_FIFO_RD.v"
read_verilog -container Ref "ASYNC_FIFO_WR.v"
read_verilog -container Ref "ASYNC_FIFO.v"
# DATA_SYNC
read_verilog -container Ref "DATA_SYNC_EN_SYNC.v"
read_verilog -container Ref "DATA_SYNC_OP.v"
read_verilog -container Ref "DATA_SYNC_PULSE_GEN.v"
read_verilog -container Ref "DATA_SYNC.v"
# CLK_DIVIDER
read_verilog -container Ref "CLK_DIV.v"
# CLK_GATING
read_verilog -container Ref "CLK_GATING.v"
# PRESCALE_CONVERTER
read_verilog -container Ref "Prescale_to_DivRatio.v"
# PULSE_GENERATOR
read_verilog -container Ref "PULSE_GEN.v"
# REGISTER_FILE
read_verilog -container Ref "Register_File.v"
# RST_SYNC
read_verilog -container Ref "RST_SYNC.v"
# ALU
read_verilog -container Ref "ALU.v"
#SYS_CONTROLLER
read_verilog -container Ref "SYS_CTRL.v"
#SYS_TOP_DFT
read_verilog -container Ref "SYS_TOP_DFT.v"

######################## set the top Reference Design ######################## 

set_reference_design SYS_TOP_DFT
set_top SYS_TOP_DFT

####################### Read Implementation tech libs ######################## 

read_db -container Imp [list $SSLIB $TTLIB $FFLIB]

#################### Read Implementation Design Files ######################## 

read_verilog -container Imp -netlist "$PROJECT_PATH/dft/netlists/SYS_TOP_DFT.v"


####################  set the top Implementation Design ######################

set_implementation_design SYS_TOP_DFT
set_top SYS_TOP_DFT


## matching Compare points
match

## verify
set successful [verify]
if {!$successful} {
diagnose
analyze_points -failing
}

report_passing_points > "reports/passing_points.rpt"
report_failing_points > "reports/failing_points.rpt"
report_aborted_points > "reports/aborted_points.rpt"
report_unverified_points > "reports/unverified_points.rpt"


start_gui
