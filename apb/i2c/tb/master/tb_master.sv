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
`include "i2c_if.vh"

module tb_master();

//Parameters
//=====================================================================
localparam CLOCK_PERIOD = 15ns;
localparam STANDARD_MODE = 300;
localparam FAST_MODE = 90;
localparam FAST_MODE_PLUS = 60;

//Create local signals
//=====================================================================
i2c_internal_bus bus();
//inputs to DUT
logic		clk;
logic 		n_rst;
AddressMode	address_mode;
DataDirection	data_direction;
MasterSlave	ms_select;
logic [5:0]	packet_size;
logic		en_clock_stretch;
logic		TX_fifo_empty;
logic		RX_fifo_full;
logic		RX_fifo_almost_full;
logic		transaction_begin;
logic		SDA_sync;
logic		SCL_sync;
logic [31:0]	clk_divider;
logic [9:0]	bus_address;
logic		set_transaction_complete_master;
logic		SCL_out_master;
logic		SDA_out_master;
logic[7:0]	rx_data_master;
logic		TX_read_enable_master;
logic 		transaction_begin_clear;
logic		RX_write_enable_master;
logic		ack_error;

//Emulated hardware
//=====================================================================
`include "tb_master.vh" 

//Connect local signals
//=====================================================================
//assign bus.tx_data = 		tx_data;
//assign bus.address_mode =	address_mode;
//assign bus.data_direction =	data_direction;
//assign bus.ms_select = 		ms_select;
//assign bus.packet_size = 	packet_size;
//assign bus.en_clock_strech = 	en_clock_stretch;
//assign bus.TX_fifo_empty = 	TX_fifo_empty;
//assign bus.RX_fifo_full = 	RX_fifo_full;
//assign bus.RX_fifo_almost_full=	RX_fifo_almost_full;
//assign bus.transaction_begin =	transaction_begin;
//assign bus.SDA_sync =		SDA_sync;
//assign bus.SCL_sync = 		SCL_sync;
//assign bus.clk_divider = 	clk_divider;
//assign bus.bus_address =	bus_address;

assign rx_data = 		rx_data_master;

//Bus signals and emulation
assign DUT_SDA = SDA_out_master;
assign DUT_SCL = SCL_out_master;
sync_high SDA_SYNC(clk, n_rst, SDA, SDA_sync);
sync_high SCL_SYNC(clk, n_rst, SCL, SCL_sync);


//Tasks
//=====================================================================
task initialize();
	n_rst=0;
	address_mode = ADDR_7_BIT;
	data_direction = TX;
	ms_select = MASTER;
	en_clock_stretch=1;
	TX_fifo_empty=0;
	RX_fifo_full=0;
	RX_fifo_almost_full=0;
	transaction_begin=0;
	ack_error=0;
	nack_byte=-1;

	slave_reset();
	master_reset();
	fifo_reset();


	@(negedge clk);
	@(negedge clk);
	n_rst=1;
	@(negedge clk);
endtask

//Drive clock
//=====================================================================
always begin
	clk=0;
	#(CLOCK_PERIOD/2.0);
	clk=1;
	#(CLOCK_PERIOD/2.0);
end

//master DUT(
//	clk,
//	n_rst,
//	bus.Master
//);

