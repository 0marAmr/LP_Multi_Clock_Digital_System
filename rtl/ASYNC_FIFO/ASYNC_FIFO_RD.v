module ASYNC_FIFO_RD #(
    parameter   DATA_WIDTH  = 8,
                ADDR_WIDTH  = 3
)(
    input   wire                    R_CLK,
    input   wire                    R_RST,
    input   wire                    rd_inc,
    input   wire [ADDR_WIDTH:0]     gray_wr_ptr,
    output  wire [ADDR_WIDTH-1:0]   rd_addr,
    output  reg  [ADDR_WIDTH:0]     gray_rd_ptr,
    output  wire                    rd_empty


);
    reg [ADDR_WIDTH:0]      read_pointer;
    
    always @(posedge R_CLK or negedge R_RST) begin
        if(~R_RST) begin
            read_pointer <= 'b0;
        end
        else if (~rd_empty && rd_inc) begin
            read_pointer = read_pointer + 1;
        end
    end
    
    always @(*) begin
        case (read_pointer)
            4'b0000: gray_rd_ptr = 4'b0000; 
            4'b0001: gray_rd_ptr = 4'b0001; 
            4'b0010: gray_rd_ptr = 4'b0011; 
            4'b0011: gray_rd_ptr = 4'b0010; 
            4'b0100: gray_rd_ptr = 4'b0110; 
            4'b0101: gray_rd_ptr = 4'b0111; 
            4'b0110: gray_rd_ptr = 4'b0101; 
            4'b0111: gray_rd_ptr = 4'b0100;  
            4'b1000: gray_rd_ptr = 4'b1100;  
            4'b1001: gray_rd_ptr = 4'b1101;  
            4'b1010: gray_rd_ptr = 4'b1111;  
            4'b1011: gray_rd_ptr = 4'b1110;  
            4'b1100: gray_rd_ptr = 4'b1010;  
            4'b1101: gray_rd_ptr = 4'b1011;  
            4'b1110: gray_rd_ptr = 4'b1001;  
            4'b1111: gray_rd_ptr = 4'b1000;  
        endcase
    end

    assign rd_addr = read_pointer[ADDR_WIDTH-1:0];
    assign rd_empty = (gray_wr_ptr == gray_rd_ptr);
endmodule