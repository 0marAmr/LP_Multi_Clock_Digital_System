module Register_File #(
    parameter   REG_WIDTH = 16,                 /*data width of each register*/
                ADDR_WIDTH = 3                 /*width of address line*/
) (
    input wire CLK, RST,
    input wire WrEn, RdEn,
    input wire [REG_WIDTH - 1: 0] WrData,
    input wire [ADDR_WIDTH - 1: 0] Address,
    output reg [REG_WIDTH - 1: 0] RdData
);

    localparam FILE_DEPTH = 2 ** ADDR_WIDTH;    /*No of registers in reg file*/
    reg [REG_WIDTH - 1: 0] Reg_File [0: FILE_DEPTH];
    integer i;
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            for (i = 0; i < FILE_DEPTH; i = i + 1) begin
                Reg_File[i] <= {REG_WIDTH{1'b0}};
            end
            RdData <= 0;
        end
        else if(WrEn) begin
            Reg_File[Address] <= WrData;
        end
        else if(RdEn)begin
            RdData <= Reg_File[Address];        /*output is registered*/
        end
    end
    
endmodule  