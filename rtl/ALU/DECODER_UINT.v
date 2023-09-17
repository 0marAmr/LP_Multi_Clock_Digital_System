module DECODER_UINT (
    input wire [1:0] selection,
    output reg Arith_Enable, Logic_Enable, CMP_Enable, SHIFT_Enable
);
    
    localparam [1:0]    Arith = 2'b00,
                        Logic = 2'b01,
                        CMP   = 2'b10,
                        SHIFT = 2'b11;
    always @(*) begin
        Arith_Enable = 0;
        Logic_Enable = 0;
        CMP_Enable   = 0;
        SHIFT_Enable = 0;
        case (selection)
            Arith: begin
                Arith_Enable =1'b1;
            end
            Logic: begin
                Logic_Enable =1'b1;
            end
            CMP: begin
                CMP_Enable =1'b1;
            end
            SHIFT: begin
                SHIFT_Enable =1'b1;
            end
        endcase    
    end
endmodule