module DATA_SYNC #(
    parameter   NUM_STAGES  = 2,
                BUS_WIDTH   = 8
)(
    input   wire                        CLK,
    input   wire                        RST,
    input   wire    [BUS_WIDTH-1:0]     unsync_bus,
    input   wire                        bus_enable,
    output  wire    [BUS_WIDTH-1:0]     sync_bus,
    output  wire                        enable_pulse
);

    wire sync_en;

    DATA_SYNC_EN_SYNC #(
        .NUM_STAGES(2)
    ) U0_EN_SYNC (
        .CLK(CLK),
        .RST(RST),
        .ASYNC_EN(bus_enable),
        .SYNC_EN(sync_en)
    );
    
    DATA_SYNC_PULSE_GEN U1_PULSE_GEN (
        .CLK(CLK),
        .RST(RST),
        .pulse_en(sync_en),
        .pulse_signal(pulse_signal)
    );

    DATA_SYNC_OP U2_DATA_SYNC_OP (
        .CLK(CLK),
        .RST(RST),
        .unsync_bus(unsync_bus),
        .bus_enable(pulse_signal),
        .sync_bus(sync_bus),
        .enable_pulse(enable_pulse)
    );
endmodule
