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

// Description: This is a module for N-Bit Parallel-To-Serial Shift Register.


module flex_pts_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 0

)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire load_enable,
	input reg [(NUM_BITS-1):0] parallel_in,
	output wire serial_out
);
	reg [(NUM_BITS-1):0] output_logic;
	reg [(NUM_BITS-1):0] next_state_logic;
	
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0) //n_rst == 0
		begin
			output_logic <= '1; 
		end
		else
		begin
			output_logic <= next_state_logic;  
		end
	end	
	
	always_comb
	begin
		if (load_enable == 1'b1)
		begin
			next_state_logic = parallel_in;
		end
		else		
		begin			
			if (shift_enable == 1'b1)
			begin
				if (SHIFT_MSB == 1)
				begin
					next_state_logic = {output_logic[(NUM_BITS-2):0],1'b1};
				end	
				else
				begin
					next_state_logic = {1'b1,output_logic[(NUM_BITS-1):1]};
				end
			end
			else
			begin
				next_state_logic = output_logic;
			end
		end
	end
	
	if (SHIFT_MSB == 1)
	begin
		assign serial_out = output_logic[NUM_BITS-1];
	end
	else
	begin
		assign serial_out = output_logic[0];
	end
endmodule 
