module ALU #(
    parameter   DATA_WIDTH = 8,
                ALU_FUN_WIDTH = 4
) (
    input   wire                            i_CLK,
    input   wire                            i_RST,
    input   wire    [DATA_WIDTH- 1:0]       i_A,
    input   wire    [DATA_WIDTH- 1:0]       i_B,
    input   wire    [ALU_FUN_WIDTH-1:0]     i_ALU_FUN,
    input   wire                            i_Enable,
    output  reg     [2*DATA_WIDTH-1:0]      o_ALU_OUT,
    output  reg                             o_OUT_Valid
);
    reg [DATA_WIDTH - 1:0] ALU_result;
    

    localparam [ALU_FUN_WIDTH-1:0]  Addition        = 4'b0000,
                                    Subtraction     = 4'b0001,
                                    Multiplication  = 4'b0010,
                                    Division        = 4'b0011,
                                    AND             = 4'b0100,
                                    OR              = 4'b0101,
                                    NAND            = 4'b0110,
                                    NOR             = 4'b0111,
                                    XOR             = 4'b1000,
                                    XNOR            = 4'b1001, 
                                    AeqB            = 4'b1010,
                                    AgtB            = 4'b1011,
                                    AltB            = 4'b1100,
                                    SHLA            = 4'b1101,
                                    SHRA            = 4'b1110;
    always @(*) begin
        case (i_ALU_FUN)
            Addition:       ALU_result = i_A + i_B;
            Subtraction:    ALU_result = i_A - i_B;
            Multiplication: ALU_result = i_A * i_B;
            Division:       ALU_result = i_A / i_B;
            AND:            ALU_result = i_A & i_B;
            OR:             ALU_result = i_A | i_B;
            NAND:           ALU_result = ~(i_A & i_B);
            NOR:            ALU_result = ~(i_A | i_B);
            XOR:            ALU_result = i_A ^ i_B;
            XNOR:           ALU_result = ~(i_A ^ i_B);
            AeqB:           ALU_result = i_A == i_B;
            AgtB:           ALU_result = i_A > i_B;
            AltB:           ALU_result = i_A < i_B;
            SHLA:           ALU_result = i_A >> 1;
            SHRA:           ALU_result = i_A << 1;
            default:        ALU_result= 0;
        endcase
    end

    always @(posedge i_CLK or negedge i_RST) begin
        if(~i_RST) begin
            o_ALU_OUT <= 'b0;
            o_OUT_Valid <= 'b0;
        end
        else if (i_Enable)begin
            o_ALU_OUT <= ALU_result;
            o_OUT_Valid <= 'b1;
        end
        else begin
            o_ALU_OUT <= 'b0; 
            o_OUT_Valid <= 'b0;
        end
    end
    
endmodule
