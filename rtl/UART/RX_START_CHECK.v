module RX_START_CHECK (
    input wire CLK,
    input wire RST,
    input wire strt_chk_en,
    input wire sampled_bit,
    output reg strt_glitch
);
    
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            strt_glitch <= 'b0;
        end
        else if (strt_chk_en) begin
            // bit sampled = 1 means it was a glitch
            strt_glitch <= sampled_bit;
        end
        else begin
            strt_glitch <= 'b0;
        end
    end
endmodule