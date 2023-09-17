module ALU #(
    parameter   DATA_WIDTH = 8,
                SELECTION_LINE = 4
) (
    input   wire                            CLK,
    input   wire                            RST,
    input   wire    [DATA_WIDTH- 1:0]       A,
    input   wire    [DATA_WIDTH- 1:0]       B,
    input   wire    [SELECTION_LINE-1:0]    ALU_FUN,
    input   wire                            Enable,
    output  reg     [2*DATA_WIDTH-1:0]      ALU_OUT,
    output  reg                             OUT_Valid
);
    reg [DATA_WIDTH - 1:0] ALU_result;
    
    localparam ALU_FUN_WIDTH = 4;

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
        case (ALU_FUN)
            Addition:       ALU_result = A + B;
            Subtraction:    ALU_result = A - B;
            Multiplication: ALU_result = A * B;
            Division:       ALU_result = A / B;
            AND:            ALU_result = A & B;
            OR:             ALU_result = A | B;
            NAND:           ALU_result = ~(A & B);
            NOR:            ALU_result = ~(A | B);
            XOR:            ALU_result = A ^ B;
            XNOR:           ALU_result = ~(A ^ B);
            AeqB:           ALU_result = A == B;
            AgtB:           ALU_result = A > B;
            AltB:           ALU_result = A < B;
            SHLA:           ALU_result = A >> 1;
            SHRA:           ALU_result = A << 1;
            default:        ALU_result= 0;
        endcase
    end

    always @(posedge CLK) begin
        if(~RST) begin
            ALU_OUT <= 'b0;
            OUT_Valid <= 'b0;
        end
        else if (Enable)begin
            ALU_OUT <= ALU_result;
            OUT_Valid <= 'b1;
        end
        else begin
            ALU_OUT <= 'b0; 
            OUT_Valid <= 'b0;
        end
    end
    
endmodule
