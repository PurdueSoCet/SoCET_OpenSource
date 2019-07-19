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

// Description: This is the Parallel To Serial Shift Register for the TX.

module pts_sr_tx
(
	input wire clk,
	input wire n_rst,
	input wire falling_edge,
	input wire tx_enable,
	input wire load_data,
	input wire [7:0] tx_data,
	output reg tx_out
);

	flex_pts_sr #(8,1) PTS_SR_TX
	(
		.clk(clk),
		.n_rst(n_rst),
		.shift_enable(tx_enable && falling_edge), //Enable Signal
		.load_enable(load_data),		  //Load Enable Signal
		.parallel_in(tx_data),			  //Data IN
		.serial_out(tx_out)			  //Data OUT
	);
endmodule 
