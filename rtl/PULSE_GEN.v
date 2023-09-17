module PULSE_GEN (
    input   wire                        i_CLK,
    input   wire                        i_RST,
    input   wire                        i_pulse_en,
    output  wire                        o_pulse_signal
);

    reg enable_flop;
    always @(posedge i_CLK or negedge i_RST) begin
        if(~i_RST) begin
            enable_flop<= 'b0;
        end
		else begin
			enable_flop <= i_pulse_en;
		end
    end
	assign o_pulse_signal = ~ enable_flop && i_pulse_en;
	
endmodule