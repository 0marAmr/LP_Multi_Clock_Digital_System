/*test bench is automatically generated*/
`timescale 1ns / 1ps

module TX_TB;

// input signals
reg CLK;
reg  RST;
reg Data_Valid;
reg  PAR_EN;
reg  PAR_TYP;
reg [7:0] P_DATA;

// output signals
wire TX_OUT;
wire  busy;

localparam even_parity = 0;
localparam odd_parity = 1;

// instantiation
UART_TX TX(
	.CLK(CLK),
	.RST(RST),
	.Data_Valid(Data_Valid),
	.PAR_EN(PAR_EN),
	.PAR_TYP(PAR_TYP),
	.P_DATA(P_DATA),
	.TX_OUT(TX_OUT),
	.busy(busy)
	);

parameter CLK_PERIOD = 5;
initial begin
    CLK = 0;
    forever begin
        #(CLK_PERIOD/2)
        CLK = ~CLK;
    end    
end

// test vector generator
task reset;
begin
    RST = 1;
    @(negedge CLK)
    RST = 0;
    @(negedge CLK)
    RST = 1;
end
endtask

task initialzie;
begin
    Data_Valid = 0;
    PAR_EN = 0;
    PAR_TYP = 0;
    P_DATA = 0;
end
endtask

task tx_send(
    input [7:0] data,
    input parity_en,
    input parity_type
);
begin
  P_DATA = data;
  PAR_EN = parity_en;
  PAR_TYP = parity_type;
  Data_Valid = 1'b1;
  @(negedge CLK)
  Data_Valid = 1'b0;
  if(parity_en)
  repeat(10) @(negedge CLK);
  else
  repeat(9) @(negedge CLK);

end
endtask

initial begin
    initialzie();
    reset();

    
   // testing idle state
    repeat(5) @(negedge CLK);   
    // sending a frame, no parity
    tx_send(10,0,0);
    @(negedge CLK)
    // sending a frame, even parity = 0
    tx_send(10,1,even_parity);
    @(negedge CLK)
    // sending a frame, odd parity = 1
    tx_send(10,1,odd_parity);
    @(negedge CLK)
    
    // sending two frames one after the other (should not enter idle state)
    tx_send(15,1,odd_parity);
    tx_send(14,1,even_parity);
    
    // changing data during transition
    P_DATA = 10;
    PAR_EN = 1;
    PAR_TYP = odd_parity;
    Data_Valid = 1'b1;
    @(negedge CLK)
    Data_Valid = 1'b0;
    repeat(5) @(negedge CLK);
    P_DATA = 255;
    Data_Valid = 1'b1;
    @(negedge CLK)
    Data_Valid = 1'b0;
    repeat(4) @(negedge CLK);
    @(negedge CLK)
    $finish; 
end

endmodule