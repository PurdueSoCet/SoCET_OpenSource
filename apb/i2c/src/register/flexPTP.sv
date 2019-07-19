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
// File name:   flexPTP.sv
// Created:     4/21/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Flexible parallel-to-parallel shift register
module flexPTP
#(
	parameter NUM_BITS = 8
)
(
	input reg [NUM_BITS:0] data_in,
	input wire clk, n_rst, shift_enable, clear,
	output reg [NUM_BITS:0] data_out
);

reg [NUM_BITS:0] next_data_out;

always_ff @(posedge clk, negedge n_rst)
begin
	if(0 == n_rst) begin
		data_out = '0;
	end else begin
		data_out = next_data_out;
	end
end

always_comb
begin
	if(clear) begin
		next_data_out = {data_in[NUM_BITS], 1'b0, data_in[NUM_BITS-2:0]};
	end else if(shift_enable) begin
		next_data_out = data_in;
	end else begin
		next_data_out = data_out;
	end
end
endmodule
