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

`include "apb_if.vh"
`include "i2c.vh"

module register(
	input clk, n_rst,
	output interrupt,
	i2c_internal_bus.Register i2c_bus,
	apb_if.apb_s apb_bus
);
	apbSlave IX (
		.pclk(clk),
		.n_rst(n_rst),
		.pdata(apb_bus.PWDATA),
		.paddr(apb_bus.PADDR),
		.penable(apb_bus.PENABLE),
		.psel(apb_bus.PSEL),
		.pwrite(apb_bus.PWRITE),
		.rx_data(i2c_bus.rx_data),
		.rx_w_ena(i2c_bus.RX_write_enable),
		.i2c_status({i2c_bus.transaction_begin_clear, i2c_bus.busy, i2c_bus.set_arbitration_lost, i2c_bus.set_transaction_complete, i2c_bus.line_busy, i2c_bus.ack_error_set}),
		.scl(clk),
		.tx_r_ena(i2c_bus.TX_read_enable),
		.prdata(apb_bus.PRDATA),
		.i2c_interrupt(interrupt),
		.tx_data(i2c_bus.tx_data),
		.rx_full(i2c_bus.RX_fifo_full),
		.rx_almost_full(i2c_bus.RX_fifo_almost_full),
		.control({i2c_bus.en_clock_strech, i2c_bus.transaction_begin, i2c_bus.data_direction, i2c_bus.packet_size, i2c_bus.ms_select, i2c_bus.address_mode}),
		.address(i2c_bus.bus_address),
		.clk_out(i2c_bus.clk_divider),
		.tx_empty(i2c_bus.TX_fifo_empty)
	);
	
endmodule
