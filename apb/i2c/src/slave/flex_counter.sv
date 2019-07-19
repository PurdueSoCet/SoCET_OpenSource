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
// Created:     2/2/2016
// Author:      Arnav Mittal
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: This is the module for Flexible and Scalable counter with a Controlled Rollover



module flex_counter

#(
	parameter NUM_CNT_BITS = 4
)

(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [(NUM_CNT_BITS-1):0] rollover_val,
	output wire [(NUM_CNT_BITS-1):0]count_out,
	output reg rollover_flag
);
	reg [(NUM_CNT_BITS-1):0] next_count;
	reg [(NUM_CNT_BITS-1):0] curr_count;
	reg next_rollover_flag;
	reg curr_rollover_flag;
	

	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0) //RESET == 0
		begin
			curr_rollover_flag <= 1'b0;
			curr_count <= '0; 
		end
		else //RESET == 1
		begin
			curr_rollover_flag <= next_rollover_flag;
			curr_count <= next_count; 
		end
	end

	always_comb
	begin
		next_count = '0;
		next_rollover_flag = '0;
		if(clear == 1'b1) //CLEAR == 1
		begin
			next_count = '0;
			next_rollover_flag = '0;
		end
		else //CLEAR == 0
		begin
			if(count_enable == 1'b1) //COUNT_ENABLE == 1
			begin
				next_count = curr_count+1;
				next_rollover_flag = 1'b0;

				if (curr_count == rollover_val - 1)
				begin
					next_rollover_flag = 1'b1;
				end
				if (curr_count == rollover_val )
				begin
					next_rollover_flag = 1'b0;
					next_count = {'0,1'b1};
				end
			end
			else
			begin
				next_count = curr_count;
				next_rollover_flag = curr_rollover_flag;
			end
		end
	end

	assign count_out = curr_count;
	assign rollover_flag = curr_rollover_flag;
endmodule
