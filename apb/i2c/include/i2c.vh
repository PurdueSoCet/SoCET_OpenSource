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

`ifndef __i2c_include
`define __i2c_include

//Enumerators to prevent having to remember and look up arbitrary constants
//Simple boolean flags do not need an enumerator type

//package i2c_pkg;
typedef enum logic {
	ADDR_7_BIT,
	ADDR_10_BIT
} AddressMode;

typedef enum logic [1:0]{
	BUS_SPEED_STANDARD,		//100kHz
	BUS_SPEED_FAST,			//400kHz
	BUS_SPEED_FAST_PLUS		//1MHz
} BusSpeed;

typedef enum logic{
	RX,
	TX
} DataDirection;

typedef enum logic{
	MASTER=0,
	SLAVE=1
} MasterSlave;

//endpackage

//import i2c_pkg::*;

interface i2c_internal_bus;
	//Data signals from regsiter to i2c
	//====================================================================
	logic [7:0]	tx_data;		//data from TX_FIFO

	//Data signals from i2c to registers
	//====================================================================
	logic [7:0]	rx_data_slave;		//data to store in RX_FIFO
	logic [7:0]	rx_data_master;
	logic [7:0]	rx_data;

	//Control signals from Register to i2c
	//====================================================================
	AddressMode 	address_mode;		//7_BIT or 10_BIT addresses
	//BusSpeed	bus_speed;		//How fast to clock the i2c bus
	DataDirection	data_direction;		//Transmitting or Receiving
	MasterSlave	ms_select;		//which i2c component is active
	logic [9:0]	bus_address;		//Bus address 
	logic [5:0]	packet_size;		//How many bytes to send
	logic		en_clock_strech;	//is clock streching enabled?
	logic		TX_fifo_empty;		//No more data to send
	logic		RX_fifo_full;		//No more room for new data
	logic		RX_fifo_almost_full;	//Can only hold one more byte
	logic		transaction_begin;	//Tell master to start bus transaction
	logic [31:0]    clk_divider;            //Set value of bus clock divider

	//Status signals from i2c to register
	//====================================================================
	logic		ack_error_set_slave;
	logic		ack_error_set_master;
	logic		ack_error_set;
	logic		transaction_begin_clear;//Clear the transaction begin flag
	logic		busy_slave;		//Is the slave busy?
	logic		busy_master;		//Is the master busy?
	logic		busy;
	logic		TX_read_enable_slave;	//Read a byte from the TX fifo
	logic		TX_read_enable_master;
	logic		TX_read_enable;
	logic		RX_write_enable_slave;	//Read a byte from the RX fifo
	logic		RX_write_enable_master;
	logic		RX_write_enable;
	logic		line_busy;		//I2C bus is busy
	logic		set_transaction_complete;	//Transaction complete
	logic		set_transaction_complete_slave;
	logic		set_transaction_complete_master;
	logic		set_arbitration_lost;	//Master lost bus arbitration

	//I2C bus signals
	//====================================================================
	logic 		SDA_sync;		//Synchorinzed SDA input
	logic		SCL_sync;		//Synchronized SCL input
	logic		SDA_out_slave;		//Driving SDA line
	logic		SDA_out_master;
	logic		SCL_out_slave;		//Driving SDA line
	logic		SCL_out_master;

	//Connections to register block
	//====================================================================
	modport Register(
		input 	rx_data,
                        ack_error_set,
                        transaction_begin_clear,
                        busy,
                        TX_read_enable,
                        RX_write_enable,
			line_busy,
			set_arbitration_lost,
			set_transaction_complete,
		output	tx_data,
			address_mode,
                        //bus_speed,
                        data_direction,
                        ms_select,
                        bus_address,
                        packet_size,
                        en_clock_strech,
                        TX_fifo_empty,
                        RX_fifo_full,
                        transaction_begin,
			clk_divider,
			RX_fifo_almost_full
	);

	//Connections to I2C Slave
	//====================================================================
	modport Slave(
		input	tx_data,
			address_mode,
                        ms_select,
                        bus_address,
                        en_clock_strech,
                        TX_fifo_empty,
                        RX_fifo_full,
			RX_fifo_almost_full,
			SDA_sync,
			SCL_sync,
		output 	rx_data_slave,
			set_transaction_complete_slave,
                        ack_error_set_slave,
                        busy_slave,
                        TX_read_enable_slave,
                        RX_write_enable_slave,
			SDA_out_slave,
			SCL_out_slave
	);

	//Connections to I2C Master
	//====================================================================
	modport Master(
		input	tx_data,
			address_mode,
                        //bus_speed,
                        data_direction,
                        ms_select,
                        bus_address,
                        packet_size,
                        en_clock_strech,
                        TX_fifo_empty,
                        RX_fifo_full,
			RX_fifo_almost_full,
                        transaction_begin,
			SDA_sync,
			SCL_sync,
			clk_divider,
		output 	rx_data_master,
			set_transaction_complete_master,
			set_arbitration_lost,
                        ack_error_set_master,
                        transaction_begin_clear,
                        busy_master,
                        TX_read_enable_master,
                        RX_write_enable_master,
			SDA_out_master,
			SCL_out_master,
			line_busy
	);


endinterface


`endif //__i2c_include
