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

// File name:   FifoReadCtr.sv
// Created:     7/24/2014
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Fifo Read Counter.

module FifoReadCtr
#(
	parameter regLength = 8,
	parameter addrSize = 3
)
(
	input wire clk, n_rst,
	input wire rEnable,
	input wire wEnable,
	input wire fifoEmpty,
	input wire fifoFull,
	output wire [addrSize - 1:0] rptr		// width = address size for 8 registers
);

reg [addrSize - 1:0] count, next_count;

// Register for Counter
always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		//count <= '0;
    count <= 'd7;
	end else begin
		count <= next_count;
	end
end

always_comb
begin
	if (n_rst == 0) begin
		next_count = 0;
	end
	if (fifoEmpty == 1) begin	// does not read when fifo is empty
		next_count = count;
	end else if (rEnable == 1) begin
		if (count == (regLength - 1)) begin	// check if counter reaches the top of the stack
			//next_count = 1;
      next_count=0;
		end else begin
			next_count = count + 1;
		end
	end else begin
		next_count = count;
	end
end

assign rptr = count;

endmodule
