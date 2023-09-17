module Prescale_to_DivRatio (
    input   wire [5:0]  i_Prescale,
    output  reg [7:0]   o_Div_Ratio_OUT
);
    
    always @(*) begin
        case (i_Prescale)
            6'd32:      o_Div_Ratio_OUT = 8'd1;
            6'd16:      o_Div_Ratio_OUT = 8'd2;
            6'd8:       o_Div_Ratio_OUT = 8'd4;
            6'd4:       o_Div_Ratio_OUT = 8'd8;
            default:    o_Div_Ratio_OUT = 8'd2;
        endcase
    end
endmodule