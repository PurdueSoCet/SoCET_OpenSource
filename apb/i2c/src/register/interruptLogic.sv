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
// File name:   interrupt_logic.sv
// Created:     4/21/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Interrupt Logic Block
module interruptLogic(
	input wire clk, n_rst,
	input wire [12:0] status,
	output reg interrupt
);
reg next_interrupt;

always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 0) begin
		interrupt <= 1'b0;
	end else begin
		interrupt <= next_interrupt;
	end
end

always_comb
begin
	if(status[0] | status[2] | status[3] | status[5] | status[6]) begin
		next_interrupt = 1'b1;
	end else begin
		next_interrupt = 1'b0;
	end
end
endmodule
