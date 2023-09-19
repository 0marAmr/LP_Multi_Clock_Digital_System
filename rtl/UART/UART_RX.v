module UART_RX #(
    parameter DATA_WIDTH = 8
)(
    input   wire                    CLK,                 // RX Clock input signal
    input   wire                    RST,   
    input   wire                    RX_IN,
    input   wire  [5:0]             Prescale,
    input   wire                    PAR_EN,
    input   wire                    PAR_TYP,
    output  wire                    Data_Valid,
    output  wire                    par_err,
    output  wire                    stp_err,
    output  wire  [DATA_WIDTH-1:0]  P_DATA
);

    wire   [2:0]  bit_cnt;
    wire bit_done;
    wire stp_chk_en;
    wire strt_chk_en;
    wire par_chk_en;
    wire deser_en;
    wire data_samp_en;
    wire edge_count_enable;
    wire bit_count_enable;
    wire sampling_done;

    RX_FSM U1_FSM (
        .CLK(CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .PAR_EN(PAR_EN),
        .bit_cnt(bit_cnt),
        .bit_done(bit_done),
        .strt_glitch(strt_glitch),
        .par_err(par_err),
        .stp_err(stp_err),
        .stp_chk_en(stp_chk_en),
        .strt_chk_en(strt_chk_en),
        .par_chk_en(par_chk_en),
        .deser_en(deser_en),
        .data_samp_en(data_samp_en),
        .edge_count_enable(edge_count_enable),
        .bit_count_enable(bit_count_enable),
        .Data_Valid(Data_Valid)
    );

    wire [4:0]   edge_cnt;
    RX_EDGE_BIT_COUNTER U0_EB_COUNTER (
        .CLK(CLK),
        .RST(RST),
        .edge_count_enable(edge_count_enable),
        .bit_count_enable(bit_count_enable),
        .Prescale(Prescale),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt),
        .bit_done(bit_done)
    );

    wire sampled_bit;
    RX_DATA_SAMPLING U0_DATA_SAMP (
        .CLK(CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .Prescale(Prescale),
        .data_samp_en(data_samp_en),
        .edge_cnt(edge_cnt),
        .sampling_done(sampling_done),
        .sampled_bit(sampled_bit)
    );

    RX_DESERIALIZER U0_DESER (
        .CLK(CLK),
        .RST(RST),
        .sampled_bit(sampled_bit),
        .deser_en(deser_en),
        .P_DATA(P_DATA)
    );

    RX_START_CHECK U0_STRT_CKH (
        .CLK(CLK),
        .RST(RST),
        .strt_chk_en(strt_chk_en),
        .sampled_bit(sampled_bit),
        .strt_glitch(strt_glitch)
    );

    RX_PARITY_CHECK U0_PAR_CHK (
        .CLK(CLK),
        .RST(RST),
        .PAR_TYP(PAR_TYP),
        .par_chk_en(par_chk_en),
        .sampled_bit(sampled_bit),
        .sampling_done(sampling_done),
        .P_DATA(P_DATA),
        .par_err(par_err)
    );

    RX_STOP_CHECK U0_STP_CHK (
        .CLK(CLK),
        .RST(RST),
        .stp_chk_en(stp_chk_en),
        .sampled_bit(sampled_bit),
        .sampling_done(sampling_done),
        .stp_err(stp_err)
    );

endmodule
