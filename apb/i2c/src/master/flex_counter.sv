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

module flex_counter
#(parameter NUM_CNT_BITS = 4)

(
	input wire clk, n_rst, clear, count_enable,
	input wire [NUM_CNT_BITS-1:0]  rollover_val,
	output reg [NUM_CNT_BITS-1:0]  count_out,
	output reg rollover_flag
);
	//local variables
	reg [NUM_CNT_BITS-1:0] incremented_count;
	reg [NUM_CNT_BITS:0] carrys;
	wire [NUM_CNT_BITS-1:0]pre_rollover = rollover_val == 1 ? 1 : rollover_val -1;

	//assign local variables
	//assign incremented_count = count_out + 1;
	assign carrys[0] = 1'b1;
	
	//incremented using a chain of half adders
	genvar i;
	generate
	for (i=0;i<NUM_CNT_BITS;i++) begin
		assign incremented_count[i] = carrys[i] ^ count_out[i];
		assign carrys[i+1] = carrys[i] & count_out[i]; 
	end
	endgenerate

	//output logic for rollover flag
	always @ (posedge clk, negedge n_rst) begin
		if (!n_rst)
			rollover_flag <= 0;
		else if (count_enable && !clear) begin
			if (count_out == pre_rollover)
				rollover_flag <= '1;
			else
				rollover_flag <= '0;
		end
		else if (clear)
			rollover_flag <= 0;
			
	end

	//next state logic for counter
	always @ (posedge clk, negedge n_rst) begin
		if (!n_rst)				//Reset asynchronously
			count_out<=0;
		else if (clear)				//Reset synchronously
			count_out<=0;
		else if (count_enable) begin		//If counting is enabled
			if (count_out==rollover_val)	//Rollover
				count_out<=1;
			else				//No rollover so increment
				count_out<=incremented_count;
		end else				//Hold state
			count_out<=count_out;
	end

endmodule
