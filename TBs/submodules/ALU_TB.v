`timescale 1ns/1ps

module ALU_TB ();
    localparam DATA_WIDTH = 8, SELECTION_LINE = 4;
    reg                             RST;
    reg                             CLK;
    reg [DATA_WIDTH - 1:0]          A;
    reg [DATA_WIDTH - 1:0]          B;
    reg [SELECTION_LINE-1:0]        ALU_FUN;
    reg                             Enable;
    wire [2*DATA_WIDTH-1:0]         ALU_OUT;
    wire                            OUT_Valid;



    ALU DUT(
        .RST(RST),
        .CLK (CLK),
        .A(A),
        .B(B),
        .ALU_FUN(ALU_FUN),
        .Enable(Enable),
        .ALU_OUT(ALU_OUT),
        .OUT_Valid(OUT_Valid)
    );

    localparam CLK_PERIOD = 10; // TCLK = 10 microseconds
    always begin
        #(CLK_PERIOD - 4) CLK = 1'b0;
        #(CLK_PERIOD - 6) CLK = 1'b1;
    end

    task initialize;
    begin
        CLK = 1;
        A = 0;
        B = 0;
        ALU_FUN = 0;
    end
    endtask

    task reset;
    begin
        RST = 1;
        @(negedge CLK)
        RST = 0;
        @(negedge CLK)
        RST = 1;
    end
    endtask
    initial begin
        initialize();    
        reset();    
    
        $monitor("A = %d, B =%d , ALU_FUN = %b, ALU_OUT = %d , OUT_Valid = %d", A, B, ALU_FUN, ALU_OUT, OUT_Valid);

        /* Arithmatic operations*/
        A = 10;
        B = 5;
        Enable = 1'b1;
        ALU_FUN = 4'b0000;
        @(negedge CLK);
        ALU_FUN = 4'b0001;
        @(negedge CLK);
        ALU_FUN = 4'b0010;
        @(negedge CLK);
        ALU_FUN = 4'b0011;
        @(negedge CLK);
        A = 2**16 - 2;
        B = 2;
        ALU_FUN = 4'b0000; /*check for carry out*/
        @(negedge CLK);

        /* Logic operations*/
        A = 1;
        B = 0;
        ALU_FUN = 4'b0100;
        @(negedge CLK);
        ALU_FUN = 4'b0101;
        @(negedge CLK);
        ALU_FUN = 4'b0110;
        @(negedge CLK);
        ALU_FUN = 4'b0111;
        @(negedge CLK);
        
        /* Copmarison operations*/
        A = 10;
        B = 10;
        ALU_FUN = 4'b1001;
        @(negedge CLK);
        B = 5;
        ALU_FUN = 4'b1010;
        @(negedge CLK);
        ALU_FUN = 4'b1011;
        @(negedge CLK);
        ALU_FUN = 4'b1000;         /* NO OP */
        @(negedge CLK);

        Enable = 0;
        /* Shift operations*/
        A = 8;
        B = 16;
        ALU_FUN = 4'b1100;
        @(negedge CLK);
        ALU_FUN = 4'b1101;
        @(negedge CLK);
        ALU_FUN = 4'b1110;
        @(negedge CLK);
        ALU_FUN = 4'b1111;
        @(negedge CLK);
        $finish;
    end
endmodule