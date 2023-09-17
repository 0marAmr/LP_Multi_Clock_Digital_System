module SYS_CTRL #(
    parameter   DATA_WIDTH      = 8,
                ADDR_WIDTH      = 4,
                ALU_FUN_WIDTH   = 4

)(
    input   wire                        CLK,
    input   wire                        RST,
    input   wire [2*DATA_WIDTH-1:0]     ALU_OUT,
    input   wire                        OUT_Valid,
    input   wire [DATA_WIDTH-1:0]       RdData,
    input   wire                        RdData_Valid,
    input   wire [DATA_WIDTH-1:0]       RX_P_DATA,
    input   wire                        RX_D_VLD,
    output  reg  [ALU_FUN_WIDTH-1:0]    ALU_FUN,
    output  reg  [ADDR_WIDTH-1:0]       Address,
    output  reg  [DATA_WIDTH-1:0]       WrData,
    output  reg  [DATA_WIDTH-1:0]       TX_P_DATA,
    // Control signals
    output  reg                         WrEn,
    output  reg                         RdEn,
    output  reg                         ALU_EN,
    output  reg                         CLK_EN,
    output  reg                         TX_D_VLD,
    output  reg                         clk_div_en
);

    localparam STATE_REG_WIDTH = 4;
    localparam RF_Wr_CMD            = 8'hAA;
    localparam RF_Rd_CMD            = 8'hBB;
    localparam ALU_OPER_W_OP_CMD    = 8'hCC;
    localparam ALU_OPER_W_NOP_CMD   = 8'hDD;

    /*Grey encode these MFs*/
    localparam [STATE_REG_WIDTH-1:0]    IDLE        = 'b0000,
                                        RF_WR_Addr  = 'b0001, 
                                        RF_WR_Data  = 'b0010,
                                        RF_WRITE    = 'b0011,
                                        RF_RD_Addr  = 'b0100,
                                        RF_READ     = 'b0101,
                                        FIFO_WR     = 'b0110,
                                        TX_SEND     = 'b0111;


    reg RF_Addr_Str;
    reg RF_Data_Wr_Str;
    reg RF_Data_Rd_Str;

    reg [STATE_REG_WIDTH-1:0] present_state, next_state;
    // State transition Logic
    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            present_state <= IDLE;
        end
        else begin
            present_state <= next_state;
        end
    end

    // Next State & Output Logic
    always @(*) begin
        WrEn            = 'b0;
        RdEn            = 'b0;
        ALU_EN          = 'b0;
        CLK_EN          = 'b0;
        TX_D_VLD        = 'b0;
        clk_div_en      = 'b1; // clock divider is ON by default
        RF_Addr_Str     = 'b0;
        RF_Data_Wr_Str  = 'b0;
        RF_Data_Rd_Str  = 'b0;
        case (present_state)
            IDLE: begin
                // NS Logic
                if (~RX_D_VLD) begin
                    next_state = IDLE;
                end
                else begin
                    case (RX_P_DATA)
                        RF_Wr_CMD:  next_state = RF_WR_Addr;
                        RF_Rd_CMD:  next_state = RF_RD_Addr;
                        default:    next_state = IDLE;
                    endcase
                end

                // Output Logic
                // Default Values
            end
            RF_WR_Addr: begin
                // NS Logic
                if (~RX_D_VLD) begin
                    next_state = RF_WR_Addr;
                end
                else begin
                    next_state = RF_WR_Data;
                end

                // Output Logic
                RF_Addr_Str = 'b1;
            end
            RF_WR_Data: begin
                // NS Logic
                if (~RX_D_VLD) begin
                    next_state = RF_WR_Data;
                end
                else begin
                    next_state = RF_WRITE;
                end        
                
                // Output Logic
                RF_Data_Wr_Str = 'b1;
            end
              RF_WR_Data: begin
                // NS Logic
                next_state = IDLE;
                
                // Output Logic
                WrEn = 'b1;
            end          
            default: begin
                next_state = IDLE;
            end
        endcase
    end
endmodule