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

`include "i2c.vh"
module control_buffer(
	input 	logic clk, logic n_rst,
		logic [9:0]	u_bus_address,
		DataDirection	u_data_direction,
		AddressMode	u_address_mode,
		logic[31:0] 	u_clock_div,
		logic		u_stretch_enabled,
		logic 		load_buffer,
	output	logic [9:0]	bus_address,
		DataDirection	data_direction,
		AddressMode	address_mode,
		logic		stretch_enabled,
		logic[31:0]	clock_div
);

always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst) begin
		bus_address <= 		10'b0;
		data_direction <=	RX;
		address_mode <=		ADDR_7_BIT;
		stretch_enabled <=	1;
		clock_div <=		300;
	end
	else if(load_buffer) begin
		bus_address <= 		u_bus_address;
		data_direction <=	u_data_direction;
		address_mode <=		u_address_mode;
		stretch_enabled <=	u_stretch_enabled;
		clock_div <=		u_clock_div;
	end
	else begin
		bus_address <= 		bus_address;
		data_direction <=	data_direction;
		address_mode <=		address_mode;
		stretch_enabled <=	stretch_enabled;
		clock_div <=		clock_div;

	end
end

endmodule
