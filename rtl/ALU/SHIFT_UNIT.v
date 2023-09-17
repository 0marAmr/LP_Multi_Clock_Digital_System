module SHIFT_UNIT #(
    parameter   DATA_WIDTH = 16,
                SEL_LINE = 2          
)(
    input wire clk, SHIFT_Enable, async_rst,
    input wire [DATA_WIDTH - 1:0] A, B,
    input wire [SEL_LINE - 1:0] ALU_FUN,
    output reg [DATA_WIDTH - 1:0] SHIFT_OUT,
    output reg SHIFT_Flag
);
    reg [DATA_WIDTH - 1:0] SHIFT_RESULT;
    localparam ALU_FUN_WIDTH = 2;
    localparam [ALU_FUN_WIDTH-1:0]  SHLA            = 2'b00,
                                    SHRA            = 2'b01,
                                    SHLB            = 2'b10,
                                    SHRB            = 2'b11;
                                    
    always @(*) begin
        SHIFT_RESULT = 0;
        SHIFT_Flag = 1'b0;
        if(SHIFT_Enable)begin
            case (ALU_FUN)
                SHLA: begin
                    SHIFT_RESULT = A >> 1;
                end            
                SHRA: begin
                    SHIFT_RESULT = A << 1;
                end            
                SHLB: begin
                    SHIFT_RESULT = B >> 1;
                end             
                SHRB: begin
                    SHIFT_RESULT = B << 1;
                end            
            endcase    
            SHIFT_Flag = 1'b1;
        end
    end

    always @(posedge clk or negedge async_rst) begin
        if (~async_rst) begin
            SHIFT_OUT <= 0;
        end
        else begin
            SHIFT_OUT <= SHIFT_RESULT;
        end
    end

endmodule