master_wrapper DUT(
	clk,
	n_rst,
	tx_data,
	address_mode,
	data_direction,
	ms_select,
	bus_address,
	packet_size,
	en_clock_stretch,
	TX_fifo_empty,
	RX_fifo_full,
	RX_fifo_almost_full,
	transaction_begin,
	SDA_sync,
	SCL_sync,
	clk_divider,
	rx_data_master,
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

//Helper hardware
//=====================================================================
logic transaction_complete;
always @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		transaction_complete<=0;
	else if(set_transaction_complete_master)
		transaction_complete <=1;
end

always @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		ack_error<=0;
	else if(ack_error_set_master)
		ack_error <=1;
end

//Test tasks
//=====================================================================
task checkAddress(input logic[9:0] address, AddressMode mode, DataDirection dir);
	logic dirbit;
	dirbit = dir==RX?1'b1:1'b0;
	if(mode == ADDR_7_BIT)
		assert(slave_rx_fifo[0]=={address[6:0],dirbit}) else
			$error("7 bit address mode wrong address sent!");
	else begin
		assert(slave_rx_fifo[0]=={5'b11110,address[9:8],dirbit}) else
			$error("10 bit address mode wrong first byte sent!");
		assert(slave_rx_fifo[1]==address[7:0]) else
			$error("10 bit address mode wrong second byte sent!");
	end
endtask

task checkReceivedData(input integer size);
	integer i;
	for(i=0; i<size; i++) begin
		assert(rx_fifo[i] == slave_tx_fifo[i+2]) else
			$error("Error during receiving, expected %d, got %d on byte %d",tx_fifo[i+2],rx_fifo[i], i);
	end
endtask

task checkSentData(input integer size, AddressMode mode);
	integer i, j, addr_offset;
	if(nack_byte!=-1)
		size=nack_byte;
	if(mode == ADDR_7_BIT)
		addr_offset=1;
	else
		addr_offset=2;
	for(i=0; i<size; i++) begin
		j = i+addr_offset;
		assert(tx_fifo[i] == slave_rx_fifo[j]) else
			$error("Bad transmision, slave expected %d but received %d!",tx_fifo[i],slave_rx_fifo[j]);
	end
endtask

task sendData(
	input integer speed,
	integer size,
	logic[9:0] address,
	AddressMode mode,
	integer stretch,	//set to zero for slave to not stretch
	integer nack=-1	//If not -1, the nth byte of the transmission will be a nack, (including address bytes)
);
	integer i;
	integer j;
	integer addr_offset;

	initialize();
	data_direction=TX;
	bus_address = address;
	clk_divider=speed;
	address_mode = mode;
	slave_address_mode = mode==ADDR_10_BIT;
	packet_size=size;
	slave_stretch=stretch;
	nack_byte=nack;
	
	@(negedge clk);
	@(negedge clk);

	transaction_begin=1;
	@(posedge transaction_complete);
	@(negedge clk);
	@(negedge clk);

	checkSentData(size,mode);
	checkAddress(address, mode,TX);
	if(nack!=-1) begin
		assert(ack_error) else
			$error("ack error not asserted when expected!");
	end
	else begin
		assert(!ack_error) else
			$error("ack error asserted when not expected!");
	end
endtask

task getData(
	input integer speed,
	integer size,
	logic[9:0] address,
	AddressMode mode,
	integer stretch	//set to zero for slave to not stretch
);
	integer i;
	initialize();
	data_direction=RX;
	bus_address = address;
	clk_divider=speed;
	address_mode = mode;
	slave_address_mode = mode==ADDR_10_BIT;
	packet_size=size;
	slave_stretch=stretch;
	
	@(negedge clk);
	@(negedge clk);

	transaction_begin=1;
	@(posedge transaction_complete);
	@(negedge clk);
	@(negedge clk);
	
	checkReceivedData(size);
	checkAddress(address,mode,RX);
endtask

task getRepeatedStart(
	input integer speed,
	integer size1,
	integer size2,
	logic[9:0] address,
	AddressMode mode
);
	integer i;
	initialize();
	data_direction=RX;
	bus_address=address;
	clk_divider = speed;
	address_mode=mode;
	slave_address_mode = mode==ADDR_10_BIT;
	packet_size=size1;
	@(negedge clk);
	@(negedge clk);
	transaction_begin=1;
	@(negedge clk);
	@(negedge clk);
	@(negedge clk);
	@(negedge clk);
	packet_size=size2;
	transaction_begin=1;
	@(posedge transaction_complete);

	checkReceivedData(size1);
	checkAddress(address,mode,RX);

	slave_reset();
	@(negedge slave_active);

	checkReceivedData(size2);
	checkAddress(address,mode,RX);
endtask

task sendCompetingMaster(
	input integer module_speed,
		integer other_speed,
		integer size,
		logic[9:0] address,
		AddressMode mode,
		integer stretch
);

	initialize();
	data_direction=TX;
	bus_address = address;
	clk_divider=module_speed;
	address_mode = mode;
	slave_address_mode = mode==ADDR_10_BIT;
	packet_size=size;
	slave_stretch=stretch;
	nack_byte=-1;

	@(negedge clk);
	@(negedge clk);
	transaction_begin=1;
	@(posedge line_busy);
	fork
		begin
			master_send_data(other_speed, size);
			$error("Abort not asserted in time!");
		end
		@(posedge set_arbitration_lost);
	join_any
	disable fork;
	slave_reset();
	master_reset();
endtask


initial begin
	integer i;

	//Send some data
	tx_fifo[3:0] = {8'b11110000, 8'b10101010, 8'b11010011, 8'b00001111};
	sendData(300, 4, 10'b0001100110, ADDR_7_BIT,2000);
	sendData(20, 4, 10'b0011001100, ADDR_10_BIT,2000);
	for(i=0;i<64;i++)
		tx_fifo[i] = 5*i;
	sendData(10,0,10'd1001, ADDR_10_BIT, 0);
	sendData(10,4,10'd10,ADDR_7_BIT,0,3);

	//Receive some data
	slave_tx_fifo[5:2] = {8'b11001100, 8'b10100101, 8'b11111111 ,8'b00110000};
	getData(300, 4, 10'b0001111000, ADDR_7_BIT,0);
	slave_tx_fifo[6:2] = {8'd200, 8'd60, 8'd127, 8'd10, 8'd135};
	getData(10,5, 10'b1010101011, ADDR_10_BIT, 100);

	//Send repeated start
	slave_tx_fifo[5:2] = {8'b00110011, 8'b11111111, 8'b00000000, 8'b10101010};
	getRepeatedStart(50, 4, 2, 10'b1100110011, ADDR_10_BIT);

	//Try competing masters
	master_tx_fifo[3:0] = {8'b00000000, 8'b10101010, 8'b11110000, 8'b11111111};
	sendCompetingMaster(10,200,4,10'b0011001100, ADDR_7_BIT, 500);

	$info("Testbench complete!");
end
endmodule
