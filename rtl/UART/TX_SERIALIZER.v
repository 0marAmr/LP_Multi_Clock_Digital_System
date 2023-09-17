module TX_SERIALIZER #(
    parameter DATA_WIDTH = 8
)(
    input wire CLK, RST,
    input wire ser_en, load,
    input wire [DATA_WIDTH-1:0] P_DATA,
    output wire ser_done,
    output wire ser_data
);
    
    /*Shift right register*/
    reg [DATA_WIDTH-1:0] serializer;

    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            serializer <=0;
        end
        else if(load) begin
            serializer <= P_DATA;
        end
        else if (ser_en) begin
            serializer <= serializer >> 1; // shift right
        end
    end
    
    /*Counter to count 8 edges*/
    reg [2:0] count;
    always @(posedge CLK or negedge RST ) begin
        if (~RST) begin
            count <= 0;
        end
        else if (ser_en) begin
            count <= count + 1;
        end
        else begin
            count <= 0;
        end
    end
    assign ser_data = serializer[0];
    assign ser_done = &count;

endmodule