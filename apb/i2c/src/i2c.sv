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
`include "i2c_if.vh"

module i2c (
	input clk, n_rst,
	apb_if.apb_s apb_bus,
	i2c_if.i2c i2c
);
	//Create internal bus and connect to external bus
	//====================================================================
	i2c_internal_bus bus();
	sync_high SDA_SYNC(clk,n_rst,i2c.SDA,bus.SDA_sync);
	sync_high SCL_SYNC(clk,n_rst,i2c.SCL,bus.SCL_sync);

	//Instantiate 3 main components of i2c
	//====================================================================
	register REGISTER (
		.clk(clk),
		.n_rst(n_rst),
		.interrupt(i2c.interrupt),
		.i2c_bus(bus.Register),
		.apb_bus(apb_bus)
	);
	slave SLAVE (
		.clk(clk),
		.n_rst(n_rst),
		.bus(bus.Slave)
	);
	master MASTER (
		.clk(clk),
		.n_rst(n_rst),
		.bus(bus.Master)
	);
	//Register the I2C bus output to prevent fun metastable states and extra edge from being transmitted
	//=================================================================================================
	logic SDA_out_next, SCL_out_next;
	always @(posedge clk, negedge n_rst) begin
		if(!n_rst) begin
			i2c.SDA_out=1;
			i2c.SCL_out=1;
		end else begin
			i2c.SDA_out = SDA_out_next;
			i2c.SCL_out = SCL_out_next;
		end
	end

	//Giant mux to determine who controls the status flags in the register block
	//====================================================================
	always_comb begin
		if(bus.ms_select == 0) begin
			bus.rx_data = 		bus.rx_data_master;
			bus.set_transaction_complete = 	bus.set_transaction_complete_master;
			bus.ack_error_set =	bus.ack_error_set_master;
			bus.busy = 		bus.busy_master;
			bus.TX_read_enable = 	bus.TX_read_enable_master;
			bus.RX_write_enable = 	bus.RX_write_enable_master;
			SDA_out_next = 		bus.SDA_out_master;
			SCL_out_next = 		bus.SCL_out_master;
		end
		else begin
			bus.rx_data = 		bus.rx_data_slave;
			bus.set_transaction_complete = 	bus.set_transaction_complete_slave;
			bus.ack_error_set =	bus.ack_error_set_slave;
			bus.busy = 		bus.busy_slave;
			bus.TX_read_enable = 	bus.TX_read_enable_slave;
			bus.RX_write_enable = 	bus.RX_write_enable_slave;
			SDA_out_next = 		bus.SDA_out_slave;
			SCL_out_next = 		bus.SCL_out_slave;
		end
	end
endmodule
