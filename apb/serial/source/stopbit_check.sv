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

// File name:   stopbit_check.sv
// Created:     2/5/2013
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Checks for stop bit

module stopbit_check
(
	input  wire clk,
	input  wire n_rst,
	input  wire sbc_clear,
	input  wire sbc_enable,
	input  wire stop_bit,
	output reg  error_flag
);

	reg nxt_error_flag;
	
	always @ (negedge n_rst, posedge clk)
	begin : REG_LOGIC
		if(1'b0 == n_rst)
		begin
			error_flag	<= 1'b0; // Initialize to inactive value
		end
		else
		begin
			error_flag <= nxt_error_flag;
		end
	end
	
	always @ (error_flag, sbc_clear, sbc_enable, stop_bit)
	begin : NXT_LOGIC
		// Set default value(s)
		nxt_error_flag <= error_flag;
		
		// Define override condition(s)
		if(1'b1 == sbc_clear) // Synchronus clear/reset takes top priority for value
		begin
			nxt_error_flag <= 1'b0;
		end
		else if(1'b1 == sbc_enable) // Stop bit checker is enabled
		begin
			if(1'b1 == stop_bit) // Proper stop bit -> framming error flag should be inactive
			begin
				nxt_error_flag <= 1'b0;
			end
			else // Improper stop bit -> framing error flag should be asserted
			begin
				nxt_error_flag <= 1'b1;
			end
		end
	end

endmodule
