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

// Description: This is the wrappper for the slave_inner.

module slave_inner
(
	input wire clk,
	input wire n_rst,
	input wire [7:0] tx_data,
	input wire address_mode,
	input wire ms_select,
	input wire [9:0] bus_address,
	input wire en_clock_strech,
	input wire TX_fifo_empty,
	input wire RX_fifo_full,
	input wire RX_fifo_almost_full,
	input wire SDA_sync,
	input wire SCL_sync,

	output reg [7:0] rx_data_slave,
	output reg set_transaction_complete_slave,
	output reg ack_error_set_slave,
	output reg busy_slave,
	output reg TX_read_enable_slave,
	output reg RX_write_enable_slave,
	output reg SDA_out_slave,
	output reg SCL_out_slave
);
	reg rising_edge;
	reg falling_edge;
	reg rx_enable;
	reg [7:0] rx_data;
	reg rw_mode;
	reg [1:0] address_match;
	reg start;
	reg stop;
	reg byte_received;
	reg ack_prep;
	reg ack_check;
	reg ack_done;
	reg [1:0] sda_mode;
	reg load_data;
	reg tx_enable;
	reg tx_out;
	reg rw_store;
	
	//-----------------------------------SCL Edge Detector
	edge_detect EDGE_DETECTOR
	(
		.clk(clk),
		.n_rst(n_rst),
		.SCL_sync(SCL_sync),
		.rising_edge(rising_edge),
		.falling_edge(falling_edge)
	);

	//-----------------------------------STP_SR_RX
	stp_sr_rx STP_SR_RX
	(
		.clk(clk),
		.n_rst(n_rst),
		.SDA_sync(SDA_sync),
		.rising_edge(rising_edge),
		.rx_enable(rx_enable),
		.rx_data(rx_data)
	);

	//---OUTPUT---
	assign rx_data_slave = rx_data;

	//-----------------------------------Checker Block
	checker_block CHECKER_BLOCK
	(
		.clk(clk),
		.n_rst(n_rst),
		.SDA_sync(SDA_sync),
		.SCL_sync(SCL_sync),
		.rx_data(rx_data),
		.bus_address(bus_address),
		.address_mode(address_mode),
		.rw_store(rw_store),
		.rw_mode(rw_mode),
		.address_match(address_match),
		.start(start),
		.stop(stop)
	);

	//---OUTPUT---
	assign set_transaction_complete_slave = stop;

	//-----------------------------------Timer
	slave_timer TIMER
	(
		.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.stop(stop),
		.rising_edge(rising_edge),
		.falling_edge(falling_edge),
		.byte_received(byte_received),
		.ack_prep(ack_prep),
		.ack_check(ack_check),
		.ack_done(ack_done)
	);

	//-----------------------------------Main Controller
	slave_controller CONTROLLER
	(
		.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.stop(stop),
		.address_match(address_match),
		.rw_mode(rw_mode),
		.SDA_sync(SDA_sync),
		.address_mode(address_mode),
		.TX_fifo_empty(TX_fifo_empty),
		.RX_fifo_full(RX_fifo_full),
		.en_clock_strech(en_clock_strech),
		.RX_fifo_almost_full(RX_fifo_almost_full),
		.byte_received(byte_received),
		.ack_prep(ack_prep),
		.ack_check(ack_check),
		.ack_done(ack_done),
		.rx_enable(rx_enable),
		.SCL_out_slave(SCL_out_slave),
		.busy_slave(busy_slave),
		.TX_read_enable_slave(TX_read_enable_slave),
		.RX_write_enable_slave(RX_write_enable_slave),
		.ack_error_set_slave(ack_error_set_slave),
		.sda_mode(sda_mode),
		.load_data(load_data),
		.tx_enable(tx_enable),
		.rw_store(rw_store)
	);

	//-----------------------------------PTS_SR_TX
	pts_sr_tx PTS_SR_TX
	(
		.clk(clk),
		.n_rst(n_rst),
		.falling_edge(falling_edge),
		.tx_enable(tx_enable),
		.load_data(load_data),
		.tx_data(tx_data),
		.tx_out(tx_out)
	);
	//-----------------------------------SDA Selector
	sda_select SDA_SECLECT
	(
		.sda_mode(sda_mode),
		.tx_out(tx_out),
		.SDA_out_slave(SDA_out_slave)
	);
	
	
endmodule 
