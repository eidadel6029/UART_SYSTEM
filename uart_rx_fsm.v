module uart_rx_fsm #(parameter DATA_WIDTH =8)(
input wire									clk,
input wire									rst,
input wire									s_data,
input wire		[5:0]						prescale,
input wire		[5:0]						edge_count,
input wire		[3:0]						bit_count,
input wire									start_glitch,
input wire									stop_error,
input wire									parity_error,
output reg									data_sampling_en,
output reg									edge_bit_en,
output reg									deserializer_en,
output reg									start_chk_en,
output reg									stop_chk_en,
output reg									parity_chk_en,
output reg									data_valid);

localparam [2:0]  	IDLE=3'b000,
					START=3'b001,
					DATA=3'b010,
					PARITY=3'b011,
					STOP=3'b100,
					ERROR_CHK=3'b101;
					
reg [2:0] current_state, next_state;
wire        [5:0]      check_edge , error_check_edge;  
assign  check_edge = (Prescale - 6'd1) ;
assign  error_check_edge = (Prescale - 6'd2) ;

//state transiton 
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    current_state <= IDLE ;
   end
  else
   begin
    current_state <= next_state ;
   end
 end
 

// next state logic
always @ (*)
 begin
  case(current_state)
  IDLE   : begin
             if(!S_DATA)
			  next_state = start ;
			else
			  next_state = IDLE ; 			
           end
  start  : begin
             if(bit_count == 4'd0 && edge_count == check_edge)
			   begin
			    if(!strt_glitch)                    // check that start bit not a glitch
				 begin
			      next_state = data ;
                 end
                else 
                 begin
 			      next_state = IDLE ;       
                 end		
               end
			 else
			   begin
			    next_state = start ; 			
               end			  
           end
  data   : begin
             if(bit_count == 4'd8 && edge_count == check_edge)
			   begin
			     if(parity_enable)
				   begin
			        next_state = parity ;
				   end 
                 else
				   begin
			        next_state = stop ;
                   end					
               end
			 else
			   begin
			    next_state = data ; 			
               end			  
           end 
  parity : begin
             if(bit_count == 4'd9 && edge_count == check_edge)
			   begin
			    next_state = stop ; 
               end
			 else
			   begin
			    next_state = parity ; 			
               end			  
            end
  stop    : begin  
			  if(parity_enable)
				begin
				  if(bit_count == 4'd10 && edge_count == error_check_edge)
			        begin
			          next_state = err_chk ; 
                    end
			      else
			        begin
					  next_state = stop ; 			
                   end					   
			    end
              else
                begin
				  if(bit_count == 4'd9 && edge_count == error_check_edge)
			        begin
			          next_state = err_chk ; 
                    end
			      else
			        begin
					  next_state = stop ; 			
                   end	
                end				
            end	
  err_chk : begin
              if(!S_DATA)
			   next_state = start ;
			  else
			   next_state = IDLE ; 									  
            end				  		   
  default: begin
			 next_state = IDLE ; 
           end	
  endcase                 	   
 end 

 
// output logic
always @ (*)
 begin
  edge_bit_en = 1'b0 ;
  dat_samp_en = 1'b0 ;  
  deser_en    = 1'b0 ; 
  par_chk_en  = 1'b0 ; 
  stp_chk_en  = 1'b0 ;
  data_valid  = 1'b0 ;
  strt_chk_en = 1'b0 ;
  case(current_state)
  IDLE   : begin
             if(!S_DATA)
			  begin
               edge_bit_en = 1'b1 ; 
               deser_en    = 1'b0 ; 
               par_chk_en  = 1'b0 ; 
               stp_chk_en  = 1'b0 ;	
			   strt_chk_en = 1'b1 ;
               dat_samp_en = 1'b1 ; 			   
			  end 
			else
			  begin
			   strt_chk_en = 1'b0 ;
               edge_bit_en = 1'b0 ; 
               deser_en    = 1'b0 ; 
               par_chk_en  = 1'b0 ; 
               stp_chk_en  = 1'b0 ;
               dat_samp_en = 1'b0 ; 			   
			  end  			
           end
  start  : begin
			 strt_chk_en = 1'b1 ;  
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;			 
           end
  data   : begin
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b1 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;			 
           end
  parity : begin
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b1 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;				 
           end
  stop   : begin
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b1 ;
             dat_samp_en = 1'b1 ;				 
           end	
  err_chk: begin
             edge_bit_en = 1'b0 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;
             if(par_err | stp_err)
			   begin
			    data_valid = 1'b0 ; 
               end
			 else
			   begin
			    data_valid = 1'b1 ; 	    				
               end				 
           end			   
  default: begin
             edge_bit_en = 1'b0 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;	
			 data_valid  = 1'b0 ;
             dat_samp_en = 1'b0 ;				 
		   end 
  endcase                 	   
 end 

endmodule
 