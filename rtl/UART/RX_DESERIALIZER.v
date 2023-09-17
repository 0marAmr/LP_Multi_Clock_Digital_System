module RX_DESERIALIZER #(
    parameter DATA_WIDTH = 8
)(
    input   wire                   CLK,                 // RX Clock input signal
    input   wire                   RST,           
    input   wire                   sampled_bit,
    input   wire                   deser_en,
    output  wire [DATA_WIDTH-1:0]  P_DATA
);
    
    /*Shift left register*/
    reg [DATA_WIDTH-1:0] de_serializer; 
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            de_serializer <= 'b0;
        end
        else if (deser_en) begin
            de_serializer <= {sampled_bit, de_serializer[7:1]};
        end
    end

    assign P_DATA = de_serializer;
endmodule
