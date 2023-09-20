module UART_TX (
    input wire CLK, RST,
    input wire Data_Valid, PAR_EN, PAR_TYP,
    input wire [7:0] P_DATA,
    output wire TX_OUT, busy
);
    
    wire [1:0] mux_sel; 
    wire ser_done;
    wire ser_en;
    wire par_en;
    wire load;
    wire ser_data;
    wire par_bit;

    TX_FSM U0_FSM(
        .CLK(CLK),
        .RST(RST),
        .Data_Valid(Data_Valid),
        .PAR_EN(PAR_EN),
        .ser_done(ser_done),
        .ser_en(ser_en),
        .busy(busy),
        .mux_sel(mux_sel),
        .par_en(par_en),
        .load(load)
    );

    TX_SERIALIZER U0_SER (
        .CLK(CLK),
        .RST(RST),
        .ser_en(ser_en),
        .P_DATA(P_DATA),
        .ser_done(ser_done),
        .ser_data(ser_data),
        .load(load)
    );

    TX_PARITY_CALC U0_PAR_CALC (
        .CLK(CLK),
        .RST(RST),
        .par_en(par_en),
        .PAR_TYP(PAR_TYP),
        .P_DATA(P_DATA),
        .par_bit(par_bit)
    );

    TX_OUTPUT U0_OUTPUT(
        .CLK(CLK),
        .RST(RST),
        .mux_sel(mux_sel),
        .in0(1'b0),
        .in1(1'b1),
        .in2(ser_data),
        .in3(par_bit),
        .busy(busy),
        .TX_OUT(TX_OUT)
    );

endmodule