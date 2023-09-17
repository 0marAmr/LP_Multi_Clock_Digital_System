module RST_SYNC #(
    parameter   NUM_STAGES  = 2
)(
    input   wire    CLK,
    input   wire    RST,
    output  wire    SYNC_RST
);

    reg [NUM_STAGES-1:0] sync_chain;
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
                sync_chain <= 'b0;
        end
        else begin
                sync_chain <= {1'b1, sync_chain[NUM_STAGES-1:1]};
        end
    end

    assign SYNC_RST = sync_chain[0];
endmodule