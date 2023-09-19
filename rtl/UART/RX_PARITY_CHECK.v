module RX_PARITY_CHECK #(
    parameter DATA_WIDTH = 8
)(
    input wire CLK,
    input wire RST,
    input wire PAR_TYP,
    input wire par_chk_en,
    input wire sampled_bit,
    input wire sampling_done,
    input wire [DATA_WIDTH-1:0] P_DATA,
    output reg par_err
);
    
    reg par_res;
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            par_err <= 'b0;
        end
        else if (sampling_done && par_chk_en) begin
            par_err <= (sampled_bit != par_res);
        end
        else if (~par_chk_en) begin
            par_err <= 0;
        end
    end

    
    localparam  EVEN_PARITY = 1'b0;
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            par_res <= 'b0;
        end
        else if (PAR_TYP == EVEN_PARITY) begin
                par_res <= ^P_DATA;
            end
        else begin /*Odd Parity*/
                par_res <= ~^P_DATA;
        end
    end

endmodule
