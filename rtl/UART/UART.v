module UART #(
    parameter   DATA_WIDTH  = 8,
                PRESC_WIDTH = 6
)(
    input   wire                        i_TX_CLK,
    input   wire                        i_RX_CLK,
    input   wire                        i_RST,
    input   wire                        i_PAR_EN,
    input   wire                        i_TX_Data_Valid, 
    input   wire                        i_PAR_TYP,
    input   wire    [DATA_WIDTH-1:0]    i_TX_IN,
    input   wire                        i_RX_IN,
    input   wire    [PRESC_WIDTH-1:0]   i_Prescale,
    output  wire                        o_busy,
    output  wire    [DATA_WIDTH-1:0]    o_RX_OUT,
    output  wire                        o_TX_OUT, 
    output  wire                        o_RX_Data_Valid,
    output  wire                        o_par_err,
    output  wire                        o_stp_err

);
    
///////////////////// UART Transmitter Instantiation///////////////////
    UART_TX U0_TX (
        .CLK(i_TX_CLK),
        .RST(i_RST),
        .Data_Valid(i_TX_Data_Valid),
        .PAR_EN(i_PAR_EN),
        .PAR_TYP(i_PAR_TYP),
        .P_DATA(i_TX_IN),
        .TX_OUT(o_TX_OUT),
        .busy(o_busy)
    );
    
///////////////////// UART Reciever Instantiation///////////////////
    UART_RX U1_RX (
        .CLK(i_RX_CLK),
        .RST(i_RST),
        .RX_IN(i_RX_IN),
        .Prescale(i_Prescale),
        .PAR_EN(i_PAR_EN),
        .PAR_TYP(i_PAR_TYP),
        .Data_Valid(o_RX_Data_Valid),
        .P_DATA(o_RX_OUT),
        .par_err(o_par_err),
        .stp_err(o_stp_err)
    );

endmodule
