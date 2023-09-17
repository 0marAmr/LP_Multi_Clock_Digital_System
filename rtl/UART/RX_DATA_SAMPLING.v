module RX_DATA_SAMPLING (
    input wire          CLK,                 // RX Clock input signal
    input wire          RST,    
    input wire          RX_IN,
    input wire  [5:0]   Prescale,
    input wire          data_samp_en,
    input wire  [4:0]   edge_cnt,
    output reg          sampled_bit
);

    wire [4:0] half_prescale;
    assign half_prescale = Prescale >> 1;

    reg [2:0] samples;
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            samples <= 'b000;
        end
        else if (data_samp_en) begin
                if(edge_cnt == (half_prescale - 4'b1))
                    samples[0] <= RX_IN;
                else if(edge_cnt == half_prescale)
                    samples[1] <= RX_IN;
                else if(edge_cnt == (half_prescale + 4'b1))
                    samples[2] <= RX_IN;
        end
        else begin
            samples <= 'b000;
        end
    end

    always @(*) begin
        if ((half_prescale == 4'd2) && (edge_cnt == 5'd2)) begin
            sampled_bit = RX_IN;
        end
        else begin
            case (samples)
                3'b000, 3'b001, 3'b010, 3'b100: sampled_bit = 1'b0;
                3'b011, 3'b101, 3'b110, 3'b111: sampled_bit = 1'b1;
            endcase
        end
    end
endmodule
