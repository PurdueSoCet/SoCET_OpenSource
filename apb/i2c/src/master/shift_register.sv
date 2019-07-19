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
`include "i2c_master_const.vh"

module shift_register(
	input	logic 		clk, n_rst,
		logic [9:0]	bus_address,		//The bus address
		logic [7:0]	tx_data,		//Data from the TX_FIFO
		ShiftSelectType	shift_input_select,	//Select which byte to load into the shift register
		DataDirection	data_direction,		//Is this a rx packet or a tx packet?
		DataDirection	shift_direction,	//Is this byte shifted in or out?
		logic		shift_strobe,		//shift the shift register
		logic		shift_in,		//the value to shift in
		logic		shift_load,		//tell shift regiser to load new data
	output	logic		shift_out,		//The msb of the shift register
		logic [7:0]	data_out		//The byte contained in the register
);

//Local variables
logic[7:0] load_value;	//The next value to load into the shift register
logic read_write;	//The R/W flag to send to the slave
logic[7:0] next_data;	//The next value of data_out

assign read_write = data_direction==RX;
assign shift_out = data_out[7];

//Input mux, selects which value to load into the shift regsiter
//=====================================================================

always_comb begin
	case(shift_input_select)
		SS_10_BIT_ADDRESS_BYTE_1:	load_value = {5'b11110,bus_address[9:8],read_write};
		SS_10_BIT_ADDRESS_BYTE_2:	load_value = bus_address[7:0];
		SS_7_BIT_ADDRESS:		load_value = {bus_address[6:0],read_write};
		SS_TX_FIFO:			load_value = tx_data;

	endcase
end

//Next state logic
//=====================================================================
always_comb begin
	if(shift_load)
		next_data = load_value;
	else if (shift_strobe && shift_direction==RX)
		next_data = {data_out[6:0],shift_in};
	else if (shift_strobe && shift_direction==TX)
		next_data = {data_out[6:0],1'b1};
	else
		next_data = data_out;
end

//Register logic
//=====================================================================
always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		data_out <= 8'b11111111; //reset to idle line value
	else
		data_out <= next_data;
end


endmodule
