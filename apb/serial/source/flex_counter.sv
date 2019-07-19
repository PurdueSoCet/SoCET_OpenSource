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

// File name:   flex_counter.sv
// Created:     2/9/2014
// Author:      Xin Tze Tee
// Version:     1.0  Initial Design Entry
// Description: flex_counter

module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [NUM_CNT_BITS - 1 :0] rollover_val,
	output wire [NUM_CNT_BITS - 1 :0] count_out,
	output wire rollover_flag
);


reg [NUM_CNT_BITS : 0] out;
reg[NUM_CNT_BITS : 0] next_logic;
reg[NUM_CNT_BITS - 1: 0] inter;


assign count_out = out[NUM_CNT_BITS - 1:0];
assign rollover_flag = out[NUM_CNT_BITS];

always_comb 
begin
  inter = out[NUM_CNT_BITS - 1: 0] + 1;
  next_logic = out; //default state
    
  if (1'b1 == clear)
  begin  
      next_logic[NUM_CNT_BITS:0] = 0;
  end    
  else if(inter == rollover_val && 1'b1 == count_enable)
  begin
      next_logic[NUM_CNT_BITS - 1:0] = inter;
      next_logic[NUM_CNT_BITS] = 1'b1;
  end
  else if(out[NUM_CNT_BITS -1:0] == rollover_val && 1'b1 == count_enable)
  begin
      next_logic[NUM_CNT_BITS -1 :0] = 1;
     
     //new added
      if(next_logic[NUM_CNT_BITS - 1:0] != rollover_val) //checking
        begin
           next_logic[NUM_CNT_BITS] = 1'b0;
        end
  end
  else if(1'b1 == count_enable)
  begin 
      next_logic[NUM_CNT_BITS - 1:0] = inter;
      next_logic[NUM_CNT_BITS] = 1'b0;
  end
    
end 

always_ff @(posedge clk, negedge n_rst) 
begin
  if(1'b0 == n_rst) begin
	out <= 0;    
  end else begin
	out <= next_logic;     
  end    
end


endmodule
