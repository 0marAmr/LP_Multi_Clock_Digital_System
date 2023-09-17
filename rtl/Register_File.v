module Register_File #(
    parameter   REG_WIDTH = 8,                 /*data width of each register*/
                ADDR_WIDTH = 4                 /*width of address line*/
) (
    input   wire                        CLK,
    input   wire                        RST,
    input   wire                        RdEn,
    input   wire                        WrEn,
    input   wire    [ADDR_WIDTH-1:0]    Address,
    input   wire    [REG_WIDTH-1:0]     WrData,
    output  reg     [REG_WIDTH-1:0]     RdData,
    output  reg                         RdData_Valid,   
    output  wire    [REG_WIDTH-1:0]     REG0,           /*ALU Operand A*/
    output  wire    [REG_WIDTH-1:0]     REG1,           /*ALU Operand B*/
    output  wire    [REG_WIDTH-1:0]     REG2,           /*UART Config*/
    output  wire    [REG_WIDTH-1:0]     REG3
);

    localparam FILE_DEPTH = 2 ** ADDR_WIDTH;    /*No of registers in reg file*/
    localparam RESERVED_REGS = 4;
    reg [REG_WIDTH - 1: 0] Reg_File [0: FILE_DEPTH];
    integer i;

    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            for (i = RESERVED_REGS; i < FILE_DEPTH; i = i + 1) begin
                Reg_File[i] <= {REG_WIDTH{1'b0}};
            end

            RdData <= 0;
            RdData_Valid <= 'b0;

            /*default values*/
            Reg_File[2][0]      <= 'b1;         /*Parity Enable*/
            Reg_File[2][1]      <= 'b0;         /*Parity Type*/
            Reg_File[2][7:2]    <= 'd32;        /*Prescale*/
        end
        else if(WrEn) begin
            Reg_File[Address] <= WrData;
            RdData <= 'b0;
            RdData_Valid <= 'b0;
        end
        else if(RdEn)begin
            RdData <= Reg_File[Address];        /*output is registered*/
            RdData_Valid <= 'b1;
        end
        else begin
            RdData <= 0;
            RdData_Valid <= 'b0;
        end
    end
    
    assign REG0 = Reg_File[0];
    assign REG1 = Reg_File[1];
    assign REG2 = Reg_File[2];
    assign REG3 = Reg_File[3];

endmodule  