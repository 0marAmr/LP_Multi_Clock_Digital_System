/////////////////////////////////////////////////////////////
//////////////////////// ASYNC_FIFO /////////////////////////
/////////////////////////////////////////////////////////////
module ASYNC_FIFO #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH  = 3,
    parameter PTR_WIDTH  = 4
)(
    input   wire                    i_W_CLK,
    input   wire                    i_W_RST,
    input   wire                    i_W_INC,
    input   wire [DATA_WIDTH-1:0]   i_WR_DATA,
    input   wire                    i_R_CLK,
    input   wire                    i_R_RST,
    input   wire                    i_R_INC,
    output  wire                    o_FULL,
    output  wire                    o_EMPTY,
    input   wire [DATA_WIDTH-1:0]   o_RD_DATA
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
        .W_CLK(i_W_CLK),
        .W_RST(i_W_RST),
        .wr_inc(i_W_INC),
        .gray_rd_ptr(gray_sync_rd_ptr),
        .wr_addr(wr_addr),
        .gray_wr_ptr(gray_wr_ptr),
        .wr_full(o_FULL)
    );
    
    ASYNC_FIFO_RD #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) U1_READ_BLOCK (
        .R_CLK(i_R_CLK),
        .R_RST(i_R_CLK),
        .rd_inc(i_R_INC),
        .gray_wr_ptr(gray_sync_wr_ptr),
        .rd_addr(rd_addr),
        .gray_rd_ptr(gray_rd_ptr),
        .rd_empty(o_EMPTY)
    );  

    ASYNC_FIFO_MEMORY #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) U2_MEMORY (
        .CLK(i_W_CLK),
        .wclken((!o_FULL && i_W_INC)),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .wr_data(i_WR_DATA),
        .rd_data(o_RD_DATA)
    );

    ASYNC_FIFO_BIT_SYNC #(
        .NUM_STAGES(2),
        .BUS_WIDTH(PTR_WIDTH)
    ) U3_WR_RD_SYNC (
        .CLK(i_W_CLK),
        .RST(i_W_RST),
        .ASYNC(gray_rd_ptr),
        .SYNC(gray_sync_rd_ptr)
    );

    ASYNC_FIFO_BIT_SYNC #(
        .NUM_STAGES(2),
        .BUS_WIDTH(PTR_WIDTH)
    ) U4_WR_RD_SYNC (
        .CLK(i_R_CLK),
        .RST(i_R_RST),
        .ASYNC(gray_wr_ptr),
        .SYNC(gray_sync_wr_ptr)
    );
endmodule