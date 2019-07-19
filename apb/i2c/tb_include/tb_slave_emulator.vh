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

AddressMode tb_slave_address_mode;	//Look for 7 or 10 bit address
logic tb_slave_enabled;			//Will the slave respond
logic [7:0] tb_slave_buffer [63:0];	//Data to send/data received
integer tb_slave_nack_byte;		//If not -1, send a nack at this byte
integer tb_slave_stretch;		//How many cycles the slave should strech the clock before the ack/nack
integer tb_slave_bit;

task slave_reset();
	tb_slave_enabled=0;
	tb_slave_address_mode = ADDR_7_BIT;
	tb_slave_nack_byte=-1;
	tb_slave_stretch=0;
	slave_SDA=1;
	slave_SCL=1;
endtask

task slave_check_received(input integer size);
	integer i;
	for(i=0;i<size;i++) begin
		assert(tb_slave_buffer[i]==tb_expected_data[i]) else
			$error("Emulated slave on byte %d received %d, expected %d",i,tb_slave_buffer[i],tb_expected_data[i]);
	end
endtask


task slave_get_byte(input logic should_ack, output logic[7:0] data);
	integer i;
	for(i=7;i>=0;i--) begin
		@(posedge SCL);
		data[i]=SDA;
	end
	@(negedge SCL);
	slave_SDA= !should_ack;
	@(negedge SCL);
	slave_SDA=1;
endtask

task slave_send_byte(input logic[7:0] data, output logic ack_found);
	integer i;
	tb_slave_bit=0;
	for(i=7; i>=0; i--) begin
		tb_slave_bit++;
		slave_SDA = data[i];
		@(posedge SCL);
		@(negedge SCL);
	end
	slave_SDA=1;
	@(posedge SCL);
	ack_found=!SDA;
	@(negedge SCL);	
	tb_slave_bit++;
endtask

task slave_wait_for_stop();
	logic stop_found;
	stop_found=0;
	while(!stop_found) begin
		@(posedge SDA);
		#(5ns);
		stop_found=SCL;
	end
endtask

task slave_get_address(output DataDirection dir);
	logic [7:0] data;
	slave_get_byte(1,data);
	dir = data[0] ? RX : TX;
	if(tb_slave_address_mode==ADDR_10_BIT)
		slave_get_byte(1,data);
endtask

task slave_do_stuff();
	DataDirection dir;
	slave_get_address(dir);
	if(dir==RX)
		slave_send_data();
	else
		slave_get_data();
endtask

task slave_send_data();
	integer pointer;
	logic ack_found;
	pointer=0;
	ack_found=1;
	while(ack_found) begin
		slave_send_byte(tb_slave_buffer[pointer++], ack_found);
	end
endtask

task slave_stretch();
	integer i;
	@(negedge SCL);	//First falling edge
	while(1) begin
		for(i=0;i<8;i++) begin
			@(negedge SCL);
		end
		slave_SCL=0;
		delay(tb_slave_stretch);
		slave_SCL=1;
		@(negedge SCL);
	end
endtask

task slave_get_data();
	integer pointer;
	pointer=0;
	while(pointer != tb_slave_nack_byte) begin
		slave_get_byte(1,tb_slave_buffer[pointer++]);
	end
	slave_get_byte(0,tb_slave_buffer[pointer++]);
endtask

task slave_begin();
	fork
		slave_wait_for_stop();	//End if stop condition found
		slave_do_stuff();	//End if nack recieved
		slave_stretch();	//Go forever
	join_any
	disable fork;
	slave_SDA=1;
	slave_SCL=1;
endtask


//Hardware helpers

always @(negedge SDA) begin
	if(SCL&& tb_slave_enabled)
		slave_begin();
end
