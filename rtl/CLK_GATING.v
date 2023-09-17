module CLK_GATING (
    input      i_CLK,
    input      i_CLK_EN,
    output     o_GATED_CLK
);

    reg     Latch_Out ;
    always @(i_CLK or i_CLK_EN) begin
        if(!i_CLK) begin
            Latch_Out <= i_CLK_EN ;
        end
     end

    assign  o_GATED_CLK = i_CLK && Latch_Out ;

endmodule
