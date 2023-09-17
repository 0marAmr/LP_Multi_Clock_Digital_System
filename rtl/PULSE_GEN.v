module PULSE_GEN (
    input   wire                        CLK,
    input   wire                        RST,
    input   wire                        pulse_en,
    output  wire                        pulse_signal
);
    reg enable_flop;
    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            enable_flop<= 'b0;
        end
		else begin
			enable_flop <= pulse_en;
		end
    end
	assign pulse_signal = ~ enable_flop && pulse_en;
	
endmodule