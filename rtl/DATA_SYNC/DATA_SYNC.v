module DATA_SYNC #(
    parameter   NUM_STAGES  = 2,
                BUS_WIDTH   = 8
)(
    input   wire                        i_CLK,
    input   wire                        i_RST,
    input   wire    [BUS_WIDTH-1:0]     i_unsync_bus,
    input   wire                        i_bus_enable,
    output  wire    [BUS_WIDTH-1:0]     o_sync_bus,
    output  wire                        o_enable_pulse
);

    wire sync_en;

    DATA_SYNC_EN_SYNC #(
        .NUM_STAGES(NUM_STAGES)
    ) U0_EN_SYNC (
        .CLK(i_CLK),
        .RST(i_RST),
        .ASYNC_EN(i_bus_enable),
        .SYNC_EN(sync_en)
    );
    
    wire pulse_signal;
    DATA_SYNC_PULSE_GEN U1_PULSE_GEN (
        .CLK(i_CLK),
        .RST(i_RST),
        .pulse_en(sync_en),
        .pulse_signal(pulse_signal)
    );

    DATA_SYNC_OP U2_DATA_SYNC_OP (
        .CLK(i_CLK),
        .RST(i_RST),
        .unsync_bus(i_unsync_bus),
        .bus_enable(pulse_signal),
        .sync_bus(o_sync_bus),
        .enable_pulse(o_enable_pulse)
    );
endmodule
