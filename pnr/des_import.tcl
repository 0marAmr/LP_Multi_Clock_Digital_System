################################ Variables ####################################

set load_fp 0

################# Define Top Module & Gate Level Netlist ######################
set PROJECT_PATH "/home/ahesham/LP_Multi_Clock_Digital_System"
set top_module SYS_TOP_DFT
set gate_level_netlist "$PROJECT_PATH/dft/netlists/SYS_TOP_DFT.v"

setUIVar rda_Input ui_topcell $top_module
setUIVar rda_Input ui_netlist $gate_level_netlist	

##################### Define Tech Libraries Timing Views ######################
set FFLIB "$PROJECT_PATH/std_cells/libs/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.lib"
set SSLIB "$PROJECT_PATH/std_cells/libs/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.lib"
set TTLIB "$PROJECT_PATH/std_cells/libs/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"

setUIVar rda_Input ui_timelib,min $FFLIB
setUIVar rda_Input ui_timelib,max $SSLIB
setUIVar rda_Input ui_timelib $TTLIB

##################### Define Tech Libraries LEF Views #########################
set TECH_LEF   "$PROJECT_PATH/std_cells/lef/tsmc13fsg_7lm_tech.lef"
set MACRO_LEF  "$PROJECT_PATH/std_cells/lef/tsmc13_m_macros.lef"
set DESIGN_LEF "$PROJECT_PATH/pnr/import/SYS_TOP_DFT.lef"

if {$load_fp == 0} {

setUIVar rda_Input ui_leffile [list $TECH_LEF $MACRO_LEF $DESIGN_LEF]

} else {

setUIVar rda_Input ui_leffile [list $TECH_LEF $MACRO_LEF]

}
######################## Define Capacitance Table #############################
set CAP_TABLE_FILE  "$PROJECT_PATH/std_cells/captables/tsmc13fsg.capTbl"

setUIVar rda_Input ui_captbl_file $CAP_TABLE_FILE
                    
######################### Define Constraints File #############################
set SDC_FILE "$PROJECT_PATH/dft/sdc/SYS_TOP_DFT_function.sdc"

setUIVar rda_Input ui_timingcon_file $SDC_FILE  

############################# Define PG Pins  #################################
set gnd_net_name VSS
set pwr_net_name VDD

setUIVar rda_Input ui_pwrnet $pwr_net_name
setUIVar rda_Input ui_gndnet $gnd_net_name


commitConfig



################ Define Multi Mode Multi Corner Analysis  #####################

source ./import/MMMC.tcl

