`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30/7/2023 03:05:46 PM
// Design Name: 
// Module Name: Register_File_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Register_File_TB;
    localparam      REG_WIDTH = 16,                 /*data width of each register*/
                    ADDR_WIDTH = 3,                 /*width of address line*/
                    FILE_DEPTH = 2 ** ADDR_WIDTH;    /*No of registers in reg file*/
        
    reg CLK, RST;
    reg WrEn, RdEn;
    reg [REG_WIDTH - 1: 0] WrData;
    reg [ADDR_WIDTH - 1: 0] Address;
    wire [REG_WIDTH - 1: 0] RdData;
        
    Register_File #(.ADDR_WIDTH(ADDR_WIDTH), .REG_WIDTH(REG_WIDTH)) uut  (
    .CLK(CLK),
    .RST(RST),
    .WrEn(WrEn),
    .RdEn(RdEn),
    .WrData(WrData),
    .Address(Address),
    .RdData(RdData)
    );

        always #15 CLK = ~CLK;

        task init_reg_file();
        begin
            CLK = 0;
            RST = 0;
            WrEn = 0;
            RdEn = 0;
            WrData = 0;
            Address = 0;
            @(negedge CLK);
            RST = 1;
        end
        endtask

        task reg_write(
            input [ADDR_WIDTH-1: 0] address,
            input [REG_WIDTH-1: 0] data
        );
            begin
                WrEn = 1;
                Address = address;
                WrData = data;
                @(negedge CLK);
                WrEn = 0;
                Address = 0;
                WrData = 0;
            end
        endtask

        task reg_read(
            input [ADDR_WIDTH-1: 0] addr
        );
        begin
            Address = addr;
            RdEn = 1;
            @(negedge CLK);
            Address = 0;
            RdEn = 0;
        end
        endtask

        initial begin

            init_reg_file();
            reg_write(1,15);
            
            reg_read(1);
            
            reg_write(20,100);
            
            reg_read(20);

            $stop;
        end
endmodule
