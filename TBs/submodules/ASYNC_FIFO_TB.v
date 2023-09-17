module ASYNC_FIFO_TB ;
   
    parameter DATA_WIDTH =8 ;
    reg W_CLK_TB;
    reg R_CLK_TB;
    reg W_RST_TB;
    reg R_RST_TB;
    reg W_INC_TB;
    reg R_INC_TB;
    reg  [DATA_WIDTH-1:0] WR_DATA_TB;
    wire [DATA_WIDTH-1:0] RD_DATA_TB;
    wire FULL_TB;
    wire EMPTY_TB;

    ASYNC_FIFO DUT(
        .W_CLK(W_CLK_TB),
        .W_RST(W_RST_TB),
        .R_CLK(R_CLK_TB),
        .R_RST(R_RST_TB),
        .W_INC(W_INC_TB),
        .R_INC(R_INC_TB),
        .WR_DATA(WR_DATA_TB),
        .RD_DATA(RD_DATA_TB),
        .FULL(FULL_TB),
        .EMPTY(EMPTY_TB)
    );

    localparam W_CLK_TB_period =10 ;
    localparam R_CLK_TB_period =25 ;

    always
    begin
        #(R_CLK_TB_period/2)
        R_CLK_TB=~R_CLK_TB;
    end

    always
    begin
        #(W_CLK_TB_period/2)
        W_CLK_TB=~W_CLK_TB;
    end

    task WRITE(
        input [DATA_WIDTH-1:0] DATA
    );
    begin
        W_INC_TB = 1;
        WR_DATA_TB=DATA;
        @(negedge W_CLK_TB);
        W_INC_TB = 0;
    end
    endtask

    task READ;
    begin
       R_INC_TB= 1;
       @(negedge R_CLK_TB);
       R_INC_TB= 0;
    end
    endtask

    initial begin
        W_CLK_TB=0;
        R_CLK_TB=0;
        W_INC_TB=0;
        R_INC_TB=0;
        WR_DATA_TB=0;
        R_RST_TB=1;
        #1
        R_RST_TB=0;
        #1
        R_RST_TB=1;

        W_RST_TB=1;
        #1
        W_RST_TB=0;
        #1
        W_RST_TB=1;


        WRITE(10);
        WRITE(20);
        WRITE(80);
        WRITE(30);
        READ();
        READ();
        READ();
        READ();
        WRITE(40);
        WRITE(50);
        WRITE(60);
        WRITE(70);
        WRITE(90);
        WRITE(100);
        WRITE(110);
        WRITE(120);
        WRITE(130);
        WRITE(140);
        WRITE(150);
        READ();
        READ();
        READ();
        READ();
        READ();

        $finish;
    end   
endmodule