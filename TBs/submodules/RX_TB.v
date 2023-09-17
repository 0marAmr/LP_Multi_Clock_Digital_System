/*test bench is automatically generated*/
`timescale 1ps / 1ps

module RX_TB;

    localparam DATA_WIDTH = 8;
    reg                     CLK;
    reg                     RST;
    reg                     RX_IN;
    reg  [5:0]              Prescale;
    reg                     PAR_EN;
    reg                     PAR_TYP;
    wire                    Data_Valid;
    wire [DATA_WIDTH-1:0]   P_DATA;
    
    localparam even_parity = 0;
    localparam odd_parity = 1;
    localparam STOP_BIT = 1;
    
    UART_RX DUT (
        .CLK(CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .Prescale(Prescale),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .Data_Valid(Data_Valid),
        .P_DATA(P_DATA)
    );

    localparam CLK_PERIOD = 10;
    initial begin
        CLK = 0;
        forever begin
            #(CLK_PERIOD/2);
            CLK = ~ CLK;
        end
    end

    task initialzie;
    begin
        RX_IN = 0;
        Prescale = 0;
        PAR_EN = 0;
        PAR_TYP = 0;
    end    
    endtask
    
    task reset;
    begin
        RST = 1;
        @(negedge CLK)
        RST = 0;
        @(negedge CLK)
        RST = 1;
    end
    endtask
    
    task set_prescale(
        input [5:0] presc_value
    );
    begin
        Prescale = presc_value;
    end
    endtask
    
    task sendframe (
        input [7:0] data,
        input parity_en,
        input parity_type,
        input parity_bit,
        input stop_bit
    );
    begin
        PAR_EN = parity_en;
        RX_IN = 0; // start bit
        repeat (Prescale) @(negedge CLK);
        RX_IN = data[0]; 
        repeat (Prescale) @(negedge CLK);        
        RX_IN = data[1]; 
        repeat (Prescale) @(negedge CLK);        
        RX_IN = data[2]; 
        repeat (Prescale) @(negedge CLK);        
        RX_IN = data[3]; 
        repeat (Prescale) @(negedge CLK);        
        RX_IN = data[4]; 
        repeat (Prescale) @(negedge CLK);        
        RX_IN = data[5]; 
        repeat (Prescale) @(negedge CLK);        
        RX_IN = data[6]; 
        repeat (Prescale) @(negedge CLK);        
        RX_IN = data[7]; 
        repeat (Prescale) @(negedge CLK);
        if(parity_en) begin
            PAR_TYP = parity_type;
            RX_IN = parity_bit; 
            repeat (Prescale) @(negedge CLK);
        end
        // stop bit
        RX_IN = stop_bit; 
        repeat (Prescale) @(negedge CLK);
        RX_IN = 1; 
    end
    endtask
    initial begin
        initialzie();
        reset();
        set_prescale(16);
        // sneding frame, no parity
        sendframe(8'b1111_0000, 0, 0, 0, STOP_BIT);
        repeat(10) @(negedge CLK);
        // sending frame, odd parity = 1
        sendframe(8'b1111_0000, 1, odd_parity , 1, STOP_BIT);
        repeat(10) @(negedge CLK);
        // sending frame, even parity = 1
        sendframe(8'b1111_1000, 1, even_parity , 1, STOP_BIT);
        repeat(10) @(negedge CLK);
        // sending frame, even parity = 0
        sendframe(8'b1111_0000, 1, even_parity , 0, STOP_BIT);
        repeat(10) @(negedge CLK);
        
        // sending two frames simultaneously
        sendframe(8'b1010_1010, 1, odd_parity , 1, STOP_BIT);
        sendframe(8'b0101_0101, 1, even_parity , 0, STOP_BIT);
        
        
        // sending a frame with parity error
        sendframe(8'b1010_1010, 1, odd_parity , 0, STOP_BIT);
        
        // sneding a frame with stop bit error
        sendframe(8'b1010_1010, 1, odd_parity , 1, 0);
        RX_IN = 1; // idle
        repeat (4) @(negedge CLK);

        // simulating start glitch (it shall return to idle state)
        RX_IN = 0;
        repeat (4) @(negedge CLK);
        RX_IN = 1;
        repeat (12) @(negedge CLK);
        
        set_prescale(32);
        sendframe(8'b1111_0000, 0, 0, 0, STOP_BIT);
        set_prescale(8);
        sendframe(8'b0000_1111, 0, 0, 0, STOP_BIT);
        @(negedge CLK);
        set_prescale(4);
        sendframe(8'b1010_1010, 0, 0, 0, STOP_BIT);
        repeat (4) @(negedge CLK);

        $finish;
    end
endmodule