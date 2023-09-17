module UART #(
    parameter   DATA_WIDTH  = 8,
                PRESC_WIDTH = 6
)(
    input   wire                        TX_CLK,
    input   wire                        RX_CLK,
    input   wire                        RST,
    input   wire                        PAR_EN,
    input   wire                        TX_Data_Valid, 
    input   wire                        PAR_TYP,
    input   wire    [DATA_WIDTH-1:0]    TX_IN,
    input   wire                        RX_IN,
    input   wire    [PRESC_WIDTH-1:0]   Prescale,
    output  wire                        busy,
    output  wire    [DATA_WIDTH-1:0]    RX_OUT,
    output  wire                        TX_OUT, 
    output  wire                        RX_Data_Valid

);
    
///////////////////// UART Transmitter Instantiation///////////////////
    UART_TX U0_TX (
        .CLK(TX_CLK),
        .RST(RST),
        .Data_Valid(TX_Data_Valid),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .P_DATA(TX_IN),
        .TX_OUT(TX_OUT),
        .busy(busy)
    );
///////////////////// UART Reciever Instantiation///////////////////
    UART_RX U1_RX (
        .CLK(RX_CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .Prescale(Prescale),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .Data_Valid(RX_Data_Valid),
        .P_DATA(RX_OUT)
    );
endmodule