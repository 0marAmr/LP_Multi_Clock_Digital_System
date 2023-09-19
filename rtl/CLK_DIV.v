module CLK_DIV #(
    parameter   COUNTER_WIDTH = 7,
                DIV_RATIO_WIDTH = 8
) (
    input wire i_ref_clk,
    input wire i_rst_n,
    input wire i_clk_en,
    input wire [DIV_RATIO_WIDTH-1:0] i_div_ratio,
    output wire o_div_clk
);
    reg     [COUNTER_WIDTH-1: 0]    count;
    wire    [DIV_RATIO_WIDTH-1:0]   half;
    wire                            is_zero;
    wire                            is_one;
    reg                             div_clk;
    always @(posedge i_ref_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            div_clk <=0;
            count <=0;
        end
        else if (i_clk_en)begin
            if (count == (half) && even) begin
                div_clk = ~div_clk;
                count <= 0;
            end
            else if ((((count==half)&&div_clk) || ((count==(half+1))&& ~div_clk))&& ~even) begin
                div_clk <= ~div_clk;
                count <= 0;
            end
            else begin
                count <= count + 1;
            end
        end
    end

    assign half = (i_div_ratio>>1) - 1;
    assign even = ~i_div_ratio[0];
    assign is_zero = (i_div_ratio == 0);
    assign is_one = (i_div_ratio == 1);
    assign o_div_clk = (is_zero || is_one)? i_ref_clk: div_clk;
endmodule
