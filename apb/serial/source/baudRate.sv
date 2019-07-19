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

// File name:   baudRate.sv
// Created:     6/16/2014
// Author:      Travis Garza
// Version:     1.0  
// Description: Register to hold variable baud rate for UART.

module baudRate
(
	input wire clk, n_rst,
	// inputs from APB Slave Interface
	input wire baud_enable,
	input wire [31:0] pWritedata, 

	// output to APB Slave Interface
	output reg [31:0] baudData_reg
);


// status register
always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst == 0) begin
		baudData_reg <= '0;
	end else begin
		if (baud_enable == 1) begin
			baudData_reg[31:0] <= pWritedata[31:0];
		end
	end
end



endmodule
 
