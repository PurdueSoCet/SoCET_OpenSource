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

`timescale 1ns/100ps
//`include "i2c.vh"

module tb_top_level_master();
logic tb_interrupt;
logic [31:0]tb_expected_PRDATA;

`include "tb_bus_emulator.vh"	
`include "tb_slave_emulator.vh"
`include "tb_master_emulator.vh"
`include "tb_apb_emulator.vh"


i2c_wrapper DUT(
	tb_clk,
	tb_n_rst,
	SDA,
	SCL,
	PWRITE,
	PENABLE,
	PSEL,
	PWDATA,
	PADDR,
	PRDATA,
	dut_SDA,
	dut_SCL,
	tb_interrupt
);


logic [31:0] tb_flags;
string tb_test;

task reset();
	slave_reset();
	APB_reset();
	master_reset();
	tb_n_rst=0;
	delay(2);
	tb_n_rst=1;
	tb_slave_enabled=1;
endtask

//Set the appropriate bytes of tb_slave_buffer before doing this task
task receive_data_test(input integer clk_period, integer size, AddressMode mode, logic [9:0] addr, integer slave_stretch_cycles);
	integer bytes_sent;
	integer i;
	logic [31:0] data;
	tb_slave_address_mode = mode;
	tb_slave_stretch = slave_stretch_cycles;

	APB_write_div(clk_period);
	APB_write_addr(addr);
	APB_write_control(
		1,1,0,size,0,mode
	);

	@(posedge tb_interrupt);
	APB_read_status(data);
	assert(data == 11'b10000000100 || data==1330) else
		$error("Incorrect status, got %d, expected %d",data,11'b10000000100);
	if(data==1330) begin
		@(posedge tb_interrupt);
		APB_read_status(data);
		assert(data==260) else
			$error("Incorrect status, got %d, expected 260",data);
		
	end
	for(i=0;i<size;i++) begin
		APB_read_rx(data);
		assert(data == tb_slave_buffer[i]) else
			$error("{size: %d, period: %d, mode:%d, slave_stretch:%d, addr:%d}Incorrect data in receiving byte %d: expected %d, got %d.",size,clk_period,mode,slave_stretch_cycles,addr,i,tb_slave_buffer[i],data);
	end
endtask

//Set the appropriate byte of tb_expected_data before doing this task
task send_data_test(input integer clk, integer size, AddressMode mode, logic[9:0] addr, integer slave_stretch_cycles);
	integer i;
	logic [31:0] data;
	tb_slave_address_mode = mode;
	tb_slave_stretch = slave_stretch_cycles;

	for(i=0;i<size;i++)
		APB_write_tx(tb_expected_data[i]);
	APB_write_div(clk);
	APB_write_addr(addr);
	APB_write_control(
		1,1,1,size,0,mode
	);
	@(posedge tb_interrupt);
	APB_read_status(data);
	assert(data == 1234) else
		$error("Problem with status, expected 1234, got %d",data);

	@(posedge tb_interrupt);
	APB_read_status(data);
	assert(data==1156) else
		$error("Problem with status, expected 1156, %d",data);
	
endtask

task test1();
integer size, slave_stretch, clk, data, addr, i;
tb_test = "Test 1";
data=0;
addr=1;
for(size=1; size<=4;size=size*2) begin
for(slave_stretch=0;slave_stretch<=1000;slave_stretch+=500) begin
for(clk=25;clk<=200;clk=clk*2) begin
	for(i=0;i<size;i++) begin
		data+=43;
		tb_slave_buffer[i] = data;
	end
	addr+=43;
	receive_data_test(clk, size, ADDR_7_BIT, addr, slave_stretch);
end end end
endtask

task test2();
integer size, slave_stretch, clk, data, addr, i;
tb_test = "Test 2";
data=0;
addr=1;
for(size=1; size<=4;size=size*2) begin
for(slave_stretch=0;slave_stretch<=1000;slave_stretch+=500) begin
for(clk=25;clk<=200;clk=clk*2) begin
	for(i=0;i<size;i++) begin
		data+=43;
		tb_expected_data[i] = data;
	end
	addr+=43;
	send_data_test(clk, size, ADDR_7_BIT, addr, slave_stretch);
	for(i=0;i<size;i++) begin
		assert(tb_slave_buffer[i]==tb_expected_data[i]) else
			$error("Transmitoin byte %d, slave expected to receive %d but got %d",i, tb_expected_data[i], tb_slave_buffer[i]);
	end
end end end
endtask

task test3();
	logic [7:0] data;
	tb_test = "Test 3";
	tb_slave_address_mode = ADDR_7_BIT;
	tb_slave_stretch = 0;
	tb_master_buffer[0] = 8'b11011111;
	APB_write_tx(8'b11111000);
	APB_write_div(200);
	APB_write_addr(10'b0001100110);
	APB_write_control(
		1,1,1,1,0,ADDR_7_BIT
	);
	master_send(1,150,10'b0001100110,ADDR_7_BIT);
	APB_read_status(data);
	assert(data==204) else
		$error("Incorrect status flags, expected 204, got %d",data);
	APB_read_status(data);
	assert(data==128) else
		$error("Incorrect status flags, expected 128, got %d",data);
	assert(tb_slave_buffer[0]==tb_master_buffer[0]) else
		$error("multi master data corruption! Master sent %d, slave got %d!", tb_master_buffer[0], tb_slave_buffer[0]);
	
endtask

task test4();
	logic [31:0] data;
	tb_test = "Test 4";
	tb_slave_address_mode = ADDR_7_BIT;
	tb_slave_stretch = 0;
	tb_slave_nack_byte=0;
	APB_write_tx(100);
	APB_write_tx(200);
	APB_write_addr(10'b0001010011);
	APB_write_div(200);
	APB_write_control(
		1,1,1,2,0,ADDR_7_BIT
	);
	
	@(posedge tb_interrupt);
	APB_read_status(data);
	assert(data==1235) else
		$error("Incorrect status, expected 1235, got %d",data);

	@(posedge tb_interrupt);
	APB_read_status(data);
	assert(data==1156) else
		$error("Incorrect status, expected 1156, got %d",data);

	assert(tb_slave_buffer[0] == 100) else
		$error("Slave received incorrect data, expected 100, got %d",tb_slave_buffer[0]);
endtask

initial begin

	//Test 1 receive data from slave in (General usage)
	//	- 10 bit and 7 bit mode
	//	- with and without slave streching the clock
	//	- various speeds
	//	- various packet lengths
	reset();
	$info("Running test 1!");
	test1();
	$info("Test 1 complete!");

	//Test2 send data to slave (General usage)
	//	-10 bit and 7 bit
	//	with and without slave stretching the clock
	//	-various speeds
	//	-various packet lengths
	$info("Running test 2!");
	test2();
	$info("test 2 complete!");

	//Test3 run multiple masters at once, ensure arbitration fails and the slave gets the data (Corner case)
	$info("Running test 3!");
	test3();
	$info("test 3 complete!");


	//Test4, Try to transmit data as a master, and quit when a nack bit is received (Corner case)
	$info("Running test 4!");
	test4();
	$info("test 4 complete!");

	$info("Testbench complete!");
	
end
endmodule
