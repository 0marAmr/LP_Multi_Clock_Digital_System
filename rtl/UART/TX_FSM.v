module TX_FSM (
    input wire CLK, RST,
    input wire Data_Valid, PAR_EN, ser_done,
    output reg ser_en, busy, par_en, load,
    output reg [1:0] mux_sel
);
    
    localparam STATE_REG_WIDTH = 3;  /*5 states*/
    reg [STATE_REG_WIDTH-1:0] current_state, next_state;

    /* States encoding in gray code*/
    localparam [STATE_REG_WIDTH-1: 0]   IDLE            = 3'b000,
                                        START           = 3'b001,
                                        SERIALIZATION   = 3'b011,
                                        PARITY          = 3'b010,
                                        STOP            = 3'b110;
    
    /*State Transition*/
    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            current_state <=IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    /*Next State and output logic*/
    always @(*) begin
        /*Defualt Values*/
        mux_sel = 'b00;
        ser_en = 'b0;
        busy = 'b0;
        par_en = 'b0;
        load = 'b0;
        case (current_state)
            IDLE : begin
                /*NS Logic*/
                if (Data_Valid) begin
                    next_state <= START;
                end
                else begin
                    next_state <= IDLE;
                end

                /*OP logic*/
                if(PAR_EN && Data_Valid) 
                    par_en = 1'b1;    
                else
                    par_en = 1'b0;
                
                /*Load the serializer*/
                 if(Data_Valid)
                    load = 'b1;
                 else
                    load = 'b0;    
            end 
            START : begin
                /*NS Logic*/
                next_state <= SERIALIZATION;
                
                /*OP logic*/
                busy = 'b1;
                mux_sel = 'b00;

            end 
            SERIALIZATION : begin
                /*NS Logic*/
                if (ser_done && PAR_EN) begin
                    next_state <= PARITY;
                end
                else if (ser_done && ~PAR_EN) begin
                    next_state <= STOP;
                end
                else begin   // Serialization is not done
                    next_state <= SERIALIZATION;
                end
                
                /*OP logic*/
                busy = 'b1;
                mux_sel = 'b10;
                ser_en = 'b1;
            end  
            PARITY : begin
                /*NS Logic*/
                next_state <= STOP;
                
                /*OP logic*/
                busy = 'b1;
                mux_sel = 'b11;
            end  
            STOP : begin
                /*NS Logic*/
                    next_state <= IDLE;
                
                /*OP logic*/
                busy = 'b1;
                mux_sel = 'b01;
            end 
            default : begin
                next_state <= IDLE;
            end
        endcase
    end
endmodule