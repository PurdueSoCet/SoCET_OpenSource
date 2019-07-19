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

// File name:   startbit_detect.sv
// Created:     2/5/2013
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Detects Start bit

module startbit_detect
(
	input  wire clk,
	input  wire n_rst,
	input  wire serial_in,
	output wire start_bit_detected
);

	reg old_sample;
	reg new_sample;
	reg sync_phase;
	
	always @ (negedge n_rst, posedge clk)
	begin : REG_LOGIC
		if(1'b0 == n_rst)
		begin
			old_sample	<= 1'b1; // Reset value to idle line value
			new_sample	<= 1'b1; // Reset value to idle line value
			sync_phase	<= 1'b1; // Reset value to idle line value
		end
		else
		begin
			old_sample	<= new_sample;
			new_sample	<= sync_phase;
			sync_phase	<= serial_in;
		end
	end
	
	// Output logic
	assign start_bit_detected = old_sample & (~new_sample); // Detect a falling edge -> new sample must be '0' and old sample must be '1'


	
endmodule
