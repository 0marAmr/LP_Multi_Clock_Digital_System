module SYS_TOP  #(
    parameter   DATA_WIDTH      = 8,
                ALU_FUN_WIDTH   = 4,
                REG_ADDR_WIDTH  = 4,
                ADDR_WIDTH = 4


)(
    input   wire                    REF_CLK,
    input   wire                    UART_CLK,
    input   wire                    RST,
    input   wire                    RX_IN,
    output  wire                    TX_OUT
);

    ///////////////////////////////////////////////////////////////
    /////////////////////////// ALU ///////////////////////////////
    ///////////////////////////////////////////////////////////////
 
    wire ALU_CLK;
    wire REF_SYNC_RST;
    wire UART_SYNC_RST;
    wire [DATA_WIDTH-1:0] Op_A;
    wire [DATA_WIDTH-1:0] Op_B;
    wire [ALU_FUN_WIDTH-1:0] FUN;
    wire ALU_EN;
    wire [2*DATA_WIDTH-1:0] ALU_OUT;
    wire OUT_Valid;

    ALU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U0_ALU (
        .i_CLK(ALU_CLK),
        .i_RST(REF_SYNC_RST),
        .i_A(Op_A),
        .i_B(Op_B),
        .i_ALU_FUN(FUN),
        .i_Enable(ALU_EN),
        .o_ALU_OUT(ALU_OUT),
        .o_OUT_Valid(OUT_Valid)
    );

    ///////////////////////////////////////////////////////////////////
    /////////////////////////// Register File /////////////////////////
    ///////////////////////////////////////////////////////////////////
 
    wire RdEn;
    wire WrEn;
    wire [ADDR_WIDTH-1:0] Addr;
    wire [DATA_WIDTH-1:0] Wr_D;
    wire [DATA_WIDTH-1:0] Rd_D;
    wire [DATA_WIDTH-1:0] UART_Config;
    wire [DATA_WIDTH-1:0] Div_Ratio;
    wire RdData_Valid;

    Register_File #(
        .REG_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(REG_ADDR_WIDTH)
    ) U1_REG_FILE (
        .i_CLK(REF_CLK),
        .i_RST(REF_SYNC_RST),
        .i_RdEn(RdEn),
        .i_WrEn(WrEn),
        .i_Address(Addr),
        .i_WrData(Wr_D),
        .o_RdData(Rd_D),
        .o_RdData_Valid(RdData_Valid),
        .o_REG0(Op_A),
        .o_REG1(Op_B),
        .o_REG2(UART_Config),
        .o_REG3(Div_Ratio)
    );
    
    ///////////////////////////////////////////////////////////////////////
    /////////////////////////// System Controller /////////////////////////
    ///////////////////////////////////////////////////////////////////////
 
    wire [DATA_WIDTH-1:0] RX_Out_Sync;
    wire RX_Sync_Data_Valid;
    wire [DATA_WIDTH-1:0] FIFO_WR_DATA;
    wire FIFO_Wr_Inc;
    wire FIFO_Full;
    wire Gate_En;
    wire TX_Data_Valid;
    wire Clk_Div_En;

    SYS_CTRL #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH (REG_ADDR_WIDTH),
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH)
    ) U2_CONTROLLER (
        .i_CLK(REF_CLK),
        .i_RST(REF_SYNC_RST),
        .i_ALU_OUT(ALU_OUT),
        .i_OUT_Valid(OUT_Valid),
        .i_RdData(Rd_D),
        .i_RdData_Valid(RdData_Valid),
        .i_RX_P_DATA(RX_Out_Sync),
        .i_RX_D_VLD(RX_Sync_Data_Valid),
        .i_FIFO_FULL(FIFO_Full),
        .o_ALU_FUN(FUN),
        .o_Address(Addr),
        .o_WrData(Wr_D),
        .o_FIFO_DATA(FIFO_WR_DATA),
        .o_WR_INC(FIFO_Wr_Inc),
        .o_WrEn(WrEn),
        .o_RdEn(RdEn),
        .o_ALU_EN(ALU_EN),
        .o_CLK_EN(Gate_En),
        .o_TX_D_VLD(TX_Data_Valid),
        .o_clk_div_en(Clk_Div_En)
    );

    //////////////////////////////////////////////////////////////////
    ///////////////////////// UART Interface /////////////////////////
    //////////////////////////////////////////////////////////////////

    wire TX_CLK;
    wire RX_CLK;
    wire [DATA_WIDTH-1:0] FIFO_TX_RD_Data;
    wire FIFO_Empty;
    wire TX_Busy;
    wire [DATA_WIDTH-1:0] RX_Out;
    wire RX_Out_Data_Valid;

    UART #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U3_UART_INTERFACE (
        .i_TX_CLK(TX_CLK),
        .i_RX_CLK(RX_CLK),
        .i_RST(UART_SYNC_RST),
        .i_PAR_EN(UART_Config[0]),
        .i_TX_Data_Valid(~FIFO_Empty && TX_Data_Valid),
        .i_PAR_TYP(UART_Config[0]),
        .i_TX_IN(FIFO_TX_RD_Data),
        .i_RX_IN(RX_IN),
        .i_Prescale(UART_Config[7:2]),
        .o_busy(TX_Busy),
        .o_RX_OUT(RX_Out),
        .o_TX_OUT(TX_OUT),
        .o_RX_Data_Valid(RX_Out_Data_Valid)
    );

    /////////////////////////////////////////////////////////////
    //////////////////////// ASYNC_FIFO /////////////////////////
    /////////////////////////////////////////////////////////////

    wire Pulse_Gen_RD_INC;

    ASYNC_FIFO #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U4_ASYNCHRONOUS_FIFO (
        .i_W_CLK(REF_CLK),
        .i_W_RST(REF_SYNC_RST),
        .i_W_INC(FIFO_Wr_Inc),
        .i_WR_DATA(FIFO_WR_DATA),
        .i_R_CLK(UART_CLK),
        .i_R_RST(UART_SYNC_RST),
        .i_R_INC(Pulse_Gen_RD_INC),
        .o_FULL(FIFO_FULL),
        .o_EMPTY(FIFO_Empty),
        .o_RD_DATA(FIFO_TX_RD_Data)
    );

    /////////////////////////////////////////////////////////////
    //////////////////////// PULSE_GEN //////////////////////////
    /////////////////////////////////////////////////////////////
 
    PULSE_GEN U5_RD_INC_PULSE_GEN (
        .i_CLK(UART_CLK),
        .i_RST(UART_SYNC_RST),
        .i_pulse_en(TX_Busy),
        .o_pulse_signal(Pulse_Gen_RD_INC)
    );
    
    ////////////////////////////////////////////////////////////////
    //////////////////////// DATA_SYNCHRONIZER /////////////////////
    ////////////////////////////////////////////////////////////////
 
    DATA_SYNC #(
        .NUM_STAGES(2),
        .BUS_WIDTH(DATA_WIDTH)
    ) U6_RX_to_SYS_CTRL_DATA_SYNC (
        .i_CLK(REF_CLK),
        .i_RST(SYNC_REF_RST),
        .i_unsync_bus(RX_Out),
        .i_bus_enable(RX_Out_Data_Valid),
        .o_sync_bus(RX_Out_Sync),
        .o_enable_pulse(RX_Sync_Data_Valid)
    );
 
    //////////////////////////////////////////////////////////////////
    ///////////////////////// RST_SYNCHRONIZERS //////////////////////
    //////////////////////////////////////////////////////////////////
 
    RST_SYNC #(
        .NUM_STAGES(2)
    ) U7_REF_RST_SYNC (
        .i_CLK(REF_CLK),
        .i_RST(RST),
        .o_SYNC_RST(REF_SYNC_RST)
    );

    RST_SYNC #(
        .NUM_STAGES(2)
    ) U8_UART_RST_SYNC (
        .i_CLK(UART_CLK),
        .i_RST(RST),
        .o_SYNC_RST(UART_SYNC_RST)
    );

    ////////////////////////////////////////////////////////////////
    //////////////////////// CLOCK Divider /////////////////////////
    ////////////////////////////////////////////////////////////////

    wire [7:0] RX_CLK_Div_Ratio;

    CLK_DIV #(
        .DIV_RATIO_WIDTH(8)
    ) U9_RX_CLK_DIV(
        .i_ref_clk(UART_CLK),
        .i_rst_n(UART_SYNC_RST),
        .i_clk_en(Clk_Div_En),
        .i_div_ratio(RX_CLK_Div_Ratio),
        .o_div_clk(RX_CLK)
    );
    
    CLK_DIV #(
        .DIV_RATIO_WIDTH(8)
    ) U10_TX_CLK_DIV(
        .i_ref_clk(UART_CLK),
        .i_rst_n(UART_SYNC_RST),
        .i_clk_en(Clk_Div_En),
        .i_div_ratio(Div_Ratio),
        .o_div_clk(TX_CLK)
    );

    ////////////////////////////////////////////////////////////////////////
    //////////////////////////// Presc to DivRatio /////////////////////////
    ////////////////////////////////////////////////////////////////////////

    Prescale_to_DivRatio U11_Prescale_to_DivRatio_Conv (
        .i_Prescale(UART_Config[7:2]),
        .o_Div_Ratio_OUT(RX_CLK_Div_Ratio)
    );


    ///////////////////////////////////////////////////////////////////
    //////////////////////////// Clock Gate ///////////////////////////
    ///////////////////////////////////////////////////////////////////

    CLK_GATING U_12_CLK_GATE (
        .i_CLK(REF_CLK),
        .i_CLK_EN(Gate_En),
        .o_GATED_CLK(ALU_CLK)
    );



endmodule