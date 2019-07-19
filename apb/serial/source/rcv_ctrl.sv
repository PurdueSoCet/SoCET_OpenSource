// ------------------------------------------------------------------------
// Copyright 2019 Purdue University SoCET design team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ------------------------------------------------------------------------

// File name:   rcv_ctrl.sv
// Created:     2/24/2014
// Author:      Xin Tze Tee
// Version:     1.0  Initial Design Entry
// Description: Receiver Control Unit

module rcv_ctrl
  (
   input wire clk,
   input wire n_rst,
   input wire start_bit_detected,
   input wire packet_done,
   input reg error_flag,
   output wire sbc_clear,
   output wire sbc_enable,
   output wire load_buffer,
   output wire enable_timer
);

parameter [2:0] IDLE = 3'b000,
		CLEAR  = 3'b001,
		SAMPLE = 3'b010,
		CHECK1 = 3'b011,
		CHECK2 = 3'b100,
		LOAD = 3'b101;

reg [2:0]   current_state, next_state;
reg 	       sbc_clear_reg, sbc_enable_reg, enable_timer_reg,load_buffer_reg;

assign sbc_clear = sbc_clear_reg;
assign sbc_enable = sbc_enable_reg;
assign enable_timer = enable_timer_reg;
assign load_buffer = load_buffer_reg;
   

always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst == 0) current_state <= IDLE;
	else current_state <= next_state;
end

always_comb
begin
	case(current_state)
	  IDLE: begin
	    if(start_bit_detected == 1'b1) next_state = CLEAR;
	    else next_state = IDLE;
	  end
	  CLEAR: begin
	     next_state = SAMPLE;
	  end
	  SAMPLE:begin
	     if(packet_done == 1'b1) next_state = CHECK1;
	     else next_state = SAMPLE;
	  end
	  CHECK1: begin //give it one cycle to produce error flag
	     next_state = CHECK2;
	  end
	  CHECK2: begin //check the framing_error flag
	     if(error_flag == 1'b0) next_state = LOAD;
	     else next_state = IDLE;
	  end
	  LOAD: begin
	     next_state = IDLE;
	  end
	  default: next_state = IDLE;
	  
  endcase // case (current_state)
end // always_comb begin

//output logic
always_comb
begin
  case(current_state)
     IDLE:
	 begin
	    sbc_clear_reg = 1'b0;
	    sbc_enable_reg = 1'b0;
	    enable_timer_reg = 1'b0;
	    load_buffer_reg = 1'b0;		    
	 end
     CLEAR:
	 begin
	    sbc_clear_reg = 1'b1;
	    sbc_enable_reg = 1'b0;
	    enable_timer_reg = 1'b0;
	    load_buffer_reg  = 1'b0;
	 end
     SAMPLE:
	 begin
	    sbc_clear_reg = 1'b0;
	    sbc_enable_reg = 1'b0;
	    enable_timer_reg = 1'b1;
	    load_buffer_reg  = 1'b0;
	 end
     CHECK1:
	 begin
	    sbc_clear_reg = 1'b0;
	    sbc_enable_reg = 1'b1;
	    enable_timer_reg = 1'b0;
	    load_buffer_reg  = 1'b0;
	 end
     CHECK2:
	 begin
	    sbc_clear_reg = 1'b0;
	    sbc_enable_reg = 1'b0;
	    enable_timer_reg = 1'b0;
	    load_buffer_reg  = 1'b0;
	 end
     LOAD:
	 begin
	    sbc_clear_reg = 1'b0;
	    sbc_enable_reg = 1'b0;
	    enable_timer_reg = 1'b0;
	    load_buffer_reg  = 1'b1;
       	 end
     default:
	 begin
	    sbc_clear_reg = 1'b0;
	    sbc_enable_reg = 1'b0;
	    enable_timer_reg = 1'b0;
	    load_buffer_reg  = 1'b0;
	 end
  endcase // case (current_state)
end // always_comb begin
   
endmodule
	
   
	  
   
			  
   
   
