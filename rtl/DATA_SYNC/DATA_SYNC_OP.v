module DATA_SYNC_OP #(
    parameter   BUS_WIDTH   = 8
)(
    input   wire                        CLK,
    input   wire                        RST,
    input   wire    [BUS_WIDTH-1:0]     unsync_bus,
    input   wire                        bus_enable,
    output  reg    [BUS_WIDTH-1:0]      sync_bus,
    output  reg                         enable_pulse
);

    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            enable_pulse <= 'b0;
            sync_bus <= 'b0;
        end
        else begin
            sync_bus <= (bus_enable)? unsync_bus : sync_bus;
            enable_pulse <= bus_enable;
        end
    end
endmodule
