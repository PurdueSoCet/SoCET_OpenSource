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
module master(
	input clk, n_rst,
	i2c_internal_bus.Master bus
);

//Local signals
//=====================================================================

//Signals to connect different components
logic abort;
logic ack_bit;
logic ack_gen;
logic bus_busy;
logic byte_complete;
logic decrement_byte_counter;
logic load_buffers;
logic output_wait_expired;
logic one;
logic shift_load;
logic shift_strobe;
logic should_nack;
logic timer_active;
logic zero;

DataDirection shift_direction;
DriveSelectType output_select;
ShiftSelectType shift_input_select;

//I2c bus signals
logic SDA_sync;
logic SCL_sync;
logic SDA_out;
logic SCL_out;
assign SDA_sync = bus.SDA_sync;
assign SCL_sync = bus.SCL_sync;

//I2C bus signals pre-mux
logic SDA_out_shift_register;
logic SDA_out_start_stop_gen;
logic SCL_out_timer;
logic SCL_out_start_stop_gen;

//Buffered values
logic [9:0] bus_address;
logic [31:0] clock_div;
logic clock_stretch_enabled;
DataDirection data_direction;
AddressMode address_mode;


//Simple logic
assign should_nack = (!bus.en_clock_strech && bus.RX_fifo_almost_full) || zero;
assign bus.line_busy = bus_busy;
assign bus.SDA_out_master = SDA_out;
assign bus.SCL_out_master = SCL_out;

//Controller
//=====================================================================
master_controller MASTER_CONTROLLER(
	//Input
	.clk(clk),
	.n_rst(n_rst),
	.address_mode(address_mode),
	.ms_select(bus.ms_select),
	.bus_busy(bus_busy),
	.begin_transaction_flag(bus.transaction_begin),
	.ack_bit(ack_bit),
	.data_direction(data_direction),
	.output_wait_expired(output_wait_expired),
	.byte_complete(byte_complete),
	.zero_bytes_left(zero),
	.abort(abort),
	.stretch_enabled(clock_stretch_enabled),
	.rx_fifo_full(bus.RX_fifo_full),
	.tx_fifo_empty(bus.TX_fifo_empty),

	//Outputs
	.shift_input_select(shift_input_select),
	.output_select(output_select),
	.shift_direction(shift_direction),
	.shift_load(shift_load),
	.timer_active(timer_active),
	.load_buffers(load_buffers),
	.decrement_byte_counter(decrement_byte_counter),
	.set_ack_error(bus.ack_error_set_master),
	.set_arbitration_lost(bus.set_arbitration_lost),
	.clear_transaction_begin(bus.transaction_begin_clear),
	.start(start),
	.stop(stop),
	.tx_fifo_enable(bus.TX_read_enable_master),
	.rx_fifo_enable(bus.RX_write_enable_master),
	.busy(bus.busy_master),
	.set_transaction_complete(bus.set_transaction_complete_master)
);

//Timer
//=====================================================================
master_timer TIMER(
	//Input
	.clk(clk),
	.n_rst(n_rst),
	.timer_active(timer_active),
	.direction(shift_direction),
	.should_nack(should_nack),
	.SDA_sync(SDA_sync),
	.SCL_sync(SCL_sync),
	.SDA_out(SDA_out_shift_register),
	.clock_div(clock_div),

	//Output
	.SCL_out(SCL_out_timer),
	.shift_strobe(shift_strobe),
	.byte_complete(byte_complete),
	.ack_gen(ack_gen),
	.ack(ack_bit),
	.abort(abort)
);

//Control Buffer
//=====================================================================
control_buffer CONTROL_BUFFER(
	//input
	.clk(clk),
	.n_rst(n_rst),
	.u_bus_address(bus.bus_address),
	.u_data_direction(bus.data_direction),
	.u_address_mode(bus.address_mode),
	.u_clock_div(bus.clk_divider),
	.u_stretch_enabled(bus.en_clock_strech),
	.load_buffer(load_buffers),

	//output
	.bus_address(bus_address),
	.data_direction(data_direction),
	.address_mode(address_mode),
	.stretch_enabled(clock_stretch_enabled),
	.clock_div(clock_div)
);

//Shift Register
//=====================================================================
shift_register SHIFT_REGISTER(
	//input
	.clk(clk),
	.n_rst(n_rst),
	.bus_address(bus_address),
	.tx_data(bus.tx_data),
	.shift_input_select(shift_input_select),
	.data_direction(data_direction),
	.shift_direction(shift_direction),
	.shift_in(SDA_sync),
	.shift_load(shift_load),
	.shift_strobe(shift_strobe),
	
	//output
	.shift_out(SDA_out_shift_register),
	.data_out(bus.rx_data_master)
);

//Start and Stop Condition Generator
//=====================================================================
start_stop_gen START_STOP_GEN(
	//input
	.clk(clk),
	.n_rst(n_rst),
	.start(start),
	.stop(stop),
	.clock_div(clock_div),
	.bus_busy(bus_busy),
	.done(output_wait_expired),

	//output
	.SDA(SDA_out_start_stop_gen),
	.SCL(SCL_out_start_stop_gen)
);	

//Output MUX
//=====================================================================
output_mux OUTPUT_MUX(
	//input
	.drive_select(output_select),
	.tx_SDA(SDA_out_shift_register),
	.tx_SCL(SCL_out_timer),
	.rx_SDA(!ack_gen),
	.rx_SCL(SCL_out_timer),
	.start_stop_SDA(SDA_out_start_stop_gen),
	.start_stop_SCL(SCL_out_start_stop_gen),

	//output
	.SDA_out(SDA_out),
	.SCL_out(SCL_out)
);

//Busy tester
//=====================================================================
busy_tester BUSY_TESTER(
	//input
	.clk(clk),
	.n_rst(n_rst),
	.SDA_sync(SDA_sync),
	.SCL_sync(SCL_sync),

	//output
	.bus_busy(bus_busy)
);

//Byte Counter
//=====================================================================
byte_counter BYTE_COUNTER(
	//input
	.clk(clk),
	.n_rst(n_rst),
	.decrement(decrement_byte_counter),
	.load_buffer(load_buffers),
	.packet_length(bus.packet_size[5:0]),

	//output
	.zero(zero),
	.one(one)
	
);

endmodule
