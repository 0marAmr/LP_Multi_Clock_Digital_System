module CMP_UNIT #(
    parameter   DATA_WIDTH = 16,
                SEL_LINE = 2          
)(
    input wire clk, CMP_Enable, async_rst,
    input wire [DATA_WIDTH - 1:0] A, B,
    input wire [SEL_LINE - 1:0] ALU_FUN,
    output reg [DATA_WIDTH - 1:0] CMP_OUT,
    output reg CMP_Flag
);
    reg [DATA_WIDTH - 1:0] CMP_RESULT;
    localparam ALU_FUN_WIDTH = 2;
    localparam [ALU_FUN_WIDTH-1:0]  AeqB            = 2'b01,
                                    AgtB            = 2'b10,
                                    AltB            = 2'b11;
                                    
    always @(*) begin
        CMP_RESULT = 0;
        CMP_Flag = 1'b0;
        if(CMP_Enable)begin
            case (ALU_FUN)
                AeqB: begin
                    CMP_RESULT = A == B;
                end            
                AgtB: begin
                    CMP_RESULT = A > B;
                end            
                AltB: begin
                    CMP_RESULT = A < B;
                end            
                default:
                    CMP_RESULT =0;
            endcase    
            CMP_Flag = 1'b1;
        end
    end

    always @(posedge clk or negedge async_rst) begin
        if (~async_rst) begin
            CMP_OUT <= 0;
        end
        else begin
            CMP_OUT <= CMP_RESULT;
        end
    end

endmodule