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
    output  wire [ALU_FUN_WIDTH-1:0]    o_ALU_FUN,
    output  reg  [DATA_WIDTH-1:0]       o_FIFO_DATA,
    output  reg  [ADDR_WIDTH-1:0]       o_Address,
    // Control signals
    output  reg                         o_WrEn,
    output  reg                         o_WR_INC,
    output  reg                         o_RdEn,
    output  reg                         o_ALU_EN,
    output  reg                         o_CLK_EN,
    output  reg                         o_clk_div_en
);

    localparam STATE_REG_WIDTH = 4;
    localparam RF_Wr_CMD            = 8'hAA;
    localparam RF_Rd_CMD            = 8'hBB;
    localparam ALU_OPER_W_OP_CMD    = 8'hCC;
    localparam ALU_OPER_W_NOP_CMD   = 8'hDD;

    /*Grey encode these MFs*/
    localparam [STATE_REG_WIDTH-1:0]    IDLE                = 'b0000,
                                        RF_WR_Addr          = 'b0001,
                                        RF_WR_Data          = 'b0010,
                                        RF_WRITE            = 'b0011,
                                        RF_RD_Addr          = 'b0100,
                                        RF_READ             = 'b0101,
                                        RF_RD_FIFO_Wr       = 'b0110,
                                        ALU_OP_OPER1_Rd     = 'b0111,
                                        ALU_OP_Oper1_Str    = 'b1000,
                                        ALU_OP_Oper2_Rd     = 'b1001,
                                        ALU_OP_Oper2_Str    = 'b1010,
                                        ALU_OP_FUN_Rd       = 'b1011,
                                        ALU_OP_Res_Calc     = 'b1100,
                                        ALU_OP_Str          = 'b1101,
                                        ALU_FIFO_Wr_1       = 'b1110,
                                        ALU_FIFO_Wr_2       = 'b1111;



    reg o_RF_Addr_Str;          // stores the address of the Reg File to be read from/ written to
    reg o_RF_Data_Rd_Str;       // stores the data read from the Reg File
    reg [1:0] o_RF_Addr_Src_Sel;// Selects the address of the Reg File to be Fixed 0 (ALUOp1) or Fixed 1 (ALUOp2) or CTRL_Reg_Addr value
    reg o_RX_P_Data_Str;        // stores the parallel data from RX Synchronized Out
    reg o_ALU_OP_Res_Str;       // stores the result of ALU operatioon (Least & Most Significant Bytes)
    reg o_FIFO_Wr_Data_Sel;     // Choose between CTRL_Reg_Data1 & CTRL_Reg_Data2 to be written in FIFO

    // Storage Elements for Address, Read Data and Write Data
    reg [ADDR_WIDTH-1:0] CTRL_Reg_Addr;
    reg [DATA_WIDTH-1:0] CTRL_Reg_Data1;
    reg [DATA_WIDTH-1:0] CTRL_Reg_Data2;

    always @(posedge i_CLK or negedge i_RST) begin
         if(~i_RST) begin
            CTRL_Reg_Addr <= 'b0;
            CTRL_Reg_Data1 <= 'b0;
            CTRL_Reg_Data2 <= 'b0;
        end
        else if(o_RF_Addr_Str)begin
            CTRL_Reg_Addr <= i_RX_P_DATA[3:0];
        end
        else if (o_RX_P_Data_Str) begin
            CTRL_Reg_Data1 <= i_RX_P_DATA;
        end
        else if (o_RF_Data_Rd_Str) begin
            CTRL_Reg_Data1 <= i_RdData;
        end
        else if(o_ALU_OP_Res_Str) begin
            CTRL_Reg_Data1 <= i_ALU_OUT[DATA_WIDTH-1:0];
            CTRL_Reg_Data2 <= i_ALU_OUT[2*DATA_WIDTH-1:DATA_WIDTH];
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

    always @(*) begin
        case (o_RF_Addr_Src_Sel)
            2'b00: o_Address    = 'b0;
            2'b01: o_Address    = 'b1;
            2'b10: o_Address    = CTRL_Reg_Addr[3:0];
            default: o_Address  = CTRL_Reg_Addr[3:0];
        endcase

        if (o_FIFO_Wr_Data_Sel) begin
            o_FIFO_DATA = CTRL_Reg_Data2;
        end
        else begin
            o_FIFO_DATA = CTRL_Reg_Data1;
        end
    end

    // Next State & Output Logic
    always @(*) begin
        o_WrEn            = 'b0;
        o_RdEn            = 'b0;
        o_ALU_EN          = 'b0;
        o_CLK_EN          = 'b0;
        o_WR_INC          = 'b0;
        o_clk_div_en      = 'b1; // clock divider is ON by default
        o_RF_Addr_Str     = 'b0;
        o_RX_P_Data_Str   = 'b0;
        o_RF_Data_Rd_Str  = 'b0;
        o_ALU_OP_Res_Str  = 'b0;
        o_FIFO_Wr_Data_Sel= 'b0;
        o_RF_Addr_Src_Sel = 'b0;
        case (present_state)
            IDLE: begin
                // NS Logic
                if (~i_RX_D_VLD) begin
                    next_state = IDLE;
                end
                else begin
                    case (i_RX_P_DATA)
                        RF_Wr_CMD:          next_state = RF_WR_Addr;
                        RF_Rd_CMD:          next_state = RF_RD_Addr;
                        ALU_OPER_W_OP_CMD:  next_state = ALU_OP_OPER1_Rd;
                        ALU_OPER_W_NOP_CMD: next_state = ALU_OP_FUN_Rd;
                        default:            next_state = IDLE;
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
                o_RX_P_Data_Str = 'b1;
            end
            RF_WRITE: begin
                // NS Logic
                next_state = IDLE;

                // Output Logic
                o_WrEn = 'b1;
                o_RF_Addr_Src_Sel = 'b10;
            end
            RF_RD_Addr: begin
                // NS Logic
                if (~i_RX_D_VLD) begin
                    next_state = RF_RD_Addr;
                end
                else begin
                    next_state = RF_READ;
                end

                // Output Logic
                o_RF_Addr_Str = 'b1;
            end
            RF_READ: begin
                // NS Logic
                if (~i_RdData_Valid) begin
                    next_state = RF_READ;
                end
                else begin
                    next_state = RF_RD_FIFO_Wr;
                end

                // Output Logic
                o_RdEn = 1'b1;
                o_RF_Addr_Src_Sel = 'b10;
                o_RF_Data_Rd_Str = 'b1;
            end
            RF_RD_FIFO_Wr: begin
                // NS Logic
                if (i_FIFO_FULL) begin
                    next_state = RF_RD_FIFO_Wr;
                end
                else begin
                    next_state = IDLE;
                end

                // Output Logic
                o_WR_INC = 'b1;
                o_FIFO_Wr_Data_Sel = 'b0;
            end
            ALU_OP_OPER1_Rd: begin
                // NS Logic
                if (~i_RX_D_VLD) begin
                    next_state = ALU_OP_OPER1_Rd;
                end
                else begin
                    next_state = ALU_OP_Oper1_Str;
                end

                // Output Logic
                o_RX_P_Data_Str = 'b1;
            end
            ALU_OP_Oper1_Str: begin
                // NS Logic
                next_state = ALU_OP_Oper2_Rd;

                // Output Logic
                o_WrEn = 'b1;
                o_RF_Addr_Src_Sel = 'b00;
            end
            ALU_OP_Oper2_Rd: begin
                // NS Logic
                if (~i_RX_D_VLD) begin
                    next_state = ALU_OP_Oper2_Rd;
                end
                else begin
                    next_state = ALU_OP_Oper2_Str;
                end

                // Output Logic
                o_RX_P_Data_Str = 'b1;
            end
            ALU_OP_Oper2_Str: begin
                // NS Logic
                next_state = ALU_OP_FUN_Rd;

                // Output Logic
                o_WrEn = 'b1;
                o_RF_Addr_Src_Sel = 'b01;
            end
            ALU_OP_FUN_Rd: begin
                // NS Logic
                if (~i_RX_D_VLD) begin
                    next_state = ALU_OP_FUN_Rd;
                end
                else begin
                    next_state = ALU_OP_Res_Calc;
                end

                // Output Logic
                o_RX_P_Data_Str = 'b1;
            end
            ALU_OP_Res_Calc: begin
                // NS Logic
                if (~i_OUT_Valid) begin
                    next_state = ALU_OP_Res_Calc;
                end
                else begin
                    next_state = ALU_OP_Str;
                end

                // Output Logic
                o_CLK_EN = 'b1;
                o_ALU_EN = 'b1;
            end
            ALU_OP_Str: begin
                // NS Logic
                next_state = ALU_FIFO_Wr_1;

                // Output Logic
                o_ALU_OP_Res_Str = 'b1;
            end
            ALU_FIFO_Wr_1: begin
                // NS Logic
                if (i_FIFO_FULL) begin
                    next_state = ALU_FIFO_Wr_1;
                end
                else begin
                    next_state = ALU_FIFO_Wr_2;
                end

                // Output Logic
                o_WR_INC = 'b1;
                o_FIFO_Wr_Data_Sel = 'b0;
            end
            ALU_FIFO_Wr_2: begin
                // NS Logic
                if (i_FIFO_FULL) begin
                    next_state = ALU_FIFO_Wr_2;
                end
                else begin
                    next_state = IDLE;
                end

                // Output Logic
                o_WR_INC = 'b1;
                o_FIFO_Wr_Data_Sel = 'b1;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    assign o_WrData     = CTRL_Reg_Data1;
    assign o_ALU_FUN    = CTRL_Reg_Data1;
endmodule