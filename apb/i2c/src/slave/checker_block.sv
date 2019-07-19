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

// Description: This is the module for the Checker block.

module checker_block
(
	input wire clk,
	input wire n_rst,
	input wire SDA_sync,
	input wire SCL_sync,
	input wire [7:0] rx_data,
	input wire [9:0] bus_address,
	input wire address_mode,	// 7 bit or 10 bit mode
	input wire rw_store,
	output reg rw_mode,
	output reg [1:0] address_match,
	output reg start,
	output reg stop
);

	reg scl_mid1, scl_mid2, sda_mid1, sda_mid2;
	reg [1:0] temp_address_match;

	always @(posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0)
		begin
			scl_mid1 <= 1'b0;
			scl_mid2 <= 1'b0;
			sda_mid1 <= 1'b0;
			sda_mid2 <= 1'b0;
			rw_mode <= 1'b0;
			address_match <= 1'b0;
			start <= 1'b0;
			stop <= 1'b0;
		end
		else
		begin
			scl_mid1 <= SCL_sync; //Synchronizer FF1 SCL
			scl_mid2 <= scl_mid1; //Synchronizer FF2 SCL
			sda_mid1 <= SDA_sync; //Synchronizer FF1 SDA
			sda_mid2 <= sda_mid1; //Synchronizer FF2 SDA
			rw_mode <= (rw_store) && rx_data[0] || (!rw_store) && rw_mode; // Read/Write Output Logic
			address_match <= temp_address_match; //Address Match Output Logic
			start <= (scl_mid1 && scl_mid2 && !sda_mid1 && sda_mid2) ? 1'b1 : 1'b0; //Start Flag
			stop <= (scl_mid1 && scl_mid2 && sda_mid1 && !sda_mid2) ? 1'b1 : 1'b0; //Stp Flag
		end
	end


	always_comb
	begin 
		if(address_mode == 1'b0)	// 7 Bit Mode
		begin 
			temp_address_match[1] = (rx_data[7:1] == bus_address[6:0]) ? 1'b1 : 1'b0; // Address match for first byte 7 Bit addressing
			temp_address_match[0] = 0;
		end
		else				// 10 Bit Mode
		begin 
			temp_address_match[1] = (rx_data[2:1] == bus_address[9:8]) ? 1'b1 : 1'b0; // Address match for first byte 10 Bit addressing
			temp_address_match[0] = (rx_data[7:0] == bus_address[7:0]) ? 1'b1 : 1'b0; // Address match for second byte 10 Bit addressing
		end
	end
	
endmodule 
