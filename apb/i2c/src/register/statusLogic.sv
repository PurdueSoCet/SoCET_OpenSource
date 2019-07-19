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
// File name:   status_logic.sv
// Created:     4/21/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Logic block for status register
module statusLogic(
	input wire [4:0] i2c_status,
	input wire tx_full,
	input wire tx_empty,
	input wire rx_full,
	input wire rx_empty,
	input wire rx_w_ena,
	input wire tx_r_ena,
	input wire mid_tx_empty,
	input wire mid_rx_full,
	output reg [12:0] next_status
);

// Declare internal signals
reg rx_overflow;
reg tx_underflow;

// RX Overflow Error Logic
always_comb
begin
	if(rx_full & rx_w_ena) begin
		rx_overflow = 1'b1;
	end else begin
		rx_overflow = 1'b0;
	end
end

// TX Underflow Error Logic
always_comb
begin
	if(tx_empty & tx_r_ena) begin
		tx_underflow = 1'b1;
	end else begin
		tx_underflow = 1'b0;
	end
end

// Combine all signals
always_comb
begin
	next_status = {tx_underflow, tx_full, tx_empty, rx_overflow, rx_full, rx_empty, mid_tx_empty, mid_rx_full, i2c_status};	
end
endmodule
