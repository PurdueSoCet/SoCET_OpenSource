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

// Description: This is the Serial To Parallel Shift Register for the RX.

module stp_sr_rx
(
	input wire clk,
	input wire n_rst,
	input wire SDA_sync,
	input wire rising_edge,
	input wire rx_enable,
	output reg [7:0] rx_data
);

	flex_stp_sr #(8,1) STP_SR_RX
	(
		.clk(clk),
		.n_rst(n_rst),
		.shift_enable(rx_enable && rising_edge), //Shift Enable Signal
		.serial_in(SDA_sync),			 //Data IN
		.parallel_out(rx_data)			 //Data OUT
	);
endmodule 
