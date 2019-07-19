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

module sync_high
(
	input wire clk, n_rst, async_in,
	output wire sync_out
);
	localparam RESET_VALUE = 1'b1;
	reg out[1:0];
	
	assign sync_out = out[1];
	
	//flip flop one
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0)
			out[0] <= RESET_VALUE;
		else
			out[0] <= async_in;
	end

	//flip flop two
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0)
			out[1] <= RESET_VALUE;
		else
			out[1] <= out[0];
	end

endmodule
