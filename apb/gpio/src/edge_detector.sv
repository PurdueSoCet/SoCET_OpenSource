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

// File name:   edge_detector.sv
// Created:     4/16/2015
// Author:      John Skubic
// Version:     1.0 
// Description: Edge detector 
//	

module edge_detector #(
		parameter WIDTH = 1
	)
	(
		input logic clk, n_rst, 
		input logic [WIDTH - 1:0] signal,
		output logic [WIDTH - 1:0] pos_edge, neg_edge
	);

	logic [WIDTH - 1 : 0] signal_r;

	//flip flop behavior
	always_ff @ (posedge clk, negedge n_rst) begin
		if(~n_rst)
			signal_r <= '0;
		else 
			signal_r <= signal;
	end

	//output logic
	assign pos_edge = signal & ~signal_r;
	assign neg_edge = ~signal & signal_r;

endmodule
