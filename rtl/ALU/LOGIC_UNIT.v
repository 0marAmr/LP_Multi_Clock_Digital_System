module LOGIC_UNIT #(
    parameter   DATA_WIDTH = 16,
                SEL_LINE = 2          
)(
    input wire clk, Logic_Enable, async_rst,
    input wire [DATA_WIDTH - 1:0] A, B,
    input wire [SEL_LINE - 1:0] ALU_FUN,
    output reg [DATA_WIDTH - 1:0] Logic_OUT,
    output reg Logic_Flag
);
    reg [DATA_WIDTH - 1:0] Logic_RESULT;
    localparam ALU_FUN_WIDTH = 2;
    localparam [ALU_FUN_WIDTH-1:0]  AND             = 2'b00,
                                    OR              = 2'b01,
                                    NAND            = 2'b10,
                                    NOR             = 2'b11;
                                    
    always @(*) begin
        Logic_RESULT = 0;
        Logic_Flag = 0;
        if(Logic_Enable) begin
            case (ALU_FUN)
                AND: begin
                    Logic_RESULT = A & B;
                end            
                OR: begin
                    Logic_RESULT = A | B;
                end            
                NAND: begin
                    Logic_RESULT = ~(A & B);
                end            
                NOR: begin
                    Logic_RESULT = ~(A | B);
                end
            endcase    
            Logic_Flag = 1'b1;
        end
    end

    always @(posedge clk or negedge async_rst) begin
        if (~async_rst) begin
            Logic_OUT <= 0;
        end
        else begin
            Logic_OUT <= Logic_RESULT;
        end
    end

endmodule