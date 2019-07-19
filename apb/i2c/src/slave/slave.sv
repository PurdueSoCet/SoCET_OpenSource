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
module slave(
	input clk, n_rst,
	i2c_internal_bus.Slave bus
);
	slave_inner SLAVE_INNER
	(
		.clk(clk),
		.n_rst(n_rst),
		.tx_data(bus.tx_data),
		.address_mode(bus.address_mode),
		.ms_select(bus.ms_select),
		.bus_address(bus.bus_address),
		.en_clock_strech(bus.en_clock_strech),
		.TX_fifo_empty(bus.TX_fifo_empty),
		.RX_fifo_full(bus.RX_fifo_full),
		.RX_fifo_almost_full(bus.RX_fifo_almost_full),
		.SDA_sync(bus.SDA_sync),
		.SCL_sync(bus.SCL_sync),
		.rx_data_slave(bus.rx_data_slave),
		.set_transaction_complete_slave(bus.set_transaction_complete_slave),
		.ack_error_set_slave(bus.ack_error_set_slave),
		.busy_slave(bus.busy_slave),
		.TX_read_enable_slave(bus.TX_read_enable_slave),
		.RX_write_enable_slave(bus.RX_write_enable_slave),
		.SDA_out_slave(bus.SDA_out_slave),
		.SCL_out_slave(bus.SCL_out_slave)
	);

	
endmodule
