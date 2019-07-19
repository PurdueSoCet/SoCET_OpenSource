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

// Description: This is the module for the SCL Edge Detector.

module edge_detect
(
	input wire clk,
	input wire n_rst,
	input wire SCL_sync,
	output wire rising_edge, // Rising edge Flag
	output wire falling_edge // Falling edge Flag
);
	reg stage1;
	reg stage2;

	always @(posedge clk, negedge n_rst)
	begin
		if(n_rst == 1'b0) //SYNC 1
		begin
			stage1 <= 1'b0;
			stage2 <= 1'b0;
		end
		else 		//SYNC 2
		begin
			stage1 <= SCL_sync;
			stage2 <= stage1;
		end
	end

	assign rising_edge = stage1 & ~stage2; //Rising Edge SCL Flag
	assign falling_edge = ~stage1 & stage2;	//Falling Edge SCL Flag

endmodule 
