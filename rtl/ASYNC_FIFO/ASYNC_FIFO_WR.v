module ASYNC_FIFO_WR #(
    parameter   DATA_WIDTH  = 8,
                ADDR_WIDTH  = 3
)(
    input   wire                    W_CLK,
    input   wire                    W_RST,
    input   wire                    wr_inc,
    input   wire [ADDR_WIDTH:0]     gray_rd_ptr,
    output  wire [ADDR_WIDTH-1:0]   wr_addr,
    output  reg  [ADDR_WIDTH:0]     gray_wr_ptr,
    output  wire                    wr_full


);
    reg [ADDR_WIDTH:0]      write_pointer;
    
    always @(posedge W_CLK or negedge W_RST) begin
        if(~W_RST) begin
            write_pointer <= 'b0;
        end
        else if (~wr_full && wr_inc) begin
            write_pointer = write_pointer + 1;
        end
    end
    
    always @(*) begin
        case (write_pointer)
            4'b0000: gray_wr_ptr = 4'b0000; 
            4'b0001: gray_wr_ptr = 4'b0001; 
            4'b0010: gray_wr_ptr = 4'b0011; 
            4'b0011: gray_wr_ptr = 4'b0010; 
            4'b0100: gray_wr_ptr = 4'b0110; 
            4'b0101: gray_wr_ptr = 4'b0111; 
            4'b0110: gray_wr_ptr = 4'b0101; 
            4'b0111: gray_wr_ptr = 4'b0100;  
            4'b1000: gray_wr_ptr = 4'b1100;  
            4'b1001: gray_wr_ptr = 4'b1101;  
            4'b1010: gray_wr_ptr = 4'b1111;  
            4'b1011: gray_wr_ptr = 4'b1110;  
            4'b1100: gray_wr_ptr = 4'b1010;  
            4'b1101: gray_wr_ptr = 4'b1011;  
            4'b1110: gray_wr_ptr = 4'b1001;  
            4'b1111: gray_wr_ptr = 4'b1000;  
        endcase
    end

    assign wr_addr = write_pointer[ADDR_WIDTH-1:0];
    assign wr_full = (gray_wr_ptr[3] != gray_rd_ptr[3]) && (gray_wr_ptr[2] != gray_rd_ptr[2]) && ((gray_wr_ptr[1:0] == gray_rd_ptr[1:0]));
endmodule