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

// File name:   serial_rcv_timer.sv
// Updated:     03/01/2016
// Author:      Xin Tze Tee and Travis Garza
// Version:     1.0  Initial Design Entry
// Description: Timing Controller

/* 
I also might want to add an input for the baud rate here like transmitter.sv and then have a way to update rollover1
*/
module serial_rcv_timer
  (
   input wire clk,
   input wire n_rst,
   input wire enable_timer,
   input reg [31:0] baudData,
   output wire shift_strobe,
   output wire packet_done
   );

   wire        clear;
   
   wire [31:0]  count_out1;
   wire [11:0]  count_out2;

   wire [31:0]  rollover1;
   wire [11:0]  rollover2;


   wire        inter;

   reg start_count;
   reg [7:0] out, next_out;

   assign clear = inter;
   assign packet_done = inter;
   
   
   assign rollover1 = baudData;  // number of cycle for 1 bit (baud-rate) *used to be a set rate of 286
   assign rollover2 = 2574;	// total of cycles for 9 bits


   defparam IN1.NUM_CNT_BITS = 32;
   defparam IN2.NUM_CNT_BITS = 12;
 

   flex_counter IN1(clk,n_rst,clear,(enable_timer & start_count),rollover1,count_out1,shift_strobe);

   flex_counter IN2(clk,n_rst,clear,(enable_timer & start_count),rollover2,count_out2,inter);
   
   always_comb 
   begin
	next_out = 0;
	start_count = 0;
	if (enable_timer == 1) begin 
		if (out < 8'd138) begin
			next_out = out + 1;
		  start_count = 0;
		   
		end
		else begin 
			next_out = out;
			start_count = 1;
		end
	end
	else if (enable_timer == 0) begin
		start_count = 0;
		next_out = 0; 
	end
   end

   always_ff @(posedge clk, negedge n_rst) begin
	if(1'b0 == n_rst) begin
      	out <= 0;    
  	end
	else begin
  		out <= next_out;     
  	end      
   end

endmodule // timer
