module ARITHMATIC_UNIT #(
    parameter   DATA_WIDTH = 16,
                SEL_LINE = 2          
)(
    input wire clk, Arith_Enable, async_rst,
    input wire [DATA_WIDTH - 1:0] A, B,
    input wire [SEL_LINE - 1:0] ALU_FUN,
    output reg [DATA_WIDTH - 1:0] Arith_OUT,
    output reg Carry_OUT, Arith_Flag
);
    reg [DATA_WIDTH - 1:0] Arith_RESULT;
    localparam ALU_FUN_WIDTH = 2;
    localparam [ALU_FUN_WIDTH-1:0]  Addition        = 2'b00,
                                    Subtraction     = 2'b01,
                                    Multiplication  = 2'b10,
                                    Division        = 2'b11;
                                    
    always @(*) begin
        Arith_RESULT = 0;
        Carry_OUT = 0;
        Arith_Flag = 1'b0; 
        if(Arith_Enable) begin
            case (ALU_FUN)
                Addition: begin
                    {Carry_OUT, Arith_RESULT} = A + B;
                end            
                Subtraction: begin
                    {Carry_OUT, Arith_RESULT} = A - B;
                end            
                Multiplication: begin
                    {Carry_OUT, Arith_RESULT} = A * B;
                end            
                Division: begin
                    {Carry_OUT, Arith_RESULT} = A / B;
                end
            endcase   
            Arith_Flag = 1'b1; 
        end
    end

    always @(posedge clk or negedge async_rst) begin
        if (~async_rst) begin
            Arith_OUT <= 0;
        end
        else begin
            Arith_OUT <= Arith_RESULT;
        end

    end

always @(*) begin
    if()
end
assign c = a & b;
endmodule