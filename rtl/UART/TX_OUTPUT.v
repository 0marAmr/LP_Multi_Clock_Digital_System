module TX_OUTPUT (
    input wire CLK, RST,
    input wire [1:0] mux_sel,
    input wire in0, in1, in2, in3,
    input wire busy,
    output reg TX_OUT
);
    
    reg mux_out;

    always @(*) begin
        case (mux_sel)
            2'b00: mux_out = in0;
            2'b01: mux_out = in1;
            2'b10: mux_out = in2;
            2'b11: mux_out = in3;
        endcase
    end

    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            TX_OUT <= 'b0;
        end
        else if (~busy) begin
            TX_OUT <= 'b1;
        end
        else begin
            TX_OUT <= mux_out;
        end
    end

endmodule