/////////////////////////////////////////////////////////////
//////////////////////// ASYNC_FIFO /////////////////////////
/////////////////////////////////////////////////////////////
module ASYNC_FIFO #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH  = 3,
    parameter PTR_WIDTH  = 4
)(
    input   wire                    W_CLK,
    input   wire                    W_RST,
    input   wire                    W_INC,
    input   wire                    R_CLK,
    input   wire                    R_RST,
    input   wire                    R_INC,
    input   wire [DATA_WIDTH-1:0]   WR_DATA,
    output  wire                    FULL,
    output  wire                    EMPTY,
    input   wire [DATA_WIDTH-1:0]   RD_DATA
);

    wire [ADDR_WIDTH:0]     gray_rd_ptr;
    wire [ADDR_WIDTH:0]     gray_sync_rd_ptr;
    wire [ADDR_WIDTH:0]     gray_wr_ptr;
    wire [ADDR_WIDTH:0]     gray_sync_wr_ptr;
    wire [ADDR_WIDTH-1:0]   rd_addr;
    wire [ADDR_WIDTH-1:0]   wr_addr;

    ASYNC_FIFO_WR #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) U0_WRITE_BLOCK (
        .W_CLK(W_CLK),
        .W_RST(W_RST),
        .wr_inc(W_INC),
        .gray_rd_ptr(gray_sync_rd_ptr),
        .wr_addr(wr_addr),
        .gray_wr_ptr(gray_wr_ptr),
        .wr_full(FULL)
    );
    
    ASYNC_FIFO_RD #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) U1_READ_BLOCK (
        .R_CLK(R_CLK),
        .R_RST(R_RST),
        .rd_inc(R_INC),
        .gray_wr_ptr(gray_sync_wr_ptr),
        .rd_addr(rd_addr),
        .gray_rd_ptr(gray_rd_ptr),
        .rd_empty(EMPTY)
    );  

    ASYNC_FIFO_MEMORY #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) U2_MEMORY (
        .CLK(W_CLK),
        .wclken((!FULL && W_INC)),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .wr_data(WR_DATA),
        .rd_data(RD_DATA)
    );

    ASYNC_FIFO_BIT_SYNC #(
        .NUM_STAGES(2),
        .BUS_WIDTH(PTR_WIDTH)
    ) U3_WR_RD_SYNC (
        .CLK(W_CLK),
        .RST(W_RST),
        .ASYNC(gray_rd_ptr),
        .SYNC(gray_sync_rd_ptr)
    );

    ASYNC_FIFO_BIT_SYNC #(
        .NUM_STAGES(2),
        .BUS_WIDTH(PTR_WIDTH)
    ) U4_WR_RD_SYNC (
        .CLK(R_CLK),
        .RST(R_RST),
        .ASYNC(gray_wr_ptr),
        .SYNC(gray_sync_wr_ptr)
    );
endmodule