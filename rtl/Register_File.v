module Register_File #(
    parameter   REG_WIDTH = 8,                 /*data width of each register*/
                ADDR_WIDTH = 4                 /*width of address line*/
) (
    input   wire                        i_CLK,
    input   wire                        i_RST,
    input   wire                        i_RdEn,
    input   wire                        i_WrEn,
    input   wire    [ADDR_WIDTH-1:0]    i_Address,
    input   wire    [REG_WIDTH-1:0]     i_WrData,
    output  reg     [REG_WIDTH-1:0]     o_RdData,
    output  reg                         o_RdData_Valid,   
    output  wire    [REG_WIDTH-1:0]     o_REG0,           /*ALU Operand A*/
    output  wire    [REG_WIDTH-1:0]     o_REG1,           /*ALU Operand B*/
    output  wire    [REG_WIDTH-1:0]     o_REG2,           /*UART Config*/
    output  wire    [REG_WIDTH-1:0]     o_REG3
);

    localparam FILE_DEPTH = 2 ** ADDR_WIDTH;    /*No of registers in reg file*/
    localparam RESERVED_REGS = 4;
    reg [REG_WIDTH - 1: 0] Reg_File [0: FILE_DEPTH-1];
    integer i;

    always @(posedge i_CLK or negedge i_RST) begin
        if (~i_RST) begin
            for (i = RESERVED_REGS; i < FILE_DEPTH; i = i + 1) begin
                Reg_File[i] <= {REG_WIDTH{1'b0}};
            end

            o_RdData <= 0;
            o_RdData_Valid <= 'b0;

            /*default values*/
                Reg_File[3]         <= 'd32;        /*Div Ratio*/
        end
        else if(i_WrEn) begin
            Reg_File[i_Address] <= i_WrData;
            o_RdData <= 'b0;
            o_RdData_Valid <= 'b0;
        end
        else if(i_RdEn)begin
            o_RdData <= Reg_File[i_Address];        /*output is registered*/
            o_RdData_Valid <= 'b1;
        end
        else begin
            o_RdData <= 0;
            o_RdData_Valid <= 'b0;
        end
    end
    
    assign o_REG0 = Reg_File[0];
    assign o_REG1 = Reg_File[1];
    assign o_REG2 = Reg_File[2];
    assign o_REG3 = Reg_File[3];

endmodule  