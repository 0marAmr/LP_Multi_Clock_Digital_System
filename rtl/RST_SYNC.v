module RST_SYNC #(
    parameter   NUM_STAGES  = 2
)(
    input   wire    i_CLK,
    input   wire    i_RST,
    output  wire    o_SYNC_RST
);

    reg [NUM_STAGES-1:0] sync_chain;
    always @(posedge i_CLK or negedge i_RST) begin
        if (~i_RST) begin
                sync_chain <= 'b0;
        end
        else begin
                sync_chain <= {1'b1, sync_chain[NUM_STAGES-1:1]};
        end
    end

    assign o_SYNC_RST = sync_chain[0];
endmodule