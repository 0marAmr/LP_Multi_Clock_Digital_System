module DATA_SYNC_TB ();
 
parameter NUM_STAGES_TB = 5 ;
parameter BUS_WIDTH_TB  = 4 ; 

reg                           CLK_TB         ;
reg                           RST_TB         ;
reg                           bus_enable_TB  ;
reg      [BUS_WIDTH_TB-1:0]   unsync_bus_TB  ;
wire     [BUS_WIDTH_TB-1:0]   sync_bus_TB    ;
wire                          enable_pulse_TB;

////////// Initial Block ////////
initial
begin

CLK_TB = 1'b0 ;
RST_TB = 1'b1 ;
bus_enable_TB = 1'b0 ;
unsync_bus_TB = 'b1011 ;

#7 
RST_TB = 1'b0 ;    

#8 
RST_TB = 1'b1 ; 

#13    
bus_enable_TB = 1'b1;

#10
bus_enable_TB = 1'b0;



#100 ;
$stop ;
    
end  

////////// Clock Generation /////////

always #5 CLK_TB = ! CLK_TB ;

///////////// Instantiation ///////////
					 
DATA_SYNC  # ( .NUM_STAGES(NUM_STAGES_TB) , .BUS_WIDTH(BUS_WIDTH_TB) )  DUT
(
.i_CLK(CLK_TB),
.i_RST(RST_TB),
.i_unsync_bus(unsync_bus_TB),
.o_sync_bus(sync_bus_TB),
.i_bus_enable(bus_enable_TB),
.o_enable_pulse(enable_pulse_TB)
);


endmodule
