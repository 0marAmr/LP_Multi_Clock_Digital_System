module DATA_SYNC_EN_SYNC #(
    parameter   NUM_STAGES  = 2
)(
    input   wire     CLK,
    input   wire     RST,
    input   wire     ASYNC_EN,
    output  wire     SYNC_EN
);

    reg [NUM_STAGES-1:0] sync_chain;
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
                sync_chain <= 'b0;
        end
        else begin
                sync_chain <= {ASYNC_EN, sync_chain[NUM_STAGES-1:1]};
        end
    end

    assign SYNC_EN = sync_chain[0];
endmodule
