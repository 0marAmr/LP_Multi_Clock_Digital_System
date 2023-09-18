`timescale 1ps/1ps

module SYS_TOP_TB;

    /////////////////////////////////////////////////////////
    ///////////////////// Parameters ////////////////////////
    /////////////////////////////////////////////////////////

    parameter   DATA_WIDTH      = 8;
    parameter   FRAME_WIDTH     = 8;
    parameter   ALU_FUN_WIDTH   = 4;
    parameter   REG_ADDR_WIDTH  = 4;
    parameter   ADDR_WIDTH      = 4;
    parameter   REF_CLK_PERIOD  = 20;
    parameter   UART_CLK_PERIOD = 271.267;
    parameter   TX_CLK_PERIOD = UART_CLK_PERIOD * 32;
    
    localparam RF_Wr_CMD            = 8'hAA;
    localparam RF_Rd_CMD            = 8'hBB;
    localparam ALU_OPER_W_OP_CMD    = 8'hCC;
    localparam ALU_OPER_W_NOP_CMD   = 8'hDD;

    /////////////////////////////////////////////////////////
    //////////////////// DUT Signals ////////////////////////
    /////////////////////////////////////////////////////////

    reg                         REF_CLK_TB;
    reg                         UART_CLK_TB;
    reg                         RST_TB;
    reg                         RX_IN_TB;
    wire                        TX_OUT_TB;
    reg     [FRAME_WIDTH-1:0]   RECEIVED_FRAME;

    /////////////////////////////////////////////////////////
    ///////////////// Loops Variables ///////////////////////
    /////////////////////////////////////////////////////////

    integer i;

    ////////////////////////////////////////////////////////
    ////////////////// initial block ///////////////////////
    ////////////////////////////////////////////////////////

    initial begin
        initialize();
        reset();
        reg_file_write(11, 22);
        # (TX_CLK_PERIOD)
        
        reg_file_read(11, RECEIVED_FRAME);
        #(TX_CLK_PERIOD)
        $finish;
    end

    ////////////////////////////////////////////////////////
    /////////////////////// TASKS //////////////////////////
    ////////////////////////////////////////////////////////

    /////////////// Signals Initialization //////////////////

    task initialize;
    begin
        RX_IN_TB = 1; // in IDLE state RX_IN must be high
    end
    endtask

    ///////////////////////// RESET /////////////////////////

    task reset;
    begin
        RST_TB = 1;
        #5
        RST_TB = 0;
        #5
        RST_TB = 1;
    end
    endtask
    
    ///////////////////////// SEND FRAME (TX SIMULATION) /////////////////////////

    task send_frame (
        input [FRAME_WIDTH-1:0] Data
    );
    begin
        RX_IN_TB = 0;           // start bit
        #(TX_CLK_PERIOD)   // 32 is prescale value
        for (i = 0; i< FRAME_WIDTH; i = i + 1) begin
            RX_IN_TB = Data[i];
            #(TX_CLK_PERIOD)
            RX_IN_TB = Data[i];
        end
        RX_IN_TB = ~^Data;       // even parity by default
        #(TX_CLK_PERIOD)
        RX_IN_TB = 1;
        #(TX_CLK_PERIOD)
        RX_IN_TB = 1;
    end
    endtask

    ///////////////////////// RECEIVE FRAME (RX SIMULATION) /////////////////////////

    task receive_frame (
        output [FRAME_WIDTH-1:0] Data
    );
    begin
        @(negedge TX_OUT_TB) // wait for start bit
        #(TX_CLK_PERIOD) 
        for (i = 0; i< FRAME_WIDTH; i = i + 1) begin
            #(TX_CLK_PERIOD) // sample @ the middle of the period
            Data[i]= TX_OUT_TB;
        end
        #(TX_CLK_PERIOD)          
        if (TX_OUT_TB != ~^Data)    // even parity by default
            Data = 0; // error
        
    end
    endtask

    ///////////////////////// REG WRITE /////////////////////////
    
    task reg_file_write(
        input [FRAME_WIDTH-1:0] Addr,
        input [FRAME_WIDTH-1:0] Data
    );
    begin
        send_frame(RF_Wr_CMD);
        send_frame(Addr);
        send_frame(Data);
    end
    endtask
 
    ///////////////////////// REG READ /////////////////////////

    task reg_file_read(
        input   [FRAME_WIDTH-1:0]   Addr,
        output  [FRAME_WIDTH-1:0]   Data
    );
    begin
        send_frame(RF_Rd_CMD);
        send_frame(Addr);
        receive_frame(Data);
    end
    endtask

    /////////////////////////////////////////////////////////
    ////////////////// Clock Generators  ////////////////////
    /////////////////////////////////////////////////////////

    /////////////// REF CLK Generator //////////////////

    initial begin
        REF_CLK_TB = 0;
        forever begin
            #(REF_CLK_PERIOD/2)
            REF_CLK_TB = ~ REF_CLK_TB;
        end
    end

    /////////////// UART CLK Generator //////////////////

    initial begin
        UART_CLK_TB = 0;
        forever begin
            #(UART_CLK_PERIOD/2)
            UART_CLK_TB = ~ UART_CLK_TB;
        end
    end

    ////////////////////////////////////////////////////////
    /////////////////// DUT Instantation ///////////////////
    ////////////////////////////////////////////////////////
    
    SYS_TOP  #(
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .REF_CLK(REF_CLK_TB),
        .UART_CLK(UART_CLK_TB),
        .RST(RST_TB),
        .RX_IN(RX_IN_TB),
        .TX_OUT(TX_OUT_TB)
    );

endmodule
