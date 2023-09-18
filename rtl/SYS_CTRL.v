module SYS_CTRL #(
    parameter   DATA_WIDTH      = 8,
                ADDR_WIDTH      = 4,
                ALU_FUN_WIDTH   = 4

)(
    input   wire                        i_CLK,
    input   wire                        i_RST,
    input   wire [2*DATA_WIDTH-1:0]     i_ALU_OUT,
    input   wire                        i_OUT_Valid,
    input   wire [DATA_WIDTH-1:0]       i_RdData,
    input   wire                        i_RdData_Valid,
    input   wire [DATA_WIDTH-1:0]       i_RX_P_DATA,
    input   wire                        i_RX_D_VLD,
    input   wire                        i_FIFO_FULL,
    output  wire [DATA_WIDTH-1:0]       o_WrData,
    output  reg  [ALU_FUN_WIDTH-1:0]    o_ALU_FUN,
    output  reg  [ADDR_WIDTH-1:0]       o_Address,
    output  reg  [DATA_WIDTH-1:0]       o_FIFO_DATA,
    // Control signals
    output  reg                         o_WrEn,
    output  reg                         o_WR_INC,
    output  reg                         o_RdEn,
    output  reg                         o_ALU_EN,
    output  reg                         o_CLK_EN,
    output  reg                         o_TX_D_VLD,
    output  reg                         o_clk_div_en
);

    localparam STATE_REG_WIDTH = 4;
    localparam RF_Wr_CMD            = 8'hAA;
    localparam RF_Rd_CMD            = 8'hBB;
    localparam ALU_OPER_W_OP_CMD    = 8'hCC;
    localparam ALU_OPER_W_NOP_CMD   = 8'hDD;

    /*Grey encode these MFs*/
    localparam [3:0]    IDLE        = 'b0000,
                        RF_WR_Addr  = 'b0001, 
                        RF_WR_Data  = 'b0010,
                        RF_WRITE    = 'b0011,
                        RF_RD_Addr  = 'b0100,
                        RF_READ     = 'b0101,
                        FIFO_WR     = 'b0110,
                        TX_SEND     = 'b0111;


    reg o_RF_Addr_Str;
    reg o_RF_Data_Wr_Str;
    reg o_RF_Data_Rd_Str;

    // Storage Elements for Address, Read Data and Write Data
    reg [ADDR_WIDTH-1:0] RF_Addr;
    reg [DATA_WIDTH-1:0] RF_Data; // for both read and write
    always @(posedge i_CLK or negedge i_RST) begin
         if(~i_RST) begin
            RF_Addr <= 'b0;
            RF_Data <= 'b0;
        end
        else if(o_RF_Addr_Str)begin
            RF_Addr <= i_RX_P_DATA;
        end
        else if (o_RF_Data_Wr_Str) begin
            RF_Data <= i_RX_P_DATA;
        end 
        else if (o_RF_Data_Rd_Str) begin
            RF_Data <= i_RdData;
        end 
    end

    // State transition Logic
    reg [3:0] present_state, next_state;
    always @(posedge i_CLK or negedge i_RST) begin
        if(~i_RST) begin
            present_state <= IDLE;
        end
        else begin
            present_state <= next_state;
        end
    end

    // Next State & Output Logic
    always @(*) begin
        o_WrEn            = 'b0;
        o_RdEn            = 'b0;
        o_ALU_EN          = 'b0;
        o_CLK_EN          = 'b0;
        o_TX_D_VLD        = 'b0;
        o_WR_INC          = 'b0;
        o_clk_div_en      = 'b1; // clock divider is ON by default
        o_RF_Addr_Str     = 'b0;
        o_RF_Data_Wr_Str  = 'b0;
        o_RF_Data_Rd_Str  = 'b0;
        case (present_state)
            IDLE: begin
                // NS Logic
                if (~i_RX_D_VLD) begin
                    next_state = IDLE;
                end
                else begin
                    case (i_RX_P_DATA)
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
                if (~i_RX_D_VLD) begin
                    next_state = RF_WR_Addr;
                end
                else begin
                    next_state = RF_WR_Data;
                end

                // Output Logic
                o_RF_Addr_Str = 'b1;
            end
            RF_WR_Data: begin
                // NS Logic
                if (~i_RX_D_VLD) begin
                    next_state = RF_WR_Data;
                end
                else begin
                    next_state = RF_WRITE;
                end        
                
                // Output Logic
                o_RF_Data_Wr_Str = 'b1;
            end
            RF_WRITE: begin
                // NS Logic
                next_state = IDLE;
                
                // Output Logic
                o_WrEn = 'b1;
            end          
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    assign o_WrData = RF_Data;
endmodule