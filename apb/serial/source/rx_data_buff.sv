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

// File name:   rx_data_buff.sv
// Created:     2/5/2013
// Author:      foo
// Version:     1.0  Initial Design Entry
// Description: 8-bit data buffer 

module rx_data_buff
(
	input  wire clk,
	input  wire n_rst,
	input  wire load_buffer,
	input  wire [7:0] packet_data,
	input  wire data_read,
	output reg  [7:0] rx_data,
	output reg  data_ready,
	output reg  overrun_error
);

	reg [7:0] nxt_rx_data;
	reg nxt_overrun_error;
	reg nxt_data_ready;
	integer i;
	
	always @ (negedge n_rst, posedge clk)
	begin : REG_LOGIC
		if(1'b0 == n_rst)
		begin
			rx_data				<= 8'b11111111;	// Initialize the rx_data buffer to have all bits be the idle line value
			data_ready		<= 1'b0;				// Initialize the data_ready flag to be inactive
			overrun_error	<= 1'b0;				// Initialize the overrun_error flag to be inactive
		end
		else
		begin
			rx_data				<= nxt_rx_data;
			data_ready		<= nxt_data_ready;
			overrun_error	<= nxt_overrun_error;
		end
	end
	
	always @ (rx_data, data_ready, overrun_error, packet_data, load_buffer, data_read)
	begin : NXT_LOGIC
		// Assign default values
		nxt_rx_data				<= rx_data;
		nxt_data_ready		<= data_ready;
		nxt_overrun_error	<= overrun_error;
		
		// Define override condition(s)
		// RX data logic
		if(1'b1 == load_buffer)
		begin
			nxt_rx_data <= packet_data;
		end
		
		// Data ready logic
		if(1'b1 == load_buffer)	// New data will be loaded on the next clock edge -> should always cause data_ready to be asserted
		begin
			nxt_data_ready <= 1'b1;
		end
		else if (1'b1 == data_read) // If new data is not going to be loaded on the next clk edge and the currently stored data is being read -> deassert the data ready flag
		begin
			nxt_data_ready <= 1'b0;
		end
		
		// Overrun Error logic
		if((1'b1 == load_buffer) && (1'b1 == data_ready) && (1'b0 == data_read)) // Loading new data, already have data loaded, and current data is not being read -> overrun will occur
		begin
			nxt_overrun_error <= 1'b1;
		end
		else if (1'b1 == data_read) // Currently stored data is being read -> clear any prior overrun error
		begin
			nxt_overrun_error <= 1'b0;
		end
	end	
	
endmodule
