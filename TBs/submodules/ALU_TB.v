`timescale 1us/1ps

module ALU_TB ();
    localparam DATA_WIDTH = 16, SEL_LINE = 4;
    reg                     async_rst;
    reg                     clk ;
    reg [DATA_WIDTH - 1:0]  A;
    reg [DATA_WIDTH - 1:0]  B;
    reg [SEL_LINE - 1:0]    ALU_FUN;
    wire [DATA_WIDTH - 1:0] Arith_OUT;
    wire                    Arith_Flag;
    wire                    Carry_OUT;
    wire [DATA_WIDTH - 1:0] Logic_OUT;
    wire                    Logic_Flag;
    wire [DATA_WIDTH - 1:0] CMP_OUT;
    wire                    CMP_Flag;
    wire [DATA_WIDTH - 1:0] SHIFT_OUT;
    wire                    SHIFT_Flag;


    ALU_TOP DUT(
        .async_rst(async_rst),
        .clk (clk),
        .A(A),
        .B(B),
        .ALU_FUN(ALU_FUN),
        /*Aritmatic unit*/
        .Carry_OUT(Carry_OUT),
        .Arith_OUT(Arith_OUT),
        .Arith_Flag(Arith_Flag),
        /*Logic unit*/
        .Logic_OUT(Logic_OUT),
        .Logic_Flag(Logic_Flag),
        /*Compare unit*/
        .CMP_OUT(CMP_OUT),
        .CMP_Flag(CMP_Flag),
        /*Shift unit*/
        .SHIFT_OUT(SHIFT_OUT),
        .SHIFT_Flag(SHIFT_Flag)
    );

    localparam CLK_PERIOD = 10; // TCLK = 10 microseconds
    always begin
        #(CLK_PERIOD - 4) clk = 1'b0;
        #(CLK_PERIOD - 6) clk = 1'b1;
    end

    task initialize();
    begin
        clk = 1;
        async_rst = 0;
        A = 0;
        B = 0;
        ALU_FUN = 0;
        @(negedge clk);
        async_rst = 1;
    end
    endtask
    
    initial begin
        initialize();    
    
        $monitor("A = %d, B =%d , ALU_FUN = %b, Arith_OUT = %d , Arith_Flag = %d , Carry_OUT= %d, Logic_OUT = %b ,Logic_Flag = %d , CMP_OUT = %d , CMP_Flag = %d, SHIFT_OUT = %b, SHIFT_Flag = %d ", 
        A, B, ALU_FUN, Arith_OUT, Arith_Flag, Carry_OUT, Logic_OUT, Logic_Flag, CMP_OUT, CMP_Flag, SHIFT_OUT, SHIFT_Flag);

        /* Arithmatic operations*/
        A = 10;
        B = 5;
        ALU_FUN = 4'b0000;
        @(negedge clk);
        ALU_FUN = 4'b0001;
        @(negedge clk);
        ALU_FUN = 4'b0010;
        @(negedge clk);
        ALU_FUN = 4'b0011;
        @(negedge clk);
        A = 2**16 - 2;
        B = 2;
        ALU_FUN = 4'b0000; /*check for carry out*/
        @(negedge clk);

        /* Logic operations*/
        A = 1;
        B = 0;
        ALU_FUN = 4'b0100;
        @(negedge clk);
        ALU_FUN = 4'b0101;
        @(negedge clk);
        ALU_FUN = 4'b0110;
        @(negedge clk);
        ALU_FUN = 4'b0111;
        @(negedge clk);
        
        /* Copmarison operations*/
        A = 10;
        B = 10;
        ALU_FUN = 4'b1001;
        @(negedge clk);
        B = 5;
        ALU_FUN = 4'b1010;
        @(negedge clk);
        ALU_FUN = 4'b1011;
        @(negedge clk);
        ALU_FUN = 4'b1000;         /* NO OP */
        @(negedge clk);

        /* Shift operations*/
        A = 8;
        B = 16;
        ALU_FUN = 4'b1100;
        @(negedge clk);
        ALU_FUN = 4'b1101;
        @(negedge clk);
        ALU_FUN = 4'b1110;
        @(negedge clk);
        ALU_FUN = 4'b1111;
        @(negedge clk);
    end
endmodule