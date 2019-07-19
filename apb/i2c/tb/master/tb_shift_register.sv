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

//`include "i2c.vh"
`include "i2c_master_const.vh"
`timescale 1ns / 100ps

module tb_shift_register();

//Parameters
localparam CLOCK_PERIOD = 15ns;

//Signals
logic tb_clk, tb_n_rst;
logic [7:0] tb_tx_data;
logic [9:0] tb_bus_address;
ShiftSelectType tb_shift_input_select;
DataDirection tb_data_direction;
DataDirection tb_shift_direction;
logic tb_shift_strobe, tb_shift_in, tb_shift_load, tb_shift_out;
logic [7:0] tb_data_out;

logic [7:0] tb_expected_value;
logic [7:0] tb_in_data;
logic RW;
assign RW = tb_data_direction == RX;
assign tb_shift_in = tb_in_data[7];

//Clock
always begin
	tb_clk=1;
	#(CLOCK_PERIOD/2.0);
	tb_clk=0;
	#(CLOCK_PERIOD/2.0);
end

//Tasks
task reset();
	tb_shift_strobe=0;
	tb_shift_load =0;

	@(negedge tb_clk);
	tb_n_rst=0;
	@(negedge tb_clk);
	tb_n_rst=1;
endtask

task shift();
	@(negedge tb_clk);
	tb_shift_strobe=1;
	@(negedge tb_clk);
	tb_shift_strobe=0;
	@(negedge tb_clk);
	@(negedge tb_clk);
	@(negedge tb_clk);
endtask

task txByte(input ShiftSelectType ss);
	integer i;
	case(ss)
		SS_10_BIT_ADDRESS_BYTE_1:
			tb_expected_value = {5'b11110,tb_bus_address[9:8], RW};
		SS_10_BIT_ADDRESS_BYTE_2:
			tb_expected_value = tb_bus_address[7:0];
		SS_7_BIT_ADDRESS:
			tb_expected_value = {tb_bus_address[6:0],RW};
		SS_TX_FIFO:
			tb_expected_value = tb_tx_data;
	endcase
	tb_shift_input_select=ss;
	@(negedge tb_clk);
	tb_shift_load=1;
	@(negedge tb_clk);
	tb_shift_load=0;

	for(i=0;i<8;i++) begin
		assert (tb_expected_value[7]==tb_shift_out) else
			$error("TX ouput doesnt match expected value");
		shift();
		tb_expected_value = tb_expected_value<<1;
	end
endtask

task testVector(input [10:0] address, input [7:0] tx_data, input DataDirection data_direction, input [7:0] in);
	integer i;
	tb_in_data=in;
	tb_bus_address = address;
	tb_tx_data = tx_data;
	tb_data_direction=data_direction;
	tb_shift_direction = TX;

	reset();
	txByte(SS_10_BIT_ADDRESS_BYTE_1);
	reset();
	txByte(SS_10_BIT_ADDRESS_BYTE_2);
	reset();
	txByte(SS_7_BIT_ADDRESS);
	reset();
	txByte(SS_TX_FIFO);
	
	tb_shift_direction=RX;
	reset();
	tb_expected_value = tb_in_data;
	for(i=0;i<8;i++) begin
		shift();
		tb_in_data = tb_in_data<<1;
	end
	assert(tb_data_out == tb_expected_value) else
		$error("Did not receive correct data!");

endtask

//DUT
//=====================================================================
shift_register DUT(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.bus_address(tb_bus_address),
	.tx_data(tb_tx_data),
	.shift_input_select(tb_shift_input_select),
	.data_direction(tb_data_direction),
	.shift_direction(tb_shift_direction),
	.shift_strobe(tb_shift_strobe),
	.shift_in(tb_shift_in),
	.shift_load(tb_shift_load),
	.shift_out(tb_shift_out),
	.data_out(tb_data_out)
);

initial begin
	testVector(10'b1111100000, 8'b11110000, TX, 8'b11111111);
	testVector(10'b0011001100, 8'b00001111, RX, 8'b00000000);
	testVector(10'b1010101000, 8'b11111111, TX, 8'b10101010);
	$info("testbench complete!");
end
	
endmodule
