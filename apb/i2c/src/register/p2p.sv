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

// Parallel-to-Parallel Shift Register
// Created by: Sam Sowell
module p2p
(
	input reg [7:0] data_in,
	input wire clk, n_rst, shift_enable,
	output reg [7:0] data_out
);

reg [7:0] next_data_out;

always_ff @(posedge clk, negedge n_rst)
begin
	if(0 == n_rst) begin
		data_out = 8'b0;
	end else begin
		data_out = next_data_out;
	end
end

always_comb
begin
	if(shift_enable) begin
		next_data_out = data_in;
	end else begin
		next_data_out = data_out;
	end
end
endmodule
