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

// Description: This is the module for a N-Bit Serial-To-Parallel Shift register.

module flex_stp_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 0

)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output reg [(NUM_BITS-1):0] parallel_out
);

	integer i;
	reg [(NUM_BITS-1):0] next_state_logic;
	
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0) //n_rst == 0
		begin
			for (i=0; i <=(NUM_BITS-1); i++)
			begin
				parallel_out[i] <= 1'b1;
			end 
		end
		else
		begin
			parallel_out <= next_state_logic;
		end
	end	
	
	always_comb
	begin
		if (shift_enable == 1'b1)
		begin
			if (SHIFT_MSB == 0)// SHIFT_MSB = 1 implies data goes LSB
			begin
				next_state_logic = {serial_in,parallel_out[(NUM_BITS-1):1]};
			end
			else// SHIFT_MSB = 0 implies data goes MSB first
			begin
				next_state_logic = {parallel_out[(NUM_BITS-2):0],serial_in};
			end
		end
		else		
		begin
			next_state_logic = parallel_out;
		end
	end
endmodule 
