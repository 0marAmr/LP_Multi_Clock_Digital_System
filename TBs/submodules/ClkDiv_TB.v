`timescale 1ns/1ps

module ClkDiv_TB;

    parameter DIV_RATIO_WIDTH = 4;

    reg i_ref_clk;
    reg i_rst_n;
    reg i_clk_en;
    reg [DIV_RATIO_WIDTH-1:0] i_div_ratio;
    wire o_div_clk;
    
    localparam CLK_PERIOD = 10;
    initial begin
        i_ref_clk = 0;
        forever begin
            #(CLK_PERIOD/2)
            i_ref_clk = ~i_ref_clk;
        end
    end

    ClkDiv DUT(
        .i_ref_clk(i_ref_clk),
        .i_rst_n(i_rst_n),
        .i_clk_en(i_clk_en),
        .i_div_ratio(i_div_ratio),
        .o_div_clk(o_div_clk)
    );

    task initialize;
    begin
        i_clk_en = 0;
        i_div_ratio = 0;
    end
    endtask
    
    task reset;
    begin
        i_rst_n = 1;
        #1
        i_rst_n = 0;
        #1
        i_rst_n = 1;

    end
    endtask 

    task clk_divide(
        input [DIV_RATIO_WIDTH-1:0] division_ratio
    );
    begin
        i_clk_en = 1;
        i_div_ratio = division_ratio;
    end
    endtask

    initial begin
        initialize();
        reset();
        
        // testing output when enable is zero (must output the ref clk)
        repeat(5) @(negedge i_ref_clk);

        clk_divide(2);
        repeat(10) @(negedge i_ref_clk);

        clk_divide(4);
        repeat(40) @(negedge i_ref_clk);
        
        clk_divide(3);
        repeat(30) @(negedge i_ref_clk);
        
        clk_divide(5);
        repeat(50) @(negedge i_ref_clk);
        $finish;
    end
endmodule