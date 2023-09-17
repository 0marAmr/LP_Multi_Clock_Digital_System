module TX_PARITY_CALC #(
    parameter DATA_WIDTH = 8
)(
    input wire CLK, RST,
    input wire par_en,
    input wire PAR_TYP,
    input wire [DATA_WIDTH-1:0] P_DATA,
    output reg par_bit
);
    
    localparam  EVEN_PARITY  = 'b0;

    always @(posedge CLK or negedge RST) begin
        if(~RST)begin
            par_bit <= 1'b0;
        end
        else if (par_en) begin
            if (PAR_TYP == EVEN_PARITY) begin
                par_bit <= ^P_DATA;
            end
            else  begin /*Odd Parity*/
                par_bit <= ~^P_DATA;
            end
        end
    end
endmodule