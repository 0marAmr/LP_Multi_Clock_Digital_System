`timescale 1ps/1ps

module SYS_TOP_TB;

        

    ///////////////////////////////////////////////////////////////
    ///////////////////// Local Parameters ////////////////////////
    ///////////////////////////////////////////////////////////////
    
    localparam RF_Wr_CMD            = 8'hAA;
    localparam RF_Rd_CMD            = 8'hBB;
    localparam ALU_OPER_W_OP_CMD    = 8'hCC;
    localparam ALU_OPER_W_NOP_CMD   = 8'hDD;
    localparam  EVEN_PARITY     = 'b0;
    localparam  ODD_PARITY      = 'b1;

    /////////////////////////////////////////////////////////
    ///////////////////// Parameters ////////////////////////
    /////////////////////////////////////////////////////////
   
    ////////////////////// DEVICE CONFIGURATIONS /////////////////////
    
    parameter   PAR_TYPE        = EVEN_PARITY;
    parameter   PAR_ENABLE      = 1;
    parameter   PRESCALE_VALUE  = 32;


    ////////////////////// DO NOT CHANGE !! /////////////////////
   
    parameter   DATA_WIDTH      = 8;
    parameter   FRAME_WIDTH     = 8;
    parameter   ALU_FUN_WIDTH   = 4;
    parameter   REG_ADDR_WIDTH  = 4;
    parameter   ADDR_WIDTH      = 4;
    parameter   REF_CLK_PERIOD  = 20;
    parameter   PRESC_WIDTH     = 6;
    parameter   UART_CLK_PERIOD = 271.267;
    parameter   TX_CLK_PERIOD   = UART_CLK_PERIOD * PRESCALE_VALUE;



    localparam [ALU_FUN_WIDTH-1:0]  Addition        = 4'b0000,
                                    Subtraction     = 4'b0001,
                                    Multiplication  = 4'b0010,
                                    Division        = 4'b0011,
                                    AND             = 4'b0100,
                                    OR              = 4'b0101,
                                    NAND            = 4'b0110,
                                    NOR             = 4'b0111,
                                    XOR             = 4'b1000,
                                    XNOR            = 4'b1001,
                                    AeqB            = 4'b1010,
                                    AgtB            = 4'b1011,
                                    AltB            = 4'b1100,
                                    SHLA            = 4'b1101,
                                    SHRA            = 4'b1110;

    /////////////////////////////////////////////////////////
    //////////////////// DUT Signals ////////////////////////
    /////////////////////////////////////////////////////////

    reg                         REF_CLK_TB;
    reg                         UART_CLK_TB;
    reg                         RST_TB;
    reg                         RX_IN_TB;
    reg                         PAR_EN_TB;
    reg                         PAR_TYP_TB;
    reg     [PRESC_WIDTH-1:0]   PRESCALE_TB;
    wire                        TX_OUT_TB;
    wire                        PAR_ERR_TB;
    wire                        STP_ERR_TB;
    reg     [FRAME_WIDTH-1:0]   RECEIVED_FRAME = 0;
    reg     [2*FRAME_WIDTH-1:0] ALU_OP_RESULT  = 0;

    /////////////////////////////////////////////////////////
    ///////////////// Loops Variables ///////////////////////
    /////////////////////////////////////////////////////////

    integer i;

    ////////////////////////////////////////////////////////
    ////////////////// initial block ///////////////////////
    ////////////////////////////////////////////////////////

    initial begin
        initialize();
        configure(PAR_ENABLE, PAR_TYPE, PRESCALE_VALUE);
        reset();
        reg_file_write(11, 22);
        #(TX_CLK_PERIOD)

        reg_file_read(11, RECEIVED_FRAME);
        #(TX_CLK_PERIOD)

        alu_op_w_operands(5, 6, Multiplication, ALU_OP_RESULT[7:0], ALU_OP_RESULT[15:8]);
        #(TX_CLK_PERIOD)
        alu_op_w_operands(15, 2, Division, ALU_OP_RESULT[7:0], ALU_OP_RESULT[15:8]);
        #(TX_CLK_PERIOD)
        alu_op_w_operands(255, 4, Multiplication, ALU_OP_RESULT[7:0], ALU_OP_RESULT[15:8]);
        #(TX_CLK_PERIOD)
        alu_op_n_operands(Addition, ALU_OP_RESULT[7:0], ALU_OP_RESULT[15:8]);
        #(TX_CLK_PERIOD)
        alu_op_n_operands(Subtraction, ALU_OP_RESULT[7:0], ALU_OP_RESULT[15:8]);
        #(TX_CLK_PERIOD)
        alu_op_w_operands(255, 254, AgtB, ALU_OP_RESULT[7:0], ALU_OP_RESULT[15:8]);
        #(5*TX_CLK_PERIOD)
        $finish;
    end

    ////////////////////////////////////////////////////////
    /////////////////////// TASKS //////////////////////////
    ////////////////////////////////////////////////////////
    
    /////////////// Device Configuration //////////////////
   
    task configure (
        input                   par_en,
        input                   par_type,
        input [PRESC_WIDTH-1:0] presc
    );
    begin
        PAR_TYP_TB = par_type;
        PAR_EN_TB = par_en;
        PRESCALE_TB = presc;
    end
    endtask
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

    ///////////////////////// ALU OPERATION WITH OPERANDS /////////////////////////
    task alu_op_w_operands(
        input   [FRAME_WIDTH-1:0]   operand1,
        input   [FRAME_WIDTH-1:0]   operand2,
        input   [FRAME_WIDTH-1:0]   alu_fun,
        output   [FRAME_WIDTH-1:0]  LSByte,
        output   [FRAME_WIDTH-1:0]  MSByte
    );
    begin
        send_frame(ALU_OPER_W_OP_CMD);
        send_frame(operand1);
        send_frame(operand2);
        send_frame(alu_fun);
        receive_frame(LSByte);
        receive_frame(MSByte);
    end
    endtask

    ///////////////////////// ALU OPERATION WITHOUT OPERANDS /////////////////////////
    task alu_op_n_operands(
        input   [FRAME_WIDTH-1:0]   alu_fun,
        output   [FRAME_WIDTH-1:0]  LSByte,
        output   [FRAME_WIDTH-1:0]  MSByte
    );
    begin
        send_frame(ALU_OPER_W_NOP_CMD);
        send_frame(alu_fun);
        receive_frame(LSByte);
        receive_frame(MSByte);
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
        .PAR_EN(PAR_EN_TB),
        .PAR_TYP(PAR_TYP_TB),
        .PRESCALE(PRESCALE_TB),
        .TX_OUT(TX_OUT_TB),
        .PAR_ERR(PAR_ERR_TB),
        .STP_ERR(STP_ERR_TB)
    );

endmodule
