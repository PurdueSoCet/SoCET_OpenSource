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

// Description: This is the module for the SDA Selector

module sda_select
(
	input wire [1:0] sda_mode,
	input wire tx_out,
	output reg SDA_out_slave
);

	always_comb
	begin 
		if(sda_mode == 2'b00)		//IDLE
			SDA_out_slave = 1'b1;
		else if(sda_mode == 2'b01)	//ACK
			SDA_out_slave = 1'b0;
		else if(sda_mode == 2'b10)	//NACK
			SDA_out_slave = 1'b1;
		else if(sda_mode == 2'b11)	//TX_OUT
			SDA_out_slave = tx_out;
	end
	
endmodule 
