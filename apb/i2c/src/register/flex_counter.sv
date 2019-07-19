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

// $Id: $
// File name:   flex_counter.sv
// Created:     2/3/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter
module flex_counter
#(
  parameter NUM_CNT_BITS = 4
)
(
  input wire clk,
  input wire n_rst,
  input wire clear,
  input wire count_enable,
  input reg [NUM_CNT_BITS-1:0] rollover_val,
  output reg [NUM_CNT_BITS-1:0] count_out,
  output reg rollover_flag
);

reg [NUM_CNT_BITS-1:0] next_count;
reg rollover;

always_ff @ (posedge clk, negedge n_rst)
begin
  //rollover_flag <= rollover;
  if(n_rst == 1'b0) begin
    count_out <= '0;
    rollover_flag <= '0;
  end else begin
    count_out <= next_count;
    rollover_flag <= rollover;
  end
end

always_comb
begin
  if((rollover_val-1) == count_out) begin
    rollover = 1;
  end else begin
    rollover = 0;
  end
  //rollover = rollover_val & (count_out-1);
  if(clear == 1) begin
    next_count = 0;
    rollover = 1'b0;
  end else begin
    if(count_enable == 1'b1) begin
      if(rollover_flag == 1'b0) begin
        next_count = count_out + 1'b1;
	//if(count_out == (rollover_val)) begin
	//  rollover = 1'b1;
	//end else begin
	//  rollover = 1'b0;
        //end
      end else begin
        next_count = 1'b1;
      end
    end else begin
      next_count = count_out;
      if(count_out == (rollover_val)) begin
        rollover = 1'b1;
      end else begin
	rollover = 1'b0;
      end
    end
  end
end
endmodule
