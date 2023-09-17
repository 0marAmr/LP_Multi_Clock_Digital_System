module ClkDiv #(
    parameter   COUNTER_WIDTH = 3,
                DIV_RATIO_WIDTH = 4
) (
    input wire i_ref_clk,
    input wire i_rst_n,
    input wire i_clk_en,
    input wire [DIV_RATIO_WIDTH-1:0] i_div_ratio,
    output reg o_div_clk
);
    reg     [COUNTER_WIDTH-1: 0] count;
    wire    [DIV_RATIO_WIDTH-1:0] half;
    always @(posedge i_ref_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            o_div_clk <=0;
            count <=0;
        end
        else if (i_clk_en)begin
            if (count == (half) && even) begin
                o_div_clk = ~o_div_clk;
                count <= 0;
            end
            else if ((((count==half)&&o_div_clk) || ((count==(half+1))&& ~o_div_clk))&& ~even) begin
                o_div_clk <= ~o_div_clk;
                count <= 0;
            end
            else begin
                count <= count + 1;
            end
        end
        else begin
            o_div_clk <= ~o_div_clk;
        end
    end

    assign half = (i_div_ratio>>1) - 1;
    assign even = ~i_div_ratio[0];

endmodule
