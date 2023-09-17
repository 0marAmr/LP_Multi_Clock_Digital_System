module ALU_TOP #(
    parameter   DATA_WIDTH = 16,
                SEL_LINE = 4   
) (
    input   wire clk, async_rst,
    input   wire [DATA_WIDTH - 1:0] A, B,
    input   wire [SEL_LINE - 1:0] ALU_FUN,
    output  wire [DATA_WIDTH - 1:0] Arith_OUT, Logic_OUT, CMP_OUT, SHIFT_OUT,
    output  wire Carry_OUT, Arith_Flag, Logic_Flag, CMP_Flag, SHIFT_Flag
);

    wire Arith_Enable, Logic_Enable, CMP_Enable, SHIFT_Enable;

    ARITHMATIC_UNIT AR_U(
        .clk(clk),
        .Arith_Enable(Arith_Enable),
        .async_rst(async_rst),
        .A(A),
        .B(B),
        .ALU_FUN(ALU_FUN[1:0]),
        .Arith_OUT(Arith_OUT),
        .Carry_OUT(Carry_OUT),
        .Arith_Flag(Arith_Flag)
    );

    LOGIC_UNIT L_U(
        .clk(clk),
        .Logic_Enable(Logic_Enable),
        .async_rst(async_rst),
        .A(A),
        .B(B),
        .ALU_FUN(ALU_FUN[1:0]),
        .Logic_OUT(Logic_OUT),
        .Logic_Flag(Logic_Flag)
    );

    SHIFT_UNIT SH_U(
        .clk(clk),
        .SHIFT_Enable(SHIFT_Enable),
        .async_rst(async_rst),
        .A(A),
        .B(B),
        .ALU_FUN(ALU_FUN[1:0]),
        .SHIFT_OUT(SHIFT_OUT),
        .SHIFT_Flag(SHIFT_Flag)
    );
    
    CMP_UNIT CMP_U(
        .clk(clk),
        .CMP_Enable(CMP_Enable),
        .async_rst(async_rst),
        .A(A),
        .B(B),
        .ALU_FUN(ALU_FUN[1:0]),
        .CMP_OUT(CMP_OUT),
        .CMP_Flag(CMP_Flag)
    );

    DECODER_UINT DEC(
        .selection(ALU_FUN[3:2]),
        .Arith_Enable(Arith_Enable),
        .Logic_Enable(Logic_Enable),
        .CMP_Enable(CMP_Enable),
        .SHIFT_Enable(SHIFT_Enable)
    );

endmodule